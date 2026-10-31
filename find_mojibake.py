import os, re

files = [
    'f:/TELEGRAMBOT/lib/contributor_handlers.dart',
    'f:/TELEGRAMBOT/lib/admin_handlers.dart',
    'f:/TELEGRAMBOT/lib/student_handlers.dart',
    'f:/TELEGRAMBOT/lib/strings.dart',
    'f:/TELEGRAMBOT/lib/utils.dart',
    'f:/TELEGRAMBOT/lib/firebase_db.dart'
]

for path in files:
    if not os.path.exists(path):
        continue
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
    bad_lines = []
    for line_no, line in enumerate(lines, start=1):
        if ('â' in line or 'ط§ظ' in line or 'ظ…ظ' in line or 'طھظ' in line or 
            'ط¹ظ' in line or 'ط­ط' in line or 'ط¥ظ' in line or 'ًں' in line):
            bad_lines.append((line_no, line.strip()))
    if bad_lines:
        print(f"=== {path} ({len(bad_lines)} lines with mojibake) ===")
        for ln, l in bad_lines:
            print(f"{ln}: {l}")

