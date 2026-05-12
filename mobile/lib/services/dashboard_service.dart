import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/music.dart';
import '../models/video.dart';
import '../utils/app_exception.dart';
import 'storage_service.dart';

class DashboardService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<MusicModel>> getMyMusic() async {
    try {
      final user = await StorageService.getUser();
      final userId = user['id'] ?? '';
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.music}'),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body is Map ? body['data'] : body) as List<dynamic>;
        return list
            .map((e) => MusicModel.fromJson(e as Map<String, dynamic>))
            .where((m) => m.artisteId == userId || m.artisteId.contains(userId))
            .toList();
      }
      throw AppException('Impossible de charger vos musiques.', statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<List<VideoModel>> getMyVideos() async {
    try {
      final user = await StorageService.getUser();
      final userId = user['id'] ?? '';
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.videos}'),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body is Map ? body['data'] : body) as List<dynamic>;
        return list
            .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
            .where((v) => v.artisteId == userId || v.artisteId.contains(userId))
            .toList();
      }
      throw AppException('Impossible de charger vos vidéos.', statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<MusicModel> uploadMusic({
    required String titre,
    required String audioUrl,
    String? coverImg,
  }) async {
    try {
      final headers = await _authHeaders();
      final user = await StorageService.getUser();
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.music}'),
        headers: headers,
        body: jsonEncode({
          'titre': titre,
          'artisteId': user['id'],
          'audioUrl': audioUrl,
          if (coverImg != null && coverImg.isNotEmpty) 'coverImg': coverImg,
        }),
      );
      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return MusicModel.fromJson(body['data'] ?? body);
      }
      if (res.statusCode == 401) throw const UnauthorizedException();
      throw AppException('Erreur lors de l\'upload.', statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<VideoModel> uploadVideo({
    required String titre,
    required String videoUrl,
  }) async {
    try {
      final headers = await _authHeaders();
      final user = await StorageService.getUser();
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.videos}'),
        headers: headers,
        body: jsonEncode({
          'titre': titre,
          'artisteId': user['id'],
          'videoUrl': videoUrl,
        }),
      );
      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return VideoModel.fromJson(body['data'] ?? body);
      }
      if (res.statusCode == 401) throw const UnauthorizedException();
      throw AppException('Erreur lors de l\'upload.', statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<void> deleteMusic(String id) async {
    try {
      final headers = await _authHeaders();
      final res = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.music}/$id'),
        headers: headers,
      );
      if (res.statusCode == 401) throw const UnauthorizedException();
      if (res.statusCode != 204) {
        throw AppException('Impossible de supprimer ce morceau.', statusCode: res.statusCode);
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<void> deleteVideo(String id) async {
    try {
      final headers = await _authHeaders();
      final res = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.videos}/$id'),
        headers: headers,
      );
      if (res.statusCode == 401) throw const UnauthorizedException();
      if (res.statusCode != 204) {
        throw AppException('Impossible de supprimer cette vidéo.', statusCode: res.statusCode);
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
