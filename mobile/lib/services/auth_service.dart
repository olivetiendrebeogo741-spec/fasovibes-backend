import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _base = 'https://fasovibes-backend.onrender.com';
  static const _tokenKey = 'fasovibes_token';

  static Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String motDePasse,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nom': nom, 'email': email, 'motDePasse': motDePasse}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 201) return {'success': true, ...data};
      return {'success': false, 'message': data['message'] ?? 'Erreur inscription'};
    } catch (_) {
      return {'success': false, 'message': 'Impossible de contacter le serveur'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String motDePasse,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'motDePasse': motDePasse}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['token'] != null) {
        await _saveToken(data['token']);
        return {'success': true, 'user': data['user']};
      }
      return {'success': false, 'message': data['message'] ?? 'Email ou mot de passe incorrect'};
    } catch (_) {
      return {'success': false, 'message': 'Impossible de contacter le serveur'};
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
