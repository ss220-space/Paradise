import glob
import os
import sys
import time
import re
import argparse
from collections import namedtuple, defaultdict

Failure = namedtuple("Failure", ["filename", "lineno", "message"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color

def print_error(message: str, filename: str, line_number: int):
    if os.getenv("GITHUB_ACTIONS") == "true":
        print(f"::error file={filename},line={line_number},title=Check istype macros::{filename}:{line_number}: {message}")
    else:
        print(f"{filename}:{line_number}: {RED}{message}{NC}")

# Built‑in DM type checks
BUILTIN_CHECKS = {
    '/area': 'isarea',
    '/mob': 'ismob',
    '/obj': 'isobj',
    '/turf': 'isturf',
    '/list': 'islist',
    '/file': 'isfile',
    '/icon': 'isicon',
}

# Regex to extract macro definitions (single line only)
MACRO_DEF_RE = re.compile(r'^#define\s+(\w+)\s*\(\s*(\w+)\s*\)\s*(.*)$')
def load_istype_macros(filepath):
    """
    Return a tuple (exact_macros, or_macros) where each is a dict {path: list of macro names}.
    exact_macros: macros without '||'
    or_macros: macros with '||'
    Returns None on failure.
    """
    exact = defaultdict(list)
    or_macros = defaultdict(list)
    try:
        with open(filepath, 'r', encoding='utf-8') as file:
            for line in file:
                line = line.strip()
                m = MACRO_DEF_RE.match(line)
                if not m:
                    continue
                name, param, body = m.groups()

                # Skip macros that contain && (extra conditions)
                if '&&' in body:
                    continue

                has_or = '||' in body

                param_escaped = re.escape(param)
                func_pattern = re.compile(
                    r'(istype|is_species)\s*\(\s*\(?\s*' + param_escaped + r'\s*\)?\s*,\s*([^)]+?)\s*\)'
                )

                for func_match in func_pattern.finditer(body):
                    path = func_match.group(2).strip().rstrip('/')
                    if has_or:
                        or_macros[path].append(name)
                    else:
                        exact[path].append(name)
    except Exception as e:
        print(f"{RED}Failed to read macro file {filepath}: {e}{NC}", file=sys.stderr)
        return None
    return dict(exact), dict(or_macros)


def find_istype_calls(line):
    """
    Find all istype(...) calls in a line, correctly handling nested parentheses and optional spaces.
    Returns a list of tuples (start_pos, end_pos, arg1, arg2).
    """
    results = []
    i = 0
    while True:
        pos = line.find("istype", i)
        if pos == -1:
            break
        j = pos + 6
        while j < len(line) and line[j].isspace():
            j += 1
        if j >= len(line) or line[j] != '(':
            i = pos + 6
            continue
        start = pos
        paren_count = 1
        k = j + 1
        while k < len(line):
            ch = line[k]
            if ch == '(':
                paren_count += 1
            elif ch == ')':
                paren_count -= 1
                if paren_count == 0:
                    end = k + 1
                    break
            k += 1
        else:
            i = pos + 6
            continue

        content = line[j+1:end-1].strip()
        comma_pos = -1
        paren_count = 0
        in_quotes = False
        escape = False
        for idx, ch in enumerate(content):
            if escape:
                escape = False
                continue
            if ch == '\\':
                escape = True
                continue
            if ch == '"' and not escape:
                in_quotes = not in_quotes
                continue
            if not in_quotes:
                if ch == '(':
                    paren_count += 1
                elif ch == ')':
                    paren_count -= 1
                elif ch == ',' and paren_count == 0:
                    comma_pos = idx
                    break

        if comma_pos == -1:
            i = end
            continue

        arg1 = content[:comma_pos].strip()
        arg2 = content[comma_pos+1:].strip()
        if arg1.startswith('(') and arg1.endswith(')'):
            arg1 = arg1[1:-1].strip()
        results.append((start, end, arg1, arg2))
        i = end
    return results


def replace_istype_in_line(line, exact_macros, or_macros):
    """Replace all istype() calls in a line, preferring exact macros over OR macros."""
    new_line = ""
    last_end = 0
    modified = False
    for start, end, arg, path in find_istype_calls(line):
        new_line += line[last_end:start]
        path_normalized = path.strip().rstrip('/')
        if path_normalized.startswith('/'):
            if path_normalized in BUILTIN_CHECKS:
                new_line += f"{BUILTIN_CHECKS[path_normalized]}({arg})"
                modified = True
            else:
                if path_normalized in exact_macros and exact_macros[path_normalized]:
                    names = exact_macros[path_normalized]
                    if len(names) == 1:
                        new_line += f"{names[0]}({arg})"
                        modified = True
                    else:
                        new_line += line[start:end]
                elif path_normalized in or_macros:
                    names = or_macros[path_normalized]
                    if len(names) == 1:
                        new_line += f"{names[0]}({arg})"
                        modified = True
                    else:
                        new_line += line[start:end]
                else:
                    new_line += line[start:end]
        else:
            new_line += line[start:end]
        last_end = end
    new_line += line[last_end:]
    return new_line, modified


def fix_file(filepath, exact_macros, or_macros):
    """Fix istype() calls in a file."""
    try:
        with open(filepath, 'r', encoding='utf-8', newline='') as f:
            original_lines = f.readlines()
    except Exception as e:
        print(f"{RED}Failed to read {filepath}: {e}{NC}", file=sys.stderr)
        return False

    new_lines = []
    modified = False
    for line in original_lines:
        new_line, line_modified = replace_istype_in_line(line, exact_macros, or_macros)
        if line_modified:
            modified = True
        new_lines.append(new_line)

    if not modified or original_lines == new_lines:
        return False

    try:
        with open(filepath, 'w', encoding='utf-8', newline='') as f:
            f.writelines(new_lines)
        print(f"{GREEN}Fixed {filepath}{NC}")
        return True
    except Exception as e:
        print(f"{RED}Failed to write {filepath}: {e}{NC}", file=sys.stderr)
        return False


def check_file(filepath, exact_macros, or_macros):
    """Return failures for a file."""
    failures = []
    try:
        with open(filepath, 'r', encoding='utf-8', newline='') as f:
            lines = f.readlines()
    except Exception as e:
        return [Failure(filepath, 0, f"Failed to read file: {e}")]

    for idx, line in enumerate(lines):
        for _, _, arg, path in find_istype_calls(line):
            arg = arg.strip()
            path = path.strip().rstrip('/')
            if not path.startswith('/'):
                continue

            if path in BUILTIN_CHECKS:
                msg = (f"Raw istype() call for path '{path}'. "
                       f"Use built‑in function '{BUILTIN_CHECKS[path]}({arg})' instead.")
                failures.append(Failure(filepath, idx + 1, msg))
                continue

            if path in exact_macros:
                names = exact_macros[path]
                if len(names) == 1:
                    msg = (f"Raw istype() call for path '{path}'. "
                           f"Use macro '{names[0]}({arg})' instead.")
                    failures.append(Failure(filepath, idx + 1, msg))
                else:
                    msg = (f"Path '{path}' is covered by multiple exact macros: {', '.join(names)}. "
                           f"Please choose manually.")
                    failures.append(Failure(filepath, idx + 1, msg))
                continue

            if path in or_macros:
                names = or_macros[path]
                if len(names) == 1:
                    msg = (f"Raw istype() call for path '{path}'. "
                           f"Use macro '{names[0]}({arg})' instead.")
                    failures.append(Failure(filepath, idx + 1, msg))
                else:
                    msg = (f"Path '{path}' is covered by multiple OR macros: {', '.join(names)}. "
                           f"Please choose manually.")
                    failures.append(Failure(filepath, idx + 1, msg))
    return failures


def main():
    parser = argparse.ArgumentParser(description="Check and fix raw istype() calls.")
    parser.add_argument('--fix', action='store_true', help='Automatically fix issues')
    args = parser.parse_args()

    print("check_istype_macros started\n")
    start = time.time()

    is_helpers_path = "code/__DEFINES/is_helpers.dm"
    if not os.path.isfile(is_helpers_path):
        is_helpers_path = "is_helpers.dm"
    if not os.path.isfile(is_helpers_path):
        print(f"{RED}Macro file not found. Please specify the correct path.{NC}")
        sys.exit(1)

    result = load_istype_macros(is_helpers_path)
    if result is None:
        sys.exit(1)
    exact_macros, or_macros = result

    total_exact = len(set(name for names in exact_macros.values() for name in names))
    total_or = len(set(name for names in or_macros.values() for name in names))
    print(f"{BLUE}Loaded {total_exact} exact macros and {total_or} OR macros from '{is_helpers_path}'.{NC}")
    print(f"{BLUE}Additionally checking {len(BUILTIN_CHECKS)} built-in DM type checks.{NC}")

    all_dm_files = glob.glob("**/*.dm", recursive=True)
    files_to_check = [f for f in all_dm_files if os.path.normpath(f) != os.path.normpath(is_helpers_path)]

    if args.fix:
        print(f"{BLUE}Fixing files...{NC}")
        for filepath in files_to_check:
            fix_file(filepath, exact_macros, or_macros)

        print(f"{BLUE}Re-checking after fixes...{NC}")
        all_failures = []
        for filepath in files_to_check:
            all_failures.extend(check_file(filepath, exact_macros, or_macros))
    else:
        all_failures = []
        for filepath in files_to_check:
            all_failures.extend(check_file(filepath, exact_macros, or_macros))

    if all_failures:
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)
        sys.exit(1)
    else:
        print(f"{GREEN}All istype macro checks passed successfully.{NC}")

    elapsed = time.time() - start
    print(f"\ncheck_istype_macros completed in {elapsed:.2f}s\n")


if __name__ == "__main__":
    main()
