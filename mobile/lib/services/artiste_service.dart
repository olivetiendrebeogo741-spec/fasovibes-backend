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
        final list = (body is Map ? body['data'] : body) as List<dynamic>;
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
