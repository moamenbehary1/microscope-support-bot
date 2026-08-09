import 'package:televerse/televerse.dart';
import 'firebase_db.dart';
import 'utils.dart';
import 'config.dart';

void registerContributorAndUploadHandlers(Bot bot) {
  // Handle Text Input for State Machine (Contributor requests and file categorization)
  bot.onText((ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    final state = Utils.uploadStates[userId];
    if (state == null) return;
    
    final text = ctx.message?.text ?? '';

    switch (state['action']) {
      case 'rm_contrib_id':
        final targetId = int.tryParse(text);
        if (targetId != null) {
          await FirebaseDb.removeContributor(targetId);
          await ctx.reply('✅ Contributor $targetId has been removed successfully.');
        } else {
          await ctx.reply('❌ Invalid ID format.');
        }
        Utils.clearUploadState(userId);
        break;

      case 'add_admin_id':
        final targetId = int.tryParse(text);
        if (targetId != null) {
          await FirebaseDb.addAdmin(targetId);
          await ctx.reply('✅ User $targetId has been added as an Admin.');
        } else {
          await ctx.reply('❌ Invalid ID format.');
        }
        Utils.clearUploadState(userId);
        break;

      case 'broadcast_msg':
        await ctx.reply('📢 Broadcasting message to all users... This might take some time.');
        final users = await FirebaseDb.getAllUsers();
        Utils.broadcast(bot, users, text);
        Utils.clearUploadState(userId);
        break;

      case 'transfer_owner_id':
        final targetId = int.tryParse(text);
        if (targetId != null) {
          await FirebaseDb.setSuperAdmin(targetId);
          await ctx.reply('✅ Ownership successfully transferred to $targetId.');
          try {
            await bot.api.sendMessage(ChatID(targetId), '👑 You have been granted Super Admin (Ownership) of the bot!');
          } catch (_) {}
        } else {
          await ctx.reply('❌ Invalid ID format.');
        }
        Utils.clearUploadState(userId);
        break;
      case 'req_contribute_track':
        state['action'] = 'req_contribute_subject';
        state['track'] = text;
        await ctx.reply('Great! Now type the Subject name you want to contribute to:');
        break;
        
      case 'req_contribute_subject':
        final track = state['track'];
        final subject = text;
        Utils.clearUploadState(userId);
        
        await FirebaseDb.addRequest(userId, track, subject);
        await ctx.reply('Your request to contribute to $track -> $subject has been sent to admins.');
        
        final admins = await FirebaseDb.getAdmins();
        final keyboard = InlineKeyboard()
          .row()
          .add('Approve', 'approve_contrib:$userId:$track:$subject')
          .add('Reject', 'reject_contrib:$userId');
          
        for (var adminId in admins) {
          try {
            await bot.api.sendMessage(
              ChatID(adminId), 
              'User $userId wants to contribute to $track -> $subject',
              replyMarkup: keyboard
            );
          } catch (_) {}
        }
        break;
        
      case 'contact_admin':
        Utils.clearUploadState(userId);
        final admins = await FirebaseDb.getAdmins();
        for (var adminId in admins) {
          try {
            await bot.api.sendMessage(
              ChatID(adminId), 
              'New Feedback from $userId:\n\n$text',
            );
          } catch (_) {}
        }
        await ctx.reply('Your message has been forwarded to the admins. Thank you!');
        break;

      case 'upload_admin_track':
        state['action'] = 'upload_admin_subject';
        state['track'] = text;
        await ctx.reply('Enter Subject:');
        break;
        
      case 'upload_admin_subject':
        state['action'] = 'upload_admin_type';
        state['subject'] = text;
        await ctx.reply('Enter Material Type (e.g., Notes, Video):');
        break;
        
      case 'upload_admin_type':
        state['action'] = 'upload_admin_name';
        state['type'] = text;
        await ctx.reply('Enter Material Name:');
        break;
        
      case 'upload_admin_name':
        final track = state['track'];
        final subject = state['subject'];
        final type = state['type'];
        final name = text;
        final fileId = state['fileId'];
        final fileType = state['fileType'] ?? 'document';
        
        await _saveFileToDatabase(bot, ctx, track, subject, type, name, fileId, fileType, userId);
        Utils.clearUploadState(userId);
        break;
        
      case 'upload_contrib_type':
        state['action'] = 'upload_contrib_name';
        state['type'] = text;
        await ctx.reply('Enter Material Name:');
        break;
        
      case 'upload_contrib_name':
        final contribData = await FirebaseDb.getContributor(userId);
        if (contribData == null) {
          Utils.clearUploadState(userId);
          return;
        }
        
        final track = contribData['track'];
        final subject = contribData['subject'];
        final type = state['type'];
        final name = text;
        final fileId = state['fileId'];
        final fileType = state['fileType'] ?? 'document';
        
        await _saveFileToDatabase(bot, ctx, track, subject, type, name, fileId, fileType, userId);
        Utils.clearUploadState(userId);
        break;
    }
  });

  bot.callbackQuery(RegExp(r'^up_track:(.*)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    final state = Utils.uploadStates[userId];
    if (state == null || state['action'] != 'wait_for_upload_track') return;
    
    final track = ctx.callbackQuery!.data!.split(':')[1];
    state['track'] = track;
    state['action'] = 'wait_for_upload_subject';
    
    final subjects = await FirebaseDb.getSubjects(track);
    final keyboard = InlineKeyboard();
    for (var s in subjects) {
      keyboard.row().add(s, 'up_subj:$s');
    }
    keyboard.row().add('➕ Add New Subject', 'up_new:subject');
    
    await ctx.editMessageText('Track: $track\nSelect or add a Subject:', replyMarkup: keyboard);
  });

  bot.callbackQuery(RegExp(r'^up_subj:(.*)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    final state = Utils.uploadStates[userId];
    if (state == null || state['action'] != 'wait_for_upload_subject') return;
    
    final subject = ctx.callbackQuery!.data!.split(':')[1];
    state['subject'] = subject;
    state['action'] = 'wait_for_upload_type';
    
    final track = state['track'];
    final types = await FirebaseDb.getMaterialTypes(track, subject);
    final keyboard = InlineKeyboard();
    for (var t in types) {
      keyboard.row().add(t, 'up_type:$t');
    }
    keyboard.row().add('➕ Add New Type', 'up_new:type');
    
    await ctx.editMessageText('Subject: $subject\nSelect or add a Material Type:', replyMarkup: keyboard);
  });

  bot.callbackQuery(RegExp(r'^up_type:(.*)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    final state = Utils.uploadStates[userId];
    if (state == null || state['action'] != 'wait_for_upload_type') return;
    
    final type = ctx.callbackQuery!.data!.split(':')[1];
    state['type'] = type;
    state['action'] = 'upload_admin_name'; // Reuse the final name step
    
    await ctx.editMessageText('Type: $type\nNow, please type the Name of the Material:');
  });

  bot.callbackQuery(RegExp(r'^up_new:(.*)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    final state = Utils.uploadStates[userId];
    if (state == null) return;
    
    final level = ctx.callbackQuery!.data!.split(':')[1];
    
    if (level == 'track') {
      state['action'] = 'upload_admin_track';
      await ctx.editMessageText('Please type the name of the NEW Track:');
    } else if (level == 'subject') {
      state['action'] = 'upload_admin_subject';
      await ctx.editMessageText('Please type the name of the NEW Subject:');
    } else if (level == 'type') {
      state['action'] = 'upload_admin_type';
      await ctx.editMessageText('Please type the name of the NEW Material Type (e.g., Notes, Videos):');
    }
  });

  // Handle Document Upload
  bot.onDocument((ctx) async {
    final fileId = ctx.message?.document?.fileId;
    if (fileId != null) await _handleUploadFlow(bot, ctx, fileId, 'document');
  });

  // Handle Photo Upload
  bot.onPhoto((ctx) async {
    final fileId = ctx.message?.photo?.last.fileId;
    if (fileId != null) await _handleUploadFlow(bot, ctx, fileId, 'photo');
  });

  // Handle Video Upload
  bot.onVideo((ctx) async {
    final fileId = ctx.message?.video?.fileId;
    if (fileId != null) await _handleUploadFlow(bot, ctx, fileId, 'video');
  });
}

Future<void> _handleUploadFlow(Bot bot, Context ctx, String fileId, String fileType) async {
  final userId = ctx.from?.id;
  if (userId == null) return;

  final isAdmin = await FirebaseDb.isAdmin(userId);
  final isModeAdmin = Utils.getUserMode(userId) == UserMode.admin;
  
  // Check if replacing file
  final state = Utils.uploadStates[userId];
  if (state != null && state['action'] == 'replace_file') {
    if (!isAdmin) return;
    
    final backupFileId = await _backupFile(bot, fileId, fileType);
    await FirebaseDb.updateMaterial(
      state['track'], state['subject'], state['type'], state['materialId'], 
      {'file_id': backupFileId ?? fileId, 'file_type': fileType}
    );
    
    await ctx.reply('File replaced successfully.');
    Utils.clearUploadState(userId);
    return;
  }

  if (isAdmin && isModeAdmin) {
    Utils.uploadStates[userId] = {'action': 'wait_for_upload_track', 'fileId': fileId, 'fileType': fileType};
    
    final tracks = await FirebaseDb.getTracks();
    final keyboard = InlineKeyboard();
    for (var t in tracks) {
      keyboard.row().add(t, 'up_track:$t');
    }
    keyboard.row().add('➕ Add New Track', 'up_new:track');
    
    await ctx.reply('Admin Mode: File received. Select or add a Track:', replyMarkup: keyboard);
  } else {
    final contribData = await FirebaseDb.getContributor(userId);
    if (contribData != null) {
      Utils.uploadStates[userId] = {'action': 'wait_for_upload_type', 'fileId': fileId, 'fileType': fileType};
      
      final track = contribData['track'];
      final subject = contribData['subject'];
      final types = await FirebaseDb.getMaterialTypes(track, subject);
      
      final keyboard = InlineKeyboard();
      for (var t in types) {
        keyboard.row().add(t, 'up_type:$t');
      }
      keyboard.row().add('➕ Add New Type', 'up_new:type');
      
      await ctx.reply('Contributor Mode: File received for $subject. Select or add a Material Type:', replyMarkup: keyboard);
    } else {
      await ctx.reply('You do not have permission to upload files.');
    }
  }
}

Future<String?> _backupFile(Bot bot, String fileId, String fileType) async {
  if (Config.backupChannelId.isEmpty) return fileId;
  
  try {
    final chatId = ChatID(int.parse(Config.backupChannelId));
    final inputFile = InputFile.fromFileId(fileId);
    if (fileType == 'photo') {
      final msg = await bot.api.sendPhoto(chatId, inputFile);
      return msg.photo?.last.fileId ?? fileId;
    } else if (fileType == 'video') {
      final msg = await bot.api.sendVideo(chatId, inputFile);
      return msg.video?.fileId ?? fileId;
    } else {
      final msg = await bot.api.sendDocument(chatId, inputFile);
      return msg.document?.fileId ?? fileId;
    }
  } catch (e) {
    print('Backup failed: $e');
    return fileId;
  }
}

Future<void> _saveFileToDatabase(Bot bot, Context ctx, String track, String subject, String type, String name, String fileId, String fileType, int uploaderId) async {
  final backupFileId = await _backupFile(bot, fileId, fileType);
  
  final materialId = await FirebaseDb.addMaterial(track, subject, type, {
    'name': name,
    'file_id': backupFileId ?? fileId,
    'file_type': fileType,
    'added_by': uploaderId.toString(),
  });
  
  if (materialId != null) {
    // Show admin options immediately
    final keyboard = InlineKeyboard()
      .row()
      .add('Delete Item 🗑️', 'admin_del:$track:$subject:$type:$materialId')
      .add('Replace/Update File 🔄', 'admin_rep:$track:$subject:$type:$materialId');
      
    await ctx.reply('Saved successfully: $name\nLocation: $track -> $subject -> $type', replyMarkup: keyboard);
  } else {
    await ctx.reply('Failed to save to database.');
  }
}
