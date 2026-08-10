import 'package:televerse/televerse.dart';
import 'firebase_db.dart';
import 'utils.dart';
import 'config.dart';
import 'strings.dart';

void registerContributorAndUploadHandlers(Bot bot) {
  // ── Text input state machine ─────────────────────────────────────────
  bot.onText((ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;

    final state = Utils.uploadStates[userId];
    if (state == null) return;

    final lang = Utils.getUserLanguage(userId);
    final text = ctx.message?.text ?? '';

    switch (state['action']) {
      // ---- Admin actions ------------------------------------------------
      case 'add_admin_id':
        final targetId = int.tryParse(text);
        if (targetId != null) {
          await FirebaseDb.addAdmin(targetId);
          await ctx.reply(S.get('admin_added', lang, {'id': '$targetId'}));
        } else {
          await ctx.reply(S.get('invalid_id', lang));
        }
        Utils.clearUploadState(userId);
        break;

      case 'broadcast_msg':
        await ctx.reply(S.get('broadcasting', lang));
        final users = await FirebaseDb.getAllUsers();
        Utils.broadcast(bot, users, text);
        Utils.clearUploadState(userId);
        break;

      case 'transfer_owner_id':
        final targetId = int.tryParse(text);
        if (targetId != null) {
          await FirebaseDb.setSuperAdmin(targetId);
          await ctx.reply(
              S.get('transfer_done', lang, {'id': '$targetId'}));
          try {
            final targetLang = Utils.getUserLanguage(targetId);
            await bot.api.sendMessage(
                ChatID(targetId), S.get('transfer_notif', targetLang));
          } catch (_) {}
        } else {
          await ctx.reply(S.get('invalid_id', lang));
        }
        Utils.clearUploadState(userId);
        break;

      // ---- Contributor request ------------------------------------------
      case 'req_contribute_track':
        state['action'] = 'req_contribute_subject';
        state['track'] = text;
        await ctx.reply(S.get('contribute_subject_prompt', lang));
        break;

      case 'req_contribute_subject':
        final track = state['track'] as String;
        final subject = text;
        Utils.clearUploadState(userId);

        // Store name from Telegram profile
        final firstName = ctx.from?.firstName ?? '';
        final lastName = ctx.from?.lastName ?? '';
        final fullName = '$firstName $lastName'.trim();

        await FirebaseDb.addRequest(userId, track, subject, name: fullName);
        await ctx.reply(S.get('contribute_request_sent', lang,
            {'track': track, 'subject': subject}));

        // Notify all admins — personalized per admin language
        final admins = await FirebaseDb.getAdmins();
        for (var adminId in admins) {
          try {
            final adminLang = Utils.getUserLanguage(adminId);
            final keyboard = InlineKeyboard()
              .row()
              .add(S.get('btn_approve', adminLang),
                  'approve_contrib:$userId:$track:$subject')
              .add(S.get('btn_reject', adminLang), 'reject_contrib:$userId');
            await bot.api.sendMessage(
              ChatID(adminId),
              S.get('admin_contrib_request', adminLang, {
                'id': '$userId',
                'name': fullName.isEmpty ? '$userId' : fullName,
                'track': track,
                'subject': subject,
              }),
              replyMarkup: keyboard,
            );
          } catch (_) {}
        }
        break;

      // ---- Contact admin ------------------------------------------------
      case 'contact_admin':
        Utils.clearUploadState(userId);
        final admins = await FirebaseDb.getAdmins();
        for (var adminId in admins) {
          try {
            final adminLang = Utils.getUserLanguage(adminId);
            await bot.api.sendMessage(
              ChatID(adminId),
              S.get('new_feedback', adminLang,
                  {'id': '$userId', 'msg': text}),
            );
          } catch (_) {}
        }
        await ctx.reply(S.get('contact_admin_sent', lang));
        break;

      // ---- Contributor announcement broadcast --------------------------
      case 'contrib_announce_msg':
        Utils.clearUploadState(userId);
        await ctx.reply(S.get('announce_sending', lang));
        final users = await FirebaseDb.getAllUsers();
        Utils.broadcast(bot, users, text);
        break;

      // ---- Admin upload flow (new manual entry) ─────────────────────────
      // This path is used when admin/contributor types a NEW track/subject/type
      // by clicking "Add New" buttons. For keyboard-based selections, the flow
      // goes directly to upload_admin_name via up_type callback.
      case 'upload_admin_track':
        state['action'] = 'upload_admin_subject';
        state['track'] = text;
        // BUG-FIXED: was incorrectly asking for 'type' instead of 'subject'
        await ctx.reply(S.get('upload_enter_subject', lang));
        break;

      case 'upload_admin_subject':
        state['action'] = 'upload_admin_type';
        state['subject'] = text;
        await ctx.reply(S.get('upload_enter_type', lang));
        break;

      case 'upload_admin_type':
        state['action'] = 'upload_admin_name';
        state['type'] = text;
        await ctx.reply(S.get('upload_enter_name', lang));
        break;

      case 'upload_admin_name':
        state['action'] = 'upload_admin_desc';
        state['name'] = text;
        await ctx.reply(S.get('upload_enter_desc', lang));
        break;

      case 'upload_admin_desc':
        // Null-safe: fallback to empty string if any state value is missing
        final track = (state['track'] as String?) ?? '';
        final subject = (state['subject'] as String?) ?? '';
        final type = (state['type'] as String?) ?? '';
        final name = (state['name'] as String?) ?? '';
        final fileId = (state['fileId'] as String?) ?? '';
        final fileType = (state['fileType'] as String?) ?? 'document';
        final desc = (text.toLowerCase() == 'skip' ||
                text.toLowerCase() == 'تخطي')
            ? ''
            : text;
        Utils.clearUploadState(userId);
        if (track.isEmpty || subject.isEmpty || type.isEmpty ||
            name.isEmpty || fileId.isEmpty) {
          await ctx.reply(S.get('upload_failed', lang));
          break;
        }
        await _saveFileToDatabase(
            bot, ctx, track, subject, type, name, fileId, fileType, userId,
            description: desc);
        break;

      // NOTE: upload_contrib_* states below handle the legacy text-only path.
      // The keyboard-based flow (which is the default) uses upload_admin_*
      // states above for both admins and contributors.
      case 'upload_contrib_type':
        state['action'] = 'upload_contrib_name';
        state['type'] = text;
        await ctx.reply(S.get('upload_enter_name', lang));
        break;

      case 'upload_contrib_name':
        state['action'] = 'upload_contrib_desc';
        state['name'] = text;
        await ctx.reply(S.get('upload_enter_desc', lang));
        break;

      case 'upload_contrib_desc':
        final contribData = await FirebaseDb.getContributor(userId);
        if (contribData == null) {
          Utils.clearUploadState(userId);
          return;
        }
        final track = contribData['track'] as String;
        final subject = contribData['subject'] as String;
        final type = state['type'] as String;
        final name = state['name'] as String;
        final fileId = state['fileId'] as String;
        final fileType = state['fileType'] as String? ?? 'document';
        final desc = (text.toLowerCase() == 'skip' ||
                text.toLowerCase() == 'تخطي')
            ? ''
            : text;
        Utils.clearUploadState(userId);
        await _saveFileToDatabase(
            bot, ctx, track, subject, type, name, fileId, fileType, userId,
            description: desc);
        break;
    }
  });

  // ── Upload track/subject/type keyboard callbacks ─────────────────────

  bot.callbackQuery(RegExp(r'^up_track:(.*)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;

    final state = Utils.uploadStates[userId];
    if (state == null || state['action'] != 'wait_for_upload_track') return;

    final lang = Utils.getUserLanguage(userId);
    final track = ctx.callbackQuery!.data!.split(':')[1];
    state['track'] = track;
    state['action'] = 'wait_for_upload_subject';

    final subjects = await FirebaseDb.getSubjects(track);
    if (subjects.isEmpty) {
      await ctx.editMessageText(S.get('upload_no_categories', lang));
      Utils.clearUploadState(userId);
      return;
    }

    final keyboard = InlineKeyboard();
    for (var s in subjects) {
      keyboard.row().add(s, 'up_subj:$s');
    }

    await ctx.editMessageText(
      S.get('upload_selected_track', lang, {'track': track}),
      replyMarkup: keyboard,
    );
  });

  bot.callbackQuery(RegExp(r'^up_subj:(.*)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;

    final state = Utils.uploadStates[userId];
    if (state == null || state['action'] != 'wait_for_upload_subject') return;

    final lang = Utils.getUserLanguage(userId);
    final subject = ctx.callbackQuery!.data!.split(':')[1];
    state['subject'] = subject;
    state['action'] = 'wait_for_upload_type';

    final track = state['track'] as String;
    final types = await FirebaseDb.getMaterialTypes(track, subject);
    if (types.isEmpty) {
      await ctx.editMessageText(S.get('upload_no_categories', lang));
      Utils.clearUploadState(userId);
      return;
    }

    final keyboard = InlineKeyboard();
    for (var t in types) {
      keyboard.row().add(t, 'up_type:$t');
    }

    await ctx.editMessageText(
      S.get('upload_selected_subject', lang, {'subject': subject}),
      replyMarkup: keyboard,
    );
  });

  bot.callbackQuery(RegExp(r'^up_type:(.*)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;

    final state = Utils.uploadStates[userId];
    if (state == null || state['action'] != 'wait_for_upload_type') return;

    final lang = Utils.getUserLanguage(userId);
    final type = ctx.callbackQuery!.data!.split(':')[1];
    state['type'] = type;
    state['action'] = 'upload_admin_name';

    await ctx.editMessageText(
      S.get('upload_selected_type', lang, {'type': type}),
    );
  });

  // ── File upload handlers ─────────────────────────────────────────────

  bot.onDocument((ctx) async {
    final fileId = ctx.message?.document?.fileId;
    if (fileId != null) await _handleUploadFlow(bot, ctx, fileId, 'document');
  });

  bot.onPhoto((ctx) async {
    final fileId = ctx.message?.photo?.last.fileId;
    if (fileId != null) await _handleUploadFlow(bot, ctx, fileId, 'photo');
  });

  bot.onVideo((ctx) async {
    final fileId = ctx.message?.video?.fileId;
    if (fileId != null) await _handleUploadFlow(bot, ctx, fileId, 'video');
  });

  // ── Contributor Dashboard callbacks ──────────────────────────────────

  Future<void> _showContributorDashboard(Context ctx, int userId, String lang) async {
  final contribData = await FirebaseDb.getContributor(userId);
  if (contribData == null) {
    if (ctx.callbackQuery != null) {
      await ctx.answerCallbackQuery(
          text: S.get('no_permission_upload', lang), showAlert: true);
    } else {
      await ctx.reply(S.get('no_permission_upload', lang));
    }
    return;
  }

  final materials = await FirebaseDb.getContributorMaterials(userId);
  final count = materials.length;

  final kb = InlineKeyboard()
    .row()
    .add(S.get('btn_my_materials', lang), 'contrib_materials')
    .add(S.get('btn_announce', lang), 'contrib_announce')
    .row()
    .add(S.get('btn_self_remove', lang), 'contrib_self_remove')
    .row()
    .add(S.get('btn_back', lang), 'back:tracks');

  final msg = S.get('contrib_dashboard_title', lang, {
    'count': '$count',
  });

  if (ctx.callbackQuery != null) {
    await ctx.editMessageText(
      msg,
      replyMarkup: kb,
      parseMode: ParseMode.markdown,
    );
  } else {
    await ctx.reply(
      msg,
      replyMarkup: kb,
      parseMode: ParseMode.markdown,
    );
  }
}

  bot.callbackQuery('contrib_dash', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    await _showContributorDashboard(ctx, userId, lang);
  });


  bot.callbackQuery('contrib_materials', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    final materials = await FirebaseDb.getContributorMaterials(userId);

    if (materials.isEmpty) {
      final kb = InlineKeyboard()
        .row()
        .add(S.get('btn_back_dashboard', lang), 'contrib_dash');
      await ctx.editMessageText(S.get('contrib_no_materials', lang),
          replyMarkup: kb);
      return;
    }

    String msg = S.get('contrib_my_materials_header', lang);
    final kb = InlineKeyboard();

    materials.forEach((matId, data) {
      final name = data['name'] as String? ?? matId;
      final type = data['type'] as String? ?? '';
      final track = data['track'] as String? ?? '';
      final subject = data['subject'] as String? ?? '';
      msg += S.get('contrib_material_item', lang,
          {'name': name, 'type': type});
      kb.row().add(
          '$name 🗑️', 'contrib_del_mat:$matId:$track:$subject:$type');
    });

    kb.row().add(S.get('btn_back_dashboard', lang), 'contrib_dash');
    await ctx.editMessageText(msg,
        replyMarkup: kb, parseMode: ParseMode.markdown);
  });

  // Contributor delete their own material
  bot.callbackQuery(
      RegExp(r'^contrib_del_mat:(.*?):(.*?):(.*?):(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    final userId = ctx.from?.id;
    if (data == null || userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    final parts = data.split(':');
    final matId = parts[1];
    final track = parts[2];
    final subject = parts[3];
    final type = parts[4];

    await FirebaseDb.deleteMaterial(track, subject, type, matId);
    await FirebaseDb.removeContributorMaterialRef(userId, matId);

    await ctx.answerCallbackQuery(
        text: S.get('material_delete_toast', lang), showAlert: false);

    // Refresh materials list
    final remaining = await FirebaseDb.getContributorMaterials(userId);
    if (remaining.isEmpty) {
      final kb = InlineKeyboard()
        .row()
        .add(S.get('btn_back_dashboard', lang), 'contrib_dash');
      await ctx.editMessageText(S.get('contrib_no_materials', lang),
          replyMarkup: kb);
      return;
    }

    String msg = S.get('contrib_my_materials_header', lang);
    final kb = InlineKeyboard();
    remaining.forEach((mId, d) {
      final name = d['name'] as String? ?? mId;
      final tp = d['type'] as String? ?? '';
      final tr = d['track'] as String? ?? '';
      final subj = d['subject'] as String? ?? '';
      msg +=
          S.get('contrib_material_item', lang, {'name': name, 'type': tp});
      kb.row()
          .add('$name 🗑️', 'contrib_del_mat:$mId:$tr:$subj:$tp');
    });
    kb.row().add(S.get('btn_back_dashboard', lang), 'contrib_dash');
    await ctx.editMessageText(msg,
        replyMarkup: kb, parseMode: ParseMode.markdown);
  });

  // Contributor announce new lecture
  bot.callbackQuery('contrib_announce', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    Utils.uploadStates[userId] = {'action': 'contrib_announce_msg'};
    await ctx.editMessageText(S.get('announce_prompt', lang));
  });

  // Contributor self-removal: ask confirmation
  bot.callbackQuery('contrib_self_remove', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    final kb = InlineKeyboard()
      .row()
      .add(S.get('btn_confirm_remove', lang), 'contrib_self_remove_confirm')
      .add(S.get('btn_cancel', lang), 'contrib_dash');

    await ctx.editMessageText(
      S.get('contrib_self_remove_confirm', lang),
      replyMarkup: kb,
    );
  });

  // Contributor self-removal: confirmed
  bot.callbackQuery('contrib_self_remove_confirm', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    await FirebaseDb.removeContributor(userId);
    Utils.setUserMode(userId, UserMode.student);
    Utils.clearUploadState(userId);

    await ctx.editMessageText(S.get('contrib_self_removed', lang));
  });
}

// ── Private: handle incoming file (admin or contributor) ─────────────────

Future<void> _handleUploadFlow(
    Bot bot, Context ctx, String fileId, String fileType) async {
  final userId = ctx.from?.id;
  if (userId == null) return;
  final lang = Utils.getUserLanguage(userId);

  final isAdmin = await FirebaseDb.isAdmin(userId);
  final isModeAdmin = Utils.getUserMode(userId) == UserMode.admin;

  // Replace existing file
  final state = Utils.uploadStates[userId];
  if (state != null && state['action'] == 'replace_file') {
    if (!isAdmin) return;

    final backupFileId = await _backupFile(bot, fileId, fileType);
    await FirebaseDb.updateMaterial(
      state['track'], state['subject'], state['type'], state['materialId'],
      {'file_id': backupFileId ?? fileId, 'file_type': fileType},
    );

    await ctx.reply(S.get('file_replaced', lang));
    Utils.clearUploadState(userId);
    return;
  }

  if (isAdmin && isModeAdmin) {
    Utils.uploadStates[userId] = {
      'action': 'wait_for_upload_track',
      'fileId': fileId,
      'fileType': fileType,
    };

    final tracks = await FirebaseDb.getTracks();
    if (tracks.isEmpty) {
      await ctx.reply(S.get('upload_no_categories', lang));
      Utils.clearUploadState(userId);
      return;
    }

    final keyboard = InlineKeyboard();
    for (var t in tracks) {
      keyboard.row().add(t, 'up_track:$t');
    }

    await ctx.reply(S.get('admin_file_received', lang), replyMarkup: keyboard);
  } else {
    final contribData = await FirebaseDb.getContributor(userId);
    if (contribData != null) {
      final track = contribData['track'] as String;
      final subject = contribData['subject'] as String;

      Utils.uploadStates[userId] = {
        'action': 'wait_for_upload_type',
        'fileId': fileId,
        'fileType': fileType,
        'track': track,
        'subject': subject,
      };

      final types = await FirebaseDb.getMaterialTypes(track, subject);
      if (types.isEmpty) {
        await ctx.reply(S.get('upload_no_categories', lang));
        Utils.clearUploadState(userId);
        return;
      }

      final keyboard = InlineKeyboard();
      for (var t in types) {
        keyboard.row().add(t, 'up_type:$t');
      }

      await ctx.reply(
        S.get('contrib_file_received', lang, {'subject': subject}),
        replyMarkup: keyboard,
      );
    } else {
      await ctx.reply(S.get('no_permission_upload', lang));
    }
  }
}

// ── Private: backup file to channel ──────────────────────────────────────

Future<String?> _backupFile(Bot bot, String fileId, String fileType) async {
  if (Config.backupChannelId.isEmpty ||
      Config.backupChannelId.contains('your_channel')) return fileId;

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

// ── Private: save file to database ───────────────────────────────────────

Future<void> _saveFileToDatabase(
  Bot bot,
  Context ctx,
  String track,
  String subject,
  String type,
  String name,
  String fileId,
  String fileType,
  int uploaderId, {
  String description = '',
}) async {
  final lang = Utils.getUserLanguage(uploaderId);
  final backupFileId = await _backupFile(bot, fileId, fileType);

  final materialId = await FirebaseDb.addMaterial(track, subject, type, {
    'name': name,
    'file_id': backupFileId ?? fileId,
    'file_type': fileType,
    'added_by': uploaderId.toString(),
    if (description.isNotEmpty) 'description': description,
  });

  if (materialId != null) {
    // Add to contributor materials index
    await FirebaseDb.addContributorMaterialRef(uploaderId, materialId, {
      'track': track,
      'subject': subject,
      'type': type,
      'name': name,
      if (description.isNotEmpty) 'description': description,
    });

    final isAdmin = await FirebaseDb.isAdmin(uploaderId);
    InlineKeyboard? kb;
    if (isAdmin) {
      kb = InlineKeyboard()
        .row()
        .add(S.get('btn_delete_item', lang),
            'admin_del:$track:$subject:$type:$materialId')
        .add(S.get('btn_replace_item', lang),
            'admin_rep:$track:$subject:$type:$materialId');
    }

    await ctx.reply(
      S.get('upload_saved', lang,
          {'name': name, 'track': track, 'subject': subject, 'type': type}),
      replyMarkup: kb,
    );
  } else {
    await ctx.reply(S.get('upload_failed', lang));
  }
}
