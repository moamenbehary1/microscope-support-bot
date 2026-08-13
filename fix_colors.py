import re

with open('web/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace hardcoded whites with var(--surface) or var(--bg)
content = re.sub(r'background:\s*(#fff|white|#ffffff);', r'background:var(--surface);', content)
content = re.sub(r'background-color:\s*(#fff|white|#ffffff);', r'background-color:var(--surface);', content)

# Remove any hardcoded #000 or black color
content = re.sub(r'color:\s*(#000|black|#000000);', r'color:var(--text);', content)

# Sidebar and header background overrides (they used rgba with specific colors)
content = re.sub(r'background:rgba\(15, 21, 37, 0\.7\);', r'background:var(--surface2);', content)
content = re.sub(r'background:rgba\(15, 21, 37, 0\.6\);', r'background:var(--surface);', content)
content = re.sub(r'background:radial-gradient\(circle at top right, #1a153a, #090d16 60%\);', r'background:var(--bg);', content)

with open('web/index.html', 'w', encoding='utf-8') as f:
    f.write(content)
print("Color fix applied.")
