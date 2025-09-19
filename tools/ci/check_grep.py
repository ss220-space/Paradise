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
NC = "\033[0m"  # No Color

def print_error(message: str, filename: str, line_number: int):
    if os.getenv("GITHUB_ACTIONS") == "true": # We're on github, output in a special format.
        print(f"::error file={filename},line={line_number},title=Check Grep::{filename}:{line_number}: {RED}{message}{NC}")
    else:
        print(f"{filename}:{line_number}: {RED}{message}{NC}")

# Сheck for non-TGM map format
NON_TGM_MAP_FORMAT = re.compile(r'^\".+\" = \(.+\)')
def check_non_tgm_map_format(idx, line):
    if NON_TGM_MAP_FORMAT.search(line):
        return [(idx + 1, "Non-TGM formatted map detected. Please convert it using Map Merger!")]

NANOTRASEN_CAMEL_CASE_EN = re.compile(r"NanoTrasen")
NANOTRASEN_CAMEL_CASE_RU = re.compile(r"НаноТрейзен")
NANOTRASEN_MISSPELLING_N_RU = re.compile(r"нанотрейзен")
def check_nanotrasen_style(idx, line):
    failures = []
    if NANOTRASEN_CAMEL_CASE_EN.search(line):
        failures.append((idx + 1, "'Nanotrasen' should not be spelled in the camel case form."))
    if NANOTRASEN_CAMEL_CASE_RU.search(line):
        failures.append((idx + 1, "'Нанотрейзен' should not be spelled in the camel case form."))
    # We use UNLINT here to avoid breaking TTS.
    if NANOTRASEN_MISSPELLING_N_RU.search(line) and 'UNLINT' not in line:
        failures.append((idx + 1, "'Нанотрейзен' should not be written with a lowercase letter."))
    return failures

CODE_CHECKS = [
    check_non_tgm_map_format,
    check_nanotrasen_style,
]

def lint_file(code_filepath: str) -> list[Failure]:
    all_failures = []
    with open(code_filepath, encoding="UTF-8") as code:
        last_line = None
        for idx, line in enumerate(code):
            for check in CODE_CHECKS:
                if failures := check(idx, line):
                    all_failures += [Failure(code_filepath, lineno, message) for lineno, message in failures]
            last_line = line

        if last_line and last_line[-1] != '\n':
            all_failures.append(Failure(code_filepath, idx + 1, "Missing a trailing newline."))
    return all_failures

if __name__ == "__main__":
    print("check_grep started")

    exit_code = 0
    start = time.time()

    dmm_files = glob.glob("**/*.dmm", recursive=True)

    if len(sys.argv) > 1:
        dmm_files = [sys.argv[1]]

    all_failures = []
    with ProcessPoolExecutor() as executor:
        for failures in executor.map(lint_file, dmm_files):
            all_failures += failures

    if all_failures:
        exit_code = 1
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)

    end = time.time()
    print(f"\ncheck_grep tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)
