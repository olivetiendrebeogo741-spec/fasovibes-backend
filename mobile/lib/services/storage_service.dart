import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class StorageService {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.token, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.token);
  }

  static Future<void> saveUser({
    required String id,
    required String nom,
    String? email,
    String? telephone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.userId, id);
    await prefs.setString(StorageKeys.userNom, nom);
    if (email != null) await prefs.setString(StorageKeys.userEmail, email);
    if (telephone != null) await prefs.setString(StorageKeys.userPhone, telephone);
  }

  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(StorageKeys.userId),
      'nom': prefs.getString(StorageKeys.userNom),
      'email': prefs.getString(StorageKeys.userEmail),
      'telephone': prefs.getString(StorageKeys.userPhone),
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveLikedVideoIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('liked_video_ids', ids.toList());
  }

  static Future<Set<String>> getLikedVideoIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('liked_video_ids') ?? []).toSet();
  }
}
