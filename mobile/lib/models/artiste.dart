class ArtisteModel {
  final String id;
  final String nom;
  final String? genre;
  final String? bio;
  final String? photoProfil;

  const ArtisteModel({
    required this.id,
    required this.nom,
    this.genre,
    this.bio,
    this.photoProfil,
  });

  factory ArtisteModel.fromJson(Map<String, dynamic> json) => ArtisteModel(
        id: (json['_id'] ?? '').toString(),
        nom: json['nom'] ?? '',
        genre: json['genre'] as String?,
        bio: json['bio'] as String?,
        photoProfil: json['photoProfil'] as String?,
      );
}
