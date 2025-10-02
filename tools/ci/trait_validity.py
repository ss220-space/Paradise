import os
import re
import sys
from collections import namedtuple

Failure = namedtuple("Failure", ["filename", "lineno", "message"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m" # No Color

DEFINE_REGEX = re.compile(r"^(\s*)?#define\s+([A-Z0-9_]+)\b")
TRAIT_ASSIGNMENT_REGEX = re.compile(r'"([A-Z0-9_]+)"\s*=\s*\1')

DEFINES_FILE = "code/__DEFINES/traits/declarations.dm"
GLOBALVARS_FILE = "code/_globalvars/traits/_traits.dm"

def print_error(message: str, filename: str = None, line_number: int = None):
    if os.getenv("GITHUB_ACTIONS") == "true":
        if filename and line_number:
            print(f"::error file={filename},line={line_number},title=Trait Sanity::{message}")
        elif filename:
            print(f"::error file={filename},title=Trait Sanity::{message}")
        else:
            print(f"::error title=Trait Sanity::{message}")
    else:
        if filename and line_number:
            print(f"{filename}:{line_number}: {RED}{message}{NC}")
        elif filename:
            print(f"{filename}: {RED}{message}{NC}")
        else:
            print(f"{RED}{message}{NC}")

def check_alphabetical_sort_in_global_list(filename: str) -> list[Failure]:
    """Checks alphabetical sorting inside GLOBAL_LIST_INIT(traits_by_type, list(...))"""
    failures = []

    if not os.path.isfile(filename):
        return [Failure(filename, 0, f"File not found: {filename}")]

    with open(filename, 'r', encoding='utf-8') as file:
        content = file.read()

    # Looking for GLOBAL_LIST_INIT(traits_by_type, list(...))
    global_list_pattern = r'GLOBAL_LIST_INIT\s*\(\s*traits_by_type\s*,\s*list\s*\(([\s\S]*?)\)\s*\)'
    match = re.search(global_list_pattern, content)

    if not match:
        return [Failure(filename, 0, "Could not find GLOBAL_LIST_INIT(traits_by_type, list(...))")]

    global_list_content = match.group(1)

    # Split into lines to analyze line numbers
    with open(filename, 'r', encoding='utf-8') as file:
        all_lines = file.readlines()

    # Find the GLOBAL_LIST_INIT start line
    start_line_num = 0
    for i, line in enumerate(all_lines, 1):
        if 'GLOBAL_LIST_INIT(traits_by_type, list(' in line:
            start_line_num = i
            break

    if start_line_num == 0:
        return [Failure(filename, 0, "Could not locate GLOBAL_LIST_INIT line")]

    # We search for all nested lists of type /type = list(...)
    list_pattern = r'(\/\w+)\s*=\s*list\s*\(([^)]+)\)'
    list_matches = re.finditer(list_pattern, global_list_content)

    for match in list_matches:
        type_path = match.group(1)
        list_content = match.group(2)

        # Find the position of this list in the source file
        list_start_in_content = match.start(2)

        # We calculate the approximate line number
        lines_before = global_list_content[:list_start_in_content].count('\n')
        list_line_num = start_line_num + lines_before

        # Extract traits from the list
        trait_pattern = r'"([A-Z0-9_]+)"\s*=\s*\1'
        trait_matches = list(re.finditer(trait_pattern, list_content))

        if len(trait_matches) > 1:
            trait_names = [m.group(1) for m in trait_matches]
            sorted_trait_names = sorted(trait_names, key=str.lower)

            if trait_names != sorted_trait_names:
                # Find the first trait that breaks the order
                for i in range(len(trait_names)):
                    if trait_names[i].lower() != sorted_trait_names[i].lower():
                        # Calculate the line number for this trait
                        trait_start_in_list = trait_matches[i].start(1)
                        lines_before_trait = list_content[:trait_start_in_list].count('\n')
                        trait_line_num = list_line_num + lines_before_trait

                        failures.append(Failure(
                            filename,
                            trait_line_num,
                            f"Alphabetical ordering violation in {type_path} list: '{trait_names[i]}' should come after '{sorted_trait_names[i-1] if i > 0 else '...'}'"
                        ))
                        break

    return failures

def main():
    if not os.path.isfile(DEFINES_FILE):
        print_error(f"Could not find the defines file '{DEFINES_FILE}'!")
        sys.exit(1)

    if not os.path.isfile(GLOBALVARS_FILE):
        print_error(f"Could not find the globalvars file '{GLOBALVARS_FILE}'!")
        sys.exit(1)

    # Checking the consistency of traits between files
    defines = set()
    define_lines = {}

    with open(DEFINES_FILE, 'r', encoding="utf-8") as file:
        for line_number, line in enumerate(file, 1):
            match = DEFINE_REGEX.match(line)
            if match:
                define_name = match.group(2)
                defines.add(define_name)
                define_lines[define_name] = line_number

    if not defines:
        print_error(f"No defines found in {DEFINES_FILE}! This is likely an error.", DEFINES_FILE)
        sys.exit(1)

    trait_assignments = set()
    assignment_lines = {}

    with open(GLOBALVARS_FILE, 'r', encoding="utf-8") as file:
        for line_number, line in enumerate(file, 1):
            match = TRAIT_ASSIGNMENT_REGEX.search(line)
            if match:
                trait_name = match.group(1)
                trait_assignments.add(trait_name)
                assignment_lines[trait_name] = line_number

    missing_in_globalvars = defines - trait_assignments
    missing_in_defines = trait_assignments - defines

    trait_errors = []

    for define in missing_in_globalvars:
        trait_errors.append(Failure(
            DEFINES_FILE,
            define_lines.get(define, 1),
            f"Trait '{define}' is defined but not added to {GLOBALVARS_FILE}!"
        ))

    for trait in missing_in_defines:
        trait_errors.append(Failure(
            GLOBALVARS_FILE,
            assignment_lines.get(trait, 1),
            f"Trait '{trait}' is used in {GLOBALVARS_FILE} but not defined in {DEFINES_FILE}!"
        ))

    sort_failures = check_alphabetical_sort_in_global_list(GLOBALVARS_FILE)

    all_errors = trait_errors + sort_failures

    if all_errors:
        for error in all_errors:
            print_error(error.message, error.filename, error.lineno)

        if trait_errors and sort_failures:
            print_error("Please ensure all traits are both defined and properly assigned AND sorted alphabetically in traits_by_type list!")
        elif trait_errors:
            print_error("Please ensure all traits are both defined and properly assigned!")
        else:
            print_error("Please ensure all traits are sorted alphabetically within each type list in GLOBAL_LIST_INIT(traits_by_type, list(...))!")

        sys.exit(1)
    else:
        print(f"{GREEN}All traits are properly defined, assigned, and sorted alphabetically! (found {len(defines)} traits){NC}")

if __name__ == "__main__":
    main()
