import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/artiste.dart';
import '../utils/app_exception.dart';

class ArtisteService {
  static Future<List<ArtisteModel>> getAll() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.artistes}'),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        List<dynamic> list;
        if (body is List) {
          list = body;
        } else if (body is Map && body['data'] is List) {
          list = body['data'] as List<dynamic>;
        } else if (body is Map && body['artistes'] is List) {
          list = body['artistes'] as List<dynamic>;
        } else if (body is Map) {
          // chercher la première valeur qui est une List
          final val = body.values.firstWhere(
              (v) => v is List, orElse: () => <dynamic>[]);
          list = val as List<dynamic>;
        } else {
          list = [];
        }
        return list
            .map((e) => ArtisteModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw AppException('Erreur lors du chargement des artistes.',
          statusCode: res.statusCode);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
