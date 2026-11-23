import os
import re

TARGET_DIR = r"E:\GitHub\Parashiza\code"

REPLACEMENTS = [
    (r'\[b\](.*?)\[/b\]', r'**\1**'),
    (r'\[i\](.*?)\[/i\]', r'*\1*'),
    (r'\[u\](.*?)\[/u\]', r'<u>\1</u>'),
    (r'\[h1\](.*?)\[/h1\]', r'\n# \1\n'),
    (r'\[h2\](.*?)\[/h2\]', r'\n## \1\n'),
    (r'\[h3\](.*?)\[/h3\]', r'\n### \1\n'),
    (r'\[center\](.*?)\[/center\]', r'<center>\1</center>'),
    (r'\[br\]', r'\n'),
    (r'\[hr\]', r'\n---\n'),
    (r'\[list\]', r''),
    (r'\[/list\]', r''),
    (r'\[\*\]', r'- '),
    (r'\[field\]', r'[____]'),
    (r'\[large\](.*?)\[/large\]', r'**\1**'),
    (r'\[small\](.*?)\[/small\]', r'\1'),
    (r'\[logo\]', r''),
]

def convert_pencode(text):
    for pattern, repl in REPLACEMENTS:
        text = re.sub(pattern, repl, text, flags=re.IGNORECASE | re.DOTALL)
    return text

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    if '/obj/item/paper' not in content and 'info =' not in content:
        return False

    lines = content.splitlines(keepends=True)
    new_lines = []
    in_paper_block = False
    modified = False

    for line in lines:
        stripped = line.strip()
        if stripped.startswith('/obj/item/paper'):
            in_paper_block = True
        elif stripped.startswith('/') and not stripped.startswith('//') and not stripped.startswith('/*'):
            in_paper_block = False

        if in_paper_block:
            if re.match(r'^\s*info\s*=', line):
                line = re.sub(r'^(\s*)info(\s*=)', r'\1default_raw_text\2', line)
                line = convert_pencode(line)
                modified = True
            elif re.match(r'^\s*(header|footer|language|time|signfont|deffont|paper_width|paper_height)\s*=', line):
                line = re.sub(r'^(\s*)', r'\1// ', line)
                modified = True
            elif 'populatefields()' in line:
                line = re.sub(r'^(\s*)', r'\1// ', line)
                modified = True
            elif 'default_raw_text' in line or ']' in line:
                converted = convert_pencode(line)
                if converted != line:
                    line = converted
                    modified = True

        new_lines.append(line)

    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
    return modified

count = 0
for root, _, files in os.walk(TARGET_DIR):
    for file in files:
        if file.endswith('.dm'):
            if process_file(os.path.join(root, file)):
                count += 1

print(f"Обновлено файлов: {count}")
