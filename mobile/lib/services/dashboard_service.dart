import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/music.dart';
import '../models/video.dart';
import '../utils/app_exception.dart';
import 'storage_service.dart';

class DashboardService {
  static Future<String?> _token() => StorageService.getToken();

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
      throw AppException('Impossible de charger vos musiques.',
          statusCode: res.statusCode);
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
      throw AppException('Impossible de charger vos vidéos.',
          statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<MusicModel> uploadMusic({
    required String titre,
    required String filePath,
    String? coverPath,
  }) async {
    try {
      final token = await _token();
      final user = await StorageService.getUser();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.music}'),
      );
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      request.fields['titre'] = titre;
      request.fields['artisteId'] = user['id'] ?? '';
      request.files.add(await http.MultipartFile.fromPath('audio', filePath));
      if (coverPath != null) {
        request.files.add(await http.MultipartFile.fromPath('cover', coverPath));
      }

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return MusicModel.fromJson(body['data'] ?? body);
      }
      if (res.statusCode == 401) throw const UnauthorizedException();
      throw AppException('Erreur lors de l\'upload.',
          statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<VideoModel> uploadVideo({
    required String titre,
    required String filePath,
  }) async {
    try {
      final token = await _token();
      final user = await StorageService.getUser();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.videos}'),
      );
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      request.fields['titre'] = titre;
      request.fields['artisteId'] = user['id'] ?? '';
      request.files.add(await http.MultipartFile.fromPath('video', filePath));

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return VideoModel.fromJson(body['data'] ?? body);
      }
      if (res.statusCode == 401) throw const UnauthorizedException();
      throw AppException('Erreur lors de l\'upload.',
          statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<void> deleteMusic(String id) async {
    try {
      final token = await _token();
      final res = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.music}/$id'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 401) throw const UnauthorizedException();
      if (res.statusCode != 204) {
        throw AppException('Impossible de supprimer ce morceau.',
            statusCode: res.statusCode);
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  static Future<void> deleteVideo(String id) async {
    try {
      final token = await _token();
      final res = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.videos}/$id'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 401) throw const UnauthorizedException();
      if (res.statusCode != 204) {
        throw AppException('Impossible de supprimer cette vidéo.',
            statusCode: res.statusCode);
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
