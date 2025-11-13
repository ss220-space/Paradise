from avulto import DME
from collections import namedtuple
import os
import sys
import time

Failure = namedtuple("Failure", ["filename", "lineno", "message"])

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"

def print_error(message: str, filename: str, line_number: int):
    if os.getenv("GITHUB_ACTIONS") == "true":
        print(f"::error file={filename},line={line_number},title=Forbidden ru_names variable::{filename}:{line_number}: {message}")
    else:
        print(f"{filename}:{line_number}: {message}")

def main():
    print("ru_names check started")
    exit_code = 0
    start = time.time()

    dme = DME.from_file("paradise.dme")
    all_failures = []

    atom_descendants = dme.subtypesof("/atom")

    atom_descendants.append(dme.type_decl("/atom").path)

    for path in atom_descendants:
        typepath = dme.type_decl(path)

        for variable_name in typepath.var_names(modified=True):
            if variable_name == "ru_names":
                all_failures.append(Failure(
                    typepath.source_loc.file_path,
                    typepath.source_loc.line,
                    f"{RED}{path}{NC} has forbidden variable: {RED}ru_names{NC}. Use get_ru_names() proc instead."
                ))

    all_failures.sort(key=lambda x: (x.filename, x.lineno))

    if all_failures:
        exit_code = 1
        for failure in all_failures:
            print_error(failure.message, failure.filename, failure.lineno)

    end = time.time()
    print(f"ru_names check completed in {end - start:.2f}s")
    print(f"Found {len(all_failures)} errors\n")

    sys.exit(exit_code)

if __name__ == "__main__":
    main()
