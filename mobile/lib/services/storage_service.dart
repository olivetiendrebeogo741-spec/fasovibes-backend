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
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.userId, id);
    await prefs.setString(StorageKeys.userNom, nom);
    await prefs.setString(StorageKeys.userEmail, email);
  }

  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(StorageKeys.userId),
      'nom': prefs.getString(StorageKeys.userNom),
      'email': prefs.getString(StorageKeys.userEmail),
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
}
