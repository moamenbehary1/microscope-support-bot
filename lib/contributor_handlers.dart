import 'package:televerse/televerse.dart';
import 'firebase_db.dart';
import 'utils.dart';
import 'config.dart';
import 'strings.dart';



void registerContributorAndUploadHandlers(Bot bot) {
  // ── /مساهم command ────────────────────────────────────────────────────────
  bot.hears(RegExp(r'^/?(مساهم|contributor)$', caseSensitive: false), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    await _showContributorDashboard(ctx, userId, lang, isEdit: false);
  });

  bot.command('contributor', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    await _showContributorDashboard(ctx, userId, lang, isEdit: false);
  });
}

Future<void> handleUploadText(Context ctx, Bot bot) async {
  final userId = ctx.from?.id;
  if (userId == null) return;

  final state = Utils.uploadStates[userId];
  if (state == null) return;

  final lang = Utils.getUserLanguage(userId);
  final text = ctx.message?.text ?? '';
  if (text.startsWith('/')) return; // ignore commands

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

    // ---- Admin actions ------------------------------------------------
    case 'reply_user_id':
      final targetId = int.tryParse(text);
      if (targetId != null) {
        state['action'] = 'reply_user_msg';
        state['target_id'] = targetId;
        await ctx.reply(S.get('enter_reply_message', lang));
      } else {
        await ctx.reply(S.get('invalid_id', lang));
        Utils.clearUploadState(userId);
      }
      break;

    case 'reply_user_msg':
      final targetId = state['target_id'] as int;
      try {
        final targetLang = Utils.getUserLanguage(targetId);
        await bot.api.sendMessage(
          ChatID(targetId),
          S.get('admin_reply_msg', targetLang, {'msg': text}),
        );
        await ctx.reply(S.get('reply_sent_success', lang));
      } catch (e) {
        await ctx.reply(S.get('reply_sent_failed', lang));
      }
      Utils.clearUploadState(userId);
      break;

    case 'bcast_track_msg':
      final track = state['track'] as String? ?? '';
      await ctx.reply('ط¬ط§ط±ظٹ ط¥ط±ط³ط§ظ„ ط§ظ„ط¥ط´ط¹ط§ط± ظ„ط·ظ„ط§ط¨ ظ…ط³ط§ط± "$track"... âڈ³');
      final trackUsers = await FirebaseDb.getUsersForTrack(track);
      if (trackUsers.isEmpty) {
        await ctx.reply('âڑ ï¸ڈ ظ„ظ… ظٹطھظ… ط§ظ„ط¹ط«ظˆط± ط¹ظ„ظ‰ ط·ظ„ط§ط¨ ظ…ط³ط¬ظ„ظٹظ† ظپظٹ ظ‡ط°ط§ ط§ظ„ظ…ط³ط§ط± ط­ط§ظ„ظٹط§ظ‹.');
      } else {
        Utils.broadcast(bot, trackUsers, 'ًں“¢ *طھظ†ط¨ظٹظ‡ ظ„ط·ظ„ط§ط¨ [$track]:*\n\n$text');
        await ctx.reply('âœ… طھظ… ط¥ط±ط³ط§ظ„ ط§ظ„ط¥ط´ط¹ط§ط± ط¨ظ†ط¬ط§ط­ ط¥ظ„ظ‰ ${trackUsers.length} ط·ط§ظ„ط¨ ظپظٹ ظ…ط³ط§ط± "$track".');
      }
      Utils.clearUploadState(userId);
      break;

    case 'bcast_contribs_msg':
      await ctx.reply('ط¬ط§ط±ظٹ ط¥ط±ط³ط§ظ„ ط§ظ„ط¥ط´ط¹ط§ط± ظ„ط¬ظ…ظٹط¹ ط§ظ„ظ…ط³ط§ظ‡ظ…ظٹظ†... âڈ³');
      final contribs = await FirebaseDb.getAllContributors();
      final contribIds = contribs.keys.map((k) => int.tryParse(k)).whereType<int>().toList();
      if (contribIds.isEmpty) {
        await ctx.reply('âڑ ï¸ڈ ظ„ط§ ظٹظˆط¬ط¯ ظ…ط³ط§ظ‡ظ…ظˆظ† ظ…ط³ط¬ظ„ظˆظ† ط­ط§ظ„ظٹط§ظ‹.');
      } else {
        Utils.broadcast(bot, contribIds, 'ًں“¢ *طھظ†ط¨ظٹظ‡ ط®ط§طµ ظ„ظ„ظ…ط³ط§ظ‡ظ…ظٹظ† ظپظٹ ط§ظ„ظپط±ظٹظ‚:* ًں¤‌\n\n$text');
        await ctx.reply('âœ… طھظ… ط¥ط±ط³ط§ظ„ ط§ظ„ط¥ط´ط¹ط§ط± ط¨ظ†ط¬ط§ط­ ط¥ظ„ظ‰ ${contribIds.length} ظ…ط³ط§ظ‡ظ….');
      }
      Utils.clearUploadState(userId);
      break;

    case 'adm_ban_id':
      final banTarget = int.tryParse(text.trim());
      if (banTarget != null) {
        await FirebaseDb.banUser(banTarget);
        await ctx.reply('ًںڑ« طھظ… ط­ط¸ط± ط§ظ„ظ…ط³طھط®ط¯ظ… `$banTarget` ظˆط­ط±ظ…ط§ظ†ظ‡ ظ…ظ† ط§ط³طھط®ط¯ط§ظ… ط§ظ„ط¨ظˆطھ ط¨ظ†ط¬ط§ط­.', parseMode: ParseMode.markdown);
      } else {
        await ctx.reply('â‌Œ طµظٹط؛ط© ط§ظ„ظ€ ID ط؛ظٹط± طµط­ظٹط­ط©.');
      }
      Utils.clearUploadState(userId);
      break;

    case 'adm_unban_id':
      final unbanTarget = int.tryParse(text.trim());
      if (unbanTarget != null) {
        await FirebaseDb.unbanUser(unbanTarget);
        await ctx.reply('ًںں¢ طھظ… ظپظƒ ط§ظ„ط­ط¸ط± ط¹ظ† ط§ظ„ظ…ط³طھط®ط¯ظ… `$unbanTarget` ط¨ظ†ط¬ط§ط­.', parseMode: ParseMode.markdown);
      } else {
        await ctx.reply('â‌Œ طµظٹط؛ط© ط§ظ„ظ€ ID ط؛ظٹط± طµط­ظٹط­ط©.');
      }
      Utils.clearUploadState(userId);
      break;

    case 'adm_lookup_id':
      final lookupTarget = int.tryParse(text.trim());
      if (lookupTarget != null) {
        final isBanned = await FirebaseDb.isBanned(lookupTarget);
        final isAdmin = await FirebaseDb.isAdmin(lookupTarget);
        final isContrib = await FirebaseDb.isContributor(lookupTarget);
        final userLang = await FirebaseDb.getUserLanguage(lookupTarget);
        final tables = await FirebaseDb.getTables(lookupTarget);

        final buffer = StringBuffer('ًں‘¤ *طھظ‚ط±ظٹط± ط­ط³ط§ط¨ ط§ظ„ظ…ط³طھط®ط¯ظ…:* `$lookupTarget`\n\n');
        buffer.writeln('â€¢ ط§ظ„ط±طھط¨ط©: ${isAdmin ? 'ًں‘‘ ط£ط¯ظ…ظ†' : isContrib ? 'ًں¤‌ ظ…ط³ط§ظ‡ظ…' : 'ًںژ“ ط·ط§ظ„ط¨'}');
        buffer.writeln('â€¢ ط­ط§ظ„ط© ط§ظ„ط­ط¸ط±: ${isBanned ? 'ًںڑ« ظ…ط­ط¸ظˆط±' : 'ًںں¢ ظ†ط´ط· ظˆط؛ظٹط± ظ…ط­ط¸ظˆط±'}');
        buffer.writeln('â€¢ ط§ظ„ظ„ط؛ط© ط§ظ„ظ…ظپط¶ظ„ط©: $userLang');
        buffer.writeln('â€¢ ط¹ط¯ط¯ ط§ظ„ط¬ط¯ط§ظˆظ„ ط§ظ„ظ…ط³ط¬ظ„ط©: ${tables.length}');
        if (tables.isNotEmpty) {
          buffer.writeln('\nًں“… *ط§ظ„ط¬ط¯ط§ظˆظ„ ظˆط§ظ„ظ…ظˆط§ط¯ ط§ظ„ظ…ط³ط¬ظ„ط©:*');
          tables.forEach((tName, tData) {
            buffer.writeln('  â–«ï¸ڈ ط¬ط¯ظˆظ„: $tName (${tData['track'] ?? ''})');
          });
        }
        await ctx.reply(buffer.toString(), parseMode: ParseMode.markdown);
      } else {
        await ctx.reply('â‌Œ طµظٹط؛ط© ط§ظ„ظ€ ID ط؛ظٹط± طµط­ظٹط­ط©.');
      }
      Utils.clearUploadState(userId);
      break;

    case 'adm_add_track_name':
      final newTrack = text.trim();
      if (newTrack.isNotEmpty) {
        await FirebaseDb.addTrack(newTrack);
        await ctx.reply('âœ… طھظ…طھ ط¥ط¶ط§ظپط© ط§ظ„ظ…ط³ط§ط± "$newTrack" ط¥ظ„ظ‰ ط´ط¬ط±ط© ط§ظ„ظ…ظ†ط§ظ‡ط¬ ط¨ظ†ط¬ط§ط­!');
      } else {
        await ctx.reply('â‌Œ ط§ط³ظ… ط§ظ„ظ…ط³ط§ط± ظ„ط§ ظٹظ…ظƒظ† ط£ظ† ظٹظƒظˆظ† ظپط§ط±ط؛ط§ظ‹.');
      }
      Utils.clearUploadState(userId);
      break;

    case 'adm_add_subj_name':
      final newSubj = text.trim();
      final track = state['track'] as String? ?? '';
      if (newSubj.isNotEmpty && track.isNotEmpty) {
        await FirebaseDb.addSubject(track, newSubj);
        await ctx.reply('âœ… طھظ…طھ ط¥ط¶ط§ظپط© ظ…ط§ط¯ط© "$newSubj" ط¥ظ„ظ‰ ظ…ط³ط§ط± "$track" ط¨ظ†ط¬ط§ط­!');
      } else {
        await ctx.reply('â‌Œ ط­ط¯ط« ط®ط·ط£طŒ ظٹط±ط¬ظ‰ ط¥ط¹ط§ط¯ط© ط§ظ„ظ…ط­ط§ظˆظ„ط©.');
      }
      Utils.clearUploadState(userId);
      break;

    case 'inbox_reply_msg':
      final targetId = state['target_id'] as int;
      try {
        await bot.api.sendMessage(
          ChatID(targetId),
          'ًں“© *ط±ط¯ ظ…ظ† ط¥ط¯ط§ط±ط© ظ…ظٹظƒط±ظˆط³ظƒظˆط¨ ط¹ظ„ظ‰ ط±ط³ط§ظ„طھظƒ:*\n\n$text',
          parseMode: ParseMode.markdown,
        );
        await ctx.reply('âœ… طھظ… ط¥ط±ط³ط§ظ„ ط§ظ„ط±ط¯ ط¥ظ„ظ‰ ط§ظ„ط·ط§ظ„ط¨ ط¨ظ†ط¬ط§ط­!');
      } catch (e) {
        await ctx.reply('â‌Œ طھط¹ط°ط± ط¥ط±ط³ط§ظ„ ط§ظ„ط±ط¯: ط±ط¨ظ…ط§ ظ‚ط§ظ… ط§ظ„ظ…ط³طھط®ط¯ظ… ط¨ط­ط¸ط± ط§ظ„ط¨ظˆطھ.');
      }
      Utils.clearUploadState(userId);
      break;

    case 'mis_new_title':
      final title = text.trim();
      if (title.isEmpty) {
        await ctx.reply('â‌Œ ط§ظ„ط¹ظ†ظˆط§ظ† ظ„ط§ ظٹظ…ظƒظ† ط£ظ† ظٹظƒظˆظ† ظپط§ط±ط؛ط§ظ‹.');
        Utils.clearUploadState(userId);
        return;
      }
      state['title'] = title;
      state['action'] = 'mis_new_committee';
      
      final kb = InlineKeyboard()
        .row().add('HR ًں‘¥', 'mis_com:HR').add('PR ًں“£', 'mis_com:PR').add('Social Media ًں“±', 'mis_com:Social Media')
        .row().add('Academic ًں“ڑ', 'mis_com:Academic').add('Data ًں“ٹ', 'mis_com:Data').add('IT & Dev ًں’»', 'mis_com:IT')
        .row().add('Operations / PM âڑ™ï¸ڈ', 'mis_com:PM').add('ط¹ط§ظ…ط© ظ„ظƒط§ظپط© ط§ظ„ظ„ط¬ط§ظ† ًںŒگ', 'mis_com:General');

      await ctx.reply('طھظ… ط­ظپط¸ ط§ظ„ط¹ظ†ظˆط§ظ†: *$title*\n\nط§ظ„ط¢ظ† ط§ط®طھط± ط§ظ„ظ„ط¬ظ†ط© ط§ظ„ظ…ط³ط¤ظˆظ„ط© ط¹ظ† ظ‡ط°ط§ ط§ظ„طھظƒظ„ظٹظپ:', parseMode: ParseMode.markdown, replyMarkup: kb);
      break;

    case 'mis_new_desc':
      final desc = text.trim();
      final title = state['title'] as String? ?? 'ظ…ظ‡ظ…ط© ط¬ط¯ظٹط¯ط©';
      final committee = state['committee'] as String? ?? 'General';
      final category = state['category'] as String? ?? 'execution';
      final priority = state['priority'] as String? ?? 'high';
      final deadline = state['deadline'] as String? ?? 'ط؛ظٹط± ظ…ط­ط¯ط¯';
      final taskId = 'tsk_' + DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseDb.saveMission(taskId, {
        'id': taskId,
        'title': title,
        'description': desc,
        'category': category,
        'committees': committee,
        'head_name': 'ط¥ط¯ط§ط±ط© ط§ظ„ظ…ظ†ط¸ظˆظ…ط© (Admin)',
        'priority': priority,
        'status': 'progress',
        'due_date': deadline,
        'created_at': DateTime.now().toIso8601String(),
        'assigned_by': userId.toString(),
      });

      Utils.clearUploadState(userId);

      final missionCard = 'ًںژ¯ *طھظ… ط¥ظ†ط´ط§ط، ظˆطھظƒظ„ظٹظپ ط§ظ„ظ…ظ‡ظ…ط© ط¨ظ†ط¬ط§ط­!* âœ…\n'
          'â”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پ\n'
          'ًں“Œ *ط§ظ„ط¹ظ†ظˆط§ظ†:* $title\n'
          'ًںڈ¢ *ط§ظ„ظ„ط¬ظ†ط©:* $committee\n'
          'ًں“… *ط§ظ„ظ…ظˆط¹ط¯ ط§ظ„ظ†ظ‡ط§ط¦ظٹ:* $deadline\n'
          'ًںڑ¥ *ط§ظ„ط­ط§ظ„ط©:* ظ‚ظٹط¯ ط§ظ„طھظ†ظپظٹط° âڑ،\n\n'
          'ًں“‌ *ط§ظ„طھظپط§طµظٹظ„:* $desc\n'
          'â”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پâ”پ\n'
          'ًں’، طھظ…طھ ظ…ط²ط§ظ…ظ†ط© ط§ظ„ظ…ظ‡ظ…ط© ظپظˆط±ط§ظ‹ ظ…ط¹ ط§ظ„ط¨ظˆطھ ظˆظ„ظˆط­ط© ط§ظ„ظˆظٹط¨.';

      final cardKb = InlineKeyboard()
        .row().add('ًں“¢ ط¥ط±ط³ط§ظ„ ط¨ط·ط§ظ‚ط© ط§ظ„طھظƒظ„ظٹظپ ظ„ظ‚ظ†ط§ط© ط§ظ„ظ„ط¬ط§ظ†', 'mis_dispatch:$taskId')
        .row().add('ًں”™ ط¥ط¯ط§ط±ط© ط§ظ„ظ…ظ‡ط§ظ…', 'adm_missions');

      await ctx.reply(missionCard, parseMode: ParseMode.markdown, replyMarkup: cardKb);
      break;

    // ---- Contributor request (name only) ---------------------------------
    case 'req_contribute_name':
      final fullName = text.trim().isNotEmpty
          ? text.trim()
          : '${ctx.from?.firstName ?? ''} ${ctx.from?.lastName ?? ''}'.trim();
      Utils.clearUploadState(userId);

      await FirebaseDb.addRequest(userId, name: fullName);
      await ctx.reply(S.get('contribute_request_sent', lang));

      // Notify all admins
      final admins = await FirebaseDb.getAdmins();
      final Map<String, dynamic> msgIds = {};
      for (var adminId in admins) {
        try {
          final adminLang = Utils.getUserLanguage(adminId);
          final keyboard = InlineKeyboard()
            .row()
            .add(S.get('btn_approve', adminLang), 'approve_contrib:$userId')
            .add(S.get('btn_reject', adminLang), 'reject_contrib:$userId');
          final msg = await bot.api.sendMessage(
            ChatID(adminId),
            S.get('admin_contrib_request', adminLang, {
              'id': '$userId',
              'name': fullName.isEmpty ? '$userId' : fullName,
            }),
            replyMarkup: keyboard,
          );
          msgIds[adminId.toString()] = msg.messageId;
        } catch (_) {}
      }
      await FirebaseDb.updateRequestMessageIds(userId, msgIds);
      break;

    // ---- Contact admin ------------------------------------------------
    case 'contact_admin':
      Utils.clearUploadState(userId);
      
      // Save to Firebase
      await FirebaseDb.addFeedback(userId, text);
      
      final admins2 = await FirebaseDb.getAdmins();
      for (var adminId in admins2) {
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
      final users2 = await FirebaseDb.getAllUsers();
      Utils.broadcast(bot, users2, text);
      break;

    // ---- Smart Search Beta -------------------------------------------
    case 'smart_search_query':
      Utils.clearUploadState(userId);
      final query = text.trim();
      final results = await FirebaseDb.searchCurriculum(query);
      if (results.isEmpty) {
        final backKb = InlineKeyboard().row().add(S.get('btn_back', lang), 'back:main');
        await ctx.reply(
          S.get('search_no_results', lang, {'query': query}),
          replyMarkup: backKb,
          parseMode: ParseMode.markdown,
        );
        break;
      }

      final kb = InlineKeyboard();
      for (var r in results) {
        final kind = r['kind'];
        if (kind == 'subject') {
          kb.row().add(
            r['title'],
            'subj:${Utils.shorten(r['track'])}:${Utils.shorten(r['subject'])}',
          );
        } else if (kind == 'material') {
          kb.row().add(
            r['title'],
            'mat:${Utils.shorten(r['track'])}:${Utils.shorten(r['subject'])}:${Utils.shorten(r['matType'])}:${Utils.shorten(r['materialId'])}',
          );
        }
      }
      kb.row().add(S.get('btn_back', lang), 'back:main');
      await ctx.reply(
        S.get('search_results_title', lang, {'query': query}),
        replyMarkup: kb,
        parseMode: ParseMode.markdown,
      );
      break;

    // ---- Contributor Quick Add Lecture (by name/text) ----------------
    case 'contrib_quick_add_name':
      state['lecture_name'] = text.trim();
      state['action'] = 'contrib_quick_add_desc';
      await ctx.reply(S.get('quick_add_desc_prompt', lang));
      break;

    case 'contrib_quick_add_desc':
      final qTrack = state['track'] as String? ?? '';
      final qSubject = state['subject'] as String? ?? '';
      final qType = state['type'] as String? ?? 'ظ…ظ„ط®طµ';
      final qName = state['lecture_name'] as String? ?? 'ظ…ط­ط§ط¶ط±ط©';
      final desc = text.trim().toLowerCase() == 'طھط®ط·ظٹ' || text.trim().toLowerCase() == 'skip'
          ? ''
          : text.trim();
      Utils.clearUploadState(userId);

      final isLink = desc.startsWith('http://') || desc.startsWith('https://');
      final fType = isLink ? 'link' : 'text';

      final matId = await FirebaseDb.addMaterial(qTrack, qSubject, qType, {
        'name': qName,
        'file_id': desc.isNotEmpty ? desc : qName,
        'file_type': fType,
        'description': desc,
        'added_by': userId.toString(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (matId != null) {
        await FirebaseDb.addContributorMaterialRef(userId, matId, {
          'track': qTrack,
          'subject': qSubject,
          'type': qType,
          'name': qName,
          'file_id': desc.isNotEmpty ? desc : qName,
          'file_type': fType,
        });

        // Notify subscribers
        final subscribers = await FirebaseDb.getSubjectSubscribers(qSubject);
        if (subscribers.isNotEmpty) {
          final notifyText = 'ًں”” ط¥ط¶ط§ظپط© ط¬ط¯ظٹط¯ط©!\n\nطھظ…طھ ط¥ط¶ط§ظپط©: **$qName** ظپظٹ ظ…ط§ط¯ط©: **$qSubject**\nط§ظ„ظ†ظˆط¹: $qType\n\nطھظپط¶ظ„ ط¨ط²ظٹط§ط±ط© ط§ظ„ط¨ظˆطھ ظ„ظ„ط§ط·ظ„ط§ط¹ ط¹ظ„ظٹظ‡ط§.';
          Utils.broadcast(bot, subscribers, notifyText);
        }

        final backKb = InlineKeyboard().row().add(S.get('btn_back_dashboard', lang), 'contrib_dash');
        await ctx.reply(
          S.get('quick_add_success', lang, {
            'name': qName,
            'track': qTrack,
            'subject': qSubject,
            'type': qType,
          }),
          replyMarkup: backKb,
        );
      } else {
        await ctx.reply(S.get('upload_failed', lang));
      }
      break;

    // ---- Upload flow: new track / subject typed manually â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    case 'upload_admin_track':
      state['action'] = 'upload_admin_subject';
      state['track'] = text;
      await ctx.reply(S.get('upload_enter_subject', lang));
      break;

    case 'upload_admin_subject':
      final track = state['track'] as String? ?? '';
      final subject = text;
      state['subject'] = subject;
      state['action'] = 'wait_for_upload_type';

      // Fetch dynamic material types
      final types = await FirebaseDb.getMaterialTypes(track, subject);
      if (types.isEmpty) {
        await ctx.reply(S.get('upload_no_types', lang)); 
        Utils.clearUploadState(userId);
        break;
      }

      final kb = InlineKeyboard();
      for (var t in types) {
        kb.row().add(t, 'up_type:$t');
      }
      await ctx.reply(
        S.get('upload_selected_track', lang, {'track': track}),
        replyMarkup: kb,
      );
      break;

    // ---- Material name: contributor provides a name -----------------
    case 'wait_for_upload_name':
      state['material_name'] = text;
      final type = state['type'] as String? ?? '';
      
      // Move any pending single file into the files list
      final pendingFile = state['pending_file'] as Map<String, dynamic>?;
      final List<Map<String, dynamic>> files = [];
      if (pendingFile != null) {
        files.add(pendingFile);
        state.remove('pending_file');
      }
      state['files'] = files;

      if (type == 'ط±ط§ط¨ط·' || type.toLowerCase() == 'link') {
        // Switch to link mode
        state['action'] = 'contrib_upload_link';
        await ctx.reply(S.get('upload_link_prompt', lang));
      } else {
        state['action'] = 'collect_files';
        final doneKb = InlineKeyboard().row()
          .add(S.get('btn_done_uploading', lang), 'contrib_upload_done');

        if (files.isNotEmpty) {
          await ctx.reply(
            S.get('upload_file_received_count', lang, {'count': '${files.length}'}),
            replyMarkup: doneKb,
          );
        } else {
          await ctx.reply(
            S.get('upload_collecting_files', lang),
            replyMarkup: doneKb,
          );
        }
      }
      break;

    // â”€â”€ Edit: Auth code verification â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    case 'edit_auth_code_check':
      final inputCode = text.trim();
      final codeRes = await FirebaseDb.verifyAndConsumeAuthCode(inputCode);
      if (codeRes != 'valid') {
        final retryKb = InlineKeyboard().row().add(S.get('btn_cancel_action', lang), 'edt_cancel');
        String errMsg = S.get('edit_auth_invalid', lang);
        if (codeRes == 'expired_time') {
          errMsg = S.get('edit_auth_expired_time', lang);
        } else if (codeRes == 'expired_uses') {
          errMsg = S.get('edit_auth_expired_uses', lang);
        }
        await ctx.reply(errMsg, replyMarkup: retryKb);
        // Stay in state so user can try again
        return;
      }
      // Code correct â€” proceed to action
      final pendingAction = state.remove('pending_action') as String? ?? '';
      state['auth_verified'] = true;

      if (pendingAction == 'rename') {
        state['action'] = 'edit_rename_input';
        final cancelKb = InlineKeyboard().row().add(S.get('btn_cancel_action', lang), 'edt_cancel');
        await ctx.reply(S.get('edit_rename_prompt', lang), replyMarkup: cancelKb);
      } else if (pendingAction == 'delete') {
        state['action'] = 'edit_delete_confirm';
        final matName = state['edit_mat_name'] as String? ?? 'ط§ظ„ظ…ظ„ظپ';
        final kb = InlineKeyboard()
          .row()
          .add('âœ… ظ†ط¹ظ…طŒ ط§ط­ط°ظپ ط§ظ„ظ…ظ„ظپ', 'edt_delete_confirm')
          .add('â‌Œ ط¥ظ„ط؛ط§ط،', 'edt_delete_cancel');
        await ctx.reply(
          S.get('edit_delete_confirm', lang, {'name': matName}),
          replyMarkup: kb,
          parseMode: ParseMode.markdown,
        );
      } else if (pendingAction == 'move') {
        state['action'] = 'edit_move_pick_track';
        final tracks = await FirebaseDb.getTracks();
        final keyboard = Utils.paginateKeyboard(
          tracks,
          page: 0,
          prefix: 'emv_track:',
          backData: 'edt_cancel',
          lang: lang,
        );
        await ctx.reply(
          S.get('edit_move_select_track', lang),
          replyMarkup: keyboard,
          parseMode: ParseMode.markdown,
        );
      }
      break;

    // â”€â”€ Edit: Rename input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    case 'edit_rename_input':
      final newName = text.trim();
      if (newName.isEmpty) {
        await ctx.reply(S.get('edit_rename_prompt', lang));
        return;
      }
      state['pending_new_name'] = newName;
      final oldName = state['edit_mat_name'] as String? ?? 'ط§ظ„ظ…ظ„ظپ';
      final kb = InlineKeyboard()
        .row().add(S.get('btn_save_done', lang), 'edt_rename_save')
        .row().add(S.get('btn_change_name', lang), 'edt_rename_retry')
        .row().add(S.get('btn_cancel_action', lang), 'edt_cancel');
      await ctx.reply(
        S.get('edit_rename_confirm', lang, {'oldName': oldName, 'newName': newName}),
        replyMarkup: kb,
        parseMode: ParseMode.markdown,
      );
      break;

    // â”€â”€ Edit: Move â€” new name input â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    case 'edit_move_name_input':
      final moveName = text.trim();
      if (moveName.isEmpty) return;
      state['pending_move_name'] = moveName;
      final mTrack = state['edit_track'] as String? ?? '';
      final mSubject = state['edit_subject'] as String? ?? '';
      final mType = state['edit_type'] as String? ?? '';
      final mNewTrack = state['move_new_track'] as String? ?? '';
      final mNewSubject = state['move_new_subject'] as String? ?? '';
      final mNewType = state['move_new_type'] as String? ?? '';

      final kb = InlineKeyboard()
        .row().add(S.get('btn_save_move', lang), 'emv_confirm_save')
        .row().add(S.get('btn_change_name', lang), 'emv_ask_name')
        .row().add(S.get('btn_cancel_action', lang), 'edt_cancel');
      await ctx.reply(
        S.get('edit_move_confirm', lang, {
          'name': moveName,
          'oldTrack': mTrack,
          'oldSubject': mSubject,
          'oldType': mType,
          'newTrack': mNewTrack,
          'newSubject': mNewSubject,
          'newType': mNewType,
        }),
        replyMarkup: kb,
        parseMode: ParseMode.markdown,
      );
      break;
    // ---- Link upload: user pastes URL --------------------------------
    case 'contrib_upload_link':
      final track2 = (state['track'] as String?) ?? '';
      final subject2 = (state['subject'] as String?) ?? '';
      final type2 = (state['type'] as String?) ?? 'ط±ط§ط¨ط·';
      Utils.clearUploadState(userId);

      final url = text.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        await ctx.reply(S.get('upload_link_invalid', lang));
        break;
      }

      final linkName = url.length > 60 ? '${url.substring(0, 60)}â€¦' : url;
      final materialName = (state['material_name'] as String?) ?? linkName;
      final materialId = await FirebaseDb.addMaterial(track2, subject2, type2, {
        'name': materialName,
        'file_id': url,
        'file_type': 'link',
        'added_by': userId.toString(),
      });

      if (materialId != null) {
        await FirebaseDb.addContributorMaterialRef(userId, materialId, {
          'track': track2,
          'subject': subject2,
          'type': type2,
          'name': materialName,
          'file_id': url,
          'file_type': 'link'
        });

        // Send notifications to subscribers
        final subscribers = await FirebaseDb.getSubjectSubscribers(subject2);
        if (subscribers.isNotEmpty) {
          final text = 'ًں”” ط¥ط¶ط§ظپط© ط¬ط¯ظٹط¯ط©!\n\nطھظ…طھ ط¥ط¶ط§ظپط© ظ…ظ„ظپ ط¬ط¯ظٹط¯ ظپظٹ ظ…ط§ط¯ط©: **$subject2**\nط§ظ„ظ†ظˆط¹: $type2\n\nظ‚ظ… ط¨ط²ظٹط§ط±ط© ط§ظ„ط¨ظˆطھ ظ„طھظپظ‚ط¯ظ‡ط§.';
          Utils.broadcast(bot, subscribers, text);
        }

        await ctx.reply(S.get('upload_multi_success', lang, {
          'count': '1',
          'subject': subject2,
          'track': track2,
          'type': type2,
        }));
      } else {
        await ctx.reply(S.get('upload_failed', lang));
      }
      break;
  }
}

void registerContributorUploadHandlers(Bot bot) {
  // â”€â”€ Upload track/subject/type keyboard callbacks â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  bot.callbackQuery(RegExp(r'^up_track:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;

    final state = Utils.uploadStates[userId];
    if (state == null || state['action'] != 'wait_for_upload_track') return;

    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final trackRaw = data.substring('up_track:'.length);

    if (trackRaw.startsWith('page_')) {
      final page = int.parse(trackRaw.split('_')[1]);
      final tracks = await FirebaseDb.getTracks();
      final keyboard = Utils.paginateKeyboard(
        tracks,
        page: page,
        prefix: 'up_track:',
        backData: 'contrib_dash',
        lang: lang,
      );
      await ctx.editMessageText(
        S.get('contrib_add_subject_prompt', lang),
        replyMarkup: keyboard,
      );
      return;
    }

    final track = Utils.lengthen(trackRaw);
    state['track'] = track;
    state['action'] = 'wait_for_upload_subject';

    final subjects = await FirebaseDb.getSubjects(track);
    if (subjects.isEmpty) {
      await ctx.answerCallbackQuery(
          text: S.get('upload_no_subjects', lang), showAlert: true);
      Utils.clearUploadState(userId);
      return;
    }

    final keyboard = Utils.paginateKeyboard(
      subjects,
      page: 0,
      prefix: 'up_subj:',
      backData: 'contrib_add_subject',
      lang: lang,
    );

    await ctx.editMessageText(
      S.get('upload_selected_track', lang, {'track': track}),
      replyMarkup: keyboard,
    );
  });

  bot.callbackQuery(RegExp(r'^up_subj:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;

    final state = Utils.uploadStates[userId];
    if (state == null || state['action'] != 'wait_for_upload_subject') return;

    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final subjRaw = data.substring('up_subj:'.length);
    final track = state['track'] as String? ?? '';

    if (subjRaw.startsWith('page_')) {
      final page = int.parse(subjRaw.split('_')[1]);
      final subjects = await FirebaseDb.getSubjects(track);
      final keyboard = Utils.paginateKeyboard(
        subjects,
        page: page,
        prefix: 'up_subj:',
        backData: 'contrib_add_subject',
        lang: lang,
      );
      await ctx.editMessageText(
        S.get('upload_selected_track', lang, {'track': track}),
        replyMarkup: keyboard,
      );
      return;
    }

    final subject = Utils.lengthen(subjRaw);
    state['subject'] = subject;
    state['action'] = 'wait_for_upload_type';

    // Fetch dynamic material types
    final types = await FirebaseDb.getMaterialTypes(track, subject);
    if (types.isEmpty) {
      await ctx.answerCallbackQuery(
          text: S.get('upload_no_types', lang), showAlert: true);
      Utils.clearUploadState(userId);
      return;
    }

    final keyboard = Utils.paginateKeyboard(
      types,
      page: 0,
      prefix: 'up_type:',
      backData: 'up_track:${Utils.shorten(track)}',
      lang: lang,
    );

    await ctx.editMessageText(
      S.get('upload_selected_subject', lang, {'subject': subject}),
      replyMarkup: keyboard,
    );
  });

  bot.callbackQuery(RegExp(r'^up_type:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;

    final state = Utils.uploadStates[userId];
    if (state == null || state['action'] != 'wait_for_upload_type') return;

    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final typeRaw = data.substring('up_type:'.length);
    final track = state['track'] as String? ?? '';
    final subject = state['subject'] as String? ?? '';

    if (typeRaw.startsWith('page_')) {
      final page = int.parse(typeRaw.split('_')[1]);
      final types = await FirebaseDb.getMaterialTypes(track, subject);
      final keyboard = Utils.paginateKeyboard(
        types,
        page: page,
        prefix: 'up_type:',
        backData: 'up_track:${Utils.shorten(track)}',
        lang: lang,
      );
      await ctx.editMessageText(
        S.get('upload_selected_subject', lang, {'subject': subject}),
        replyMarkup: keyboard,
      );
      return;
    }

    final type = Utils.lengthen(typeRaw);
    state['type'] = type;
    state['action'] = 'wait_for_upload_name';

    await ctx.editMessageText(S.get('upload_enter_name', lang));
  });

  // â”€â”€ Add Subject button (from contributor dashboard) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('contrib_add_subject', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    final isContributor = await FirebaseDb.isContributor(userId);
    final isAdmin = await FirebaseDb.isAdmin(userId);
    if (!isContributor && !isAdmin) {
      await ctx.answerCallbackQuery(
          text: S.get('no_permission_upload', lang), showAlert: true);
      return;
    }

    Utils.uploadStates[userId] = {
      'action': 'wait_for_upload_track',
    };

    final tracks = await FirebaseDb.getTracks();
    if (tracks.isEmpty) {
      await ctx.answerCallbackQuery(
          text: S.get('upload_no_categories', lang), showAlert: true);
      Utils.clearUploadState(userId);
      return;
    }

    final keyboard = Utils.paginateKeyboard(
      tracks,
      page: 0,
      prefix: 'up_track:',
      backData: 'contrib_dash',
      lang: lang,
    );

    await ctx.editMessageText(
      S.get('contrib_add_subject_prompt', lang),
      replyMarkup: keyboard,
    );
  });

  // â”€â”€ Done uploading â†’ save all collected files â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('contrib_upload_done', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    final state = Utils.uploadStates[userId];
    if (state == null || state['action'] != 'collect_files') {
      await ctx.answerCallbackQuery();
      return;
    }

    final track = (state['track'] as String?) ?? '';
    final subject = (state['subject'] as String?) ?? '';
    final type = (state['type'] as String?) ?? '';
    final files = (state['files'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    await ctx.answerCallbackQuery();

    if (files.isEmpty) {
      await ctx.editMessageText(S.get('upload_no_files', lang));
      Utils.clearUploadState(userId);
      return;
    }

    int savedCount = 0;
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fId = file['fileId'] as String;
      final fType = file['fileType'] as String;
      final materialName = (state['material_name'] as String?) ?? type;
      final autoName = files.length == 1 ? materialName : '$materialName ${i + 1}';

      final backupFileId = await _backupFile(bot, fId, fType);
      final matId = await FirebaseDb.addMaterial(track, subject, type, {
        'name': autoName,
        'file_id': backupFileId ?? fId,
        'file_type': fType,
        'added_by': userId.toString(),
      });

      if (matId != null) {
        await FirebaseDb.addContributorMaterialRef(userId, matId, {
          'track': track,
          'subject': subject,
          'type': type,
          'name': autoName,
          'file_id': backupFileId ?? fId,
          'file_type': fType
        });
        savedCount++;
      }
    }

    // Send notifications to subscribers
    final subscribers = await FirebaseDb.getSubjectSubscribers(subject);
    if (subscribers.isNotEmpty) {
      final text = 'ًں”” ط¥ط¶ط§ظپط© ط¬ط¯ظٹط¯ط©!\n\nطھظ…طھ ط¥ط¶ط§ظپط© ظ…ظ„ظپ ط¬ط¯ظٹط¯ ظپظٹ ظ…ط§ط¯ط©: **$subject**\nط§ظ„ظ†ظˆط¹: $type\n\nظ‚ظ… ط¨ط²ظٹط§ط±ط© ط§ظ„ط¨ظˆطھ ظ„طھظپظ‚ط¯ظ‡ط§.';
      Utils.broadcast(bot, subscribers, text);
    }

    Utils.clearUploadState(userId);
    await ctx.editMessageText(S.get('upload_multi_success', lang, {
      'count': '$savedCount',
      'subject': subject,
      'track': track,
      'type': type,
    }));
  });

  // â”€â”€ File upload handlers (all types) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  bot.onAudio((ctx) async {
    final fileId = ctx.message?.audio?.fileId;
    if (fileId != null) await _handleUploadFlow(bot, ctx, fileId, 'audio');
  });

  bot.onVoice((ctx) async {
    final fileId = ctx.message?.voice?.fileId;
    if (fileId != null) await _handleUploadFlow(bot, ctx, fileId, 'voice');
  });

  // â”€â”€ Contributor Dashboard callbacks â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
      final kb = InlineKeyboard().row().add(S.get('btn_back_dashboard', lang), 'contrib_dash');
      await ctx.editMessageText(S.get('contrib_no_materials', lang), replyMarkup: kb);
      return;
    }

    final tracks = materials.values.map((v) => v['track'] as String).toSet().toList();
    final keyboard = Utils.paginateKeyboard(
      tracks,
      page: 0,
      prefix: 'c_mat_track:',
      backData: 'contrib_dash',
      lang: lang,
    );
    keyboard.row().add('ًں—‘ï¸ڈ ظ…ط³ط­ ط¬ظ…ظٹط¹ ظ…ظˆط§ط¯ظٹ', 'c_del_all_mats_confirm');

    await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ:\nط§ط®طھط± ط§ظ„ظ…ط³ط§ط±:', replyMarkup: keyboard);
  });

  // Bulk Delete: All Materials
  bot.callbackQuery('c_del_all_mats_confirm', (ctx) async {
    final keyboard = InlineKeyboard()
        .row().add('âڑ ï¸ڈ ظ†ط¹ظ…طŒ ط§ط­ط°ظپ ط¬ظ…ظٹط¹ ظ…ظˆط§ط¯ظٹ', 'c_del_all_mats_exec')
        .row().add('ًں”™ طھط±ط§ط¬ط¹', 'contrib_materials');
    await ctx.editMessageText('ظ‡ظ„ ط£ظ†طھ ظ…طھط£ظƒط¯ ظ…ظ† ط±ط؛ط¨طھظƒ ظپظٹ ط­ط°ظپ **ط¬ظ…ظٹط¹** ط§ظ„ظ…ظˆط§ط¯ ط§ظ„طھظٹ ظ‚ظ…طھ ط¨ط±ظپط¹ظ‡ط§طں ظ„ط§ ظٹظ…ظƒظ† ط§ظ„طھط±ط§ط¬ط¹ ط¹ظ† ظ‡ط°ط§ ط§ظ„ط¥ط¬ط±ط§ط،.', replyMarkup: keyboard, parseMode: ParseMode.markdown);
  });

  bot.callbackQuery('c_del_all_mats_exec', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    await ctx.editMessageText('ط¬ط§ط±ظٹ ط§ظ„ط­ط°ظپ...');
    await FirebaseDb.deleteAllContributorMaterials(userId);
    final kb = InlineKeyboard().row().add(S.get('btn_back_dashboard', lang), 'contrib_dash');
    await ctx.editMessageText('âœ… طھظ… ط­ط°ظپ ط¬ظ…ظٹط¹ ظ…ظˆط§ط¯ظƒ ط¨ظ†ط¬ط§ط­.', replyMarkup: kb);
  });

  // Bulk Delete: Track Materials
  bot.callbackQuery(RegExp(r'^c_del_track_mats_confirm:(.+)'), (ctx) async {
    final raw = ctx.callbackQuery!.data!.substring('c_del_track_mats_confirm:'.length);
    final track = Utils.lengthen(raw);
    final keyboard = InlineKeyboard()
        .row().add('âڑ ï¸ڈ ظ†ط¹ظ…طŒ ط§ط­ط°ظپ ظ…ظˆط§ط¯ ظ…ط³ط§ط± $track', 'c_del_track_mats_exec:${Utils.shorten(track)}')
        .row().add('ًں”™ طھط±ط§ط¬ط¹', 'c_mat_track:${Utils.shorten(track)}');
    await ctx.editMessageText('ظ‡ظ„ ط£ظ†طھ ظ…طھط£ظƒط¯ ظ…ظ† ط±ط؛ط¨طھظƒ ظپظٹ ط­ط°ظپ ط¬ظ…ظٹط¹ ظ…ظˆط§ط¯ظƒ ظپظٹ ظ…ط³ط§ط± **$track**طں ظ„ط§ ظٹظ…ظƒظ† ط§ظ„طھط±ط§ط¬ط¹ ط¹ظ† ظ‡ط°ط§ ط§ظ„ط¥ط¬ط±ط§ط،.', replyMarkup: keyboard, parseMode: ParseMode.markdown);
  });

  bot.callbackQuery(RegExp(r'^c_del_track_mats_exec:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    final raw = ctx.callbackQuery!.data!.substring('c_del_track_mats_exec:'.length);
    final track = Utils.lengthen(raw);
    if (userId == null) return;
    
    await ctx.editMessageText('ط¬ط§ط±ظٹ ط§ظ„ط­ط°ظپ...');
    final materials = await FirebaseDb.getContributorMaterials(userId);
    for (var entry in materials.entries) {
      final matId = entry.key;
      final data = entry.value;
      if (data['track'] == track) {
        final subject = data['subject'] as String? ?? '';
        final type = data['type'] as String? ?? '';
        await FirebaseDb.deleteMaterial(track, subject, type, matId);
        await FirebaseDb.removeContributorMaterialRef(userId, matId);
      }
    }
    
    final keyboard = InlineKeyboard().row().add('ًں”™ ط±ط¬ظˆط¹ ط¥ظ„ظ‰ ظ…ظˆط§ط¯ظٹ', 'contrib_materials');
    await ctx.editMessageText('âœ… طھظ… ط­ط°ظپ ط¬ظ…ظٹط¹ ظ…ظˆط§ط¯ ظ…ط³ط§ط± $track ط¨ظ†ط¬ط§ط­.', replyMarkup: keyboard);
  });

  bot.callbackQuery(RegExp(r'^c_mat_track:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    final data = ctx.callbackQuery?.data;
    if (userId == null || data == null) return;
    final lang = Utils.getUserLanguage(userId);
    final trackRaw = data.substring('c_mat_track:'.length);

    if (trackRaw.startsWith('page_')) {
      final page = int.parse(trackRaw.split('_')[1]);
      final materials = await FirebaseDb.getContributorMaterials(userId);
      final tracks = materials.values.map((v) => v['track'] as String).toSet().toList();
      final keyboard = Utils.paginateKeyboard(
        tracks,
        page: page,
        prefix: 'c_mat_track:',
        backData: 'contrib_dash',
        lang: lang,
      );
      keyboard.row().add('ًں—‘ï¸ڈ ظ…ط³ط­ ط¬ظ…ظٹط¹ ظ…ظˆط§ط¯ظٹ', 'c_del_all_mats_confirm');
      await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ:\nط§ط®طھط± ط§ظ„ظ…ط³ط§ط±:', replyMarkup: keyboard);
      return;
    }

    final track = Utils.lengthen(trackRaw);
    final materials = await FirebaseDb.getContributorMaterials(userId);
    final subjects = materials.values
        .where((v) => v['track'] == track)
        .map((v) => v['subject'] as String)
        .toSet()
        .toList();

    final keyboard = Utils.paginateKeyboard(
      subjects,
      page: 0,
      prefix: 'c_mat_subj:${Utils.shorten(track)}:',
      backData: 'contrib_materials',
      lang: lang,
    );
    keyboard.row().add('ًں—‘ï¸ڈ ظ…ط³ط­ ط¬ظ…ظٹط¹ ظ…ظˆط§ط¯ ط§ظ„ظ…ط³ط§ط±', 'c_del_track_mats_confirm:${Utils.shorten(track)}');

    await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ - $track:\nط§ط®طھط± ط§ظ„ظ…ط§ط¯ط©:', replyMarkup: keyboard);
  });

  bot.callbackQuery(RegExp(r'^c_mat_subj:(.*?):(.*)'), (ctx) async {
    final userId = ctx.from?.id;
    final data = ctx.callbackQuery?.data;
    if (userId == null || data == null) return;
    final lang = Utils.getUserLanguage(userId);
    
    final parts = data.split(':');
    final track = Utils.lengthen(parts[1]);
    final subjRaw = parts[2];
    
    final materials = await FirebaseDb.getContributorMaterials(userId);

    if (subjRaw.startsWith('page_')) {
      final page = int.parse(subjRaw.split('_')[1]);
      final subjects = materials.values
          .where((v) => v['track'] == track)
          .map((v) => v['subject'] as String)
          .toSet()
          .toList();

      final keyboard = Utils.paginateKeyboard(
        subjects,
        page: page,
        prefix: 'c_mat_subj:${Utils.shorten(track)}:',
        backData: 'contrib_materials',
        lang: lang,
      );
      keyboard.row().add('ًں—‘ï¸ڈ ظ…ط³ط­ ط¬ظ…ظٹط¹ ظ…ظˆط§ط¯ ط§ظ„ظ…ط³ط§ط±', 'c_del_track_mats_confirm:${Utils.shorten(track)}');

      await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ - $track:\nط§ط®طھط± ط§ظ„ظ…ط§ط¯ط©:', replyMarkup: keyboard);
      return;
    }

    final subject = Utils.lengthen(subjRaw);
    final types = materials.values
        .where((v) => v['track'] == track && v['subject'] == subject)
        .map((v) => v['type'] as String)
        .toSet()
        .toList();

    final keyboard = Utils.paginateKeyboard(
      types,
      page: 0,
      prefix: 'c_mat_type:${Utils.shorten(track)}:${Utils.shorten(subject)}:',
      backData: 'c_mat_track:${Utils.shorten(track)}',
      lang: lang,
    );

    await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ - $subject:\nط§ط®طھط± ط§ظ„ظ†ظˆط¹:', replyMarkup: keyboard);
  });

  bot.callbackQuery(RegExp(r'^c_mat_type:(.*?):(.*?):(.*)'), (ctx) async {
    final userId = ctx.from?.id;
    final data = ctx.callbackQuery?.data;
    if (userId == null || data == null) return;
    final lang = Utils.getUserLanguage(userId);
    
    final parts = data.split(':');
    final track = Utils.lengthen(parts[1]);
    final subject = Utils.lengthen(parts[2]);
    final typeRaw = parts[3];
    
    final materials = await FirebaseDb.getContributorMaterials(userId);

    if (typeRaw.startsWith('page_')) {
      final page = int.parse(typeRaw.split('_')[1]);
      final types = materials.values
          .where((v) => v['track'] == track && v['subject'] == subject)
          .map((v) => v['type'] as String)
          .toSet()
          .toList();

      final keyboard = Utils.paginateKeyboard(
        types,
        page: page,
        prefix: 'c_mat_type:${Utils.shorten(track)}:${Utils.shorten(subject)}:',
        backData: 'c_mat_track:${Utils.shorten(track)}',
        lang: lang,
      );

      await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ - $subject:\nط§ط®طھط± ط§ظ„ظ†ظˆط¹:', replyMarkup: keyboard);
      return;
    }

    final type = Utils.lengthen(typeRaw);
    final mats = materials.entries
        .where((e) => e.value['track'] == track && e.value['subject'] == subject && e.value['type'] == type)
        .toList();

    final itemsList = mats.map((e) {
      final matId = e.key;
      final name = (e.value['name'] as String?) ?? matId;
      return MapEntry(matId, '$name ًں—‘ï¸ڈ');
    }).toList();

    final keyboard = Utils.paginateMapKeyboard(
      itemsList,
      page: 0,
      prefix: 'c_dmat:${Utils.shorten(track)}:${Utils.shorten(subject)}:${Utils.shorten(type)}:',
      backData: 'c_mat_subj:${Utils.shorten(track)}:${Utils.shorten(subject)}',
      lang: lang,
    );

    await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ - $type:\nط§ط®طھط± ط§ظ„ظ…ظ„ظپ ظ„ط­ط°ظپظ‡:', replyMarkup: keyboard);
  });

  bot.callbackQuery(RegExp(r'^c_dmat:(.*?):(.*?):(.*?):(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    final userId = ctx.from?.id;
    if (data == null || userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    final parts = data.split(':');
    final track = Utils.lengthen(parts[1]);
    final subject = Utils.lengthen(parts[2]);
    final type = Utils.lengthen(parts[3]);
    final rawId = parts[4];

    final materials = await FirebaseDb.getContributorMaterials(userId);

    if (rawId.startsWith('page_')) {
      final page = int.parse(rawId.split('_')[1]);
      final mats = materials.entries
          .where((e) => e.value['track'] == track && e.value['subject'] == subject && e.value['type'] == type)
          .toList();
      final itemsList = mats.map((e) {
        final id = e.key;
        final name = (e.value['name'] as String?) ?? id;
        return MapEntry(id, '$name ًں—‘ï¸ڈ');
      }).toList();

      final keyboard = Utils.paginateMapKeyboard(
        itemsList,
        page: page,
        prefix: 'c_dmat:${Utils.shorten(track)}:${Utils.shorten(subject)}:${Utils.shorten(type)}:',
        backData: 'c_mat_subj:${Utils.shorten(track)}:${Utils.shorten(subject)}',
        lang: lang,
      );
      await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ - $type:\nط§ط®طھط± ط§ظ„ظ…ظ„ظپ ظ„ط­ط°ظپظ‡:', replyMarkup: keyboard);
      return;
    }

    final matId = Utils.lengthen(rawId);
    await FirebaseDb.deleteMaterial(track, subject, type, matId);
    await FirebaseDb.removeContributorMaterialRef(userId, matId);

    await ctx.answerCallbackQuery(text: S.get('material_delete_toast', lang), showAlert: false);

    // Refresh materials list for the current type
    final refreshedMaterials = await FirebaseDb.getContributorMaterials(userId);
    final mats = refreshedMaterials.entries
        .where((e) => e.value['track'] == track && e.value['subject'] == subject && e.value['type'] == type)
        .toList();

    if (mats.isEmpty) {
      final types = refreshedMaterials.values
          .where((v) => v['track'] == track && v['subject'] == subject)
          .map((v) => v['type'] as String)
          .toSet()
          .toList();
      
      if (types.isEmpty) {
         if (refreshedMaterials.isEmpty) {
            final kb = InlineKeyboard().row().add(S.get('btn_back_dashboard', lang), 'contrib_dash');
            await ctx.editMessageText(S.get('contrib_no_materials', lang), replyMarkup: kb);
         } else {
            final tracks = refreshedMaterials.values.map((v) => v['track'] as String).toSet().toList();
            final keyboard = Utils.paginateKeyboard(
              tracks,
              page: 0,
              prefix: 'c_mat_track:',
              backData: 'contrib_dash',
              lang: lang,
            );
            keyboard.row().add('ًں—‘ï¸ڈ ظ…ط³ط­ ط¬ظ…ظٹط¹ ظ…ظˆط§ط¯ظٹ', 'c_del_all_mats_confirm');
            await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ:\nط§ط®طھط± ط§ظ„ظ…ط³ط§ط±:', replyMarkup: keyboard);
         }
      } else {
          final keyboard = Utils.paginateKeyboard(
            types,
            page: 0,
            prefix: 'c_mat_type:${Utils.shorten(track)}:${Utils.shorten(subject)}:',
            backData: 'c_mat_track:${Utils.shorten(track)}',
            lang: lang,
          );
          await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ - $subject:\nط§ط®طھط± ط§ظ„ظ†ظˆط¹:', replyMarkup: keyboard);
      }
      return;
    }

    final itemsList = mats.map((e) {
      final id = e.key;
      final name = (e.value['name'] as String?) ?? id;
      return MapEntry(id, '$name ًں—‘ï¸ڈ');
    }).toList();

    final keyboard = Utils.paginateMapKeyboard(
      itemsList,
      page: 0,
      prefix: 'c_dmat:${Utils.shorten(track)}:${Utils.shorten(subject)}:${Utils.shorten(type)}:',
      backData: 'c_mat_subj:${Utils.shorten(track)}:${Utils.shorten(subject)}',
      lang: lang,
    );

    await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ - $type:\nط§ط®طھط± ط§ظ„ظ…ظ„ظپ ظ„ط­ط°ظپظ‡:', replyMarkup: keyboard);
  });

  bot.callbackQuery(RegExp(r'^contrib_del_mat:(.*?):(.*?):(.*?):(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    final userId = ctx.from?.id;
    if (data == null || userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    final parts = data.split(':');
    final matId = Utils.lengthen(parts[1]);
    final track = Utils.lengthen(parts[2]);
    final subject = Utils.lengthen(parts[3]);
    final type = Utils.lengthen(parts[4]);

    await FirebaseDb.deleteMaterial(track, subject, type, matId);
    await FirebaseDb.removeContributorMaterialRef(userId, matId);

    await ctx.answerCallbackQuery(text: S.get('material_delete_toast', lang), showAlert: false);

    // Refresh materials list for the current type
    final materials = await FirebaseDb.getContributorMaterials(userId);
    final mats = materials.entries
        .where((e) => e.value['track'] == track && e.value['subject'] == subject && e.value['type'] == type)
        .toList();

    if (mats.isEmpty) {
      // Check if there are other types in the subject
      final types = materials.values
          .where((v) => v['track'] == track && v['subject'] == subject)
          .map((v) => v['type'] as String)
          .toSet()
          .toList();
      
      if (types.isEmpty) {
         // Return to tracks or dashboard depending on if it's fully empty
         if (materials.isEmpty) {
            final kb = InlineKeyboard().row().add(S.get('btn_back_dashboard', lang), 'contrib_dash');
            await ctx.editMessageText(S.get('contrib_no_materials', lang), replyMarkup: kb);
         } else {
            // Jump back to tracks list as a safe fallback
            final tracks = materials.values.map((v) => v['track'] as String).toSet().toList();
            final keyboard = InlineKeyboard();
            for (var t in tracks) {
              keyboard.row().add(t, 'c_mat_track:$t');
            }
            keyboard.row().add(S.get('btn_back_dashboard', lang), 'contrib_dash');
            await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ:\nط§ط®طھط± ط§ظ„ظ…ط³ط§ط±:', replyMarkup: keyboard);
         }
      } else {
          final keyboard = InlineKeyboard();
          for (var t in types) {
            keyboard.row().add(t, 'c_mat_type:$track:$subject:$t');
          }
          keyboard.row().add('ًں”™ ط±ط¬ظˆط¹', 'c_mat_track:$track');
          await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ - $subject:\nط§ط®طھط± ط§ظ„ظ†ظˆط¹:', replyMarkup: keyboard);
      }
      return;
    }

    final keyboard = InlineKeyboard();
    for (var e in mats) {
      final id = e.key;
      final name = e.value['name'] as String? ?? id;
      keyboard.row().add('$name ًں—‘ï¸ڈ', 'contrib_del_mat:${Utils.shorten(id)}:${Utils.shorten(track)}:${Utils.shorten(subject)}:${Utils.shorten(type)}');
    }
    keyboard.row().add('ًں”™ ط±ط¬ظˆط¹', 'c_mat_subj:$track:$subject');

    await ctx.editMessageText('ًں“‹ ظ…ظˆط§ط¯ظٹ - $type:\nط§ط®طھط± ط§ظ„ظ…ظ„ظپ ظ„ط­ط°ظپظ‡:', replyMarkup: keyboard);
  });

  // â”€â”€ Contributor Analytics (NEW FEATURE) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('contrib_analytics', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    await ctx.answerCallbackQuery();

    final materials = await FirebaseDb.getContributorMaterials(userId);
    if (materials.isEmpty) {
      final backKb = InlineKeyboard().row().add(S.get('btn_back_dashboard', lang), 'contrib_dash');
      await ctx.editMessageText('ًں“ٹ ظ„ظٹط³ ظ„ط¯ظٹظƒ ط£ظٹ ظ…ظˆط§ط¯ ظ…ط±ظپظˆط¹ط© ظ„ط¹ط±ط¶ ط¥ط­طµط§ط¦ظٹط§طھظ‡ط§ ط¨ط¹ط¯.', replyMarkup: backKb);
      return;
    }

    final stats = await FirebaseDb.getStats();
    final topMaterials = stats['topMaterials'] as Map<String, dynamic>? ?? {};

    int totalViews = 0;
    final accessedList = <Map<String, dynamic>>[];

    for (var entry in materials.entries) {
      final matId = entry.key;
      final mData = entry.value as Map<String, dynamic>;
      final mName = mData['name']?.toString() ?? matId;
      int count = 0;
      if (topMaterials.containsKey(matId)) {
        final topEntry = topMaterials[matId];
        if (topEntry is Map && topEntry['count'] != null) {
          count = topEntry['count'] as int;
        }
      }
      totalViews += count;
      if (count > 0) {
        accessedList.add({'name': mName, 'count': count});
      }
    }

    accessedList.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    String msg = 'ًں“ٹ *ط¥ط­طµط§ط¦ظٹط§طھ ظ…ظˆط§ط¯ظٹ ظˆطھظپط§ط¹ظ„ ط§ظ„ط·ظ„ط§ط¨*\n\n';
    msg += 'ًں“پ *ط¥ط¬ظ…ط§ظ„ظٹ ط§ظ„ظ…ظˆط§ط¯ ط§ظ„ظ…ط±ظپظˆط¹ط©:* ${materials.length} ظ…ط§ط¯ط©\n';
    msg += 'ًں‘€ *ط¥ط¬ظ…ط§ظ„ظٹ ط§ظ„ظ…ط´ط§ظ‡ط¯ط§طھ/ط§ظ„طھط­ظ…ظٹظ„ط§طھ:* $totalViews ظ…ط´ط§ظ‡ط¯ط©\n\n';

    if (accessedList.isNotEmpty) {
      msg += 'ًں”¥ *ط§ظ„ظ…ظˆط§ط¯ ط§ظ„ط£ظƒط«ط± طھظپط§ط¹ظ„ط§ظ‹:*\n';
      for (var i = 0; i < accessedList.length && i < 5; i++) {
        msg += '${i + 1}. ${accessedList[i]['name']} â€” ${accessedList[i]['count']} ظ…ط´ط§ظ‡ط¯ط©\n';
      }
    } else {
      msg += 'âœ¨ ظ„ظ… ظٹطھظ… طھط³ط¬ظٹظ„ طھظپط§ط¹ظ„ط§طھ ط¨ط¹ط¯ ط¹ظ„ظ‰ ظ…ظˆط§ط¯ظƒ.';
    }

    final kb = InlineKeyboard().row().add(S.get('btn_back_dashboard', lang), 'contrib_dash');
    await ctx.editMessageText(msg, replyMarkup: kb, parseMode: ParseMode.markdown);
  });

  // â”€â”€ Contributor Quick Add Lecture (NEW FEATURE) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('contrib_quick_add', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    final isContributor = await FirebaseDb.isContributor(userId);
    final isAdmin = await FirebaseDb.isAdmin(userId);
    if (!isContributor && !isAdmin) {
      await ctx.answerCallbackQuery(text: S.get('no_permission_upload', lang), showAlert: true);
      return;
    }

    Utils.uploadStates[userId] = {'action': 'wait_for_quick_add_track'};
    final tracks = await FirebaseDb.getTracks();
    if (tracks.isEmpty) {
      await ctx.answerCallbackQuery(text: S.get('upload_no_categories', lang), showAlert: true);
      return;
    }

    final keyboard = Utils.paginateKeyboard(
      tracks,
      page: 0,
      prefix: 'qa_track:',
      backData: 'contrib_dash',
      lang: lang,
    );

    await ctx.editMessageText('ط§ط®طھط± ط§ظ„ظ…ط³ط§ط± ظ„ط¥ط¶ط§ظپط© ط§ظ„ظ…ط­ط§ط¶ط±ط© ظپظٹظ‡:', replyMarkup: keyboard);
  });

  bot.callbackQuery(RegExp(r'^qa_track:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final trackRaw = data.substring('qa_track:'.length);

    if (trackRaw.startsWith('page_')) {
      final page = int.parse(trackRaw.split('_')[1]);
      final tracks = await FirebaseDb.getTracks();
      final keyboard = Utils.paginateKeyboard(
        tracks,
        page: page,
        prefix: 'qa_track:',
        backData: 'contrib_dash',
        lang: lang,
      );
      await ctx.editMessageText('ط§ط®طھط± ط§ظ„ظ…ط³ط§ط± ظ„ط¥ط¶ط§ظپط© ط§ظ„ظ…ط­ط§ط¶ط±ط© ظپظٹظ‡:', replyMarkup: keyboard);
      return;
    }

    final track = Utils.lengthen(trackRaw);
    final state = Utils.uploadStates[userId];
    if (state == null) return;
    state['track'] = track;
    state['action'] = 'wait_for_quick_add_subject';

    final subjects = await FirebaseDb.getSubjects(track);
    final keyboard = Utils.paginateKeyboard(
      subjects,
      page: 0,
      prefix: 'qa_subj:',
      backData: 'contrib_quick_add',
      lang: lang,
    );

    await ctx.editMessageText('ط§ظ„ظ…ط³ط§ط±: $track\nط§ط®طھط± ط§ظ„ظ…ط§ط¯ط©:', replyMarkup: keyboard);
  });

  bot.callbackQuery(RegExp(r'^qa_subj:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final subjRaw = data.substring('qa_subj:'.length);

    final state = Utils.uploadStates[userId];
    if (state == null) return;
    final track = state['track'] as String? ?? '';

    if (subjRaw.startsWith('page_')) {
      final page = int.parse(subjRaw.split('_')[1]);
      final subjects = await FirebaseDb.getSubjects(track);
      final keyboard = Utils.paginateKeyboard(
        subjects,
        page: page,
        prefix: 'qa_subj:',
        backData: 'contrib_quick_add',
        lang: lang,
      );
      await ctx.editMessageText('ط§ظ„ظ…ط³ط§ط±: $track\nط§ط®طھط± ط§ظ„ظ…ط§ط¯ط©:', replyMarkup: keyboard);
      return;
    }

    final subject = Utils.lengthen(subjRaw);
    state['subject'] = subject;
    state['action'] = 'wait_for_quick_add_type';

    final types = await FirebaseDb.getMaterialTypes(track, subject);
    final keyboard = Utils.paginateKeyboard(
      types,
      page: 0,
      prefix: 'qa_type:',
      backData: 'qa_track:${Utils.shorten(track)}',
      lang: lang,
    );

    await ctx.editMessageText('ط§ظ„ظ…ط§ط¯ط©: $subject\nط§ط®طھط± ط§ظ„ظ†ظˆط¹ (ظ…ظ„ط®طµطŒ ط´ط±ط­طŒ ظپظٹط¯ظٹظˆ...):', replyMarkup: keyboard);
  });

  bot.callbackQuery(RegExp(r'^qa_type:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final typeRaw = data.substring('qa_type:'.length);

    final state = Utils.uploadStates[userId];
    if (state == null) return;
    final track = state['track'] as String? ?? '';
    final subject = state['subject'] as String? ?? '';

    if (typeRaw.startsWith('page_')) {
      final page = int.parse(typeRaw.split('_')[1]);
      final types = await FirebaseDb.getMaterialTypes(track, subject);
      final keyboard = Utils.paginateKeyboard(
        types,
        page: page,
        prefix: 'qa_type:',
        backData: 'qa_track:${Utils.shorten(track)}',
        lang: lang,
      );
      await ctx.editMessageText('ط§ظ„ظ…ط§ط¯ط©: $subject\nط§ط®طھط± ط§ظ„ظ†ظˆط¹ (ظ…ظ„ط®طµطŒ ط´ط±ط­طŒ ظپظٹط¯ظٹظˆ...):', replyMarkup: keyboard);
      return;
    }

    final type = Utils.lengthen(typeRaw);
    state['type'] = type;
    state['action'] = 'contrib_quick_add_name';

    await ctx.editMessageText(S.get('quick_add_name_prompt', lang));
  });

  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ
  // â”€â”€ âœڈï¸ڈ FILE MANAGEMENT & EDIT FLOW â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // â•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گâ•گ

  // Entry point: Edit button clicked
  bot.callbackQuery('edit_start', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    final isAdmin = await FirebaseDb.isAdmin(userId);
    final isContributor = await FirebaseDb.isContributor(userId);
    if (!isAdmin && !isContributor) {
      await ctx.answerCallbackQuery(text: S.get('not_authorized', lang), showAlert: true);
      return;
    }
    await ctx.answerCallbackQuery();

    final tracks = await FirebaseDb.getTracks();
    if (tracks.isEmpty) {
      await ctx.answerCallbackQuery(text: S.get('upload_no_categories', lang), showAlert: true);
      return;
    }

    final origin = (isAdmin && Utils.getUserMode(userId) == UserMode.admin) ? 'admin' : 'contrib';
    Utils.uploadStates[userId] = {'action': 'edit_pick_track', 'origin': origin};

    final backCallback = origin == 'admin' ? 'admin_dash' : 'contrib_dash';
    final backLabel = origin == 'admin' ? S.get('btn_back_admin', lang) : S.get('btn_back_dashboard', lang);

    final keyboard = Utils.paginateKeyboard(
      tracks,
      page: 0,
      prefix: 'edt_track:',
      backData: backCallback,
      backLabel: backLabel,
      lang: lang,
    );

    await ctx.editMessageText(
      S.get('edit_select_track', lang),
      replyMarkup: keyboard,
      parseMode: ParseMode.markdown,
    );
  });

  // Step 1: Track selected
  bot.callbackQuery(RegExp(r'^edt_track:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    try { await ctx.answerCallbackQuery(); } catch (_) {}
    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final trackRaw = data.substring('edt_track:'.length);

    final state = Utils.uploadStates[userId] ?? {};
    final origin = state['origin'] as String? ?? 'contrib';
    final backCallback = origin == 'admin' ? 'admin_dash' : 'contrib_dash';
    final backLabel = origin == 'admin' ? S.get('btn_back_admin', lang) : S.get('btn_back_dashboard', lang);

    if (trackRaw.startsWith('page_')) {
      final page = int.parse(trackRaw.split('_')[1]);
      final tracks = await FirebaseDb.getTracks();
      final keyboard = Utils.paginateKeyboard(
        tracks,
        page: page,
        prefix: 'edt_track:',
        backData: backCallback,
        backLabel: backLabel,
        lang: lang,
      );
      await ctx.editMessageText(
        S.get('edit_select_track', lang),
        replyMarkup: keyboard,
        parseMode: ParseMode.markdown,
      );
      return;
    }

    final track = Utils.lengthen(trackRaw);
    state['action'] = 'edit_pick_subject';
    state['edit_track'] = track;
    Utils.uploadStates[userId] = state;

    final subjects = await FirebaseDb.getSubjects(track);
    if (subjects.isEmpty) {
      await ctx.reply(S.get('upload_no_subjects', lang));
      return;
    }

    final keyboard = Utils.paginateKeyboard(
      subjects,
      page: 0,
      prefix: 'edt_subj:',
      backData: 'edit_start',
      lang: lang,
    );

    await ctx.editMessageText(S.get('edit_select_subject', lang), replyMarkup: keyboard);
  });

  // Step 2: Subject selected
  bot.callbackQuery(RegExp(r'^edt_subj:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    try { await ctx.answerCallbackQuery(); } catch (_) {}
    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final subjectRaw = data.substring('edt_subj:'.length);

    final state = Utils.uploadStates[userId] ?? {};
    final track = state['edit_track'] as String? ?? '';

    if (subjectRaw.startsWith('page_')) {
      final page = int.parse(subjectRaw.split('_')[1]);
      final subjects = await FirebaseDb.getSubjects(track);
      final keyboard = Utils.paginateKeyboard(
        subjects,
        page: page,
        prefix: 'edt_subj:',
        backData: 'edit_start',
        lang: lang,
      );
      await ctx.editMessageText(S.get('edit_select_subject', lang), replyMarkup: keyboard);
      return;
    }

    final subject = Utils.lengthen(subjectRaw);
    state['edit_subject'] = subject;
    state['action'] = 'edit_pick_type';
    Utils.uploadStates[userId] = state;

    final types = await FirebaseDb.getMaterialTypes(track, subject);
    if (types.isEmpty) {
      await ctx.reply(S.get('upload_no_types', lang));
      return;
    }

    final keyboard = Utils.paginateKeyboard(
      types,
      page: 0,
      prefix: 'edt_type:',
      backData: 'edt_track:${Utils.shorten(track)}',
      lang: lang,
    );

    await ctx.editMessageText(S.get('edit_select_type', lang), replyMarkup: keyboard);
  });

  // Step 3: Type/Category selected
  bot.callbackQuery(RegExp(r'^edt_type:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    try { await ctx.answerCallbackQuery(); } catch (_) {}
    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final typeRaw = data.substring('edt_type:'.length);

    final state = Utils.uploadStates[userId] ?? {};
    final track = state['edit_track'] as String? ?? '';
    final subject = state['edit_subject'] as String? ?? '';

    if (typeRaw.startsWith('page_')) {
      final page = int.parse(typeRaw.split('_')[1]);
      final types = await FirebaseDb.getMaterialTypes(track, subject);
      final keyboard = Utils.paginateKeyboard(
        types,
        page: page,
        prefix: 'edt_type:',
        backData: 'edt_track:${Utils.shorten(track)}',
        lang: lang,
      );
      await ctx.editMessageText(S.get('edit_select_type', lang), replyMarkup: keyboard);
      return;
    }

    final type = Utils.lengthen(typeRaw);
    state['edit_type'] = type;
    state['action'] = 'edit_pick_file';
    Utils.uploadStates[userId] = state;

    final materials = await FirebaseDb.getMaterials(track, subject, type);
    if (materials.isEmpty) {
      await ctx.reply('⚠️ لا توجد ملفات في هذه الفئة.');
      return;
    }

    final itemsList = materials.entries.map((e) {
      final name = (e.value['name'] as String?) ?? e.key;
      return MapEntry(e.key, '📄 $name');
    }).toList();

    final keyboard = Utils.paginateMapKeyboard(
      itemsList,
      page: 0,
      prefix: 'edt_file:',
      backData: 'edt_subj:${Utils.shorten(subject)}',
      lang: lang,
    );

    await ctx.editMessageText(S.get('edit_select_file', lang), replyMarkup: keyboard);
  });

  // Step 4: File selected
  bot.callbackQuery(RegExp(r'^edt_file:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    try { await ctx.answerCallbackQuery(); } catch (_) {}
    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final rawId = data.substring('edt_file:'.length);

    final state = Utils.uploadStates[userId] ?? {};
    final track = state['edit_track'] as String? ?? '';
    final subject = state['edit_subject'] as String? ?? '';
    final type = state['edit_type'] as String? ?? '';

    if (rawId.startsWith('page_')) {
      final page = int.parse(rawId.split('_')[1]);
      final materials = await FirebaseDb.getMaterials(track, subject, type);
      final itemsList = materials.entries.map((e) {
        final name = (e.value['name'] as String?) ?? e.key;
        return MapEntry(e.key, '📄 $name');
      }).toList();

      final keyboard = Utils.paginateMapKeyboard(
        itemsList,
        page: page,
        prefix: 'edt_file:',
        backData: 'edt_subj:${Utils.shorten(subject)}',
        lang: lang,
      );
      await ctx.editMessageText(S.get('edit_select_file', lang), replyMarkup: keyboard);
      return;
    }

    final matId = Utils.lengthen(rawId);
    var matData = await FirebaseDb.getMaterial(track, subject, type, matId);
    if (matData == null && track.isNotEmpty && subject.isNotEmpty && type.isNotEmpty) {
      final allMats = await FirebaseDb.getMaterials(track, subject, type);
      if (allMats.containsKey(matId)) {
        final val = allMats[matId];
        matData = val is Map ? Map<String, dynamic>.from(val) : {'name': val.toString()};
      }
    }

    if (matData == null) {
      await ctx.reply('❌ تعذر العثور على الملف المحدد أو قد تم حذفه.');
      return;
    }

    final matName = (matData['name'] as String?) ?? matId;

    state['edit_mat_id'] = matId;
    state['edit_mat_name'] = matName;
    state['action'] = 'edit_action_select';
    Utils.uploadStates[userId] = state;

    final keyboard = InlineKeyboard()
      .row()
      .add(S.get('btn_rename', lang), 'edt_action:rename')
      .add(S.get('btn_delete_file', lang), 'edt_action:delete')
      .row()
      .add(S.get('btn_move_file', lang), 'edt_action:move')
      .row()
      .add('🔙 رجوع', 'edt_type:${Utils.shorten(type)}')
      .row()
      .add(S.get('btn_cancel_action', lang), 'edt_cancel');

    final safeName = matName.replaceAll('*', '').replaceAll('_', ' ');
    final safeTrack = track.replaceAll('*', '').replaceAll('_', ' ');
    final safeSubject = subject.replaceAll('*', '').replaceAll('_', ' ');
    final safeType = type.replaceAll('*', '').replaceAll('_', ' ');

    final titleMsg = S.get('edit_file_actions_title', lang, {
      'name': safeName,
      'track': safeTrack,
      'subject': safeSubject,
      'type': safeType,
    });

    try {
      await ctx.editMessageText(
        titleMsg,
        replyMarkup: keyboard,
        parseMode: ParseMode.markdown,
      );
    } catch (_) {
      await ctx.editMessageText(
        titleMsg.replaceAll('*', ''),
        replyMarkup: keyboard,
      );
    }
  });

  // Step 5: Action chosen â€” check role
  bot.callbackQuery(RegExp(r'^edt_action:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    final action = ctx.callbackQuery!.data!.substring('edt_action:'.length);

    final isAdmin = await FirebaseDb.isAdmin(userId);
    final isContributor = await FirebaseDb.isContributor(userId);
    if (!isAdmin && !isContributor) {
      await ctx.answerCallbackQuery(text: S.get('not_authorized', lang), showAlert: true);
      return;
    }

    final state = Utils.uploadStates[userId];
    if (state == null) return;

    await ctx.answerCallbackQuery();

    // Admins skip auth check
    if (isAdmin) {
      await _proceedWithEditAction(ctx, bot, userId, lang, action, state);
    } else {
      // Contributor: require 6-digit code
      state['pending_action'] = action;
      state['action'] = 'edit_auth_code_check';
      final cancelKb = InlineKeyboard().row().add(S.get('btn_cancel_action', lang), 'edt_cancel');
      await ctx.editMessageText(S.get('edit_auth_prompt', lang), replyMarkup: cancelKb);
    }
  });

  // â”€â”€ Rename: Save â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('edt_rename_save', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    await ctx.answerCallbackQuery();

    final state = Utils.uploadStates[userId];
    if (state == null) return;

    final newName = state['pending_new_name'] as String? ?? '';
    final eTrack = state['edit_track'] as String? ?? '';
    final eSubject = state['edit_subject'] as String? ?? '';
    final eType = state['edit_type'] as String? ?? '';
    final eMatId = state['edit_mat_id'] as String? ?? '';
    final isAdmin = await FirebaseDb.isAdmin(userId);
    final backDash = _getEditBackDashboard(state, userId, isAdmin);
    final backLabel = _getEditBackLabel(backDash, lang);

    if (newName.isNotEmpty && eMatId.isNotEmpty) {
      await FirebaseDb.renameMaterial(eTrack, eSubject, eType, eMatId, newName);
    }
    Utils.clearUploadState(userId);

    final backKb = InlineKeyboard().row().add(backLabel, backDash);
    await ctx.editMessageText(
      S.get('edit_rename_done', lang, {'name': newName}),
      replyMarkup: backKb,
      parseMode: ParseMode.markdown,
    );
  });

  // â”€â”€ Rename: Retry typing another name â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('edt_rename_retry', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    await ctx.answerCallbackQuery();

    final state = Utils.uploadStates[userId];
    if (state == null) return;
    state['action'] = 'edit_rename_input';

    final cancelKb = InlineKeyboard().row().add(S.get('btn_cancel_action', lang), 'edt_cancel');
    await ctx.editMessageText(S.get('edit_rename_prompt', lang), replyMarkup: cancelKb);
  });

  // â”€â”€ Delete: Confirmed â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('edt_delete_confirm', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    await ctx.answerCallbackQuery();

    final state = Utils.uploadStates[userId];
    if (state == null) return;

    final track = state['edit_track'] as String? ?? '';
    final subject = state['edit_subject'] as String? ?? '';
    final type = state['edit_type'] as String? ?? '';
    final matId = state['edit_mat_id'] as String? ?? '';
    final isAdmin = await FirebaseDb.isAdmin(userId);
    final backDash = _getEditBackDashboard(state, userId, isAdmin);
    final backLabel = _getEditBackLabel(backDash, lang);

    await FirebaseDb.deleteMaterial(track, subject, type, matId);
    Utils.clearUploadState(userId);

    final kb = InlineKeyboard().row().add(backLabel, backDash);
    await ctx.editMessageText(S.get('edit_delete_done', lang), replyMarkup: kb);
  });

  // â”€â”€ Delete: Cancel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('edt_delete_cancel', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    final state = Utils.uploadStates[userId];
    final isAdmin = await FirebaseDb.isAdmin(userId);
    final backDash = _getEditBackDashboard(state, userId, isAdmin);
    final backLabel = _getEditBackLabel(backDash, lang);

    Utils.clearUploadState(userId);
    await ctx.answerCallbackQuery(text: 'طھظ… ط¥ظ„ط؛ط§ط، ط§ظ„ط¹ظ…ظ„ظٹط©.');
    await ctx.editMessageText('â‌Œ طھظ… ط¥ظ„ط؛ط§ط، ط§ظ„ط­ط°ظپ.', replyMarkup: InlineKeyboard().row().add(backLabel, backDash));
  });

  // â”€â”€ Move: Track selected â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery(RegExp(r'^emv_track:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    try { await ctx.answerCallbackQuery(); } catch (_) {}
    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final trackRaw = data.substring('emv_track:'.length);

    final state = Utils.uploadStates[userId];
    if (state == null) return;
    final matId = state['edit_mat_id'] as String? ?? '';

    if (trackRaw.startsWith('page_')) {
      final page = int.parse(trackRaw.split('_')[1]);
      final tracks = await FirebaseDb.getTracks();
      final keyboard = Utils.paginateKeyboard(
        tracks,
        page: page,
        prefix: 'emv_track:',
        backData: 'edt_file:${Utils.shorten(matId)}',
        lang: lang,
      );
      await ctx.editMessageText(
        S.get('edit_move_select_track', lang),
        replyMarkup: keyboard,
        parseMode: ParseMode.markdown,
      );
      return;
    }

    final newTrack = Utils.lengthen(trackRaw);
    state['move_new_track'] = newTrack;
    state['action'] = 'edit_move_pick_subject';

    final subjects = await FirebaseDb.getSubjects(newTrack);
    if (subjects.isEmpty) {
      await ctx.reply(S.get('upload_no_subjects', lang));
      return;
    }

    final keyboard = Utils.paginateKeyboard(
      subjects,
      page: 0,
      prefix: 'emv_subj:',
      backData: 'emv_pick_track',
      lang: lang,
    );

    await ctx.editMessageText(S.get('edit_move_select_subject', lang), replyMarkup: keyboard);
  });

  // â”€â”€ Move: Back to Track selection â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('emv_pick_track', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    final state = Utils.uploadStates[userId];
    if (state == null) return;

    state['action'] = 'edit_move_pick_track';
    await ctx.answerCallbackQuery();

    final tracks = await FirebaseDb.getTracks();
    final matId = state['edit_mat_id'] as String? ?? '';
    final keyboard = Utils.paginateKeyboard(
      tracks,
      page: 0,
      prefix: 'emv_track:',
      backData: 'edt_file:${Utils.shorten(matId)}',
      lang: lang,
    );

    await ctx.editMessageText(
      S.get('edit_move_select_track', lang),
      replyMarkup: keyboard,
      parseMode: ParseMode.markdown,
    );
  });

  // â”€â”€ Move: Subject selected â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery(RegExp(r'^emv_subj:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final subjRaw = data.substring('emv_subj:'.length);

    final state = Utils.uploadStates[userId];
    if (state == null) return;
    final newTrack = state['move_new_track'] as String? ?? '';

    if (subjRaw.startsWith('page_')) {
      final page = int.parse(subjRaw.split('_')[1]);
      final subjects = await FirebaseDb.getSubjects(newTrack);
      final keyboard = Utils.paginateKeyboard(
        subjects,
        page: page,
        prefix: 'emv_subj:',
        backData: 'emv_pick_track',
        lang: lang,
      );
      await ctx.editMessageText(S.get('edit_move_select_subject', lang), replyMarkup: keyboard);
      return;
    }

    final newSubject = Utils.lengthen(subjRaw);
    state['move_new_subject'] = newSubject;
    state['action'] = 'edit_move_pick_type';

    final types = await FirebaseDb.getMaterialTypes(newTrack, newSubject);
    if (types.isEmpty) {
      await ctx.reply(S.get('upload_no_types', lang));
      return;
    }

    final keyboard = Utils.paginateKeyboard(
      types,
      page: 0,
      prefix: 'emv_type:',
      backData: 'emv_track:${Utils.shorten(newTrack)}',
      lang: lang,
    );

    await ctx.editMessageText(S.get('edit_move_select_type', lang), replyMarkup: keyboard);
  });

  // ── Move: Type/Category selected — prompt for name ────────────────────────
  bot.callbackQuery(RegExp(r'^emv_type:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    try { await ctx.answerCallbackQuery(); } catch (_) {}
    final lang = Utils.getUserLanguage(userId);
    final data = ctx.callbackQuery!.data!;
    final typeRaw = data.substring('emv_type:'.length);

    final state = Utils.uploadStates[userId];
    if (state == null) return;
    final newTrack = state['move_new_track'] as String? ?? '';
    final newSubject = state['move_new_subject'] as String? ?? '';

    if (typeRaw.startsWith('page_')) {
      final page = int.parse(typeRaw.split('_')[1]);
      final types = await FirebaseDb.getMaterialTypes(newTrack, newSubject);
      final keyboard = Utils.paginateKeyboard(
        types,
        page: page,
        prefix: 'emv_type:',
        backData: 'emv_track:${Utils.shorten(newTrack)}',
        lang: lang,
      );
      await ctx.editMessageText(S.get('edit_move_select_type', lang), replyMarkup: keyboard);
      return;
    }

    final newType = Utils.lengthen(typeRaw);
    state['move_new_type'] = newType;
    state['action'] = 'edit_move_name_input';

    final keyboard = InlineKeyboard()
      .row().add(S.get('btn_keep_name', lang), 'emv_keepname')
      .row().add('ًں”™ ط±ط¬ظˆط¹', 'emv_subj:${Utils.shorten(newSubject)}')
      .row().add(S.get('btn_cancel_action', lang), 'edt_cancel');

    await ctx.editMessageText(
      S.get('edit_move_name_prompt', lang),
      replyMarkup: keyboard,
    );
  });

  // â”€â”€ Move: Keep original name -> show Done/Save confirmation â”€â”€â”€â”€â”€
  bot.callbackQuery('emv_keepname', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    await ctx.answerCallbackQuery();

    final state = Utils.uploadStates[userId];
    if (state == null) return;

    final originalName = state['edit_mat_name'] as String? ?? 'ط§ظ„ظ…ظ„ظپ';
    state['pending_move_name'] = originalName;

    final mTrack = state['edit_track'] as String? ?? '';
    final mSubject = state['edit_subject'] as String? ?? '';
    final mType = state['edit_type'] as String? ?? '';
    final mNewTrack = state['move_new_track'] as String? ?? '';
    final mNewSubject = state['move_new_subject'] as String? ?? '';
    final mNewType = state['move_new_type'] as String? ?? '';

    final kb = InlineKeyboard()
      .row().add(S.get('btn_save_move', lang), 'emv_confirm_save')
      .row().add(S.get('btn_change_name', lang), 'emv_ask_name')
      .row().add(S.get('btn_cancel_action', lang), 'edt_cancel');

    await ctx.editMessageText(
      S.get('edit_move_confirm', lang, {
        'name': originalName,
        'oldTrack': mTrack,
        'oldSubject': mSubject,
        'oldType': mType,
        'newTrack': mNewTrack,
        'newSubject': mNewSubject,
        'newType': mNewType,
      }),
      replyMarkup: kb,
      parseMode: ParseMode.markdown,
    );
  });

  // â”€â”€ Move: Prompt to type new name â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('emv_ask_name', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    await ctx.answerCallbackQuery();

    final state = Utils.uploadStates[userId];
    if (state == null) return;
    state['action'] = 'edit_move_name_input';

    final cancelKb = InlineKeyboard().row().add(S.get('btn_cancel_action', lang), 'edt_cancel');
    await ctx.editMessageText(S.get('edit_rename_prompt', lang), replyMarkup: cancelKb);
  });

  // â”€â”€ Move: Confirmed Done/Save -> execute move â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('emv_confirm_save', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    await ctx.answerCallbackQuery();

    final state = Utils.uploadStates[userId];
    if (state == null) return;

    final mTrack = state['edit_track'] as String? ?? '';
    final mSubject = state['edit_subject'] as String? ?? '';
    final mType = state['edit_type'] as String? ?? '';
    final mMatId = state['edit_mat_id'] as String? ?? '';
    final mNewTrack = state['move_new_track'] as String? ?? '';
    final mNewSubject = state['move_new_subject'] as String? ?? '';
    final mNewType = state['move_new_type'] as String? ?? '';
    final finalName = state['pending_move_name'] as String? ?? state['edit_mat_name'] as String? ?? '';

    final isAdmin = await FirebaseDb.isAdmin(userId);
    final backDash = _getEditBackDashboard(state, userId, isAdmin);
    final backLabel = _getEditBackLabel(backDash, lang);

    final newId = await FirebaseDb.moveMaterial(
      oldTrack: mTrack,
      oldSubject: mSubject,
      oldType: mType,
      materialId: mMatId,
      newTrack: mNewTrack,
      newSubject: mNewSubject,
      newType: mNewType,
      newName: finalName,
    );
    Utils.clearUploadState(userId);

    if (newId != null) {
      final successKb = InlineKeyboard().row().add(backLabel, backDash);
      await ctx.editMessageText(
        S.get('edit_move_done', lang, {
          'name': finalName,
          'track': mNewTrack,
          'subject': mNewSubject,
          'type': mNewType,
        }),
        replyMarkup: successKb,
        parseMode: ParseMode.markdown,
      );
    } else {
      await ctx.editMessageText(
        S.get('edit_move_failed', lang),
        replyMarkup: InlineKeyboard().row().add(backLabel, backDash),
      );
    }
  });

  // â”€â”€ Universal Cancel for Edit flow â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bot.callbackQuery('edt_cancel', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);
    final state = Utils.uploadStates[userId];
    final isAdmin = await FirebaseDb.isAdmin(userId);
    final backDash = _getEditBackDashboard(state, userId, isAdmin);
    final backLabel = _getEditBackLabel(backDash, lang);

    Utils.clearUploadState(userId);
    await ctx.answerCallbackQuery(text: 'طھظ… ط§ظ„ط¥ظ„ط؛ط§ط،');
    final kb = InlineKeyboard().row().add(backLabel, backDash);
    await ctx.editMessageText(S.get('edit_action_cancelled', lang), replyMarkup: kb);
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

// â”€â”€ Private: helpers for Edit flow back destination â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

String _getEditBackDashboard(Map<String, dynamic>? state, int userId, bool isAdmin) {
  if (state?['origin'] == 'admin') return 'admin_dash';
  if (isAdmin && Utils.getUserMode(userId) == UserMode.admin) return 'admin_dash';
  return 'contrib_dash';
}

String _getEditBackLabel(String target, String lang) {
  return target == 'admin_dash' ? S.get('btn_back_admin', lang) : S.get('btn_back_dashboard', lang);
}

// â”€â”€ Private: proceed with edit action (for admins who skip auth) â”€â”€â”€â”€â”€â”€â”€â”€â”€

Future<void> _proceedWithEditAction(
    Context ctx, Bot bot, int userId, String lang, String action,
    Map<String, dynamic> state) async {
  final matName = state['edit_mat_name'] as String? ?? 'ط§ظ„ظ…ظ„ظپ';

  if (action == 'rename') {
    state['action'] = 'edit_rename_input';
    final cancelKb = InlineKeyboard().row().add(S.get('btn_cancel_action', lang), 'edt_cancel');
    if (ctx.callbackQuery != null) {
      await ctx.editMessageText(S.get('edit_rename_prompt', lang), replyMarkup: cancelKb);
    } else {
      await ctx.reply(S.get('edit_rename_prompt', lang), replyMarkup: cancelKb);
    }
  } else if (action == 'delete') {
    // Show confirmation dialog
    final kb = InlineKeyboard()
      .row()
      .add('âœ… ظ†ط¹ظ…طŒ ط§ط­ط°ظپ ط§ظ„ظ…ظ„ظپ', 'edt_delete_confirm')
      .add('â‌Œ ط¥ظ„ط؛ط§ط،', 'edt_delete_cancel');
    if (ctx.callbackQuery != null) {
      await ctx.editMessageText(
        S.get('edit_delete_confirm', lang, {'name': matName}),
        replyMarkup: kb,
        parseMode: ParseMode.markdown,
      );
    } else {
      await ctx.reply(
        S.get('edit_delete_confirm', lang, {'name': matName}),
        replyMarkup: kb,
        parseMode: ParseMode.markdown,
      );
    }
  } else if (action == 'move') {
    state['action'] = 'edit_move_pick_track';
    final tracks = await FirebaseDb.getTracks();
    final matId = state['edit_mat_id'] as String? ?? '';
    final keyboard = Utils.paginateKeyboard(
      tracks,
      page: 0,
      prefix: 'emv_track:',
      backData: 'edt_file:${Utils.shorten(matId)}',
      lang: lang,
    );
    if (ctx.callbackQuery != null) {
      await ctx.editMessageText(
        S.get('edit_move_select_track', lang),
        replyMarkup: keyboard,
        parseMode: ParseMode.markdown,
      );
    } else {
      await ctx.reply(
        S.get('edit_move_select_track', lang),
        replyMarkup: keyboard,
        parseMode: ParseMode.markdown,
      );
    }
  }
}
// â”€â”€ Private: show contributor dashboard â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

Future<void> _showContributorDashboard(Context ctx, int userId, String lang,
    {bool isEdit = true}) async {
  final contribData = await FirebaseDb.getContributor(userId);
  if (contribData == null) {
    final reqKb = InlineKeyboard()
      .row()
      .add(S.get('btn_request_contribute', lang), 'req_contribute');

    final msg = S.get('not_contributor_prompt', lang);

    if (ctx.callbackQuery != null) {
      await ctx.answerCallbackQuery();
      if (isEdit) {
        await ctx.editMessageText(
          msg,
          replyMarkup: reqKb,
          parseMode: ParseMode.markdown,
        );
      } else {
        await ctx.reply(
          msg,
          replyMarkup: reqKb,
          parseMode: ParseMode.markdown,
        );
      }
    } else {
      await ctx.reply(
        msg,
        replyMarkup: reqKb,
        parseMode: ParseMode.markdown,
      );
    }
    return;
  }

  final materials = await FirebaseDb.getContributorMaterials(userId);
  final count = materials.length;

  final kb = InlineKeyboard()
    .row()
    .add(S.get('btn_add_subject', lang), 'contrib_add_subject')
    .add(S.get('btn_quick_add_lecture', lang), 'contrib_quick_add')
    .row()
    .add(S.get('btn_my_materials', lang), 'contrib_materials')
    .add(S.get('btn_contrib_stats', lang), 'contrib_analytics')
    .row()
    .add(S.get('btn_edit_files', lang), 'edit_start')
    .row()
    .add(S.get('btn_announce', lang), 'contrib_announce')
    .add(S.get('btn_self_remove', lang), 'contrib_self_remove')
    .row()
    .add(S.get('btn_back', lang), 'back:main');

  final msg = S.get('contrib_dashboard_title', lang, {
    'count': '$count',
  });

  if (isEdit && ctx.callbackQuery != null) {
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

// â”€â”€ Private: handle incoming file (admin or contributor) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

Future<void> _handleUploadFlow(
    Bot bot, Context ctx, String fileId, String fileType) async {
  final userId = ctx.from?.id;
  if (userId == null) return;
  final lang = Utils.getUserLanguage(userId);

  final isAdmin = await FirebaseDb.isAdmin(userId);
  final isModeAdmin = Utils.getUserMode(userId) == UserMode.admin;
  final isContributor = await FirebaseDb.isContributor(userId);

  final state = Utils.uploadStates[userId];

  // â”€â”€ If currently collecting files, just add to the list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  if (state != null && state['action'] == 'collect_files') {
    final files = (state['files'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    files.add({'fileId': fileId, 'fileType': fileType});
    state['files'] = files;

    final doneKb = InlineKeyboard().row()
      .add(S.get('btn_done_uploading', lang), 'contrib_upload_done');
    await ctx.reply(
      S.get('upload_file_received_count', lang, {'count': '${files.length}'}),
      replyMarkup: doneKb,
    );
    return;
  }

  // â”€â”€ Replace existing file â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

  // â”€â”€ Start a new upload session â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  if ((isAdmin && isModeAdmin) || isContributor) {
    Utils.uploadStates[userId] = {
      'action': 'wait_for_upload_track',
      'pending_file': {'fileId': fileId, 'fileType': fileType},
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

    final prompt = (isAdmin && isModeAdmin)
        ? S.get('admin_file_received', lang)
        : S.get('contrib_file_received', lang);
    await ctx.reply(prompt, replyMarkup: keyboard);
  } else {
    await ctx.reply(S.get('no_permission_upload', lang));
  }
}

// â”€â”€ Private: backup file to channel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
    } else if (fileType == 'audio') {
      final msg = await bot.api.sendAudio(chatId, inputFile);
      return msg.audio?.fileId ?? fileId;
    } else if (fileType == 'voice') {
      final msg = await bot.api.sendVoice(chatId, inputFile);
      return msg.voice?.fileId ?? fileId;
    } else {
      final msg = await bot.api.sendDocument(chatId, inputFile);
      return msg.document?.fileId ?? fileId;
    }
  } catch (e) {
    print('Backup failed: $e');
    return fileId;
  }
}
