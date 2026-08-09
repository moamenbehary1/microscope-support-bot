import 'package:televerse/televerse.dart';
import 'firebase_db.dart';
import 'utils.dart';
import 'config.dart';

void registerStudentHandlers(Bot bot) {
  // Handle /start command
  bot.command('start', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    await FirebaseDb.registerUser(userId);
    
    Utils.setUserMode(userId, UserMode.student);
    
    final tracks = await FirebaseDb.getTracks();
    InlineKeyboard keyboard = InlineKeyboard();
    
    if (tracks.isEmpty) {
      keyboard.row().add('No tracks available', 'ignore');
    } else {
      keyboard = Utils.paginateKeyboard(tracks, page: 0, prefix: 'track:');
    }
    
    keyboard.row().add('Contribute Materials 🤝', 'req_contribute');
    keyboard.row().add('Contact Admin 📞', 'contact_admin');
    
    await ctx.reply(
      'Welcome to the Educational Bot! 📚\nPlease select a track to begin:',
      replyMarkup: keyboard,
    );
  });

  bot.callbackQuery('ignore', (ctx) async {
    await ctx.answerCallbackQuery(text: 'No tracks are available yet.', showAlert: false);
  });

  // Handle Track Selection
  bot.callbackQuery(RegExp(r'^track:(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    if (data == null) return;
    
    final track = data.split(':')[1];
    
    if (track.startsWith('page_')) {
      // Handle pagination logic if needed
      return;
    }

    final subjects = await FirebaseDb.getSubjects(track);
    final keyboard = Utils.paginateKeyboard(subjects, page: 0, prefix: 'subj:$track:', backData: 'back:tracks');
    
    await ctx.editMessageText(
      'Selected Track: $track\nPlease select a subject:',
      replyMarkup: keyboard,
    );
  });

  // Handle Subject Selection
  bot.callbackQuery(RegExp(r'^subj:(.*?):(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    if (data == null) return;
    
    final parts = data.split(':');
    final track = parts[1];
    final subject = parts[2];
    
    final types = await FirebaseDb.getMaterialTypes(track, subject);
    final keyboard = Utils.paginateKeyboard(types, page: 0, prefix: 'type:$track:$subject:', backData: 'track:$track');
    
    await ctx.editMessageText(
      'Subject: $subject\nPlease select material type:',
      replyMarkup: keyboard,
    );
  });

  // Handle Material Type Selection
  bot.callbackQuery(RegExp(r'^type:(.*?):(.*?):(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    if (data == null) return;
    
    final parts = data.split(':');
    final track = parts[1];
    final subject = parts[2];
    final type = parts[3];
    
    final materials = await FirebaseDb.getMaterials(track, subject, type);
    final materialList = materials.keys.toList(); // These are IDs
    
    final keyboard = InlineKeyboard();
    for (var mId in materialList) {
      final name = materials[mId]['name'];
      keyboard.row().add(name, 'mat:$track:$subject:$type:$mId');
    }
    keyboard.row().add('🔙 Back', 'subj:$track:$subject');
    
    await ctx.editMessageText(
      'Materials for $type:\nSelect a file to download:',
      replyMarkup: keyboard,
    );
  });

  // Handle Material Download
  bot.callbackQuery(RegExp(r'^mat:(.*?):(.*?):(.*?):(.*)'), (ctx) async {
    final data = ctx.callbackQuery?.data;
    if (data == null) return;
    
    final parts = data.split(':');
    final track = parts[1];
    final subject = parts[2];
    final type = parts[3];
    final materialId = parts[4];
    
    final material = await FirebaseDb.getMaterial(track, subject, type, materialId);
    if (material != null) {
      final fileId = material['file_id'];
      final name = material['name'];
      final fileType = material['file_type'] ?? 'document';
      
      final inputFile = InputFile.fromFileId(fileId);
      final caption = 'Here is your material: $name\nFrom: $track -> $subject -> $type';
      
      if (fileType == 'photo') {
        await ctx.replyWithPhoto(inputFile, caption: caption);
      } else if (fileType == 'video') {
        await ctx.replyWithVideo(inputFile, caption: caption);
      } else {
        await ctx.replyWithDocument(inputFile, caption: caption);
      }
      
      // Log Analytics
      await FirebaseDb.logMaterialAccess(materialId, name);
    } else {
      await ctx.answerCallbackQuery(text: 'Material not found!', showAlert: true);
    }
  });

  // Handle Request to Contribute
  bot.callbackQuery('req_contribute', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    Utils.uploadStates[userId] = {'action': 'req_contribute_track'};
    
    await ctx.reply('To become a contributor, please type the Track name you want to contribute to:');
    await ctx.answerCallbackQuery();
  });
  
  // Handle Contact Admin
  bot.callbackQuery('contact_admin', (ctx) async {
    final userId = ctx.from?.id;
    if (userId == null) return;
    
    Utils.uploadStates[userId] = {'action': 'contact_admin'};
    
    await ctx.reply('Please send your feedback/complaint in a single message. It will be forwarded to the admins.');
    await ctx.answerCallbackQuery();
  });
}
