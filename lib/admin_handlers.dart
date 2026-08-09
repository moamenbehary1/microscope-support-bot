import 'package:televerse/televerse.dart';
import 'firebase_db.dart';
import 'utils.dart';
import 'config.dart';

void registerAdminHandlers(Bot bot) {
  // Mode Toggle & Interactive Dashboard
  bot.command('admin', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;

    if (!(await FirebaseDb.isAdmin(userId))) {
      await ctx.reply('You are not authorized to use this command.');
      return;
    }

    Utils.setUserMode(userId, UserMode.admin);
    Utils.clearUploadState(userId);
    final superAdminId = await FirebaseDb.getSuperAdmin();
    final isSuperAdmin = userId == superAdminId;
    
    final keyboard = InlineKeyboard()
      .row()
      .add('➕ Add Admin', 'dash_add_admin')
      .add('📢 Broadcast', 'dash_broadcast')
      .row()
      .add('📊 Statistics', 'dash_stats')
      .add('📩 Pending Requests', 'dash_requests')
      .row()
      .add('🗑️ Wipe Database', 'dash_wipe')
      .add('🚫 Remove Contributor', 'dash_rm_contrib');
      
    if (isSuperAdmin) {
      keyboard.row().add('👑 Transfer Ownership', 'dash_transfer_owner');
    }
    
    keyboard.row().add('🎓 Switch to Student Mode', 'dash_student');

    await ctx.reply(
      '🛡️ **Admin Dashboard**\n\n'
      'Welcome to the admin panel. From here you can manage the bot.\n\n'
      '*(To add new Tracks/Subjects/Materials, simply send the file directly in this chat while in Admin Mode)*',
      replyMarkup: keyboard,
      parseMode: ParseMode.markdown,
    );
  });

  bot.command('student', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    Utils.setUserMode(userId, UserMode.student);
    Utils.clearUploadState(userId);
    await ctx.reply('Switched to STUDENT_MODE 🎓');
  });

  // Dashboard Callbacks
  bot.callbackQuery('dash_student', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    Utils.setUserMode(userId, UserMode.student);
    Utils.clearUploadState(userId);
    await ctx.editMessageText('Switched to STUDENT_MODE 🎓\nSend /start to browse.');
  });

  bot.callbackQuery('dash_add_admin', (ctx) async {
    final userId = ctx.from?.id;
    final superAdminId = await FirebaseDb.getSuperAdmin();
    if (userId == null || userId != superAdminId) {
      await ctx.answerCallbackQuery(text: 'Only Super Admin can do this.', showAlert: true);
      return;
    }
    
    Utils.uploadStates[userId] = {'action': 'add_admin_id'};
    await ctx.editMessageText('Please send the Telegram ID of the user you want to make an Admin:');
  });

  bot.callbackQuery('dash_broadcast', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    Utils.uploadStates[userId] = {'action': 'broadcast_msg'};
    await ctx.editMessageText('Please send the message you want to broadcast to all users:');
  });

  bot.callbackQuery('dash_stats', (ctx) async {
    final stats = await FirebaseDb.getStats();
    final topMaterials = stats['topMaterials'] as Map<String, dynamic>;
    
    String msg = '📊 **Analytics Dashboard**\n\nTotal Users: ${stats['totalUsers']}\n\nTop Materials:\n';
    
    var entries = topMaterials.entries.toList();
    entries.sort((a, b) => (b.value['count'] as int).compareTo(a.value['count'] as int));
    
    for (var i = 0; i < entries.length && i < 5; i++) {
      msg += '${i+1}. ${entries[i].value['name']} - ${entries[i].value['count']} views\n';
    }

    final kb = InlineKeyboard().row().add('🔙 Back to Dashboard', 'dash_back');
    await ctx.editMessageText(msg, replyMarkup: kb, parseMode: ParseMode.markdown);
  });

  bot.callbackQuery('dash_wipe', (ctx) async {
    final userId = ctx.from?.id;
    final superAdminId = await FirebaseDb.getSuperAdmin();
    if (userId == null || userId != superAdminId) {
      await ctx.answerCallbackQuery(text: 'Only Super Admin can wipe data.', showAlert: true);
      return;
    }
    
    final kb = InlineKeyboard()
      .row()
      .add('⚠️ YES, WIPE DATA', 'dash_wipe_confirm')
      .add('NO, CANCEL', 'dash_back');
      
    await ctx.editMessageText(
      '⚠️ **WARNING** ⚠️\nAre you sure you want to wipe all curriculum and analytics data? This cannot be undone.',
      replyMarkup: kb,
      parseMode: ParseMode.markdown,
    );
  });

  bot.callbackQuery('dash_wipe_confirm', (ctx) async {
    final userId = ctx.from?.id;
    final superAdminId = await FirebaseDb.getSuperAdmin();
    if (userId == null || userId != superAdminId) return;
    
    await FirebaseDb.wipeCurriculum();
    final kb = InlineKeyboard().row().add('🔙 Back to Dashboard', 'dash_back');
    await ctx.editMessageText('✅ Database wiped successfully.', replyMarkup: kb);
  });

  bot.callbackQuery('dash_rm_contrib', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    Utils.uploadStates[userId] = {'action': 'rm_contrib_id'};
    await ctx.editMessageText('Please send the Telegram ID of the Contributor you want to remove:');
  });

  bot.callbackQuery('dash_transfer_owner', (ctx) async {
    final userId = ctx.from?.id;
    final superAdminId = await FirebaseDb.getSuperAdmin();
    if (userId == null || userId != superAdminId) return;
    
    Utils.uploadStates[userId] = {'action': 'transfer_owner_id'};
    await ctx.editMessageText('⚠️ **TRANSFER OWNERSHIP** ⚠️\nPlease send the Telegram ID of the new Super Admin:\n\n*Note: You will be demoted to a regular Admin after this.*', parseMode: ParseMode.markdown);
  });

  bot.callbackQuery('dash_requests', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    final requests = await FirebaseDb.getPendingRequests();
    if (requests.isEmpty) {
      final kb = InlineKeyboard().row().add('🔙 Back to Dashboard', 'dash_back');
      await ctx.editMessageText('No pending requests found.', replyMarkup: kb);
      return;
    }
    
    String msg = '📩 **Pending Contributor Requests:**\n\n';
    final kb = InlineKeyboard();
    
    requests.forEach((id, data) {
      msg += '• User $id wants to contribute to ${data['track']} -> ${data['subject']}\n';
      kb.row()
        .add('✅ Approve $id', 'approve_contrib:$id:${data['track']}:${data['subject']}')
        .add('❌ Reject $id', 'reject_contrib:$id');
    });
    
    kb.row().add('🔙 Back to Dashboard', 'dash_back');
    await ctx.editMessageText(msg, replyMarkup: kb, parseMode: ParseMode.markdown);
  });

  bot.callbackQuery('dash_back', (ctx) async {
    final userId = ctx.from?.id;
    final superAdminId = await FirebaseDb.getSuperAdmin();
    final isSuperAdmin = userId == superAdminId;
    
    final keyboard = InlineKeyboard()
      .row()
      .add('➕ Add Admin', 'dash_add_admin')
      .add('📢 Broadcast', 'dash_broadcast')
      .row()
      .add('📊 Statistics', 'dash_stats')
      .add('📩 Pending Requests', 'dash_requests')
      .row()
      .add('🗑️ Wipe Database', 'dash_wipe')
      .add('🚫 Remove Contributor', 'dash_rm_contrib');
      
    if (isSuperAdmin) {
      keyboard.row().add('👑 Transfer Ownership', 'dash_transfer_owner');
    }
    
    keyboard.row().add('🎓 Switch to Student Mode', 'dash_student');

    await ctx.editMessageText(
      '🛡️ **Admin Dashboard**\n\n'
      'Welcome to the admin panel. From here you can manage the bot.\n\n'
      '*(To add new Tracks/Subjects/Materials, simply send the file directly in this chat while in Admin Mode)*',
      replyMarkup: keyboard,
      parseMode: ParseMode.markdown,
    );
  });

  // Admin Content Deletion and Replacement Callbacks
  bot.callbackQuery(RegExp(r'^admin_del:(.*?):(.*?):(.*?):(.*)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    if (!(await FirebaseDb.isAdmin(userId))) return;

    final data = ctx.callbackQuery?.data;
    if (data == null) return;
    
    final parts = data.split(':');
    await FirebaseDb.deleteMaterial(parts[1], parts[2], parts[3], parts[4]);
    await ctx.answerCallbackQuery(text: 'Material deleted!', showAlert: true);
    await ctx.editMessageText('Material has been deleted.');
  });
  
  bot.callbackQuery(RegExp(r'^admin_rep:(.*?):(.*?):(.*?):(.*)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    if (!(await FirebaseDb.isAdmin(userId))) return;

    final data = ctx.callbackQuery?.data;
    if (data == null) return;
    
    final parts = data.split(':');
    Utils.uploadStates[userId] = {
      'action': 'replace_file',
      'track': parts[1],
      'subject': parts[2],
      'type': parts[3],
      'materialId': parts[4]
    };
    
    await ctx.answerCallbackQuery();
    await ctx.reply('Please send the new file to replace this material.');
  });

  // Handle Admin Approving/Rejecting Contributors
  bot.callbackQuery(RegExp(r'^approve_contrib:(.*?):(.*?):(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    if (data == null) return;
    
    final parts = data.split(':');
    final targetId = int.parse(parts[1]);
    final track = parts[2];
    final subject = parts[3];
    
    await FirebaseDb.setContributor(targetId, track, subject);
    await FirebaseDb.removeRequest(targetId);
    await ctx.editMessageText('Approved $targetId for $track -> $subject.');
    
    try {
      await bot.api.sendMessage(ChatID(targetId), 'Your request to contribute to $subject ($track) has been APPROVED! Send a document to start contributing.');
    } catch (_) {}
  });

  bot.callbackQuery(RegExp(r'^reject_contrib:(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    if (data == null) return;
    
    final parts = data.split(':');
    final targetId = int.parse(parts[1]);
    
    await FirebaseDb.removeRequest(targetId);
    await ctx.editMessageText('Rejected contributor request for $targetId.');
    
    try {
      await bot.api.sendMessage(ChatID(targetId), 'Your request to contribute has been REJECTED.');
    } catch (_) {}
  });
}
