/// Bilingual string resources for the bot (Arabic & English).
/// Usage: S.get('key', lang) or S.get('key', lang, {'param': 'value'})
class S {
  static const Map<String, Map<String, String>> _data = {
    // ── Language selection ──────────────────────────────────────────
    'lang_prompt': {
      'ar': 'مرحباً! 👋\nاختر لغتك المفضلة:\n\nHello! 👋\nChoose your preferred language:',
      'en': 'Hello! 👋\nChoose your preferred language:\n\nمرحباً! 👋\nاختر لغتك المفضلة:',
    },
    'btn_arabic': {'ar': 'العربية 🇸🇦', 'en': 'العربية 🇸🇦'},
    'btn_english': {'ar': 'English 🇬🇧', 'en': 'English 🇬🇧'},
    'lang_set': {
      'ar': '✅ تم ضبط اللغة على العربية.',
      'en': '✅ Language set to English.',
    },
    // ── Admin Reply Keyboard ──────────────────────────────────────────
    'btn_admin_panel': {'ar': '👑 لوحة الإدارة', 'en': '👑 Admin Panel'},
    'btn_student_mode': {'ar': '🎓 وضع الطالب', 'en': '🎓 Student Mode'},
    'btn_restart_bot': {'ar': '🔄 تحديث البوت', 'en': '🔄 Restart Bot'},
    
    // ── Welcome / Start ─────────────────────────────────────────────
    'welcome': {
      'ar': 'مرحباً بك في البوت التعليمي! 📚\nاختر من القائمة بالأسفل:',
      'en': 'Welcome to the Educational Bot! 📚\nPlease select from the menu below:',
    },
    'departments': {
      'ar': 'اختر المسار الذي تريده:',
      'en': 'Please select a track to begin:',
    },
    'btn_departments': {
      'ar': '🏢 الأقسام (Departments)',
      'en': '🏢 Departments',
    },
    'btn_contribute': {
      'ar': 'المساهمة بمواد 🤝',
      'en': 'Contribute Materials 🤝',
    },
    'btn_contact_admin': {
      'ar': 'التواصل مع الأدمن 📞',
      'en': 'Contact Admin 📞',
    },
    'btn_whatsapp_support': {
      'ar': 'الدعم عبر الواتساب 💬',
      'en': 'WhatsApp Support 💬',
    },
    'btn_change_lang': {
      'ar': 'تغيير اللغة 🌐',
      'en': 'Change Language 🌐',
    },
    'btn_my_dashboard': {
      'ar': 'لوحة المساهم 🎛️',
      'en': 'Contributor Dashboard 🎛️',
    },
    'btn_my_tables': {
      'ar': '📅 جداولي الدراسية والتنبيهات ⚡',
      'en': '📅 My Schedules & Alerts ⚡',
    },
    'btn_smart_search_beta': {
      'ar': '🔍 البحث الذكي في المواد [BETA 🧪]',
      'en': '🔍 Smart Material Search [BETA 🧪]',
    },
    'btn_chat_miko': {
      'ar': '🤖 كلّم ميكو (المساعد الذكي)',
      'en': '🤖 Chat with Miko (AI)',
    },
    'search_prompt': {
      'ar': '🔍 أرسل اسم المادة أو المحاضرة أو كلمة مفتاحية للبحث عنها في كل الأقسام:\n(أرسل /start للإلغاء)',
      'en': '🔍 Send a subject, lecture name, or keyword to search across all tracks:\n(Send /start to cancel)',
    },
    'search_results_title': {
      'ar': '🔎 نتائج البحث عن "*{query}*":\n\nاختر النتيجة للوصول المباشر:',
      'en': '🔎 Search results for "*{query}*":\n\nSelect a result to open:',
    },
    'search_no_results': {
      'ar': '❌ لم يتم العثور على أي نتائج تطابق "*{query}*". جرب كلمة بحث أخرى.',
      'en': '❌ No matching results found for "*{query}*". Try another keyword.',
    },
    'btn_feedback_inbox': {
      'ar': '📬 صندوق الرسائل والشكاوى',
      'en': '📬 Feedback & Inbox',
    },
    'btn_system_health': {
      'ar': '🩺 فحص صحة النظام',
      'en': '🩺 System Health',
    },
    'btn_contrib_stats': {
      'ar': '📊 إحصائيات موادي والتفاعل',
      'en': '📊 My Uploads & Stats',
    },
    'btn_quick_add_lecture': {
      'ar': '➕ إضافة محاضرة بالاسم',
      'en': '➕ Add Lecture by Name',
    },
    'quick_add_name_prompt': {
      'ar': 'اكتب اسم المحاضرة أو الملخص الجديد (مثال: المحاضرة 1 - مقدمة في المنهج):',
      'en': 'Type the lecture or summary title (e.g. Lecture 1 - Introduction):',
    },
    'quick_add_desc_prompt': {
      'ar': 'أدخل نص/وصف أو رابط للمحاضرة (أو اكتب "تخطي"):',
      'en': 'Enter text/description or link for the lecture (or type "skip"):',
    },
    'quick_add_success': {
      'ar': '✅ تم حفظ المحاضرة بنجاح:\n📌 {name}\n📁 {track} ← {subject} ← {type}',
      'en': '✅ Lecture saved successfully:\n📌 {name}\n📁 {track} → {subject} → {type}',
    },
    'tab_recent_updates': {
      'ar': '🔔 آخر تحديثات موادي',
      'en': '🔔 Recent Updates for My Subjects',
    },
    'tab_share': {
      'ar': '📤 مشاركة بطاقة الجدول',
      'en': '📤 Share Schedule Card',
    },
    'btn_student_tools_beta': {
      'ar': '✨ أدوات المذاكرة والإنتاجية [BETA 🧪]',
      'en': '✨ Smart Study Tools [BETA 🧪]',
    },
    'btn_my_favorites_beta': {
      'ar': '🔖 مفضلاتي ومحفوظاتي [BETA 🧪]',
      'en': '🔖 My Saved & Bookmarks [BETA 🧪]',
    },
    'btn_pomodoro_beta': {
      'ar': '⏱ مؤقت التركيز (بومودورو) [BETA 🧪]',
      'en': '⏱ Pomodoro Focus Timer [BETA 🧪]',
    },
    'btn_gpa_calc_beta': {
      'ar': '📊 حاسبة المعدل التراكمي GPA [BETA 🧪]',
      'en': '📊 GPA Calculator [BETA 🧪]',
    },
    'btn_study_tips_beta': {
      'ar': '💡 تقنيات المذاكرة والحفظ الفعال [BETA 🧪]',
      'en': '💡 Effective Study Techniques [BETA 🧪]',
    },
    'btn_add_favorite': {
      'ar': '⭐️ حفظ في المفضلة',
      'en': '⭐️ Save to Bookmarks',
    },
    'no_tracks': {
      'ar': 'لا توجد مسارات بعد',
      'en': 'No tracks available yet',
    },
    'btn_back': {'ar': '🔙 رجوع', 'en': '🔙 Back'},
    'btn_back_dashboard': {
      'ar': '🔙 رجوع للداش بورد',
      'en': '🔙 Back to Dashboard',
    },

    // ── Browse / Navigation ─────────────────────────────────────────
    'selected_track': {
      'ar': 'المسار: {track}\nاختر المادة:',
      'en': 'Track: {track}\nPlease select a subject:',
    },
    'selected_subject': {
      'ar': 'المادة: {subject}\nاختر نوع المادة:',
      'en': 'Subject: {subject}\nPlease select material type:',
    },
    'materials_list': {
      'ar': 'مواد {type}:\nاختر ملفاً للتحميل:',
      'en': 'Materials for {type}:\nSelect a file to download:',
    },
    'here_is_material': {
      'ar': 'إليك المادة: {name}\nمن: {track} ← {subject} ← {type}',
      'en': 'Here is your material: {name}\nFrom: {track} → {subject} → {type}',
    },
    'material_not_found': {
      'ar': '❌ لم يتم العثور على المادة!',
      'en': '❌ Material not found!',
    },
    'no_files_found': {
      'ar': 'لا يوجد داتا حالياً',
      'en': 'No data currently',
    },

    // ── Contact Admin ───────────────────────────────────────────────
    'contact_admin_prompt': {
      'ar': 'أرسل رسالتك أو ملاحظتك في رسالة واحدة وسيتم إرسالها للأدمن.',
      'en': 'Please send your feedback/complaint in a single message. It will be forwarded to the admins.',
    },
    'contact_admin_sent': {
      'ar': '✅ تم إرسال رسالتك إلى الأدمن. شكراً!',
      'en': '✅ Your message has been forwarded to the admins. Thank you!',
    },
    'new_feedback': {
      'ar': 'رسالة جديدة من المستخدم {id}:\n\n{msg}',
      'en': 'New Feedback from {id}:\n\n{msg}',
    },

    // ── Contribute request ──────────────────────────────────────────
    'contribute_name_prompt': {
      'ar': 'تريد أن تصبح مساهماً؟ اكتب اسمك الكامل:',
      'en': 'Want to become a contributor? Type your full name:',
    },
    'already_contributor_msg': {
      'ar': 'أنت بالفعل مساهم! 🎉\nافتح لوحة التحكم من الزر أدناه.',
      'en': 'You are already a contributor! 🎉\nOpen your dashboard with the button below.',
    },
    'contribute_request_sent': {
      'ar': '✅ تم إرسال طلبك للمساهمة إلى الأدمن. سيتم إخطارك عند الموافقة.',
      'en': '✅ Your contribution request has been sent. You will be notified upon approval.',
    },
    'admin_contrib_request': {
      'ar': '📩 طلب مساهمة جديد!\nالمستخدم: {name}\nالمعرّف: {id}',
      'en': '📩 New contributor request!\nUser: {name}\nID: {id}',
    },
    'btn_approve': {'ar': '✅ قبول', 'en': '✅ Approve'},
    'btn_reject': {'ar': '❌ رفض', 'en': '❌ Reject'},
    'contrib_approved_notif': {
      'ar': '✅ تمت الموافقة على طلبك! أنت الآن مساهم.\nاستخدم /مساهم أو زر لوحة التحكم للبدء.',
      'en': '✅ Your request has been APPROVED! You are now a contributor.\nUse /contributor or the dashboard button to start.',
    },
    'contrib_rejected_notif': {
      'ar': '❌ تم رفض طلبك للمساهمة.',
      'en': '❌ Your contribution request has been REJECTED.',
    },
    'contrib_approved_admin': {
      'ar': 'تمت الموافقة على {name} ({id}) كمساهم.',
      'en': 'Approved {name} ({id}) as a contributor.',
    },
    'contrib_rejected_admin': {
      'ar': 'تم رفض طلب المساهمة للمستخدم {id}.',
      'en': 'Rejected contributor request for {id}.',
    },

    // ── Upload flow ─────────────────────────────────────────────────
    'admin_file_received': {
      'ar': 'وضع الأدمن: تم استلام الملف.\nاختر أو أضف مساراً:',
      'en': 'Admin Mode: File received.\nSelect or add a Track:',
    },
    'contrib_file_received': {
      'ar': 'وضع المساهم: تم استلام الملف.\nاختر أو أضف مساراً:',
      'en': 'Contributor Mode: File received.\nSelect or add a Track:',
    },
    'upload_selected_track': {
      'ar': 'المسار: {track}\nاختر أو أضف مادة:',
      'en': 'Track: {track}\nSelect or add a Subject:',
    },
    'upload_selected_subject': {
      'ar': 'المادة: {subject}\nاختر أو أضف نوع المادة:',
      'en': 'Subject: {subject}\nSelect or add a Material Type:',
    },
    'upload_selected_type': {
      'ar': 'النوع: {type}\nأرسل ملفاتك الآن أو اضغط ✅ خلصت عند الانتهاء.',
      'en': 'Type: {type}\nSend your files now or press ✅ Done when finished.',
    },
    'upload_enter_track': {
      'ar': 'اكتب اسم المسار الجديد:',
      'en': 'Type the new Track name:',
    },
    'upload_no_categories': {
      'ar': '❌ لا توجد أقسام متاحة حالياً. يجب على الأدمن إضافتها أولاً من لوحة التحكم.',
      'en': '❌ No categories available. The admin must add them first from the dashboard.',
    },
    'upload_enter_subject': {
      'ar': 'اكتب اسم المادة الجديدة:',
      'en': 'Please type the name of the NEW Subject:',
    },
    'upload_enter_type': {
      'ar': 'أدخل نوع المادة (مثال: ملاحظات، فيديو):',
      'en': 'Enter Material Type (e.g., Notes, Video):',
    },
    'upload_enter_type_new': {
      'ar': 'اكتب اسم نوع المادة الجديد (مثال: ملاحظات، فيديوهات):',
      'en': 'Please type the name of the NEW Material Type (e.g., Notes, Videos):',
    },
    'upload_enter_name': {
      'ar': 'اكتب اسم المادة:',
      'en': 'Please type the Name of the Material:',
    },
    'upload_enter_desc': {
      'ar': 'أدخل وصفاً للمادة:\n(اكتب "تخطي" للتخطي)',
      'en': 'Enter a description for this material:\n(Type "skip" to skip)',
    },
    'upload_saved': {
      'ar': '✅ تم الحفظ بنجاح: {name}\nالموقع: {track} ← {subject} ← {type}',
      'en': '✅ Saved successfully: {name}\nLocation: {track} → {subject} → {type}',
    },
    'upload_failed': {
      'ar': '❌ فشل الحفظ في قاعدة البيانات.',
      'en': '❌ Failed to save to database.',
    },
        'not_contributor_prompt': {
      'ar': '⚠️ *ليس لديك صلاحية مساهم حالياً.*\n\nهل ترغب بالانضمام إلى فريق المساهمين ورفع المواد والملخصات؟ اضغط على الزر أدناه لإرسال طلبك للإدارة:',
      'en': '⚠️ *You do not have contributor permissions currently.*\n\nWould you like to join the contributors team and upload materials? Tap the button below to send your request:',
    },
    'btn_request_contribute': {
      'ar': '🤝 طلب الانضمام كمساهم',
      'en': '🤝 Request to Become a Contributor',
    },
'no_permission_upload': {
      'ar': '❌ ليس لديك صلاحية لرفع الملفات.',
      'en': '❌ You do not have permission to upload files.',
    },
    'btn_add_subject': {'ar': '➕ أضف مادة جديدة', 'en': '➕ Add New Subject'},
    'contrib_add_subject_prompt': {
      'ar': 'اختر المسار الذي تريد الإضافة إليه:',
      'en': 'Choose a Track to add content to:',
    },
    'upload_collecting_files': {
      'ar': 'أرسل ملفاتك الآن 📎\nيمكنك إرسال أكثر من ملف.\nاضغط ✅ خلصت عند الانتهاء.',
      'en': 'Send your files now 📎\nYou can send multiple files.\nPress ✅ Done when finished.',
    },
    'upload_file_received_count': {
      'ar': '✅ تم استلام الملف! الإجمالي: {count} ملف.\nاستمر في الإرسال أو اضغط ✅ خلصت.',
      'en': '✅ File received! Total: {count} file(s).\nKeep sending or press ✅ Done.',
    },
    'upload_multi_success': {
      'ar': '🎉 تم رفع {count} ملف بنجاح!\n📁 {subject} ← {track}\n📂 النوع: {type}',
      'en': '🎉 Successfully uploaded {count} file(s)!\n📁 {subject} ← {track}\n📂 Type: {type}',
    },
    'upload_link_prompt': {
      'ar': 'الصق الرابط هنا 🔗\n(يجب أن يبدأ بـ http:// أو https://)',
      'en': 'Paste the link here 🔗\n(must start with http:// or https://)',
    },
    'upload_link_invalid': {
      'ar': '❌ الرابط غير صالح. يجب أن يبدأ بـ http:// أو https://',
      'en': '❌ Invalid link. It must start with http:// or https://',
    },
    'btn_done_uploading': {'ar': '✅ خلصت', 'en': '✅ Done'},
    'upload_no_files': {
      'ar': '❌ لم ترسل أي ملف! أرسل ملفاً أولاً.',
      'en': '❌ No files sent! Please send a file first.',
    },
    'upload_no_subjects': {
      'ar': '❌ لا توجد مواد في هذا المسار. تواصل مع الأدمن.',
      'en': '❌ No subjects in this track. Contact admin.',
    },
    'upload_no_types': {
      'ar': '❌ لا توجد أنواع في هذه المادة. تواصل مع الأدمن.',
      'en': '❌ No types in this subject. Contact admin.',
    },
    'btn_add_new_track': {'ar': '➕ إضافة مسار جديد', 'en': '➕ Add New Track'},
    'btn_add_new_subject': {
      'ar': '➕ إضافة مادة جديدة',
      'en': '➕ Add New Subject',
    },
    'btn_add_new_type': {
      'ar': '➕ إضافة نوع جديد',
      'en': '➕ Add New Type',
    },
    'btn_delete_item': {'ar': 'حذف 🗑️', 'en': 'Delete 🗑️'},
    'btn_replace_item': {'ar': 'استبدال 🔄', 'en': 'Replace/Update 🔄'},
    'material_deleted': {'ar': 'تم حذف المادة.', 'en': 'Material has been deleted.'},
    'material_delete_toast': {'ar': 'تم الحذف!', 'en': 'Material deleted!'},
    'replace_file_prompt': {
      'ar': 'أرسل الملف الجديد لاستبدال هذه المادة.',
      'en': 'Please send the new file to replace this material.',
    },
    'file_replaced': {
      'ar': '✅ تم استبدال الملف بنجاح.',
      'en': '✅ File replaced successfully.',
    },

    // ── Contributor Dashboard ───────────────────────────────────────
    'contrib_dashboard_title': {
      'ar': '🎛️ *لوحة تحكم المساهم*\n\nالمواد المرفوعة: {count}',
      'en': '🎛️ *Contributor Dashboard*\n\nMaterials uploaded: {count}',
    },
    'btn_my_materials': {'ar': '📋 موادي', 'en': '📋 My Materials'},
    'btn_announce': {
      'ar': '📢 إعلان محاضرة جديدة',
      'en': '📢 Announce New Lecture',
    },
    'btn_self_remove': {
      'ar': '❌ إلغاء عضويتي كمساهم',
      'en': '❌ Remove Myself as Contributor',
    },
    'contrib_no_materials': {
      'ar': 'لم ترفع أي مواد بعد.',
      'en': 'You have not uploaded any materials yet.',
    },
    'contrib_my_materials_header': {
      'ar': '📋 *موادك المرفوعة:*\n\n',
      'en': '📋 *Your uploaded materials:*\n\n',
    },
    'contrib_material_item': {
      'ar': '• {name} ({type})\n',
      'en': '• {name} ({type})\n',
    },
    'contrib_self_remove_confirm': {
      'ar': '⚠️ هل أنت متأكد أنك تريد إلغاء عضويتك كمساهم؟\nيمكنك إرسال طلب جديد لاحقاً.',
      'en': '⚠️ Are you sure you want to remove yourself as a contributor?\nYou can re-apply at any time.',
    },
    'btn_confirm_remove': {'ar': '⚠️ نعم، إلغاء العضوية', 'en': '⚠️ Yes, Remove Me'},
    'btn_cancel': {'ar': 'لا، إلغاء', 'en': 'No, Cancel'},
    'contrib_self_removed': {
      'ar': '✅ تم إلغاء عضويتك كمساهم.\nيمكنك إرسال طلب جديد عبر /start في أي وقت.',
      'en': '✅ You have been removed as a contributor.\nYou can re-apply via /start at any time.',
    },
    'announce_prompt': {
      'ar': 'اكتب رسالة الإعلان التي ستُرسل لجميع المستخدمين:',
      'en': 'Type the announcement message to send to all users:',
    },
    'announce_sending': {
      'ar': '📢 جاري إرسال الإعلان لجميع المستخدمين...',
      'en': '📢 Sending announcement to all users...',
    },

    // ── Admin Dashboard ─────────────────────────────────────────────
    'admin_dashboard_title': {
      'ar': '🛡️ *لوحة الأدمن*\n\nمرحباً بك في لوحة الإدارة.\n\n*(لإضافة مسارات/مواد جديدة، أرسل الملف مباشرة وأنت في وضع الأدمن)*',
      'en': '🛡️ *Admin Dashboard*\n\nWelcome to the admin panel.\n\n*(To add new content, simply send the file directly while in Admin Mode)*',
    },
    'not_authorized': {
      'ar': '❌ غير مصرح لك باستخدام هذا الأمر.',
      'en': '❌ You are not authorized to use this command.',
    },
    'only_super_admin': {
      'ar': 'هذا الأمر للأدمن الأعلى فقط.',
      'en': 'Only Super Admin can do this.',
    },
    'btn_add_admin': {'ar': '➕ إضافة أدمن', 'en': '➕ Add Admin'},
    'btn_broadcast': {'ar': '📢 بث جماعي', 'en': '📢 Broadcast'},
    'btn_reply_user': {'ar': '💬 رد على مستخدم', 'en': '💬 Reply to User'},
    'btn_stats': {'ar': '📊 إحصائيات', 'en': '📊 Statistics'},
    'btn_requests': {'ar': '📩 الطلبات المعلقة', 'en': '📩 Pending Requests'},
    'btn_wipe': {'ar': '🗑️ مسح المناهج', 'en': '🗑️ Wipe Curriculum'},
    'btn_wipe_users': {'ar': '🗑️ مسح كل المستخدمين', 'en': '🗑️ Wipe All Users'},
    'btn_rm_contrib': {'ar': '🚫 إزالة مساهم', 'en': '🚫 Remove Contributor'},
    'btn_transfer_owner': {'ar': '👑 نقل الملكية', 'en': '👑 Transfer Ownership'},
    'btn_back_to_dash': {
      'ar': '🔙 رجوع للداش بورد',
      'en': '🔙 Back to Dashboard',
    },
    'admin_switched_student': {
      'ar': 'تم التبديل لوضع الطالب 🎓\nأرسل /start للتصفح.',
      'en': 'Switched to Student Mode 🎓\nSend /start to browse.',
    },
    'enter_admin_id': {
      'ar': 'أرسل الـ ID التيليجرام للمستخدم الذي تريد جعله أدمن:',
      'en': 'Please send the Telegram ID of the user you want to make an Admin:',
    },
    'admin_added': {
      'ar': '✅ تم إضافة المستخدم {id} كأدمن.',
      'en': '✅ User {id} has been added as an Admin.',
    },
    'enter_user_id_to_reply': {
      'ar': 'أرسل الـ ID التيليجرام للمستخدم الذي تريد الرد عليه:',
      'en': 'Please send the Telegram ID of the user you want to reply to:',
    },
    'enter_reply_message': {
      'ar': 'أرسل الرسالة التي تريد إرسالها كاستجابة/رد للمستخدم:',
      'en': 'Please send the message you want to send as a reply:',
    },
    'admin_reply_msg': {
      'ar': '📩 رسالة من الإدارة:\n\n{msg}',
      'en': '📩 Message from Admin:\n\n{msg}',
    },
    'reply_sent_success': {
      'ar': '✅ تم إرسال الرد للمستخدم بنجاح.',
      'en': '✅ Reply sent to user successfully.',
    },
    'reply_sent_failed': {
      'ar': '❌ فشل إرسال الرد، قد يكون الـ ID غير صحيح أو البوت محظور من قبل المستخدم.',
      'en': '❌ Failed to send reply, the ID might be invalid or the bot was blocked by the user.',
    },
    'enter_broadcast': {
      'ar': 'أرسل الرسالة التي تريد إرسالها لجميع المستخدمين:',
      'en': 'Please send the message you want to broadcast to all users:',
    },
    'broadcasting': {
      'ar': '📢 جاري إرسال الرسالة لجميع المستخدمين...',
      'en': '📢 Broadcasting message to all users... This might take some time.',
    },
    'no_requests': {
      'ar': 'لا توجد طلبات معلقة.',
      'en': 'No pending requests found.',
    },
    'pending_requests_title': {
      'ar': '📩 *طلبات المساهمة المعلقة:*\n\n',
      'en': '📩 *Pending Contributor Requests:*\n\n',
    },
    'request_item': {
      'ar': '• المستخدم {id} ({name}) يريد المساهمة في {track} ← {subject}\n',
      'en': '• User {id} ({name}) wants to contribute to {track} → {subject}\n',
    },
    'wipe_confirm_msg': {
      'ar': '⚠️ تحذير: هذا سيحذف جميع *المسارات والمواد* نهائياً.\nهل أنت متأكد؟',
      'en': '⚠️ Warning: This will permanently delete all *Tracks and Materials*.\nAre you sure?',
    },
    'wipe_users_confirm_msg': {
      'ar': '⚠️ تحذير: هذا سيحذف جميع *المستخدمين* نهائياً من قاعدة البيانات.\nهل أنت متأكد؟',
      'en': '⚠️ Warning: This will permanently delete all *Users* from the database.\nAre you sure?',
    },
    'btn_wipe_confirm': {
      'ar': '⚠️ نعم، امسح البيانات',
      'en': '⚠️ YES, WIPE DATA',
    },
    'btn_cancel_action': {'ar': 'لا، إلغاء', 'en': 'NO, CANCEL'},
    'wipe_done': {
      'ar': '✅ تم الحذف بنجاح.',
      'en': '✅ Wipe completed successfully.',
    },
    'select_contrib_to_remove': {
      'ar': 'اختر المساهم الذي تريد إزالته:',
      'en': 'Select the contributor you want to remove:',
    },
    'no_contributors': {
      'ar': 'لا يوجد مساهمون حالياً.',
      'en': 'No contributors found.',
    },
    'contrib_removed': {
      'ar': '✅ تمت إزالة المساهم بنجاح.',
      'en': '✅ Contributor has been removed successfully.',
    },
    'transfer_owner_prompt': {
      'ar': '⚠️ *نقل الملكية* ⚠️\nأرسل الـ ID التيليجرام للأدمن الجديد:\n\n_ملاحظة: ستصبح أدمناً عادياً بعد هذا._',
      'en': '⚠️ *TRANSFER OWNERSHIP* ⚠️\nPlease send the Telegram ID of the new Super Admin:\n\n_Note: You will be demoted to a regular Admin after this._',
    },
    'transfer_done': {
      'ar': '✅ تم نقل الملكية بنجاح إلى {id}.',
      'en': '✅ Ownership successfully transferred to {id}.',
    },
    'transfer_notif': {
      'ar': '👑 لقد تمت منحك صلاحيات الأدمن الأعلى للبوت!',
      'en': '👑 You have been granted Super Admin (Ownership) of the bot!',
    },
    'invalid_id': {
      'ar': '❌ صيغة الـ ID غير صحيحة.',
      'en': '❌ Invalid ID format.',
    },
    'stats_title': {
      'ar': '📊 *إحصائيات*\n\nإجمالي المستخدمين: {total}\n\nأكثر المواد تحميلاً:\n',
      'en': '📊 *Analytics Dashboard*\n\nTotal Users: {total}\n\nTop Materials:\n',
    },
    'super_admin_registered': {
      'ar': 'تم تسجيل الأدمن الأعلى.',
      'en': 'Super Admin registered.',
    },
    // ── File Edit / Management ─────────────────────────────────────────
    'btn_edit_files': {
      'ar': '✏️ تعديل الملفات (Edit)',
      'en': '✏️ Edit Files',
    },
    'edit_file_actions_title': {
      'ar': '📄 *{name}*\n📂 {track} › {subject} › {type}\n\nاختر الإجراء المطلوب:',
      'en': '📄 *{name}*\n📂 {track} › {subject} › {type}\n\nChoose an action:',
    },
    'edit_select_track': {
      'ar': '✏️ *تعديل ملف*\n\nاختر القسم (المسار):',
      'en': '✏️ *Edit File*\n\nSelect a Department (Track):',
    },
    'edit_select_subject': {
      'ar': 'اختر المادة:',
      'en': 'Select a Subject:',
    },
    'edit_select_type': {
      'ar': 'اختر النوع (فئة الملفات):',
      'en': 'Select a Category:',
    },
    'edit_select_file': {
      'ar': 'اختر الملف المراد تعديله:',
      'en': 'Select the file to edit:',
    },
    'edit_action_prompt': {
      'ar': '📄 *الملف:* {name}\n\nاختر الإجراء المطلوب:',
      'en': '📄 *File:* {name}\n\nChoose an action:',
    },
    'btn_rename': {
      'ar': '✏️ تغيير الاسم (Rename)',
      'en': '✏️ Rename',
    },
    'btn_delete_file': {
      'ar': '🗑️ حذف (Delete)',
      'en': '🗑️ Delete',
    },
    'btn_move_file': {
      'ar': '📦 نقل (Move)',
      'en': '📦 Move',
    },
    'edit_auth_prompt': {
      'ar': '🔐 أدخل الكود المكون من 6 أرقام الذي أعطاك إياه الأدمن للمتابعة:',
      'en': '🔐 Enter the 6-digit authorization code provided by the admin:',
    },
    'edit_auth_invalid': {
      'ar': '❌ الكود غير صحيح. تأكد من الكود وحاول مرة أخرى.',
      'en': '❌ Invalid code. Please check and try again.',
    },
    'edit_rename_prompt': {
      'ar': 'اكتب الاسم الجديد للملف:',
      'en': 'Type the new file name:',
    },
    'edit_rename_done': {
      'ar': '✅ تم تغيير اسم الملف إلى *{name}* بنجاح.',
      'en': '✅ File renamed to *{name}* successfully.',
    },
    'edit_delete_confirm': {
      'ar': '⚠️ هل أنت متأكد من رغبتك في حذف الملف *{name}*؟\n\nلا يمكن التراجع عن هذا الإجراء.',
      'en': '⚠️ Are you sure you want to delete *{name}*?\n\nThis action cannot be undone.',
    },
    'edit_delete_done': {
      'ar': '✅ تم حذف الملف بنجاح.',
      'en': '✅ File deleted successfully.',
    },
    'edit_move_select_track': {
      'ar': '📦 *نقل الملف*\n\nاختر القسم (المسار) الجديد:',
      'en': '📦 *Move File*\n\nSelect the new Department (Track):',
    },
    'edit_move_select_subject': {
      'ar': 'اختر المادة الجديدة:',
      'en': 'Select the new Subject:',
    },
    'edit_move_select_type': {
      'ar': 'اختر النوع/الفئة الجديدة:',
      'en': 'Select the new Category:',
    },
    'edit_move_name_prompt': {
      'ar': '💡 هل تريد تغيير اسم الملف عند النقل؟\nاكتب الاسم الجديد أو اضغط "الاحتفاظ بالاسم الحالي":',
      'en': '💡 Do you want to rename the file while moving?\nType a new name or tap "Keep Original Name":',
    },
    'btn_keep_name': {
      'ar': '✔️ الاحتفاظ بالاسم الحالي',
      'en': '✔️ Keep Original Name',
    },
    'edit_move_done': {
      'ar': '✅ تم نقل الملف *{name}* إلى {track} ← {subject} ← {type} بنجاح.',
      'en': '✅ File *{name}* moved to {track} → {subject} → {type} successfully.',
    },
    'edit_move_failed': {
      'ar': '❌ فشل نقل الملف. يرجى المحاولة مرة أخرى.',
      'en': '❌ Failed to move the file. Please try again.',
    },
    'btn_generate_code': {
      'ar': '🔑 توليد كود تصريح للمساهمين',
      'en': '🔑 Generate Auth Code',
    },
    'gen_code_result': {
      'ar': '🔑 *كود تصريح المساهمين:*\n\n`{code}`\n\n⏳ شارك هذا الكود مع المساهم للسماح له بتعديل أو حذف أو نقل الملفات.\n_(الكود يُلغى وينتهي عند توليد كود جديد)_',
      'en': '🔑 *Contributor Authorization Code:*\n\n`{code}`\n\n⏳ Share this code with the contributor to allow file edit/delete/move operations.\n_(Code is replaced when a new one is generated)_',
    },
    'gen_code_menu_title': {
      'ar': '🔑 *توليد كود تصريح للمساهمين*\n\nاختر طريقة إنشاء الكود:',
      'en': '🔑 *Generate Contributor Auth Code*\n\nChoose an option:',
    },
    'btn_gen_fast': {
      'ar': '⚡ توليد سريع (مرة واحدة — 30 دقيقة)',
      'en': '⚡ Quick (1 use — 30 min)',
    },
    'btn_gen_custom': {
      'ar': '⚙️ تخصيص عدد المرات والوقت',
      'en': '⚙️ Custom Uses & Time',
    },
    'btn_revoke_code': {
      'ar': '❌ إبطال الكود الحالي فوراً',
      'en': '❌ Revoke Current Code',
    },
    'code_revoked_success': {
      'ar': '✅ تم إبطال كود التصريح الحالي بنجاح. لا يمكن لأحد استخدامه الآن.',
      'en': '✅ Current authorization code has been revoked.',
    },
    'gen_custom_uses_prompt': {
      'ar': '🎯 *اختر عدد مرات الاستخدام المسموح بها للكود:*',
      'en': '🎯 *Select maximum allowed uses for the code:*',
    },
    'gen_custom_time_prompt': {
      'ar': '⏳ *اختر مدة صلاحية الكود (الوقت المتبقي حتى ينتهي):*',
      'en': '⏳ *Select code validity duration:*',
    },
    'gen_code_detailed_result': {
      'ar': '🔑 *كود تصريح المساهمين الجديد:*\n\n`{code}`\n\n🎯 *مرات الاستخدام المتاحة:* {uses} مرة\n⏳ *صلاحية الكود:* {duration}\n\n💡 بمجرد استخدام الكود بعدد المرات المحددة أو انقضاء وقته سينتهي تلقائيًا.',
      'en': '🔑 *New Contributor Auth Code:*\n\n`{code}`\n\n🎯 *Max Uses:* {uses}\n⏳ *Validity:* {duration}\n\n💡 Once consumed or expired, the code will be invalidated automatically.',
    },
    'edit_auth_expired_time': {
      'ar': '⏳ انتهت صلاحية هذا الكود زمنيًا. اطلب كودًا جديدًا من الأدمن.',
      'en': '⏳ This authorization code has expired. Please request a new code from the admin.',
    },
    'edit_auth_expired_uses': {
      'ar': '❌ تم استهلاك هذا الكود بالكامل واستخدامه مسبقًا. اطلب كودًا جديدًا من الأدمن.',
      'en': '❌ This authorization code has reached its maximum uses. Please request a new code from the admin.',
    },
    'edit_rename_confirm': {
      'ar': '📝 *تأكيد تغيير اسم الملف*\n\n📄 الاسم الحالي: *{oldName}*\n✏️ الاسم الجديد: *{newName}*\n\nاضغط "حفظ" لتأكيد التغيير:',
      'en': '📝 *Confirm Rename*\n\n📄 Current Name: *{oldName}*\n✏️ New Name: *{newName}*\n\nClick "Save" to confirm:',
    },
    'btn_save_done': {
      'ar': '💾 حفظ (Done/Save)',
      'en': '💾 Save / Done',
    },
    'edit_action_cancelled': {
      'ar': '❌ تم إلغاء العملية.',
      'en': '❌ Action cancelled.',
    },
    'edit_move_confirm': {
      'ar': '📦 *تأكيد نقل الملف*\n\n📄 اسم الملف: *{name}*\n📁 المسار الأصلي: {oldTrack} ← {oldSubject} ← {oldType}\n📍 الوجهة الجديدة: {newTrack} ← {newSubject} ← {newType}\n\nاضغط "حفظ ونقل" لإتمام العملية:',
      'en': '📦 *Confirm File Move*\n\n📄 File: *{name}*\n📁 Original: {oldTrack} → {oldSubject} → {oldType}\n📍 New: {newTrack} → {newSubject} → {newType}\n\nClick "Save & Move" to finish:',
    },
    'btn_save_move': {
      'ar': '💾 حفظ ونقل (Done/Save)',
      'en': '💾 Save & Move',
    },
    'btn_change_name': {
      'ar': '✏️ كتابة اسم آخر',
      'en': '✏️ Type Another Name',
    },
    'btn_back_admin': {
      'ar': '🔙 لوحة الإدارة',
      'en': '🔙 Admin Dashboard',
    },  };

  /// Returns the localized string for [key] in [lang].
  /// Supports {placeholder} substitution via [params].
  static String get(String key, String lang, [Map<String, String>? params]) {
    String text = _data[key]?[lang] ?? _data[key]?['en'] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }
}
