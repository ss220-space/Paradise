import os
import sys
from collections import namedtuple
from pathlib import Path

Failure = namedtuple("Failure", ["filename", "lineno", "message"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"

START_MARKER = "// START OF ALPHABETICAL SORTING"
END_MARKER = "// END OF ALPHABETICAL SORTING"

REQUIRED_FILES = [
    'code/tests/game_tests.dm',
    'code/_globalvars/lists/names.dm',
]

def find_txt_files(directory):
    """Find all .txt files in directory and subdirectories using pathlib."""
    if not os.path.exists(directory):
        return []
    return [str(p) for p in Path(directory).rglob("*.txt")]

def print_error(message, filename=None, line_number=None):
    """Print error with GitHub Actions formatting support."""
    if os.getenv("GITHUB_ACTIONS") == "true":
        location = f"file={filename},line={line_number}" if filename and line_number else f"file={filename}" if filename else ""
        print(f"::error {location},title=Alphabetical Sort Check::{message}")
    else:
        location = f"{filename}:{line_number}:" if filename and line_number else f"{filename}:" if filename else ""
        print(f"{location} {RED}{message}{NC}")

def get_file_content_lines(filename):
    """Read file and return lines with error handling."""
    if not os.path.isfile(filename):
        return None, [Failure(filename, 0, f"File not found: {filename}")]

    try:
        with open(filename, 'r', encoding='utf-8') as file:
            return file.readlines(), []
    except Exception as e:
        return None, [Failure(filename, 0, f"Error reading file: {e}")]

def extract_marker_block(lines):
    """Extract lines between START and END markers."""
    inside_block = False
    block_lines = []
    block_line_numbers = []
    failures = []

    for i, line in enumerate(lines, 1):
        stripped_line = line.strip()

        if START_MARKER in stripped_line:
            if inside_block:
                failures.append(Failure(None, i, "Found nested start marker"))
            inside_block = True
            continue

        if END_MARKER in stripped_line:
            if not inside_block:
                failures.append(Failure(None, i, "Found end marker without start marker"))
            else:
                inside_block = False
            continue

        if inside_block and stripped_line and not stripped_line.startswith("//"):
            block_lines.append(stripped_line)
            block_line_numbers.append(i)

    if inside_block:
        failures.append(Failure(None, len(lines), "Unclosed alphabetical sorting block"))

    return block_lines, block_line_numbers, failures

def extract_all_content(lines):
    """Extract all non-empty, non-comment lines."""
    content_lines = []
    content_line_numbers = []

    for i, line in enumerate(lines, 1):
        stripped_line = line.strip()
        if stripped_line and not stripped_line.startswith(("//", "#")):
            content_lines.append(stripped_line)
            content_line_numbers.append(i)

    return content_lines, content_line_numbers

def check_sorting(block_lines, line_numbers, filename):
    """Check if lines are alphabetically sorted."""
    if not block_lines:
        return []

    sorted_lines = sorted(block_lines, key=str.lower)
    if block_lines == sorted_lines:
        return []

    # Find first mismatch
    for i, (current, expected) in enumerate(zip(block_lines, sorted_lines)):
        if current.lower() != expected.lower():
            prev_line = sorted_lines[i-1] if i > 0 else '...'
            return [Failure(
                filename,
                line_numbers[i],
                f"Alphabetical ordering violation: '{current}' should come after '{prev_line}'"
            )]

    return [Failure(filename, line_numbers[len(sorted_lines)], "Extra line at end of block")]

def check_file_alphabetical(filename, use_markers=True):
    """Check alphabetical sorting of file content."""
    lines, failures = get_file_content_lines(filename)
    if failures:
        return failures

    if use_markers:
        block_lines, line_numbers, marker_failures = extract_marker_block(lines)
        failures.extend(f for f in marker_failures if f.filename is not None)
        # Update filename for marker failures
        marker_failures = [Failure(filename, f.lineno, f.message) for f in marker_failures if f.filename is None]
        failures.extend(marker_failures)
    else:
        block_lines, line_numbers = extract_all_content(lines)

    if not failures:
        failures.extend(check_sorting(block_lines, line_numbers, filename))

    return failures

def main():
    strings_dir = "strings/"
    strings_txt_files = find_txt_files(strings_dir)

    if not strings_txt_files:
        print(f"{BLUE}Note: No .txt files found in '{strings_dir}'{NC}")

    # Determine files to check
    files_to_check = sys.argv[1:] if len(sys.argv) > 1 else REQUIRED_FILES + strings_txt_files

    all_failures = []
    checked_files = []

    for file_to_check in files_to_check:
        if not os.path.isfile(file_to_check):
            all_failures.append(Failure(file_to_check, 0, f"File not found: {file_to_check}"))
            continue

        checked_files.append(file_to_check)

        # Use markerless check for .txt files in strings directory
        use_markers = file_to_check not in strings_txt_files
        failures = check_file_alphabetical(file_to_check, use_markers)
        all_failures.extend(failures)

    # Report results
    if all_failures:
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)

        print_error(f"Found {len(all_failures)} alphabetical sorting violation(s)!")

        if any(f.filename in strings_txt_files for f in all_failures):
            print_error("Please ensure all .txt files in strings/ directory are properly sorted!")
        if any(f.filename not in strings_txt_files for f in all_failures):
            print_error("Please ensure all lines between sort markers are properly sorted!")

        sys.exit(1)
    else:
        print(f"{GREEN}All files are properly sorted!{NC}")
        print(f"{BLUE}Checked {len(checked_files)} files.{NC}")
        #for checked_file in checked_files:
        #    check_type = "full file" if checked_file in strings_txt_files else "marker-based"
        #    print(f"  - {checked_file} ({check_type} check)")

if __name__ == "__main__":
    main()
