class UserModel {
  final String id;
  final String nom;
  final String email;
  final String? photoProfil;

  const UserModel({
    required this.id,
    required this.nom,
    required this.email,
    this.photoProfil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        nom: json['nom'] ?? '',
        email: json['email'] ?? '',
        photoProfil: json['photoProfil'] as String?,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'nom': nom,
        'email': email,
        'photoProfil': photoProfil,
      };

  UserModel copyWith({String? nom, String? email, String? photoProfil}) => UserModel(
        id: id,
        nom: nom ?? this.nom,
        email: email ?? this.email,
        photoProfil: photoProfil ?? this.photoProfil,
      );
}
