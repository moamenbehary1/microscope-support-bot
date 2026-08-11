import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';


class FirebaseDb {
  static String get _baseUrl {
    String url = Config.firebaseDatabaseUrl;
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }
  static String get _authParam => '?auth=${Config.firebaseSecret}';

  static Future<dynamic> _get(String path) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl$path.json$_authParam'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        if (response.body == 'null') return null;
        return json.decode(response.body);
      }
      print('[Firebase] GET $path failed: ${response.statusCode}');
      return null;
    } catch (e) {
      print('[Firebase] GET $path error: $e');
      return null;
    }
  }

  static Future<bool> _put(String path, dynamic data) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl$path.json$_authParam'),
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        print('[Firebase] PUT $path failed: ${response.statusCode}');
      }
      return response.statusCode == 200;
    } catch (e) {
      print('[Firebase] PUT $path error: $e');
      return false;
    }
  }

  static Future<bool> _patch(String path, dynamic data) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$_baseUrl$path.json$_authParam'),
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        print('[Firebase] PATCH $path failed: ${response.statusCode}');
      }
      return response.statusCode == 200;
    } catch (e) {
      print('[Firebase] PATCH $path error: $e');
      return false;
    }
  }

  static Future<bool> _delete(String path) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl$path.json$_authParam'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        print('[Firebase] DELETE $path failed: ${response.statusCode}');
      }
      return response.statusCode == 200;
    } catch (e) {
      print('[Firebase] DELETE $path error: $e');
      return false;
    }
  }

  static Future<String?> _post(String path, dynamic data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$path.json$_authParam'),
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        return res['name']; // Returns the generated ID
      }
      print('[Firebase] POST $path failed: ${response.statusCode}');
      return null;
    } catch (e) {
      print('[Firebase] POST $path error: $e');
      return null;
    }
  }

  // --- Users & Admins ---

  static Future<void> registerUser(int userId) async {
    final existing = await _get('/users/$userId');
    if (existing == null) {
      await _put('/users/$userId', {
        'joinedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<String> getUserLanguage(int userId) async {
    final data = await _get('/users/$userId');
    if (data != null && data is Map && data.containsKey('language')) {
      return data['language'] as String;
    }
    return '';
  }

  static Future<void> setUserLanguage(int userId, String lang) async {
    await _patch('/users/$userId', {'language': lang});
  }

  static Future<List<int>> getAdmins() async {
    final data = await _get('/admins');
    if (data == null) return [];
    return (data as Map<String, dynamic>).keys.map((e) => int.parse(e)).toList();
  }

  static Future<void> addAdmin(int userId) async {
    await _put('/admins/$userId', true);
  }

  static Future<void> removeAdmin(int userId) async {
    await _delete('/admins/$userId');
  }

  static Future<bool> isAdmin(int userId) async {
    if (userId == Config.superAdminId) return true;
    final admins = await getAdmins();
    return admins.contains(userId);
  }

  // --- Contributors ---

  static Future<void> setContributor(int userId, {String name = ''}) async {
    await _put('/contributors/$userId', {
      'approved': true,
      if (name.isNotEmpty) 'name': name,
    });
  }

  /// Returns all contributors as Map<userId, {track, subject, name?}>
  static Future<Map<String, dynamic>> getAllContributors() async {
    final data = await _get('/contributors');
    if (data == null) return {};
    return data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>?> getContributor(int userId) async {
    return await _get('/contributors/$userId');
  }

  static Future<void> removeContributor(int userId) async {
    await _delete('/contributors/$userId');
  }

  static Future<bool> isContributor(int userId) async {
    final data = await getContributor(userId);
    return data != null;
  }

  // --- Feedback ---

  static Future<void> addFeedback(int userId, String message) async {
    await _post('/feedbacks', {
      'userId': userId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>> getFeedbacks() async {
    final data = await _get('/feedbacks');
    if (data == null) return {};
    return data as Map<String, dynamic>;
  }

  // --- Curriculum (Content) ---

  // Get all tracks
  static Future<List<String>> getTracks() async {
    final data = await _get('/curriculum');
    if (data == null) return [];
    return (data as Map<String, dynamic>).keys.where((k) => k != '_placeholder').toList();
  }

  // Get subjects for a track
  static Future<List<String>> getSubjects(String track) async {
    final data = await _get('/curriculum/$track');
    if (data == null) return [];
    return (data as Map<String, dynamic>).keys.where((k) => k != '_placeholder').toList();
  }

  // Get material types for a subject
  static Future<List<String>> getMaterialTypes(String track, String subject) async {
    final data = await _get('/curriculum/$track/$subject');
    if (data == null) return [];
    return (data as Map<String, dynamic>).keys.where((k) => k != '_placeholder').toList();
  }

  // Get materials for a type (filters out _placeholder and non-Map entries)
  static Future<Map<String, dynamic>> getMaterials(String track, String subject, String type) async {
    final data = await _get('/curriculum/$track/$subject/$type');
    if (data == null) return {};
    final raw = data as Map<String, dynamic>;
    // Filter out _placeholder entries and entries where value is not a Map
    return Map.fromEntries(
      raw.entries.where((e) =>
        e.key != '_placeholder' && e.value is Map<String, dynamic>),
    );
  }

  // Add material
  static Future<String?> addMaterial(String track, String subject, String type, Map<String, dynamic> materialData) async {
    return await _post('/curriculum/$track/$subject/$type', materialData);
  }

  // --- Contributor Materials Index ---

  static Future<void> addContributorMaterialRef(int userId, String materialId, Map<String, dynamic> data) async {
    await _put('/contributor_materials/$userId/$materialId', data);
  }

  static Future<Map<String, dynamic>> getContributorMaterials(int userId) async {
    final data = await _get('/contributor_materials/$userId');
    if (data == null) return {};
    return data as Map<String, dynamic>;
  }

  static Future<void> removeContributorMaterialRef(int userId, String materialId) async {
    await _delete('/contributor_materials/$userId/$materialId');
  }

  // Delete material
  static Future<void> deleteMaterial(String track, String subject, String type, String materialId) async {
    await _delete('/curriculum/$track/$subject/$type/$materialId');
  }

  // Update material (Replace)
  static Future<void> updateMaterial(String track, String subject, String type, String materialId, Map<String, dynamic> updateData) async {
    await _patch('/curriculum/$track/$subject/$type/$materialId', updateData);
  }
  
  static Future<Map<String, dynamic>?> getMaterial(String track, String subject, String type, String materialId) async {
     return await _get('/curriculum/$track/$subject/$type/$materialId');
  }

  // --- Analytics ---

  static Future<void> logMaterialAccess(String materialId, String materialName) async {
    final data = await _get('/analytics/top_accessed/$materialId');
    int count = 1;
    if (data != null && data['count'] != null) {
      count = data['count'] + 1;
    }
    await _put('/analytics/top_accessed/$materialId', {
      'count': count,
      'name': materialName,
    });
  }
  
  static Future<Map<String, dynamic>> getStats() async {
    final users = await _get('/users') as Map<String, dynamic>? ?? {};
    final analytics = await _get('/analytics/top_accessed') as Map<String, dynamic>? ?? {};
    return {
      'totalUsers': users.length,
      'topMaterials': analytics
    };
  }
  
  static Future<List<int>> getAllUsers() async {
    final users = await _get('/users') as Map<String, dynamic>? ?? {};
    return users.keys.map((e) => int.tryParse(e) ?? 0).where((e) => e != 0).toList();
  }

  static Future<void> wipeCurriculum() async {
    await _delete('/curriculum');
    await _delete('/analytics');
  }

  // --- Super Admin Ownership ---
  static Future<int> getSuperAdmin() async {
    final data = await _get('/super_admin');
    if (data != null && data is Map && data.containsKey('id')) {
      return data['id'] as int;
    }
    // Fallback to .env
    return Config.superAdminId;
  }

  static Future<void> setSuperAdmin(int newAdminId) async {
    await _put('/super_admin', {'id': newAdminId});
    // Ensure the new owner is also a regular admin
    await addAdmin(newAdminId);
  }

  // --- Contributor Requests ---
  static Future<void> addRequest(int userId, {String name = ''}) async {
    await _put('/requests/$userId', {
      'timestamp': DateTime.now().toIso8601String(),
      if (name.isNotEmpty) 'name': name,
    });
  }

  static Future<void> updateRequestMessageIds(int userId, Map<String, dynamic> messageIds) async {
    await _patch('/requests/$userId', {
      'messageIds': messageIds,
    });
  }

  static Future<Map<String, dynamic>?> getRequest(int userId) async {
    return await _get('/requests/$userId');
  }

  static Future<Map<String, dynamic>> getPendingRequests() async {
    final data = await _get('/requests');
    if (data == null) return {};
    return data as Map<String, dynamic>;
  }

  static Future<void> removeRequest(int userId) async {
    await _delete('/requests/$userId');
  }

  static Future<void> wipeUsers() async {
    await _delete('/users');
  }
}
