import os
import subprocess
import markdown
import sys

def convert_md_to_pdf(md_file):
    base_name = os.path.splitext(md_file)[0]
    html_file = base_name + ".html"
    pdf_file = base_name + ".pdf"
    
    # Read MD
    with open(md_file, "r", encoding="utf-8") as f:
        text = f.read()
    
    # Convert to HTML with basic styles
    html_body = markdown.markdown(text, extensions=['tables', 'fenced_code'])
    html_content = f"""
    <!DOCTYPE html>
    <html lang="ar" dir="rtl">
    <head>
        <meta charset="utf-8">
        <style>
            body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 40px; line-height: 1.6; }}
            h1, h2, h3 {{ color: #2c3e50; }}
            table {{ border-collapse: collapse; width: 100%; margin-bottom: 20px; }}
            th, td {{ border: 1px solid #ddd; padding: 8px; text-align: right; }}
            th {{ background-color: #f2f2f2; }}
            code {{ background-color: #f8f9fa; padding: 2px 4px; border-radius: 4px; font-family: Consolas, monospace; }}
            pre {{ background-color: #f8f9fa; padding: 15px; border-radius: 4px; overflow-x: auto; direction: ltr; text-align: left; }}
            pre code {{ background-color: transparent; padding: 0; }}
            blockquote {{ border-right: 4px solid #ccc; margin: 0; padding-right: 15px; color: #666; }}
        </style>
    </head>
    <body>
        {html_body}
    </body>
    </html>
    """
    
    with open(html_file, "w", encoding="utf-8") as f:
        f.write(html_content)
    
    # Find Edge or Chrome
    browser_paths = [
        r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
        r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files\Google\Chrome\Application\chrome.exe"
    ]
    
    browser_path = None
    for p in browser_paths:
        if os.path.exists(p):
            browser_path = p
            break
            
    if not browser_path:
        print("Could not find Edge or Chrome")
        sys.exit(1)
        
    abs_html = os.path.abspath(html_file)
    abs_pdf = os.path.abspath(pdf_file)
    
    print(f"Generating {pdf_file} using {browser_path}...")
    subprocess.run([browser_path, "--headless", "--disable-gpu", f"--print-to-pdf={abs_pdf}", abs_html], check=True)
    print(f"Successfully generated {pdf_file}")
    
    # Cleanup html
    try:
        os.remove(html_file)
    except:
        pass

if __name__ == "__main__":
    for file in ["bot_documentation.md", "dashboard_documentation.md"]:
        if os.path.exists(file):
            convert_md_to_pdf(file)
        else:
            print(f"File not found: {file}")
