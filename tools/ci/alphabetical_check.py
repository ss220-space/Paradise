import os
import sys
from collections import namedtuple
from pathlib import Path

Failure = namedtuple("Failure", ["filename", "lineno", "message"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"

DIRECTORIES_TO_CHECK = [
    'strings/',
]

def print_error(message, filename=None, line_number=None):
    """Print error with GitHub Actions formatting support."""
    if os.getenv("GITHUB_ACTIONS") == "true":
        location_parts = []
        if filename:
            location_parts.append(f"file={filename}")
        if line_number:
            location_parts.append(f"line={line_number}")
        location = ",".join(location_parts)
        print(f"::error {location},title=Alphabetical Sort Check::{message}")
    else:
        location = f"{filename}:{line_number}:" if filename and line_number else f"{filename}:" if filename else ""
        print(f"{location} {RED}{message}{NC}")

def find_txt_files():
    """Find all .txt files in specified directories and subdirectories."""
    txt_files = []
    for directory in DIRECTORIES_TO_CHECK:
        path = Path(directory)
        if path.exists():
            txt_files.extend(path.rglob("*.txt"))
        else:
            print(f"{RED}Directory not found: '{directory}'.{NC}")
    return txt_files

def check_alphabetical_sort(filename):
    """Check if all non-empty lines are alphabetically sorted."""
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            lines = [line.strip() for line in file if line.strip()]
    except Exception as e:
        return [Failure(str(filename), None, f"Error reading file: {e}")]

    # Early return for empty files or single line files
    if len(lines) <= 1:
        return []

    # Check sorting in single pass
    for i in range(1, len(lines)):
        if lines[i].lower() < lines[i-1].lower():
            return [Failure(str(filename), None, f"File is not sorted alphabetically.")]

    return []

def main():
    txt_files = find_txt_files()

    if not txt_files:
        print(f"{BLUE}No .txt files found in specified directories.{NC}")
        return

    print(f"{BLUE}Checking {len(txt_files)} files...{NC}")

    all_failures = []
    for file_path in txt_files:
        all_failures.extend(check_alphabetical_sort(file_path))

    if all_failures:
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)
        print(f"{RED}Alphabetical sorting check failed!{NC}")
        sys.exit(1)

    print(f"{GREEN}All files are properly sorted alphabetically!{NC}")

if __name__ == "__main__":
    main()
