import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/video.dart';
import '../utils/app_exception.dart';
import 'storage_service.dart';

class VideoService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<VideoModel>> getAll() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.videos}'),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body is Map ? body['data'] : body) as List<dynamic>;
        return list.map((e) => VideoModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw AppException('Erreur lors du chargement des vidéos.', statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<VideoModel> like(String id) async {
    try {
      final res = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.videoLike(id)}'),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return VideoModel.fromJson(body is Map && body['data'] != null ? body['data'] : body);
      }
      throw AppException('Impossible de liker cette vidéo.', statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<VideoModel> addComment(String videoId, String texte) async {
    try {
      final headers = await _authHeaders();
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.videoComment(videoId)}'),
        headers: headers,
        body: jsonEncode({'texte': texte}),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return VideoModel.fromJson(body is Map && body['data'] != null ? body['data'] : body);
      }
      if (res.statusCode == 401) throw const UnauthorizedException();
      throw AppException('Impossible d\'ajouter le commentaire.', statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
