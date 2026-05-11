class ApiConstants {
  static const String baseUrl = 'https://fasovibes-backend.onrender.com';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String videos = '/videos';
  static const String music = '/music';
  static const String artistes = '/artistes';

  static String videoLike(String id) => '/videos/$id/like';
  static String videoComment(String id) => '/videos/$id/commentaires';
}

class AppColors {
  static const int primaryOrange = 0xFFFF6B00;
  static const int backgroundBlack = 0xFF0A0A0A;
  static const int surfaceDark = 0xFF1A1A1A;
  static const int textWhite = 0xFFFFFFFF;
  static const int textGrey = 0xFF9E9E9E;
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String userId = 'user_id';
  static const String userNom = 'user_nom';
  static const String userEmail = 'user_email';
}
