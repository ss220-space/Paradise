import os
import re

TARGET_DIR = r"E:\GitHub\Parashiza\code"
PAPER_VARS = r'(?:P|p|paper|slip|reqform|form|report|ch|ref|transcript|printout|Joke|pinned_paper|monitor_key|R|T|paperaffected)'

HTML_TO_MD = [
    (r'<br\s*/?>', r'\\n'),
    (r'<hr\s*/?>', r'\\n---\\n'),
    (r'</?(?:b|strong)>', r'**'),
    (r'</?(?:i|em)>', r'*'),
    (r'<h1>(.*?)</h1>', r'\\n# \1\\n'),
    (r'<h2>(.*?)</h2>', r'\\n## \1\\n'),
    (r'<h3>(.*?)</h3>', r'\\n### \1\\n'),
    (r'<li>', r'- '),
    (r'</li>', r'\\n'),
    (r'</?ul>', r''),
    (r'<div[^>]*>', r''),
    (r'</div>', r'\\n'),
    (r'&emsp;', r'    '),
    (r'&deg;', r'°'),
]

def convert_string_html(line):
    for pattern, repl in HTML_TO_MD:
        line = re.sub(pattern, repl, line, flags=re.IGNORECASE)
    return line

def process_file(filepath):
    if filepath.endswith(r'paperwork\paper.dm'):
        return False

    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    new_lines = []
    modified = False

    for line in lines:
        orig_line = line

        # 1. Замена var.header/info/footer = или += на var.add_raw_text(...)
        m = re.match(rf'^(\s*)({PAPER_VARS})\.(?:header|info|footer)\s*\+?=\s*(.+)$', line)
        if m:
            indent, var_name, expr = m.groups()
            expr = convert_string_html(expr)
            line = f"{indent}{var_name}.add_raw_text({expr})\n"

        # 2. Замена оставшихся info = / info_links = в дефайнах объектов (руины, сейфы, компы)
        elif re.match(r'^\s*info\s*\+?=\s*.+$', line):
            line = re.sub(r'^(\s*)info\s*\+?=\s*(.+)$', lambda x: f"{x.group(1)}default_raw_text = {convert_string_html(x.group(2))}", line)
        elif re.match(r'^\s*info_links\s*\+?=\s*.+$', line):
            line = re.sub(r'^(\s*)', r'\1// ', line)

        # 3. Замена .info_links у переменных
        elif re.search(rf'\b({PAPER_VARS})\.info_links\b', line):
            line = re.sub(r'^(\s*)', r'\1// ', line)

        # 4. Замена .show_content(...) -> .ui_interact(...)
        elif re.search(rf'\b({PAPER_VARS})\.show_content\(', line):
            line = re.sub(rf'\b({PAPER_VARS})\.show_content\(([^,)]+).*?\)', r'\1.ui_interact(\2)', line)

        # 5. Замена .clearpaper() -> .clear_paper()
        elif re.search(rf'\b({PAPER_VARS})\.clearpaper\(\)', line):
            line = re.sub(rf'\b({PAPER_VARS})\.clearpaper\(\)', r'\1.clear_paper()', line)

        # 6. Устаревшие вызовы populatefields / updateinfolinks
        elif re.search(rf'\b({PAPER_VARS})\.(?:populatefields|updateinfolinks)\(\)', line):
            line = re.sub(rf'\b({PAPER_VARS})\.(?:populatefields|updateinfolinks)\(\)', r'\1.update_appearance()', line)

        if line != orig_line:
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
