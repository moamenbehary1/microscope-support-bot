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
      'ar': 'مرحباً بك في البوت التعليمي! 📚\nاختر المسار الذي تريده:',
      'en': 'Welcome to the Educational Bot! 📚\nPlease select a track to begin:',
    },
    'btn_contribute': {
      'ar': 'المساهمة بمواد 🤝',
      'en': 'Contribute Materials 🤝',
    },
    'btn_contact_admin': {
      'ar': 'التواصل مع الأدمن 📞',
      'en': 'Contact Admin 📞',
    },
    'btn_change_lang': {
      'ar': 'تغيير اللغة 🌐',
      'en': 'Change Language 🌐',
    },
    'btn_my_dashboard': {
      'ar': 'لوحة المساهم 🎛️',
      'en': 'Contributor Dashboard 🎛️',
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
    'contribute_track_prompt': {
      'ar': 'لتصبح مساهماً، اكتب اسم المسار الذي تريد المساهمة فيه:',
      'en': 'To become a contributor, please type the Track name you want to contribute to:',
    },
    'contribute_subject_prompt': {
      'ar': 'ممتاز! الآن اكتب اسم المادة التي تريد المساهمة فيها:',
      'en': 'Great! Now type the Subject name you want to contribute to:',
    },
    'contribute_request_sent': {
      'ar': 'تم إرسال طلبك للمساهمة في {track} ← {subject} إلى الأدمن.',
      'en': 'Your request to contribute to {track} → {subject} has been sent to admins.',
    },
    'admin_contrib_request': {
      'ar': 'المستخدم {id} ({name}) يريد المساهمة في {track} ← {subject}',
      'en': 'User {id} ({name}) wants to contribute to {track} → {subject}',
    },
    'btn_approve': {'ar': '✅ قبول', 'en': '✅ Approve'},
    'btn_reject': {'ar': '❌ رفض', 'en': '❌ Reject'},
    'contrib_approved_notif': {
      'ar': '✅ تمت الموافقة على طلبك للمساهمة في {subject} ({track})!\nأرسل ملفاً لبدء المساهمة.',
      'en': '✅ Your request to contribute to {subject} ({track}) has been APPROVED!\nSend a document to start contributing.',
    },
    'contrib_rejected_notif': {
      'ar': '❌ تم رفض طلبك للمساهمة.',
      'en': '❌ Your request to contribute has been REJECTED.',
    },
    'contrib_approved_admin': {
      'ar': 'تمت الموافقة على {id} للمساهمة في {track} ← {subject}.',
      'en': 'Approved {id} for {track} → {subject}.',
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
      'ar': 'وضع المساهم: تم استلام الملف لـ {subject}.\nاختر أو أضف نوع المادة:',
      'en': 'Contributor Mode: File received for {subject}.\nSelect or add a Material Type:',
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
      'ar': 'النوع: {type}\nالآن اكتب اسم المادة:',
      'en': 'Type: {type}\nNow, please type the Name of the Material:',
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
    'no_permission_upload': {
      'ar': '❌ ليس لديك صلاحية لرفع الملفات.',
      'en': '❌ You do not have permission to upload files.',
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
      'ar': '🎛️ **لوحة تحكم المساهم**\n\nالمسار: {track}\nالمادة: {subject}\nالمواد المرفوعة: {count}',
      'en': '🎛️ **Contributor Dashboard**\n\nTrack: {track}\nSubject: {subject}\nMaterials uploaded: {count}',
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
      'ar': '📋 **موادك المرفوعة:**\n\n',
      'en': '📋 **Your uploaded materials:**\n\n',
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
      'ar': '🛡️ **لوحة الأدمن**\n\nمرحباً بك في لوحة الإدارة.\n\n*(لإضافة مسارات/مواد جديدة، أرسل الملف مباشرة وأنت في وضع الأدمن)*',
      'en': '🛡️ **Admin Dashboard**\n\nWelcome to the admin panel.\n\n*(To add new content, simply send the file directly while in Admin Mode)*',
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
    'btn_stats': {'ar': '📊 إحصائيات', 'en': '📊 Statistics'},
    'btn_requests': {'ar': '📩 الطلبات المعلقة', 'en': '📩 Pending Requests'},
    'btn_wipe': {'ar': '🗑️ مسح قاعدة البيانات', 'en': '🗑️ Wipe Database'},
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
      'ar': '📩 **طلبات المساهمة المعلقة:**\n\n',
      'en': '📩 **Pending Contributor Requests:**\n\n',
    },
    'request_item': {
      'ar': '• المستخدم {id} ({name}) يريد المساهمة في {track} ← {subject}\n',
      'en': '• User {id} ({name}) wants to contribute to {track} → {subject}\n',
    },
    'wipe_confirm_msg': {
      'ar': '⚠️ **تحذير** ⚠️\nهل أنت متأكد أنك تريد مسح جميع بيانات المناهج والتحليلات؟ لا يمكن التراجع عن هذا.',
      'en': '⚠️ **WARNING** ⚠️\nAre you sure you want to wipe all curriculum and analytics data? This cannot be undone.',
    },
    'btn_wipe_confirm': {
      'ar': '⚠️ نعم، امسح البيانات',
      'en': '⚠️ YES, WIPE DATA',
    },
    'btn_cancel_action': {'ar': 'لا، إلغاء', 'en': 'NO, CANCEL'},
    'wipe_done': {
      'ar': '✅ تم مسح قاعدة البيانات بنجاح.',
      'en': '✅ Database wiped successfully.',
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
      'ar': '⚠️ **نقل الملكية** ⚠️\nأرسل الـ ID التيليجرام للأدمن الجديد:\n\n*ملاحظة: ستصبح أدمناً عادياً بعد هذا.*',
      'en': '⚠️ **TRANSFER OWNERSHIP** ⚠️\nPlease send the Telegram ID of the new Super Admin:\n\n*Note: You will be demoted to a regular Admin after this.*',
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
      'ar': '📊 **إحصائيات**\n\nإجمالي المستخدمين: {total}\n\nأكثر المواد تحميلاً:\n',
      'en': '📊 **Analytics Dashboard**\n\nTotal Users: {total}\n\nTop Materials:\n',
    },
    'super_admin_registered': {
      'ar': 'تم تسجيل الأدمن الأعلى.',
      'en': 'Super Admin registered.',
    },
  };

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
