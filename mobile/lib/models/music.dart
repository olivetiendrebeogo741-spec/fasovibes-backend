class MusicModel {
  final String id;
  final String titre;
  final String artisteId;
  final String audioUrl;
  final String? coverImg;

  const MusicModel({
    required this.id,
    required this.titre,
    required this.artisteId,
    required this.audioUrl,
    this.coverImg,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) => MusicModel(
        id: (json['_id'] ?? '').toString(),
        titre: json['titre'] ?? '',
        artisteId: json['artisteId'] is Map
            ? json['artisteId']['nom'] ?? ''
            : json['artisteId'] ?? '',
        audioUrl: json['audioUrl'] ?? '',
        coverImg: json['coverImg'] as String?,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'titre': titre,
        'artisteId': artisteId,
        'audioUrl': audioUrl,
        'coverImg': coverImg,
      };
}
