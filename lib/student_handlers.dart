import 'package:televerse/televerse.dart';
import 'firebase_db.dart';
import 'utils.dart';
import 'config.dart';
import 'strings.dart';

void registerStudentHandlers(Bot bot) {
  // ── /start ──────────────────────────────────────────────────────────
  bot.command('start', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;

    await FirebaseDb.registerUser(userId);
    Utils.setUserMode(userId, UserMode.student);
    Utils.clearUploadState(userId);

    // Resolve language: memory cache → Firebase → ask user
    if (!Utils.hasLanguage(userId)) {
      final savedLang = await FirebaseDb.getUserLanguage(userId);
      if (savedLang == 'ar' || savedLang == 'en') {
        Utils.setUserLanguage(userId, savedLang);
      } else {
        // No language set yet — ask the user
        await _sendLanguageSelection(ctx);
        return;
      }
    }

    await _sendMainMenu(bot, ctx, userId);
  });

  // ── Language selection callbacks ─────────────────────────────────────
  bot.callbackQuery('lang_ar', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    await ctx.answerCallbackQuery();
    Utils.setUserLanguage(userId, 'ar');
    await FirebaseDb.setUserLanguage(userId, 'ar');
    await ctx.editMessageText(S.get('lang_set', 'ar'));
    await _sendMainMenuNew(bot, ctx, userId);
  });

  bot.callbackQuery('lang_en', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    await ctx.answerCallbackQuery();
    Utils.setUserLanguage(userId, 'en');
    await FirebaseDb.setUserLanguage(userId, 'en');
    await ctx.editMessageText(S.get('lang_set', 'en'));
    await _sendMainMenuNew(bot, ctx, userId);
  });

  // Change language button — re-shows language selection (editing message)
  bot.callbackQuery('change_lang', (ctx) async {
    await ctx.answerCallbackQuery();
    final kb = InlineKeyboard()
      .row()
      .add('العربية 🇸🇦', 'lang_ar')
      .add('English 🇬🇧', 'lang_en');
    await ctx.editMessageText(S.get('lang_prompt', 'en'), replyMarkup: kb);
  });

  // ── back:tracks — return to main track list ──────────────────────────
  bot.callbackQuery('back:tracks', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    await ctx.answerCallbackQuery();
    final lang = Utils.getUserLanguage(userId);
    final tracks = await FirebaseDb.getTracks();

    InlineKeyboard keyboard;
    if (tracks.isEmpty) {
      keyboard = InlineKeyboard()
        ..row().add(S.get('no_tracks', lang), 'ignore');
    } else {
      keyboard = Utils.paginateKeyboard(tracks, page: 0, prefix: 'track:');
    }

    final isContrib = await FirebaseDb.isContributor(userId);
    if (isContrib) {
      keyboard.row().add(S.get('btn_my_dashboard', lang), 'contrib_dash');
    }
    keyboard.row().add(S.get('btn_contribute', lang), 'req_contribute');
    keyboard.row().add(S.get('btn_contact_admin', lang), 'contact_admin');
    keyboard.row().add(S.get('btn_change_lang', lang), 'change_lang');

    await ctx.editMessageText(S.get('welcome', lang), replyMarkup: keyboard);
  });

  // ── ignore (no-op button) ─────────────────────────────────────────────
  bot.callbackQuery('ignore', (ctx) async {
    final lang = Utils.getUserLanguage(ctx.from?.id ?? 0);
    await ctx.answerCallbackQuery(
        text: S.get('no_tracks', lang), showAlert: false);
  });

  // ── Track Selection ───────────────────────────────────────────────────
  bot.callbackQuery(RegExp(r'^track:(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    final userId = ctx.from?.id;
    if (data == null || userId == null) return;

    final track = data.split(':')[1];
    if (track.startsWith('page_')) return; // pagination placeholder

    final lang = Utils.getUserLanguage(userId);
    final subjects = await FirebaseDb.getSubjects(track);
    final keyboard = Utils.paginateKeyboard(
      subjects,
      page: 0,
      prefix: 'subj:$track:',
      backData: 'back:tracks',
    );

    await ctx.editMessageText(
      S.get('selected_track', lang, {'track': track}),
      replyMarkup: keyboard,
    );
  });

  // ── Subject Selection ─────────────────────────────────────────────────
  bot.callbackQuery(RegExp(r'^subj:(.*?):(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    final userId = ctx.from?.id;
    if (data == null || userId == null) return;

    final parts = data.split(':');
    final track = parts[1];
    final subject = parts[2];

    final lang = Utils.getUserLanguage(userId);
    final types = await FirebaseDb.getMaterialTypes(track, subject);
    final keyboard = Utils.paginateKeyboard(
      types,
      page: 0,
      prefix: 'type:$track:$subject:',
      backData: 'track:$track',
    );

    await ctx.editMessageText(
      S.get('selected_subject', lang, {'subject': subject}),
      replyMarkup: keyboard,
    );
  });

  // ── Material Type Selection ───────────────────────────────────────────
  bot.callbackQuery(RegExp(r'^type:(.*?):(.*?):(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    final userId = ctx.from?.id;
    if (data == null || userId == null) return;

    final parts = data.split(':');
    final track = parts[1];
    final subject = parts[2];
    final type = parts[3];

    final lang = Utils.getUserLanguage(userId);
    final materials = await FirebaseDb.getMaterials(track, subject, type);
    final keyboard = InlineKeyboard();

    for (var mId in materials.keys) {
      final name = materials[mId]['name'];
      keyboard.row().add(name, 'mat:$track:$subject:$type:$mId');
    }
    keyboard.row().add(S.get('btn_back', lang), 'subj:$track:$subject');

    await ctx.editMessageText(
      S.get('materials_list', lang, {'type': type}),
      replyMarkup: keyboard,
    );
  });

  // ── Material Download ─────────────────────────────────────────────────
  bot.callbackQuery(RegExp(r'^mat:(.*?):(.*?):(.*?):(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    final userId = ctx.from?.id;
    if (data == null || userId == null) return;

    final parts = data.split(':');
    final track = parts[1];
    final subject = parts[2];
    final type = parts[3];
    final materialId = parts[4];

    final lang = Utils.getUserLanguage(userId);
    final material = await FirebaseDb.getMaterial(track, subject, type, materialId);

    if (material != null) {
      final fileId = material['file_id'];
      final name = material['name'] as String;
      final fileType = material['file_type'] ?? 'document';
      final description = material['description'] as String? ?? '';

      final inputFile = InputFile.fromFileId(fileId);
      String caption = S.get('here_is_material', lang,
          {'name': name, 'track': track, 'subject': subject, 'type': type});
      if (description.isNotEmpty) caption += '\n\n📝 $description';

      if (fileType == 'photo') {
        await ctx.replyWithPhoto(inputFile, caption: caption);
      } else if (fileType == 'video') {
        await ctx.replyWithVideo(inputFile, caption: caption);
      } else {
        await ctx.replyWithDocument(inputFile, caption: caption);
      }

      await FirebaseDb.logMaterialAccess(materialId, name);
    } else {
      await ctx.answerCallbackQuery(
          text: S.get('material_not_found', lang), showAlert: true);
    }
  });

  // ── Request to Contribute ─────────────────────────────────────────────
  bot.callbackQuery('req_contribute', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    Utils.uploadStates[userId] = {'action': 'req_contribute_track'};
    await ctx.reply(S.get('contribute_track_prompt', lang));
    await ctx.answerCallbackQuery();
  });

  // ── Contact Admin ─────────────────────────────────────────────────────
  bot.callbackQuery('contact_admin', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final lang = Utils.getUserLanguage(userId);

    Utils.uploadStates[userId] = {'action': 'contact_admin'};
    await ctx.reply(S.get('contact_admin_prompt', lang));
    await ctx.answerCallbackQuery();
  });
}

// ── Private helpers ─────────────────────────────────────────────────────

Future<void> _sendLanguageSelection(Context ctx) async {
  final kb = InlineKeyboard()
    .row()
    .add('العربية 🇸🇦', 'lang_ar')
    .add('English 🇬🇧', 'lang_en');
  await ctx.reply(S.get('lang_prompt', 'en'), replyMarkup: kb);
}

/// Sends a new main-menu message (after language was just picked via callback).
Future<void> _sendMainMenuNew(Bot bot, Context ctx, int userId) async {
  final lang = Utils.getUserLanguage(userId);
  final tracks = await FirebaseDb.getTracks();

  InlineKeyboard keyboard;
  if (tracks.isEmpty) {
    keyboard = InlineKeyboard()
      ..row().add(S.get('no_tracks', lang), 'ignore');
  } else {
    keyboard = Utils.paginateKeyboard(tracks, page: 0, prefix: 'track:');
  }

  final isContrib = await FirebaseDb.isContributor(userId);
  if (isContrib) {
    keyboard.row().add(S.get('btn_my_dashboard', lang), 'contrib_dash');
  }
  keyboard.row().add(S.get('btn_contribute', lang), 'req_contribute');
  keyboard.row().add(S.get('btn_contact_admin', lang), 'contact_admin');
  keyboard.row().add(S.get('btn_change_lang', lang), 'change_lang');

  await ctx.reply(S.get('welcome', lang), replyMarkup: keyboard);
}

/// Sends a new main-menu message from a /start command.
Future<void> _sendMainMenu(Bot bot, Context ctx, int userId) async {
  final lang = Utils.getUserLanguage(userId);
  final tracks = await FirebaseDb.getTracks();

  InlineKeyboard keyboard;
  if (tracks.isEmpty) {
    keyboard = InlineKeyboard()
      ..row().add(S.get('no_tracks', lang), 'ignore');
  } else {
    keyboard = Utils.paginateKeyboard(tracks, page: 0, prefix: 'track:');
  }

  final isContrib = await FirebaseDb.isContributor(userId);
  if (isContrib) {
    keyboard.row().add(S.get('btn_my_dashboard', lang), 'contrib_dash');
  }
  keyboard.row().add(S.get('btn_contribute', lang), 'req_contribute');
  keyboard.row().add(S.get('btn_contact_admin', lang), 'contact_admin');
  keyboard.row().add(S.get('btn_change_lang', lang), 'change_lang');

  await ctx.reply(S.get('welcome', lang), replyMarkup: keyboard);
}
