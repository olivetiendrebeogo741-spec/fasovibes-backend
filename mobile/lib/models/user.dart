class UserModel {
  final String id;
  final String nom;
  final String? email;
  final String? telephone;
  final String? photoProfil;

  const UserModel({
    required this.id,
    required this.nom,
    this.email,
    this.telephone,
    this.photoProfil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        nom: json['nom'] ?? '',
        email: json['email'] as String?,
        telephone: json['telephone'] as String?,
        photoProfil: json['photoProfil'] as String?,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'nom': nom,
        if (email != null) 'email': email,
        if (telephone != null) 'telephone': telephone,
        'photoProfil': photoProfil,
      };

  UserModel copyWith({
    String? nom,
    String? email,
    String? telephone,
    String? photoProfil,
  }) =>
      UserModel(
        id: id,
        nom: nom ?? this.nom,
        email: email ?? this.email,
        telephone: telephone ?? this.telephone,
        photoProfil: photoProfil ?? this.photoProfil,
      );

  String get displayIdentifier => email ?? telephone ?? '';
}
