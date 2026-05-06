import sys, os, re, argparse
from dataclasses import dataclass, field
from typing import List, Optional
import jinja2
from avulto import DME

@dataclass
class AdminVerb:
    readable_name: str
    description: str
    category: str
    visibility_flag: Optional[str] = None
    readable_permissions: List[str] = field(default_factory=list)

RE_DEFINE_SHIFT = re.compile(r'#define\s+(R_\w+)\s+\(?\s*1<<(\d+)\s*\)?')
RE_DEFINE_NUMERIC = re.compile(r'#define\s+(R_\w+)\s+(\d+|0x[0-9a-fA-F]+)')
RE_DEFINE_NAME = re.compile(r'#define\s+(R_\w+_NAME)\s+"([^"]*)"')

def _parse_macros_from_text(text, bit_macros, name_macros, lines):
    for m in RE_DEFINE_NAME.finditer(text):
        name_macros[m.group(1)] = m.group(2)
    for m in RE_DEFINE_SHIFT.finditer(text):
        bit_macros[m.group(1)] = 1 << int(m.group(2))
        lines.append(m.group(0).strip())
    for m in RE_DEFINE_NUMERIC.finditer(text):
        macro = m.group(1)
        if macro not in bit_macros:
            val = m.group(2)
            try:
                bit_macros[macro] = int(val, 16) if val.lower().startswith('0x') else int(val)
                lines.append(m.group(0).strip())
            except ValueError:
                pass

def parse_macros(dme_path):
    root = os.path.dirname(os.path.abspath(dme_path))
    includes, bit_macros, name_macros, r_macro_lines = [], {}, {}, []
    try:
        with open(dme_path, encoding='utf-8', errors='ignore') as f:
            dme_text = f.read()
    except Exception:
        dme_text = ""
    for line in dme_text.splitlines():
        code = line.split('//')[0].strip()
        m = re.match(r'#include\s+"([^"]+)"', code)
        if m:
            abs_path = os.path.normpath(os.path.join(root, m.group(1)))
            if os.path.isfile(abs_path):
                includes.append(abs_path)
    _parse_macros_from_text(dme_text, bit_macros, name_macros, r_macro_lines)
    for filepath in includes:
        try:
            with open(filepath, encoding='utf-8', errors='ignore') as f:
                _parse_macros_from_text(f.read(), bit_macros, name_macros, r_macro_lines)
        except Exception:
            continue
    if not bit_macros:
        print("\n[!] No R_* bit macros found.")
        if r_macro_lines:
            print("   Sample lines:"); [print(f"    {l}") for l in r_macro_lines[:10]]
    return bit_macros, name_macros

def extract_permissions_from_map(root, bit_macros, name_macros):
    path = os.path.join(root, "code", "_globalvars", "lists", "permissions.dm")
    if not os.path.isfile(path):
        print(f"Permissions file not found: {path}"); return {}
    try:
        with open(path, encoding='utf-8', errors='ignore') as f:
            text = f.read()
    except Exception:
        return {}
    m = re.search(r'GLOBAL_LIST_INIT\s*\(\s*permissions_name_to_flag\s*,\s*list\s*\((.*?)\)\s*\)', text, re.DOTALL)
    if not m:
        print(f"No permissions list found in {path}"); return {}
    perms = {}
    for name_m, bit_m in re.findall(r'(R_\w+_NAME)\s*=\s*(R_\w+)', m.group(1)):
        if bit_m in bit_macros and name_m in name_macros:
            perms[bit_macros[bit_m]] = name_macros[name_m]
    return perms

def _safe(td, name, default=None):
    try:
        v = td.var_decl(name).const_val
        return str(v) if v is not None else default
    except Exception:
        return default

def collect_admin_verbs(dme, perms_map):
    sorted_perms = sorted(perms_map.items(), key=lambda kv: kv[1])
    verbs = []
    for path in dme.subtypesof("/datum/admin_verb"):
        td = dme.types[path]
        try:
            raw = int(td.var_decl("permissions").const_val or 0)
        except Exception:
            raw = 0
        verbs.append(AdminVerb(
            readable_name=_safe(td, "name", "<unnamed>"),
            description=_safe(td, "description", ""),
            category=_safe(td, "category", "Hidden"),
            visibility_flag=_safe(td, "visibility_flag", None),
            readable_permissions=[name for bit, name in sorted_perms if raw & bit]
        ))
    return verbs

HTML_TEMPLATE = """\
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="utf-8">
<title>Admin Verbs</title>
<style>
    h1 {
        text-align: center;
        margin: 20px 0 10px;
    }
    table {
        border-collapse: collapse;
        width: 90%;
        max-width: 1200px;
        margin: 0 auto;
        table-layout: fixed;
    }
    th, td {
        border: 1px solid #ccc;
        padding: 2px 6px;
        font-size: 0.85em;
        text-align: center;
        vertical-align: middle;
        word-wrap: break-word;
        overflow-wrap: break-word;
    }
    th {
        background: #eee;
    }
    th:nth-child(1), td:nth-child(1) { width: 15%; }
    th:nth-child(2), td:nth-child(2) { width: 20%; }
    th:nth-child(3), td:nth-child(3) { width: 30%; }
    th:nth-child(4), td:nth-child(4) { width: 25%; }
    th:nth-child(5), td:nth-child(5) { width: 10%; }
</style>
</head>
<body>
<h1>Admin Verbs ({{ total_verbs }})</h1>
<table>
<tr><th>Категория</th><th>Название</th><th>Описание</th><th>Права</th><th>Видимость</th></tr>
{% for verb in verbs %}
<tr>
<td>{{ verb.category }}</td>
<td><strong>{{ verb.readable_name }}</strong></td>
<td>{{ verb.description }}</td>
<td>{% for perm in verb.readable_permissions %}{{ perm }}{% if not loop.last %}, {% endif %}{% endfor %}</td>
<td>{{ verb.visibility_flag or '' }}</td>
</tr>
{% endfor %}
</table>
</body>
</html>
"""

def main(dme_path, out_dir):
    dme = DME.from_file(dme_path, parse_procs=True)
    root = os.path.dirname(os.path.abspath(dme_path))
    bit_macros, name_macros = parse_macros(dme_path)
    if not bit_macros: sys.exit(1)
    perms_map = extract_permissions_from_map(root, bit_macros, name_macros)
    if not perms_map: sys.exit(1)
    verbs = collect_admin_verbs(dme, perms_map)
    verbs.sort(key=lambda v: (v.category, v.readable_name))
    html = jinja2.Environment(autoescape=True).from_string(HTML_TEMPLATE).render(verbs=verbs, total_verbs=len(verbs))
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "admin_verbs.html")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(html)
    print(f"Report saved to {out_path}")

if __name__ == "__main__":
    p = argparse.ArgumentParser(
        prog="extract_admin_verbs",
        description="Generate an HTML report of all /datum/admin_verb subtypes.",
    )
    p.add_argument("--dme", default="paradise.dme", help="path to .dme (default: paradise.dme)")
    p.add_argument("--output", "-o", default="data", help="output directory (default: data)")
    args = p.parse_args()
    main(args.dme, args.output)
