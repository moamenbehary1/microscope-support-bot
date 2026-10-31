import re

with open('f:/TELEGRAMBOT/lib/contributor_handlers.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines, 1):
    if 'â' in line or 'ط§ظ' in line or 'ظ†ط' in line or 'ط­ط' in line or 'ط¥ظ' in line:
        print(f"{i}: {line.strip()}")

