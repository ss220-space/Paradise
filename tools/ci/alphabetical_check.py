import os
import sys
from collections import namedtuple

Failure = namedtuple("Failure", ["filename", "lineno", "message"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m" # No Color

START_MARKER = "// START OF ALPHABETICAL SORTING"
END_MARKER = "// END OF ALPHABETICAL SORTING"

# List of files that should contain sort markers
REQUIRED_FILES = [
    "code/modules/mob/transform_procs.dm",
    "code/modules/unit_tests/_unit_tests.dm",
]

def print_error(message: str, filename: str = None, line_number: int = None):
    if os.getenv("GITHUB_ACTIONS") == "true":
        if filename and line_number:
            print(f"::error file={filename},line={line_number},title=Alphabetical Sort Check::{message}")
        elif filename:
            print(f"::error file={filename},title=Alphabetical Sort Check::{message}")
        else:
            print(f"::error title=Alphabetical Sort Check::{message}")
    else:
        if filename and line_number:
            print(f"{filename}:{line_number}: {RED}{message}{NC}")
        elif filename:
            print(f"{filename}: {RED}{message}{NC}")
        else:
            print(f"{RED}{message}{NC}")

def check_markers_presence(filename: str) -> list[Failure]:
    """Checks for the presence of START and END markers in a file."""
    failures = []

    if not os.path.isfile(filename):
        return [Failure(filename, 0, f"File not found: {filename}")]

    with open(filename, 'r', encoding='utf-8') as file:
        content = file.read()

    has_start = START_MARKER in content
    has_end = END_MARKER in content

    if not has_start:
        failures.append(Failure(filename, 0, f"Missing required marker: {START_MARKER}"))
    if not has_end:
        failures.append(Failure(filename, 0, f"Missing required marker: {END_MARKER}"))

    return failures

def check_alphabetical_sort(filename: str) -> list[Failure]:
    """Checks the alphabetical sorting of the file between the START and END markers."""
    failures = []

    if not os.path.isfile(filename):
        return [Failure(filename, 0, f"File not found: {filename}")]

    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    inside_block = False
    block_lines = []
    block_line_numbers = []

    # Collect lines between markers
    for i, line in enumerate(lines, 1):
        stripped_line = line.strip()

        if START_MARKER in stripped_line:
            if inside_block:
                failures.append(Failure(filename, i, "Found nested start marker"))
            inside_block = True
            continue

        if END_MARKER in stripped_line:
            if not inside_block:
                failures.append(Failure(filename, i, "Found end marker without start marker"))
            else:
                inside_block = False
            continue

        if inside_block:
            # Ignore empty lines and comments inside the block
            if stripped_line and not stripped_line.startswith("//"):
                block_lines.append(stripped_line)
                block_line_numbers.append(i)

    # If we are still inside the block at the end of the file, it is an error
    if inside_block:
        failures.append(Failure(filename, len(lines), "Unclosed alphabetical sorting block - missing end marker"))

    # Check the sorting of the collected lines
    if block_lines and not failures:
        sorted_lines = sorted(block_lines, key=str.lower)

        if block_lines != sorted_lines:
            # Find the first line that breaks the order
            for j in range(min(len(block_lines), len(sorted_lines))):
                if block_lines[j].lower() != sorted_lines[j].lower():
                    failures.append(Failure(
                        filename,
                        block_line_numbers[j],
                        f"Alphabetical ordering violation: '{block_lines[j]}' should come after '{sorted_lines[j-1] if j > 0 else '...'}'"
                    ))
                    break
            else:
                # If all lines up to the min length are the same, but the lengths are different
                if len(block_lines) > len(sorted_lines):
                    failures.append(Failure(
                        filename,
                        block_line_numbers[len(sorted_lines)],
                        "Alphabetical ordering violation: extra line at the end of block"
                    ))

    return failures

def main():
    # First, we check the required files for markers
    marker_failures = []
    for required_file in REQUIRED_FILES:
        marker_failures.extend(check_markers_presence(required_file))

    if marker_failures:
        for failure in marker_failures:
            print_error(failure.message, failure.filename, failure.lineno)

        print_error("Some required files are missing alphabetical sorting markers!")
        sys.exit(1)

    if len(sys.argv) > 1:
        files_to_check = sys.argv[1:]
    else:
        files_to_check = REQUIRED_FILES

    all_failures = []
    checked_files = []

    for file_to_check in files_to_check:
        if not os.path.isfile(file_to_check):
            all_failures.append(Failure(file_to_check, 0, f"File not found: {file_to_check}"))
            continue

        checked_files.append(file_to_check)
        sort_failures = check_alphabetical_sort(file_to_check)
        all_failures.extend(sort_failures)

    if all_failures:
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)

        print_error(f"Found {len(all_failures)} alphabetical sorting violation(s)!")
        print_error("Please ensure all lines between // START OF ALPHABETICAL SORTING and // END OF ALPHABETICAL SORTING are properly sorted!")
        sys.exit(1)
    else:
        print(f"{GREEN}All alphabetical sorting blocks are properly sorted in {len(checked_files)} file(s)!{NC}")
        print(f"{BLUE}Checked files:{NC}")
        for checked_file in checked_files:
            print(f"    - {checked_file}")

if __name__ == "__main__":
    main()
