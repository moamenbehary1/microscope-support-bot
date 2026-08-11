import 'package:televerse/televerse.dart';
import 'firebase_db.dart';
import 'utils.dart';

void registerTableHandlers(Bot bot) {
  bot.hears(RegExp(r'^/table', caseSensitive: false), (ctx) async {
    print('Command /table triggered by user!');
    final userId = ctx.from?.id;
    if (userId == null) {
      print('userId is null!');
      return;
    }
    print('Calling _showTableDashboard for $userId');
    try {
      await _showTableDashboard(ctx, userId);
      print('_showTableDashboard completed successfully');
    } catch (e, stack) {
      print('Error in _showTableDashboard: $e');
      print(stack);
    }
  });

  bot.callbackQuery('table_dash', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    await ctx.answerCallbackQuery();
    Utils.tableCreationStates.remove(userId);
    await _showTableDashboard(ctx, userId, edit: true);
  });

  bot.callbackQuery('add_table', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    await ctx.answerCallbackQuery();
    Utils.tableCreationStates[userId] = {'step': 'name'};
    await ctx.editMessageText('الرجاء إدخال اسم للجدول الجديد:\n(مثلاً: جدول الفصل الدراسي الأول)', replyMarkup: InlineKeyboard().row().add('🔙 رجوع', 'table_dash'));
  });

  bot.callbackQuery(RegExp(r'^tab_track:page_(\d+)'), (ctx) async {
    final userId = ctx.from?.id;
    final data = ctx.callbackQuery?.data;
    if (userId == null || data == null) return;
    await ctx.answerCallbackQuery();
    final page = int.parse(data.split('page_')[1]);
    final tracks = await FirebaseDb.getTracks();
    final keyboard = Utils.paginateKeyboard(tracks, page: page, prefix: 'tab_track:', backData: 'table_dash');
    await ctx.editMessageReplyMarkup(replyMarkup: keyboard);
  });

  bot.callbackQuery(RegExp(r'^tab_track:(?!page_)(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    final data = ctx.callbackQuery?.data;
    if (userId == null || data == null) return;
    final trackName = data.replaceFirst('tab_track:', '');
    await ctx.answerCallbackQuery();

    final state = Utils.tableCreationStates[userId];
    if (state == null) return;
    
    state['track'] = trackName;
    state['step'] = 'subjects';
    state['subjects'] = <String>[]; // List to hold selected subjects

    await _showSubjectsSelection(ctx, userId, trackName, 0);
  });

  bot.callbackQuery(RegExp(r'^tab_subj:page_(\d+)'), (ctx) async {
    final userId = ctx.from?.id;
    final data = ctx.callbackQuery?.data;
    if (userId == null || data == null) return;
    await ctx.answerCallbackQuery();
    final state = Utils.tableCreationStates[userId];
    if (state == null) return;
    
    final page = int.parse(data.split('page_')[1]);
    await _showSubjectsSelection(ctx, userId, state['track'], page);
  });

  bot.callbackQuery(RegExp(r'^tab_subj:(?!page_)(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    final data = ctx.callbackQuery?.data;
    if (userId == null || data == null) return;
    final subj = data.replaceFirst('tab_subj:', '');
    await ctx.answerCallbackQuery();

    final state = Utils.tableCreationStates[userId];
    if (state == null) return;

    List<String> selected = (state['subjects'] as List<String>?) ?? [];
    if (selected.contains(subj)) {
      selected.remove(subj);
    } else {
      selected.add(subj);
    }
    state['subjects'] = selected;

    // We must extract the current page from the callback message if possible, or reset to 0.
    // To keep it simple, we can store current page in state.
    final page = state['current_page'] ?? 0;
    await _showSubjectsSelection(ctx, userId, state['track'], page);
  });

  bot.callbackQuery('tab_done', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    final state = Utils.tableCreationStates[userId];
    if (state == null) {
      await ctx.answerCallbackQuery();
      return;
    }
    
    final subjects = (state['subjects'] as List<String>?) ?? [];
    if (subjects.isEmpty) {
      await ctx.answerCallbackQuery(text: 'الرجاء اختيار مادة واحدة على الأقل!', showAlert: true);
      return;
    }

    await ctx.answerCallbackQuery(text: 'جاري الحفظ...');
    final name = state['name'] ?? 'بدون اسم';
    final track = state['track'] ?? '';
    
    await FirebaseDb.saveTable(userId, name, track, subjects);
    Utils.tableCreationStates.remove(userId);
    
    await ctx.editMessageText('تم حفظ الجدول "$name" بنجاح وتم تفعيل الإشعارات للمواد المحددة. ✅');
    await _showTableDashboard(ctx, userId, edit: false);
  });

  bot.callbackQuery('view_tables', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    await ctx.answerCallbackQuery();

    final tables = await FirebaseDb.getTables(userId);
    if (tables.isEmpty) {
      await ctx.editMessageText('لا يوجد جداول محفوظة لديك.', replyMarkup: InlineKeyboard().row().add('🔙 رجوع', 'table_dash'));
      return;
    }

    final kb = InlineKeyboard();
    tables.forEach((tableName, data) {
      kb.row().add('📅 $tableName', 'vt:$tableName');
    });
    kb.row().add('🔙 رجوع', 'table_dash');

    await ctx.editMessageText('اختر الجدول لعرض تفاصيله:', replyMarkup: kb);
  });

  bot.callbackQuery(RegExp(r'^vt:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    final data = ctx.callbackQuery?.data;
    if (userId == null || data == null) return;
    final tableName = data.replaceFirst('vt:', '');
    await ctx.answerCallbackQuery();

    final tables = await FirebaseDb.getTables(userId);
    if (!tables.containsKey(tableName)) return;

    final track = tables[tableName]['track'];
    final subjects = (tables[tableName]['subjects'] as List<dynamic>).cast<String>();

    final kb = InlineKeyboard();
    for (var s in subjects) {
      kb.row().add('📚 $s', 'track:$track:$s');
    }
    kb.row().add('🗑 مسح الجدول', 'del_table:$tableName');
    kb.row().add('🔙 رجوع لجداولك', 'view_tables');

    await ctx.editMessageText('جدول: $tableName\nالمواد المسجلة:', replyMarkup: kb);
  });

  bot.callbackQuery(RegExp(r'^del_table:(.+)'), (ctx) async {
    final userId = ctx.from?.id;
    final data = ctx.callbackQuery?.data;
    if (userId == null || data == null) return;
    final tableName = data.replaceFirst('del_table:', '');
    await ctx.answerCallbackQuery(text: 'تم حذف الجدول.');
    
    await FirebaseDb.deleteTable(userId, tableName);
    
    // go back to view tables
    final tables = await FirebaseDb.getTables(userId);
    if (tables.isEmpty) {
      await _showTableDashboard(ctx, userId, edit: true);
    } else {
      final kb = InlineKeyboard();
      tables.forEach((name, data) {
        kb.row().add('📅 $name', 'vt:$name');
      });
      kb.row().add('🔙 رجوع', 'table_dash');
      await ctx.editMessageText('اختر الجدول لعرض تفاصيله:', replyMarkup: kb);
    }
  });

  bot.callbackQuery('del_all_tables', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    await ctx.answerCallbackQuery(text: 'تم حذف جميع الجداول.');
    await FirebaseDb.deleteAllTables(userId);
    await _showTableDashboard(ctx, userId, edit: true);
  });
}

void registerTableTextHandler(Bot bot) {
  bot.onText((ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    final state = Utils.tableCreationStates[userId];
    if (state == null) return;

    final text = ctx.message?.text ?? '';
    if (text.startsWith('/')) return;

    if (state['step'] == 'name') {
      state['name'] = text;
      state['step'] = 'track';
      
      final tracks = await FirebaseDb.getTracks();
      if (tracks.isEmpty) {
        await ctx.reply('لا يوجد فرق دراسية متاحة حالياً.');
        Utils.tableCreationStates.remove(userId);
        return;
      }
      
      final keyboard = Utils.paginateKeyboard(tracks, page: 0, prefix: 'tab_track:', backData: 'table_dash');
      await ctx.reply('تم حفظ الاسم: $text\n\nاختر الفرقة الدراسية (Track):', replyMarkup: keyboard);
    }
  });
}

Future<void> _showTableDashboard(Context ctx, int userId, {bool edit = false}) async {
  final kb = InlineKeyboard()
    .row().add('➕ إضافة جدول جديد', 'add_table')
    .row().add('📋 عرض جداولي', 'view_tables')
    .row().add('🗑 مسح جميع الجداول', 'del_all_tables');

  final msg = '📚 إدارة الجداول الدراسية\n\nأهلاً بك! يمكنك هنا إنشاء جدول بالمواد التي تدرسها هذا الترم. سيقوم البوت بإرسال إشعار لك فور إضافة أي ملف جديد في المواد التي اخترتها.';
  
  if (edit && ctx.callbackQuery != null) {
    await ctx.editMessageText(msg, replyMarkup: kb);
  } else {
    await ctx.reply(msg, replyMarkup: kb);
  }
}

Future<void> _showSubjectsSelection(Context ctx, int userId, String trackName, int page) async {
  final state = Utils.tableCreationStates[userId];
  if (state == null) return;
  state['current_page'] = page;

  final subjects = await FirebaseDb.getSubjects(trackName);
  if (subjects.isEmpty) {
    await ctx.editMessageText('لا توجد مواد في هذه الفرقة.', replyMarkup: InlineKeyboard().row().add('🔙 رجوع', 'table_dash'));
    return;
  }

  List<String> selected = (state['subjects'] as List<String>?) ?? [];

  final kb = Utils.paginateMultiSelectKeyboard(
    subjects,
    selected,
    page: page,
    itemsPerPage: 7,
    togglePrefix: 'tab_subj:',
    doneData: 'tab_done',
    backData: 'table_dash',
  );

  await ctx.editMessageText('المواد المتاحة في $trackName:\n(اختر المواد المطلوبة ثم اضغط ✅ Done)', replyMarkup: kb);
}
