with open('web/members_form.html', 'r', encoding='utf-8') as f:
    content = f.read()

import re
scripts = re.findall(r'<script.*?>([\s\S]*?)<\/script>', content)
import subprocess, tempfile
all_ok = True
for i, s in enumerate(scripts):
    if not s.strip(): continue
    with tempfile.NamedTemporaryFile('w', suffix='.js', delete=False, encoding='utf-8') as tmp:
        tmp.write(s)
        tmp_name = tmp.name
    res = subprocess.run(['node', '--check', tmp_name], capture_output=True, text=True)
    if res.returncode != 0:
        print(f'Script {i} syntax error:', res.stderr)
        all_ok = False
    else:
        print(f'Script {i} syntax OK')
if all_ok:
    print("ALL SCRIPTS IN MEMBERS_FORM SYNTAX OK!")

