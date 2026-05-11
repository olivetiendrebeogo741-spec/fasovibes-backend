class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Erreur réseau. Vérifiez votre connexion.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expirée. Veuillez vous reconnecter.'])
      : super(statusCode: 401);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Ressource introuvable.'])
      : super(statusCode: 404);
}
