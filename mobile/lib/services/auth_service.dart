import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/user.dart';
import '../utils/app_exception.dart';
import 'storage_service.dart';

class AuthService {
  static Future<UserModel> register({
    required String nom,
    required String email,
    required String motDePasse,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nom': nom, 'email': email, 'motDePasse': motDePasse}),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) {
        return UserModel.fromJson(data['data'] ?? data);
      }
      throw AppException(data['message'] ?? 'Erreur lors de l\'inscription.', statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<UserModel> login({
    required String email,
    required String motDePasse,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'motDePasse': motDePasse}),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        final userData = data['data'] ?? data;
        final token = userData['token'] as String;
        final user = UserModel.fromJson(userData['user'] as Map<String, dynamic>);
        await StorageService.saveToken(token);
        await StorageService.saveUser(id: user.id, nom: user.nom, email: user.email);
        return user;
      }
      if (res.statusCode == 401) throw const UnauthorizedException('Email ou mot de passe incorrect.');
      throw AppException(data['message'] ?? 'Erreur lors de la connexion.', statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<void> logout() => StorageService.clear();

  static Future<bool> isLoggedIn() => StorageService.isLoggedIn();
}
