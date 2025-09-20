import sys
import re

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def annotate(raw_output):
    print("::group::OpenDream Output")
    print(raw_output)
    print("::endgroup::")

    ansi_escape = re.compile(r'(?:\x1B[@-_]|[\x80-\x9F])[0-?]*[ -/]*[@-~]')
    clean_output = ansi_escape.sub('', raw_output)

    failures_detected = False
    expected_failure_case_detected = False

    pattern = r'^\s*(?P<type>Error|Warning) (?P<errorcode>OD\d+) at (?P<filename>.+?):(?P<line>\d+):(?P<column>\d+):\s*(?P<message>.*)$'
    internal_pattern = r'^\s*(?P<type>Error|Warning) (?P<errorcode>OD\d+) at <internal>:\s*(?P<message>.*)$'

    print("OpenDream Code Annotations:")
    for line in clean_output.splitlines():
        if not line.strip() or "Compilation failed with" in line:
            continue

        match = re.match(pattern, line)
        if match:
            groups = match.groupdict()
            filename = groups['filename']
            line_num = groups['line']
            column = groups['column']
            message = groups['message']
            error_type = groups['type']
            error_code = groups['errorcode']
        else:
            match = re.match(internal_pattern, line)
            if match:
                groups = match.groupdict()
                message = groups['message']
                error_type = groups['type']
                error_code = groups['errorcode']
                filename = None
                line_num = None
                column = None
            else:
                continue

        if message == "Unimplemented proc & var warnings are currently suppressed":
            message += " (This is expected and can be ignored)"
            expected_failure_case_detected = True

        if error_type == "Error":
            failures_detected = True

        error_string = f"{error_code}: {message}"

        if filename is not None:
            print(f"::{error_type} file={filename},line={line_num},col={column}::{error_string}")
        else:
            print(f"::{error_type} file=,line=,col=::{error_string}")

    if failures_detected:
        sys.exit(1)

    if not expected_failure_case_detected:
        print(red("Failed to detect the expected failure case! If you have recently changed how we work with OpenDream Pragmas, please fix the od_annotator script!"))
        sys.exit(1)

    print(green("No OpenDream issues found!"))

def main():
    annotate(sys.stdin.read())

if __name__ == "__main__":
    main()
