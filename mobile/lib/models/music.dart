class MusicModel {
  final String id;
  final String titre;
  final String artisteId;
  final String audioUrl;
  final String? coverImg;

  MusicModel({
    required this.id,
    required this.titre,
    required this.artisteId,
    required this.audioUrl,
    this.coverImg,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) => MusicModel(
        id: json['_id'] ?? '',
        titre: json['titre'] ?? '',
        artisteId: json['artisteId'] ?? '',
        audioUrl: json['audioUrl'] ?? '',
        coverImg: json['coverImg'],
      );
}
