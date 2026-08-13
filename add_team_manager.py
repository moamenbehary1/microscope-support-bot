import re

with open('web/index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# 1. Add Sidebar Toggle CSS & JS
if '.sidebar-collapsed' not in html:
    css_injection = """
.sidebar-collapsed #sidebar { transform: translateX(100%); }
.sidebar-collapsed #main { margin-right: 0 !important; }
@media(max-width:768px){
  #sidebar { transform: translateX(100%); }
  #main { margin-right: 0 !important; }
  .sidebar-collapsed #sidebar { transform: translateX(0); }
}
"""
    html = html.replace('</style>', css_injection + '</style>')
    
    # Add toggle button in header
    toggle_btn = """<button class="btn btn-icon" onclick="document.body.classList.toggle('sidebar-collapsed')" style="background:transparent;border:none;font-size:1.2rem;cursor:pointer;color:var(--text)">☰</button>"""
    html = html.replace('<div id="header">', f'<div id="header">\n  {toggle_btn}')

# 2. Add 'إدارة الفريق' (Team Management) to sidebar
if 'page-team' not in html:
    sidebar_item = """
      <div class="nav-sep"></div>
      <div class="nav-item" onclick="S.nav('page-team')">
        <span class="icon">👥</span> إدارة الفريق
      </div>
"""
    html = html.replace('<!-- End Navigation -->', sidebar_item + '<!-- End Navigation -->')

# 3. Add 'Master Settings' to Bot Config page
if 'Master Settings' not in html and 'إعدادات متقدمة' not in html:
    master_settings_html = """
    <hr style="border-color:var(--border); margin: 24px 0;">
    <h3 style="margin-bottom:16px;">إعدادات أخرى (Master Settings)</h3>
    <div style="display:flex;gap:12px;margin-bottom:20px;">
      <button class="btn" onclick="alert('سيتم إضافة هذه الميزة قريباً')">إعدادات متقدمة 1</button>
      <button class="btn" onclick="alert('سيتم إضافة هذه الميزة قريباً')">إعدادات متقدمة 2</button>
      <button class="btn" style="background:var(--accent);border-color:var(--accent)" onclick="S.nav('page-team')">الانتقال لإدارة الفريق</button>
    </div>
"""
    # Find the end of page-config inner HTML
    html = html.replace('</div>\n    </div>\n  </div>\n\n  <!-- ── 3) Curriculum ── -->', master_settings_html + '</div>\n    </div>\n  </div>\n\n  <!-- ── 3) Curriculum ── -->')

# 4. Add Team Management Page
if 'page-team' not in html or 'id="page-team"' not in html:
    team_page = """
  <!-- ── 5) Team Management ── -->
  <div id="page-team" class="page">
    <div style="display:flex;justify-content:space-between;align-items:flex-end;margin-bottom:24px">
      <div>
        <h2 style="font-size:1.8rem;font-weight:700;margin-bottom:8px">👥 إدارة الفريق</h2>
        <p style="color:var(--dim)">إدارة أعضاء الفريق، الصلاحيات، وملفات العمل المشتركة.</p>
      </div>
      <div>
        <button class="btn" onclick="S.team.showInviteModal()" style="background:var(--success);border-color:var(--success)">+ دعوة عضو جديد</button>
      </div>
    </div>

    <div class="grid" style="grid-template-columns: 1fr; gap:24px">
      <div class="card" style="padding:24px">
        <h3 style="margin-bottom:16px;display:flex;align-items:center;gap:8px">👑 أعضاء الفريق الحاليين</h3>
        <div class="table-container" style="overflow-x:auto">
          <table class="table" style="width:100%;text-align:right;border-collapse:collapse">
            <thead>
              <tr style="border-bottom:1px solid var(--border);color:var(--dim)">
                <th style="padding:12px">الاسم</th>
                <th style="padding:12px">الدور (Role)</th>
                <th style="padding:12px">المنصب</th>
                <th style="padding:12px">تاريخ الانضمام</th>
                <th style="padding:12px">إجراءات</th>
              </tr>
            </thead>
            <tbody id="team-list-tbody">
              <!-- Rendered via JS -->
            </tbody>
          </table>
        </div>
      </div>

      <div class="card" style="padding:24px">
        <h3 style="margin-bottom:16px;display:flex;align-items:center;gap:8px">📁 ملفات التيم (مرفوعات خاصة)</h3>
        <div style="margin-bottom: 16px;">
          <input type="file" id="team-file-input" style="display:none">
          <button class="btn" onclick="document.getElementById('team-file-input').click()">+ رفع ملف للتيم</button>
        </div>
        <div class="table-container" style="overflow-x:auto">
          <table class="table" style="width:100%;text-align:right;border-collapse:collapse">
            <thead>
              <tr style="border-bottom:1px solid var(--border);color:var(--dim)">
                <th style="padding:12px">اسم الملف</th>
                <th style="padding:12px">الحجم</th>
                <th style="padding:12px">تاريخ الرفع</th>
                <th style="padding:12px">تحميل</th>
              </tr>
            </thead>
            <tbody id="team-files-tbody">
              <!-- Rendered via JS -->
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
"""
    html = html.replace('</div>\n  <!-- End Main -->', team_page + '</div>\n  <!-- End Main -->')

# 5. Add Modal for Invite / Form Creation
if 'invite-modal' not in html:
    invite_modal = """
<!-- Invite Modal -->
<div id="invite-modal" class="modal">
  <div class="modal-box">
    <div class="modal-hdr">
      <h3>إرسال دعوة لعضو جديد</h3>
      <button class="btn btn-icon" onclick="S.team.closeModal()">✖</button>
    </div>
    <div class="modal-bdy">
      <p style="margin-bottom:12px;color:var(--dim);font-size:0.9rem;">
        قم باختيار الصلاحيات والدور لإنشاء رابط دعوة. عندما يفتح العضو الرابط سيقوم بملء بياناته بنفسه وستتم إضافته فوراً.
      </p>
      <div class="form-group" style="margin-bottom:16px">
        <label>الدور (Role)</label>
        <select id="invite-role" class="input">
          <option value="Member">عضو (Member)</option>
          <option value="HR">الموارد البشرية (HR)</option>
          <option value="PR">العلاقات العامة (PR)</option>
          <option value="PM">مدير مشاريع (PM)</option>
          <option value="Leader">قائد (Leader / Manager)</option>
        </select>
      </div>
      <div class="form-group" style="margin-bottom:16px">
        <label>صلاحية لوحة التحكم؟</label>
        <select id="invite-access" class="input">
          <option value="none">لا يوجد وصول</option>
          <option value="view">عرض فقط</option>
          <option value="edit">تعديل كامل</option>
        </select>
      </div>
      <div style="margin-top:20px;padding:12px;background:var(--surface2);border-radius:8px;word-break:break-all;border:1px dashed var(--border)">
        <span id="invite-link-preview" style="color:var(--primary);font-weight:600;font-size:0.85rem;">(سيظهر الرابط هنا)</span>
      </div>
    </div>
    <div class="modal-ftr">
      <button class="btn btn-outline" onclick="S.team.closeModal()">إلغاء</button>
      <button class="btn" style="background:var(--success);border-color:var(--success)" onclick="S.team.generateLink()">توليد ونسخ الرابط</button>
    </div>
  </div>
</div>

<!-- Team Registration Page (Hidden by default, shown if URL has ?invite=...) -->
<div id="registration-page" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:var(--bg);z-index:9999;align-items:center;justify-content:center;padding:24px">
  <div class="card" style="padding:32px;max-width:500px;width:100%">
    <h2 style="margin-bottom:12px;text-align:center">انضمام لفريق العمل 🤝</h2>
    <p style="text-align:center;color:var(--dim);margin-bottom:24px" id="reg-role-desc">يرجى إدخال بياناتك لإتمام التسجيل.</p>
    
    <div class="form-group" style="margin-bottom:16px">
      <label>الاسم الكامل</label>
      <input type="text" id="reg-name" class="input" placeholder="اكتب اسمك هنا...">
    </div>
    <div class="form-group" style="margin-bottom:16px">
      <label>رقم الهاتف / واتساب</label>
      <input type="text" id="reg-phone" class="input" placeholder="01xxxxxxxxx">
    </div>
    <div class="form-group" style="margin-bottom:24px">
      <label>كلمة المرور (للدخول لاحقاً)</label>
      <input type="password" id="reg-pass" class="input" placeholder="رمز سري بسيط...">
    </div>
    <button class="btn" style="width:100%;font-size:1.1rem;padding:12px" onclick="S.team.submitRegistration()">إرسال البيانات والتسجيل ✅</button>
  </div>
</div>
"""
    html = html.replace('</body>', invite_modal + '\n</body>')

# 6. Add JS Logic for Team
if 'S.team =' not in html:
    js_logic = """
    team: {
      members: [],
      files: [],
      init(){
        this.loadMembers();
        this.loadFiles();
        
        // Check for invite link
        const urlParams = new URLSearchParams(window.location.search);
        const inviteData = urlParams.get('invite');
        if(inviteData){
          document.getElementById('sidebar').style.display = 'none';
          document.getElementById('main').style.display = 'none';
          document.getElementById('registration-page').style.display = 'flex';
          try {
            const data = JSON.parse(atob(inviteData));
            document.getElementById('reg-role-desc').innerText = `أنت مدعو للانضمام كـ: ${data.r}`;
            this._currentInvite = data;
          } catch(e) {
            alert('رابط الدعوة غير صالح!');
          }
        }
      },
      async loadMembers(){
        FB.get('/team_members', (d)=>{
          this.members = d ? Object.entries(d).map(([k,v])=>({id:k, ...v})) : [];
          this.renderMembers();
        });
      },
      renderMembers(){
        const tb = document.getElementById('team-list-tbody');
        if(!tb) return;
        tb.innerHTML = this.members.map(m=>`
          <tr style="border-bottom:1px solid var(--border)">
            <td style="padding:12px"><b>${m.name}</b><br><small style="color:var(--dim)">${m.phone}</small></td>
            <td style="padding:12px">
              <span class="tree-badge" style="background:rgba(99,102,241,0.15);color:var(--primary)">${m.role}</span>
            </td>
            <td style="padding:12px">${m.access === 'edit' ? 'مدير (صلاحيات كاملة)' : (m.access === 'view' ? 'عضو' : 'محدود')}</td>
            <td style="padding:12px;color:var(--dim)">${new Date(m.date).toLocaleDateString('ar-EG')}</td>
            <td style="padding:12px">
              <button class="btn btn-sm" style="color:var(--danger);border-color:var(--danger);background:transparent" onclick="S.team.deleteMember('${m.id}')">حذف</button>
            </td>
          </tr>
        `).join('') || `<tr><td colspan="5" style="text-align:center;padding:24px;color:var(--dim)">لا يوجد أعضاء حالياً.</td></tr>`;
      },
      async deleteMember(id){
        if(!confirm('هل أنت متأكد من حذف هذا العضو؟')) return;
        await FB.del(`/team_members/${id}`);
        toast('تم حذف العضو بنجاح');
      },
      showInviteModal(){
        document.getElementById('invite-modal').classList.add('active');
        document.getElementById('invite-link-preview').innerText = '(سيظهر الرابط هنا)';
      },
      closeModal(){
        document.getElementById('invite-modal').classList.remove('active');
      },
      generateLink(){
        const role = document.getElementById('invite-role').value;
        const access = document.getElementById('invite-access').value;
        const payload = btoa(JSON.stringify({ r: role, a: access, t: Date.now() }));
        const link = window.location.origin + window.location.pathname + '?invite=' + payload;
        document.getElementById('invite-link-preview').innerText = link;
        navigator.clipboard.writeText(link);
        toast('تم نسخ الرابط! يمكنك إرساله للعضو الجديد.');
      },
      async submitRegistration(){
        const name = document.getElementById('reg-name').value;
        const phone = document.getElementById('reg-phone').value;
        const pass = document.getElementById('reg-pass').value;
        if(!name || !phone || !pass) return alert('الرجاء ملء جميع الحقول');
        
        const data = this._currentInvite;
        if(!data) return alert('رابط غير صالح');
        
        const id = 'user_' + Date.now();
        await FB.put(`/team_members/${id}`, {
          name, phone, pass, role: data.r, access: data.a, date: new Date().toISOString()
        });
        
        document.getElementById('registration-page').innerHTML = `
          <div class="card" style="padding:32px;text-align:center">
            <h1 style="font-size:3rem;margin-bottom:16px">🎉</h1>
            <h2>تم التسجيل بنجاح!</h2>
            <p style="color:var(--dim);margin-top:12px">يمكنك إغلاق هذه الصفحة الآن والتواصل مع الإدارة.</p>
          </div>
        `;
      },
      async loadFiles(){
        // For now, placeholder functionality for files since we don't have direct firebase storage in this example
      }
    },
"""
    # Insert before S.init() inside the S object
    html = html.replace('init(){', js_logic + '    init(){')
    html = html.replace('this.dashboard.init();', 'this.dashboard.init();\n      this.team.init();')

with open('web/index.html', 'w', encoding='utf-8') as f:
    f.write(html)
print("Team Management features integrated.")
