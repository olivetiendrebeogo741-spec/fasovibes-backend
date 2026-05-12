class Validators {
  static String? emailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email ou numéro de téléphone obligatoire';
    }
    final v = value.trim();
    if (v.contains('@')) {
      final regex = RegExp(r'^\S+@\S+\.\S+$');
      if (!regex.hasMatch(v)) return 'Email invalide';
    } else {
      final digits = v.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 8) return 'Numéro de téléphone invalide (min. 8 chiffres)';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return "L'email est obligatoire";
    final regex = RegExp(r'^\S+@\S+\.\S+$');
    if (!regex.hasMatch(value.trim())) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est obligatoire';
    if (value.length < 6) return 'Le mot de passe doit faire au moins 6 caractères';
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName est obligatoire';
    return null;
  }
}
