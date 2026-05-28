"""
Script to find illegal empty square brackets "[]" inside strings in .dm files.

FAIL:
    - Any occurrence of "[]" inside a string literal (double quotes or multiline {} blocks)
    - Examples:
        var/a = "text [] text"
        var/b = "[] at start"
        var/c = {"
            line
            []
            another line
        "}
        call("argument with []")

PASS (not considered errors):
    - Brackets with content: "[text]"
    - Array literals outside strings: list(), [], [1,2,3]
    - Inside text(...) calls (DM formatting function)
    - Inside comments (// or /* */)
    - Escaped brackets

The parser tracks context: strings, comments, escape sequences, nested text() calls.
"""

import sys
from pathlib import Path

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"

def find_lone_arrays(src: str):
    """
    Scans the source code and returns a list of (line, column) positions
    where an illegal empty "[]" pair is found inside a string.
    """
    results = []

    # Parser state
    in_string = False          # inside a double-quoted string
    escaped = False            # previous char was a backslash
    in_text_call = False       # inside a text(...) call
    paren_depth = 0            # parenthesis nesting depth for text()
    in_line_comment = False    # inside a // line comment
    in_block_comment = False   # inside a /* */ block comment

    line = 1
    col = 0
    i = 0
    length = len(src)

    while i < length:
        ch = src[i]
        nxt = src[i + 1] if i + 1 < length else ""

        col += 1

        # Handle newline – reset line comment flag
        if ch == '\n':
            line += 1
            col = 0
            in_line_comment = False

        # ----- Comment handling -----
        if not in_string and not in_block_comment and not in_line_comment:
            if ch == '/' and nxt == '/':
                in_line_comment = True
                i += 2
                col += 1
                continue
            if ch == '/' and nxt == '*':
                in_block_comment = True
                i += 2
                col += 1
                continue

        if in_block_comment:
            if ch == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                col += 1
                continue
            i += 1
            continue

        if in_line_comment:
            i += 1
            continue

        # ----- Escaping -----
        if escaped:
            escaped = False
            i += 1
            continue

        if ch == '\\':
            escaped = True
            i += 1
            continue

        # ----- Detect text( call -----
        # Inside text() we ignore brackets because it may contain arbitrary code
        if not in_string and not in_text_call:
            if src.startswith("text(", i):
                in_text_call = True
                paren_depth = 1
                i += 5          # length of "text("
                col += 4
                continue

        # Skip everything inside text() until the closing parenthesis
        if in_text_call:
            if ch == '(':
                paren_depth += 1
            elif ch == ')':
                paren_depth -= 1
                if paren_depth == 0:
                    in_text_call = False
            i += 1
            continue

        # ----- String handling -----
        if ch == '"':
            in_string = not in_string
            i += 1
            continue

        # ----- Find illegal "[]" inside strings -----
        # Condition: we are inside a string, current char is '[', next is ']'
        if in_string and ch == '[' and nxt == ']':
            results.append((line, col))
            i += 2
            col += 1
            continue

        i += 1

    return results


def main():
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()

    if not root.exists():
        print(f"Path does not exist: {root}")
        sys.exit(2)

    violations = 0

    for dm_file in root.rglob("*.dm"):
        try:
            src = dm_file.read_text(encoding="utf-8", errors="replace")
        except Exception as e:
            print(f"[ERROR] {dm_file}: {e}")
            continue

        for line, col in find_lone_arrays(src):
            print(
                f"{RED}ERROR{NC}: {dm_file}:{line}:{col} "
                f"illegal [] inside string"
            )
            violations += 1

    if violations:
        print()
        print(
            f"{RED}ERROR:{NC} Found {violations} illegal unescaped [] occurrence(s). "
            "Please remove or escape them."
        )
        sys.exit(1)

    print(f"{GREEN}OK:{NC} No illegal [] found.")
    sys.exit(0)


if __name__ == "__main__":
    main()
