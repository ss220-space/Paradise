import glob
import re
import os
import sys
import time
from collections import namedtuple
from concurrent.futures import ProcessPoolExecutor

Failure = namedtuple("Failure", ["filename", "lineno", "message"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m" # No Color

def print_error(message: str, filename: str, line_number: int):
    if os.getenv("GITHUB_ACTIONS") == "true": # We're on github, output in a special format.
        print(f"::error file={filename},line={line_number},title=Check Grep::{filename}:{line_number}: {RED}{message}{NC}")
    else:
        print(f"{filename}:{line_number}: {RED}{message}{NC}")

IGNORE_515_PROC_MARKER_FILENAME = "__proc_refs.dm"
CHECK_515_PROC_MARKER_RE = re.compile(r"(\.proc\/)|(CALLBACK\((?!GLOBAL_PROC)[^,\(\)]+,[^,\(\)]+proc[^,\(\)]+[,\)])|((?<!#define\s)INVOKE_ASYNC\((?!GLOBAL_PROC)[^,\(\)]+,[^,\(\)]+proc[^,\(\)]+[,\)])")
def check_515_proc_syntax(idx, line):
    if CHECK_515_PROC_MARKER_RE.search(line):
        return [(idx + 1, "Outdated proc reference use detected in code. Please use proc reference helpers.")]

CHECK_516_HREF_STYLE = re.compile(r"href[\s='\"\\\\]*\?")
def check_516_href_style(idx, line):
    if CHECK_516_HREF_STYLE.search(line):
        return [(idx + 1, "BYOND requires internal href links to begin with \"byond://\"")]

CHECK_SPACE_INDENTATION_RE = re.compile(r"^( {2})|(^ [^ *])|(^ {4,})")
def check_space_indentation(idx, line):
    """
    Check specifically for space-significant indentation. Excludes dmdoc
    block comment lines so long as there is an asterisk immediately after the
    leading spaces.

    >>> bool(check_space_indentation(["  foo"]))
    True
    >>> bool(check_space_indentation(["  * foo"]))
    True
    >>> bool(check_space_indentation([" x"]))
    True
    >>> bool(check_space_indentation(["    foo"]))
    True
    >>> bool(check_space_indentation(["  "]))
    True

    >>> bool(check_space_indentation(["\\tfoo"]))
    False
    >>> bool(check_space_indentation([" * foo"]))
    False
    >>> bool(check_space_indentation(["   foo"]))
    False
    """
    if CHECK_SPACE_INDENTATION_RE.match(line):
        return [(idx + 1, "Space indentation detected, please use tab indentation.")]

CHECK_MIXED_INDENTATION_RE = re.compile(r"^(\t+ | +\t)\s*[^\s\*]")
def check_mixed_indentation(idx, line):
    """
    Check specifically for leading whitespace which contains a mix of tab and
    space characters. Excludes dmdoc block comment lines so long as there is an
    asterisk immediately after the leading whitespace.

    >>> bool(check_mixed_indentation(["\\t\\t foo"]))
    True
    >>> bool(check_mixed_indentation(["\\t \\t foo"]))
    True
    >>> bool(check_mixed_indentation(["\\t // foo"]))
    True
    >>> bool(check_mixed_indentation([" \\tfoo"]))
    True
    >>> bool(check_mixed_indentation(["  \\t  foo"]))
    True

    >>> bool(check_mixed_indentation(["\\t  * foo"]))
    False
    >>> bool(check_mixed_indentation(["\\t\\t* foo"]))
    False
    >>> bool(check_mixed_indentation(["\\t \\t  * foo"]))
    False
    """
    if CHECK_MIXED_INDENTATION_RE.match(line):
        return [(idx + 1, "Mixed <tab><space> indentation detected, please stick to tab indentation.")]

GLOBAL_VARS_RE = re.compile(r"^/*var/")
def check_global_vars(idx, line):
    if GLOBAL_VARS_RE.match(line):
        return [(idx + 1, "Unmanaged global var use detected in code, please use the helpers.")]

TOPLEVEL_VARDECLS_RE = re.compile(r"^(/[^\*(\/\/)].*/var/(list/)?\w+)")
def check_toplevel_vardecls(idx, line):
    if match := TOPLEVEL_VARDECLS_RE.match(line):
        return [(idx + 1, f"Top-level var {match.group(0)} found, please move to type declaration.")]

PROC_ARGS_WITH_VAR_PREFIX_RE = re.compile(r"^/[\w/]\S+\((var/)?.*(, ?var/.*).*\)")
def check_proc_args_with_var_prefix(idx, line):
    if PROC_ARGS_WITH_VAR_PREFIX_RE.match(line):
        return [(idx + 1, "Changed files contains a proc argument starting with 'var'.")]

NANOTRASEN_CAMEL_CASE_EN = re.compile(r"(NanoTrasen)")
NANOTRASEN_CAMEL_CASE_RU = re.compile(r"(НаноТрейзен)")
NANOTRASEN_MISSPELLING_N_RU = re.compile(r"(нанотрейзен)")

NANOTRASEN_QUOTES_RU = re.compile(r'(..)Нанотрейзен(..)')

def check_nanotrasen_style(idx, line):
    failures = []
    if match := NANOTRASEN_CAMEL_CASE_EN.search(line):
        failures.append((idx + 1, f"Found camel case '{match.group(1)}', should be 'Nanotrasen'."))
    if match := NANOTRASEN_CAMEL_CASE_RU.search(line):
        failures.append((idx + 1, f"Found camel case '{match.group(1)}', should be 'Нанотрейзен'."))
    if match := NANOTRASEN_MISSPELLING_N_RU.search(line):
        if 'UNLINT' not in line:
            failures.append((idx + 1, f"Found lowercase '{match.group(1)}', should be 'Нанотрейзен'."))

    for match in NANOTRASEN_QUOTES_RU.finditer(line):
        context_before = match.group(1)
        context_after = match.group(2)

        if context_before != '\\"' and context_after != '\\"':
            surrounding_text = context_before[1] + "Нанотрейзен" + context_after[0]
            failures.append((idx + 1, f"Found 'Нанотрейзен' without escaped quotes '{surrounding_text}', should be \\\"Нанотрейзен\\\"."))
            continue
        elif context_before[1] != '"' and context_after[0] != '"':
            surrounding_text = context_before[1] + "Нанотрейзен" + context_after[0]
            failures.append((idx + 1, f"Found 'Нанотрейзен' without escaped quotes '{surrounding_text}', should be \\\"Нанотрейзен\\\"."))
            continue
        else:
            continue

    return failures

TO_CHAT_WITH_NO_USER_ARG_RE = re.compile(r"to_chat\(\"")
def check_to_chats_have_a_user_arguement(idx, line):
    if TO_CHAT_WITH_NO_USER_ARG_RE.search(line):
        return [(idx + 1, "Changed files contains a to_chat() procedure without a user argument.")]

CONDITIONAL_LEADING_SPACE = re.compile(r"(if|for|while|switch)\s+(\(.*?\)?)") # checks for "if (thing)", replace with $1$2
CONDITIONAL_BEGINNING_SPACE = re.compile(r"(if|for|while|switch)\((!?) (.+\)?)") # checks for "if( thing)", replace with $1($2$3
CONDITIONAL_ENDING_SPACE = re.compile(r"(if|for|while|switch)(\(.+) \)") # checks for "if(thing )", replace with $1$2)
CONDITIONAL_DOUBLE_PARENTHESIS = re.compile(r"(if)\((\([^)]+\))\)$") # checks for if((thing)), replace with $1$2
# To fix any of these, run them as regex in VSCode, with the appropriate replacement
# It may be a good idea to turn the replacement into a script someday
def check_conditional_spacing(idx, line):
    failures = []
    if CONDITIONAL_LEADING_SPACE.search(line):
        failures.append((idx + 1, "Found a conditional statement matching the format \"if (thing)\" (irregular spacing), please use \"if(thing)\" instead."))
    if CONDITIONAL_BEGINNING_SPACE.search(line):
        failures.append((idx + 1, "Found a conditional statement matching the format \"if( thing)\" (irregular spacing), please use \"if(thing)\" instead."))
    if CONDITIONAL_ENDING_SPACE.search(line):
        failures.append((idx + 1, "Found a conditional statement matching the format \"if(thing )\" (irregular spacing), please use \"if(thing)\" instead."))
    if CONDITIONAL_DOUBLE_PARENTHESIS.search(line):
        failures.append((idx + 1, "Found a conditional statement matching the format \"if((thing))\" (unnecessary outer parentheses), please use \"if(thing)\" instead."))
    return failures

# makes sure that no global list inits have an empty list in them without using the helper
GLOBAL_LIST_EMPTY = re.compile(r"(?<!#define GLOBAL_LIST_EMPTY\(X\) )GLOBAL_LIST_INIT([^,]+),.{0,5}list\(\)")
# This uses a negative look behind to make sure its not the global list definition
# An easy regex replacement for this is GLOBAL_LIST_EMPTY$1
def check_global_list_empty(idx, line):
    if GLOBAL_LIST_EMPTY.search(line):
        return [(idx + 1, "Found a GLOBAL_LIST_INIT(_, list()), please use GLOBAL_LIST_EMPTY(_) instead.")]

# makes sure arguments contained within "ui = new" are valid
TGUI_UI_NEW = re.compile(r"ui = new\(((?:(?!,\s*).)+,\s*){1,3}(?:(?!,\s*).)+\)")
def check_tgui_ui_new_argument(idx, line):
    if "\tui = new" in line and not TGUI_UI_NEW.search(line):
        return [(idx + 1, "Invalid argument within constructor, please make sure window sizing is in corresponding TypeScript file.")]

# checks for any (for var/type/x) loops that are not looping over bare datums: enforcing that the only case we will see this is if you genuinely want to loop over all datums in memory
FOR_ALL_DATUMS = re.compile(r"for\s*\(\s*var\/((\w+)(?:(?:\/\w+){2,})?)\)")
# double-checks that we don't have any attempts at looping like for(var/atom/a)
FOR_ALL_NOT_DATUMS = re.compile(r"for\s*\(\s*var\/((?:atom|area|turf|obj|mob)(?:\/\w+))\)")
def check_datum_loops(idx, line):
    if FOR_ALL_DATUMS.search(line) or FOR_ALL_NOT_DATUMS.search(line):
        return [(
            idx + 1,
            # yes this will concatenate the strings, don't look too hard
            "Found a for loop without explicit contents. If you're trying to loop over everything in the world, first double check that you truly need to, and if so specify \'in world\'.\n"
            "If you're trying to check bare datums, please ensure that your value is only cast to /datum, and please make sure you use \'as anything\', or use a global list instead."
        )]

HREF_OLD_STYLE = re.compile(r"href[\s='\"\\]*\?")
def check_href_styles(idx, line):
    if HREF_OLD_STYLE.search(line):
        return [(idx + 1, "BYOND requires internal href links to begin with \"byond://\"")]

INITIALIZE_MISSING_MAPLOAD = re.compile(r"^/(obj|mob|turf|area|atom)/.+/Initialize\((?!mapload).*\)")
def check_initialize_missing_mapload(idx, line):
    if INITIALIZE_MISSING_MAPLOAD.search(line):
        return [(idx + 1, "Initialize override without 'mapload' argument.")]

# TODO: This finds most cases except for e.g. `list(1, 2, 3 )`
# Find a way to include this without breaking macro/tab-aligned versions such as `list(		\`
# Maybe even make sure it doesn't include comments, idk
EMPTY_LIST_WHITESPACE = re.compile(r"list\([^\S\n\r\f]+.*?[^\\]\n")
def check_empty_list_whitespace(idx, line):
    if EMPTY_LIST_WHITESPACE.search(line):
        return [(idx + 1, "Empty list declarations should not have any whitespace within their parentheses.")]

IGNORE_ATOM_ICON_FILE = "atoms.dm"
NO_MANUAL_ICON_UPDATES = re.compile(r"([\s.])(update_icon_state|update_desc|update_overlays|update_name)\(.*\)")
def check_manual_icon_updates(idx, line):
    if result := NO_MANUAL_ICON_UPDATES.search(line):
        proc_result = result.group(2)
        target = "update_icon"
        if(proc_result == "update_name" or proc_result == "update_desc"):
            target = "update_appearance"
        return [(idx + 1, f"{proc_result}() should not be called manually. Use {target}({proc_result.upper()}) instead.")]

CONDITIONAL_ISTYPE_SRC = re.compile(r"if.+istype\(src,\s?\/[^turf]")
def check_istype_src(idx, line):
    if CONDITIONAL_ISTYPE_SRC.search(line):
        return [(idx + 1, "Our coding requirements prohibit use of istype(src, /any_type). Consider making the behavior dependent on a variable and/or overriding a proc instead.")]

CAMEL_CASE_TYPE_NAMES = re.compile(r"^/[\w]\S+/{1}([a-zA-Z]+([A-Z][a-z]+)+|([A-Z]+[a-z]+))$")
def check_camel_case_type_names(idx, line):
    if result := CAMEL_CASE_TYPE_NAMES.search(line):
        return [(idx + 1, f"name of type {result.group(0)} is not in snake_case format.")]

UID_WITH_PARAMETER = re.compile(r"(\bUID\(\w+\))")
def check_uid_parameters(idx, line):
    if result := UID_WITH_PARAMETER.search(line):
        return [(idx + 1, f"UID() does not take arguments. Found: '{result.group(1)}'. Use UID() instead of UID(src) and datum.UID() instead of UID(datum).")]

BALLOON_ALERT_WITHOUT_USER = re.compile(r'(balloon_alert\(["\'])')
BALLOON_ALERT_TO_VIEWERS_WRONG_FIRST_ARG = re.compile(r'(balloon_alert_to_viewers\((?!\s*message\s*,)[^"\'])')
BALLOON_ALERT_WITH_SPAN = re.compile(r'(balloon_alert(_to_viewers)?\(.*?span_)')
BALLOON_ALERT_CAPITALIZED = re.compile(r'((balloon_alert\(.*?,|balloon_alert_to_viewers\()\s*["\'][A-ZА-Я])')
BALLOON_ALERT_ENDS_WITH_PERIOD = re.compile(r'((balloon_alert\(.*?,|balloon_alert_to_viewers\()\s*"[^"]*[^\.]\.(?!\.)")')
def check_balloon_alert(idx, line):
    failures = []
    if match := BALLOON_ALERT_WITHOUT_USER.search(line):
        failures.append((idx + 1, f"balloon_alert called with a string literal without a user argument: '{match.group(1)}'"))
    if match := BALLOON_ALERT_WITH_SPAN.search(line):
        failures.append((idx + 1, f"Balloon alerts should never contain spans: '{match.group(1)}'"))
    if match := BALLOON_ALERT_CAPITALIZED.search(line):
        if 'UNLINT' not in line:
            failures.append((idx + 1, f"Balloon alerts should not start with capital letters: '{match.group(1)}'. Includes text like 'AI'. Wrap the text in UNLINT() if needed."))
    if match := BALLOON_ALERT_ENDS_WITH_PERIOD.search(line):
        if 'UNLINT' not in line:
            text_part = match.group(0)
            if text_part.endswith('."') or text_part.endswith('.")'):
                failures.append((idx + 1, f"Balloon alerts should not end with a period: '{match.group(1)}'. If this is a false positive, wrap the text in UNLINT()."))
    if match := BALLOON_ALERT_TO_VIEWERS_WRONG_FIRST_ARG.search(line):
        failures.append((idx + 1, f"balloon_alert_to_viewers called with non-string first argument. First argument should be a message string."))
    return failures

TRAIT_SINGLE_SRC = re.compile(r'(add_trait|remove_trait)\(.+,\s*.+,\s*src\)', re.IGNORECASE)
TRAIT_PLURAL_SRC = re.compile(r'(add_traits|remove_traits)\(.+,\s*src\)', re.IGNORECASE)
def check_trait_sources(idx, line):
    failures = []
    if TRAIT_SINGLE_SRC.search(line):
        failures.append((idx + 1, "Using 'src' as a trait source. Source must be a string key - don't use references to datums as a source, perhaps use 'ref(src)'."))
    if TRAIT_PLURAL_SRC.search(line):
        failures.append((idx + 1, "Using 'src' as trait sources. Source must be a string key - don't use references to datums as sources, perhaps use 'ref(src)'."))
    return failures

STATIC_LIST_IMPROPER_PATH = re.compile(r'var/list/static/')
def check_static_list_path(idx, line):
    if STATIC_LIST_IMPROPER_PATH.search(line):
        return [(idx + 1, "Found incorrect static list definition 'var/list/static/', it should be 'var/static/list/' instead.")]

TIMER_OVERRIDE_WITHOUT_UNIQUE = re.compile(r'addtimer\((?=.*TIMER_OVERRIDE)(?!.*TIMER_UNIQUE).*\)')
def check_timer_flags(idx, line):
    if TIMER_OVERRIDE_WITHOUT_UNIQUE.search(line):
        return [(idx + 1, "TIMER_OVERRIDE used without TIMER_UNIQUE.")]

FAST_LOAD_FILENAME = "common.dm"
FAST_LOAD_DEFINE = re.compile(r'#define FAST_LOAD')
def check_fast_load_define(idx, line):
    if FAST_LOAD_DEFINE.match(line):
        return [(idx + 1, "Commiting uncommented FAST_LOAD define!")]

FORCE_MOVE_TWO_ARGS = re.compile(r'forceMove\(\s*(\w+\(\)|\w+)\s*,\s*(\w+\(\)|\w+)\s*\)')
def check_force_move_syntax(idx, line):
    if FORCE_MOVE_TWO_ARGS.search(line):
        return [(idx + 1, "forceMove() call with two arguments - this is not how forceMove() is invoked! It's x.forceMove(y), not forceMove(x, y).")]

CAN_PERFORM_ACTION_IMPROPER = re.compile(r'can_perform_action\(\s*\)')
def check_can_perform_action(idx, line):
    if CAN_PERFORM_ACTION_IMPROPER.search(line):
        return [(idx + 1, "Found a can_perform_action() proc with improper arguments.")]

AS_ANYTHING_TYPELESS = re.compile(r'var/[^/]+ as anything')
AS_ANYTHING_INTERNAL = re.compile(r'var\/(turf|mob|obj|atom\/movable).+ as anything in o?(view|range|hearers)\(')
def check_as_anything(idx, line):
    failures = []
    if AS_ANYTHING_TYPELESS.search(line):
        failures.append((idx + 1, "'as anything' used in a typeless for loop. This doesn't do anything and should be removed."))
    if AS_ANYTHING_INTERNAL.search(line):
        failures.append((idx + 1, "'as anything' typed for loop over an internal function. These functions have some internal optimization that relies on the loop not having 'as anything' in it."))
    return failures

IE_TYPO_RE = re.compile(r'eciev', re.IGNORECASE)
def check_ie_typo(idx, line):
    if IE_TYPO_RE.search(line):
        return [(idx + 1, "Common I-before-E typo detected in code (found 'eciev', did you mean 'receive'?).")]

DEFINE_SPACING_RE = re.compile(r'^\s*#define\s+\S+\s{2,}\S')
def check_define_formatting(idx, line):
    if DEFINE_SPACING_RE.match(line):
        return [(idx + 1, "Invalid #define spacing. Use exactly one space between macro name and value.")]

DUPLICATE_SPANS_RE = re.compile(r'span_(\w+)\(\s*span_\1\(')
def check_duplicate_spans(idx, line):
    if match := DUPLICATE_SPANS_RE.search(line):
        return [(idx + 1, f"Found nested identical span macros: 'span_{match.group(1)}' inside another 'span_{match.group(1)}'.")]

HTML_TAGS_UPPERCASE_RE = re.compile(r'</?[A-Z][A-Z0-9]*\b[^>]*/?>')
def check_html_tags_case(idx, line):
    if match := HTML_TAGS_UPPERCASE_RE.search(line):
        return [(idx + 1, f"HTML tag '{match.group(0)}' should be in lowercase, not uppercase.")]

DASH_USAGE_RE = re.compile(r'(?:(?<=[а-яё]) [–-] (?=[а-яё])|(?<=[а-яё]) [–-] \d|\d [–-] (?=[а-яё])|(?<=[а-яё]) [–-] [\]\[]|[\]\[] [–-] (?=[а-яё]))', re.IGNORECASE)
def check_dash_usage(idx, line):
    if DASH_USAGE_RE.search(line):
        if 'UNLINT' not in line:
            return [(idx + 1, "Found hyphen or en dash, which should be replaced with em dash (—).")]

PLAYSOUND_IMPROPER_CALL = re.compile(r'playsound\(([^,]*), "(sound\/[^\[]+)"')
SOUND_IMPROPER_PATH = re.compile(r'"(sound\/[^\[]+)(.ogg)"')
def check_playsound_improper_call(idx, line):
    failures = []
    if match := PLAYSOUND_IMPROPER_CALL.search(line):
        return [(idx + 1, f"Improper playsound call detected: \"{match.group(2)}\", it should be '{match.group(2)}' instead.")]
    if match := SOUND_IMPROPER_PATH.search(line):
        return [(idx + 1, f"Improper sound path detected: {match.group(0)}, it should be '{match.group(1)}.ogg' instead.")]
    return failures

APOSTROPHE_NAME = re.compile(r'name\s*=\s*"[^"]*\[[^]]*\]\'s')
def check_apostrophe_name(idx, line):
    if APOSTROPHE_NAME.search(line):
        return [(idx + 1, f"Using an apostrophe in a name like \"[mob]'s brain\" may cause Byond to get confused between the two objects, such as click verbs, etc. Please use ’ (U+2019) instead.")]

RAND_FLOATING_POINT_NUMBERS = re.compile(r'rand\([^)]*[0-9]\.')
def check_rand_floating_point(idx, line):
    if RAND_FLOATING_POINT_NUMBERS.search(line):
        return [(idx + 1, "rand() does not support floating point numbers, use randfloat() instead.")]

BITWISE_AMBIGUOUS_RE = re.compile(r'&[ \t]*\w+[ \t]*\|[ \t]*\w+')
def check_bitwise_operator_order(idx, line):
    if BITWISE_AMBIGUOUS_RE.search(line):
        return [(idx + 1, "Error in operator order when using bitwise OR. Use parentheses to indicate intent.")]

IGNORE_LOCALIZATION_FILE = "localization.dm"
MACROED_PROCS = re.compile(r'genderize_ru|pluralize_ru')
def check_localization_macro_usage(idx, line):
    if MACROED_PROCS.search(line):
        if 'UNLINT' not in line:
            return [(idx + 1, "Do not use this proc directly. Use the ready-made macros in code/__HELPERS/localization.dm")]

CODE_CHECKS = [
    check_space_indentation,
    check_mixed_indentation,
    check_global_vars,
    check_toplevel_vardecls,
    check_proc_args_with_var_prefix,
    check_nanotrasen_style,
    check_to_chats_have_a_user_arguement,
    check_conditional_spacing,
    check_global_list_empty,
    check_tgui_ui_new_argument,
    check_datum_loops,
    check_href_styles,
    check_initialize_missing_mapload,
    check_empty_list_whitespace,
#    check_istype_src,
#    check_camel_case_type_names,
    check_uid_parameters,
    check_balloon_alert,
    check_trait_sources,
    check_static_list_path,
    check_timer_flags,
    check_force_move_syntax,
    check_can_perform_action,
    check_as_anything,
    check_ie_typo,
    check_define_formatting,
    check_duplicate_spans,
    check_html_tags_case,
    check_dash_usage,
    check_playsound_improper_call,
    check_apostrophe_name,
    check_rand_floating_point,
    check_bitwise_operator_order,
    check_516_href_style,
]

def run_multiline_check(lines, filename, patterns, strip_comments=False):
    if strip_comments:
        clean_lines = []
        for line in lines:
            clean_line = line.split('//')[0].rstrip()
            clean_lines.append(clean_line + '\n')
        content = ''.join(clean_lines)
    else:
        content = ''.join(lines)

    failures = []
    for pattern, message in patterns:
        for match in pattern.finditer(content):
            line_no = content[:match.start()].count('\n') + 1
            failures.append(Failure(filename, line_no, message))
    return failures

LONG_LIST_PATTERNS = [
    (re.compile(r'^(\t)[\w_]+ = list\(\n\1\t{2,}', re.MULTILINE),
    "Long list overindented, should be exactly two tabs."),
    (re.compile(r'^(\t)[\w_]+ = list\(\n\1\S', re.MULTILINE),
    "Long list underindented, should be exactly two tabs."),
    (re.compile(r'^(\t)[\w_]+ = list\([^\s)]+( ?= ?[\w\d]+)?,\n', re.MULTILINE),
    "First item in a long list should be on the next line with proper indentation."),
    (re.compile(r'^(\t)[\w_]+ = list\(\n(?:\1\t(?:[^,\n]|list\([^)]*\))+,\n)*\1\t(?:[^,\n]|list\([^)]*\))+\s*\n\1\)', re.MULTILINE),
    "Last item in a long list should have a comma."),
    (re.compile(r'^(\t)[\w_]+ = list\(\n(\1\t[^\s)]+( ?= ?[\w\d]+)?,\n)*\1\t[^\s)]+( ?= ?[\w\d]+)?\)', re.MULTILINE),
    "The ) in a long list should be on a new line without comma."),
    (re.compile(r'^(\t)[\w_]+ = list\(\n(\1\t[^\s)]+( ?= ?[\w\d]+)?,\n)+\1\t\)', re.MULTILINE),
    "The ) in a long list should match indentation of the opening list line."),
]
def check_long_list_formatting(lines, filename):
    return run_multiline_check(lines, filename, LONG_LIST_PATTERNS, strip_comments=True)

EXCESSIVE_EMPTY_LINES_PATTERNS = [
    (re.compile(r'\n\s*\n\s*\n\s*\n+'),
    "Too many empty lines were found. Please observe the code style, there is no point in more than 1 empty line between any code."),
]
def check_excessive_empty_lines(lines, filename):
    return run_multiline_check(lines, filename, EXCESSIVE_EMPTY_LINES_PATTERNS, strip_comments=False)

MULTI_LINE_CHECKS = [
    check_long_list_formatting,
    check_excessive_empty_lines,
]

NEW_DEFINITION_RE = re.compile(r'^\s*/?(obj|mob|turf|area|atom)/?.*/New\(')
LIMIT_NEW_DEFINITION = 2
IGNORE_NEW_DEFINITION_FILES = [
#    "labubu.dm",
]
def check_new_definitions_count(lines, filename):
    if filename in IGNORE_NEW_DEFINITION_FILES:
        return []

    failures = []
    new_line_numbers = []

    for idx, line in enumerate(lines):
        if NEW_DEFINITION_RE.match(line):
            new_line_numbers.append(idx + 1)

    if len(new_line_numbers) > LIMIT_NEW_DEFINITION:
        for line_no in new_line_numbers:
            failures.append(Failure(filename, line_no, f"Found excessive New() definition. It should be replaced with Initialize(mapload)."))
    return failures

FILE_CHECKS = [
#    check_new_definitions_count,
]

def check_updatepaths_validity():
    updatepaths_dir = "tools/UpdatePaths/Scripts/"
    if not os.path.isdir(updatepaths_dir):
        return []

    failures = []
    try:
        for entry in os.scandir(updatepaths_dir):
            if not entry.is_file():
                continue
            filename = entry.name
            path = entry.path
            if not filename.endswith('.txt'):
                failures.append(Failure(path, 0, "UpdatePaths file missing .txt extension."))
            if filename and not filename[0].isdigit():
                failures.append(Failure(path, 0, "UpdatePaths file missing PR number prefix."))
    except OSError:
        pass
    return failures

def lint_file(code_filepath: str) -> list[Failure]:
    # Otherwise, the script starts checking the OD files and the linter breaks.
    if "DMCompiler_linux-x64" in code_filepath:
        return []

    all_failures = []
    with open(code_filepath, encoding="UTF-8") as code:
        filename = code_filepath.split(os.path.sep)[-1]
        lines = code.readlines()

        extra_checks = []
        if filename != IGNORE_515_PROC_MARKER_FILENAME:
            extra_checks.append(check_515_proc_syntax)
        if filename != IGNORE_ATOM_ICON_FILE:
            extra_checks.append(check_manual_icon_updates)
        if filename == FAST_LOAD_FILENAME:
            extra_checks.append(check_fast_load_define)
        if filename != IGNORE_LOCALIZATION_FILE:
            extra_checks.append(check_localization_macro_usage)

        for idx, line in enumerate(lines):
            for check in CODE_CHECKS + extra_checks:
                if failures := check(idx, line):
                    all_failures += [Failure(code_filepath, lineno, message) for lineno, message in failures]

        for check in MULTI_LINE_CHECKS + FILE_CHECKS:
            all_failures.extend(check(lines, code_filepath))

        if lines and not lines[-1].endswith('\n'):
            all_failures.append(Failure(code_filepath, len(lines), "Missing a trailing newline."))

    return all_failures

if __name__ == "__main__":
    print("check_grep2 started")

    exit_code = 0
    start = time.time()

    dm_files = glob.glob("**/*.dm", recursive=True)

    if len(sys.argv) > 1:
        dm_files = [sys.argv[1]]

    all_failures = []
    with ProcessPoolExecutor() as executor:
        for failures in executor.map(lint_file, dm_files):
            all_failures += failures
    all_failures += check_updatepaths_validity()

    if all_failures:
        exit_code = 1
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)

    end = time.time()
    print(f"\ncheck_grep2 tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)
