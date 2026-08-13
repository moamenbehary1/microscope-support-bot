import re

with open('web/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update HTML tag
content = content.replace('<html lang="en">', '<html lang="ar" dir="rtl">')

# 2. Update CSS for RTL and sidebar
content = re.sub(r'left:0;top:0;bottom:0;', r'right:0;top:0;bottom:0;', content) # Sidebar position
content = re.sub(r'#main\{margin-left:var\(--sidebar\)', r'#main{margin-right:var(--sidebar)', content)
content = re.sub(r'border-right:1px solid var\(--border\)', r'border-left:1px solid var(--border)', content)
content = re.sub(r'border-left:3px solid transparent;', r'border-right:3px solid transparent;', content)
content = re.sub(r'border-radius:0 8px 8px 0;margin-right:8px', r'border-radius:8px 0 0 8px;margin-left:8px', content)
content = re.sub(r'margin-left:auto;', r'margin-right:auto;', content) # #req-badge
content = re.sub(r'border-left-color:var\(--primary\)', r'border-right-color:var(--primary)', content)
content = re.sub(r'linear-gradient\(90deg', r'linear-gradient(-90deg', content)

# 3. Fix Dark Mode global style
# The user wants dark mode to affect everything. 
# Currently: [data-theme="light"] overrides some vars. But we need it on <body>.
# Wait, they are on :root. `document.documentElement.setAttribute('data-theme', theme)` applies to :root.
# Let's ensure the toggle function sets it correctly.

# 4. Translations
translations = {
    '🔬 Microscope Bot — Admin Panel': '🔬 بوت الميكروسكوب — لوحة التحكم',
    '>Overview<': '>نظرة عامة<',
    '>Bot Config<': '>إعدادات البوت<',
    '>Curriculum<': '>المناهج<',
    '>Upload Material<': '>رفع ملف<',
    '>Pending Contributions<': '>المساهمات المعلقة<',
    '>Logout<': '>تسجيل خروج<',
    '>Total Users<': '>إجمالي المستخدمين<',
    '>Materials<': '>إجمالي الملفات<',
    '>Active Tracks<': '>المسارات النشطة<',
    '>Recent Actions<': '>آخر الإجراءات<',
    '>Add New Track<': '>إضافة مسار<',
    'placeholder="Search curriculum..."': 'placeholder="بحث في المناهج..."',
    '>Bot Configuration<': '>إعدادات البوت الأساسية<',
    '>Super Admin ID<': '>أيدي المدير الأساسي (Super Admin)<',
    '>Backup Channel ID<': '>أيدي قناة النسخ الاحتياطي<',
    '>WhatsApp Support Number<': '>رقم دعم الواتساب<',
    '>Save Configuration<': '>حفظ الإعدادات<',
    '>No pending materials.<': '>لا يوجد ملفات معلقة.<',
    '>Accept<': '>قبول<',
    '>Reject<': '>رفض<',
    '>Delete<': '>حذف<',
    '>Move<': '>نقل<',
    '>Upload<': '>رفع<',
    '>Cancel<': '>إلغاء<',
    '>No materials<': '>لا توجد مواد<',
    '>Admin Dashboard<': '>لوحة تحكم المشرف<'
}

for eng, ar in translations.items():
    content = content.replace(eng, ar)

with open('web/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("Update complete")
