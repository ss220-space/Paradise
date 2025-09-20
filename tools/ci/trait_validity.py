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

def main():
    if not os.path.isfile(DEFINES_FILE):
        print_error(f"Could not find the defines file '{DEFINES_FILE}'!")
        sys.exit(1)

    if not os.path.isfile(GLOBALVARS_FILE):
        print_error(f"Could not find the globalvars file '{GLOBALVARS_FILE}'!")
        sys.exit(1)

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

    errors = []

    for define in missing_in_globalvars:
        errors.append(Failure(
            DEFINES_FILE,
            define_lines.get(define, 1),
            f"Trait '{define}' is defined but not added to {GLOBALVARS_FILE}!"
        ))

    for trait in missing_in_defines:
        errors.append(Failure(
            GLOBALVARS_FILE,
            assignment_lines.get(trait, 1),
            f"Trait '{trait}' is used in {GLOBALVARS_FILE} but not defined in {DEFINES_FILE}!"
        ))

    if errors:
        for error in errors:
            print_error(error.message, error.filename, error.lineno)

        print_error("Please ensure all traits are both defined and properly assigned!")
        sys.exit(1)
    else:
        print(f"{GREEN}All traits are properly defined and assigned! (found {len(defines)} traits){NC}")

if __name__ == "__main__":
    main()
