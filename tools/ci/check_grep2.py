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

CHECK_SPACE_INDENTATION_RE = re.compile(r"^( {2})|(^ [^ *])|(^ {4,})")
def check_space_indentation(idx, line):
    """
    Check specifically for space-significant indentation.

    >>> bool(check_space_indentation(["  foo"]))
    True
    >>> bool(check_space_indentation(["  * foo"])) # 2 spaces + asterisk
    True
    >>> bool(check_space_indentation([" x"])) # 1 space + letter
    True
    >>> bool(check_space_indentation(["    foo"])) # 4+ spaces
    True
    >>> bool(check_space_indentation(["  "])) # 2 spaces only
    True

    >>> bool(check_space_indentation(["\\tfoo"])) # tabs are fine
    False
    >>> bool(check_space_indentation([" * foo"])) # 1 space + asterisk
    False
    >>> bool(check_space_indentation(["   foo"])) # 3 spaces (not matched)
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
def check_nanotrasen_style(idx, line):
    failures = []
    if match := NANOTRASEN_CAMEL_CASE_EN.search(line):
        failures.append((idx + 1, f"Found camel case '{match.group(1)}', should be 'Nanotrasen'."))
    if match := NANOTRASEN_CAMEL_CASE_RU.search(line):
        failures.append((idx + 1, f"Found camel case '{match.group(1)}', should be 'Нанотрейзен'."))
    if match := NANOTRASEN_MISSPELLING_N_RU.search(line):
        if 'UNLINT' not in line:
            failures.append((idx + 1, f"Found lowercase '{match.group(1)}', should be 'Нанотрейзен'."))
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
BALLOON_ALERT_WITH_SPAN = re.compile(r'(balloon_alert\(.*?span_)')
BALLOON_ALERT_CAPITALIZED = re.compile(r'(balloon_alert\(.*?,\s*["\'][A-ZА-Я])')
def check_balloon_alert(idx, line):
    failures = []
    if match := BALLOON_ALERT_WITHOUT_USER.search(line):
        failures.append((idx + 1, f"balloon_alert called with a string literal without a user argument: '{match.group(1)}'"))
    if match := BALLOON_ALERT_WITH_SPAN.search(line):
        failures.append((idx + 1, f"Balloon alerts should never contain spans: '{match.group(1)}'"))
    if match := BALLOON_ALERT_CAPITALIZED.search(line):
        if 'UNLINT' not in line:
            failures.append((idx + 1, f"Balloon alerts should not start with capital letters: '{match.group(1)}'. Includes text like 'AI'. Wrap the text in UNLINT() if needed."))
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
def check_as_anything_typeless(idx, line):
    if AS_ANYTHING_TYPELESS.search(line):
        return [(idx + 1, "'as anything' used in a typeless for loop. This doesn't do anything and should be removed.")]

AS_ANYTHING_INTERNAL = re.compile(r'var\/(turf|mob|obj|atom\/movable).+ as anything in o?(view|range|hearers)\(')
def check_as_anything_internal(idx, line):
    if AS_ANYTHING_INTERNAL.search(line):
        return [(idx + 1, "'as anything' typed for loop over an internal function. These functions have some internal optimization that relies on the loop not having 'as anything' in it.")]

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

HYPHEN_USAGE_RE = re.compile(r'(?:(?<=[а-яё]) - (?=[а-яё])|(?<=[а-яё]) - \d+|\d+ - (?=[а-яё]))', re.IGNORECASE)
EN_DASH_USAGE_RE = re.compile(r'(?:(?<=[а-яё]) – (?=[а-яё])|(?<=[а-яё]) – \d+|\d+ – (?=[а-яё]))', re.IGNORECASE)
def check_dash_usage(idx, line):
    failures = []
    if match := HYPHEN_USAGE_RE.search(line):
        failures.append((idx + 1, f"A hyphen with spaces was found '{match.group(0)}', which should be replaced with a dash (—)."))
    if match := EN_DASH_USAGE_RE.search(line):
        failures.append((idx + 1, f"A en dash with spaces was found '{match.group(0)}', which should be replaced with a dash (—)."))
    return failures

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
    check_as_anything_typeless,
    check_as_anything_internal,
    check_ie_typo,
    check_define_formatting,
    check_duplicate_spans,
    check_html_tags_case,
    check_dash_usage,
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
    all_failures = []
    with open(code_filepath, encoding="UTF-8") as code:
        filename = code_filepath.split(os.path.sep)[-1]

        extra_checks = []
        if filename != IGNORE_515_PROC_MARKER_FILENAME:
            extra_checks.append(check_515_proc_syntax)
        if filename != IGNORE_ATOM_ICON_FILE:
            extra_checks.append(check_manual_icon_updates)
        if filename == FAST_LOAD_FILENAME:
            extra_checks.append(check_fast_load_define)

        last_line = None
        for idx, line in enumerate(code):
            for check in CODE_CHECKS + extra_checks:
                if failures := check(idx, line):
                    all_failures += [Failure(code_filepath, lineno, message) for lineno, message in failures]
            last_line = line

        if last_line and last_line[-1] != '\n':
            all_failures.append(Failure(code_filepath, idx + 1, "Missing a trailing newline."))
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
