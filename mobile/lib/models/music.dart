class MusicModel {
  final String id;
  final String titre;
  final String artisteId;
  final String artisteRealId;
  final String? artistePhotoUrl;
  final String audioUrl;
  final String? coverImg;
  final int streams;
  final DateTime createdAt;

  const MusicModel({
    required this.id,
    required this.titre,
    required this.artisteId,
    required this.artisteRealId,
    this.artistePhotoUrl,
    required this.audioUrl,
    this.coverImg,
    this.streams = 0,
    required this.createdAt,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) => MusicModel(
        id: (json['_id'] ?? '').toString(),
        titre: json['titre'] ?? '',
        artisteId: json['artisteId'] is Map
            ? json['artisteId']['nom'] ?? ''
            : json['artisteId'] ?? '',
        artisteRealId: json['artisteId'] is Map
            ? (json['artisteId']['_id'] ?? '').toString()
            : (json['artisteId'] ?? '').toString(),
        artistePhotoUrl: json['artisteId'] is Map
            ? json['artisteId']['photoProfil'] as String?
            : null,
        audioUrl: json['audioUrl'] ?? '',
        coverImg: json['coverImg'] as String?,
        streams: (json['streams'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  MusicModel copyWith({int? streams}) => MusicModel(
        id: id,
        titre: titre,
        artisteId: artisteId,
        artisteRealId: artisteRealId,
        artistePhotoUrl: artistePhotoUrl,
        audioUrl: audioUrl,
        coverImg: coverImg,
        streams: streams ?? this.streams,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'titre': titre,
        'artisteId': artisteId,
        'artisteRealId': artisteRealId,
        'audioUrl': audioUrl,
        'coverImg': coverImg,
        'streams': streams,
        'createdAt': createdAt.toIso8601String(),
      };
}
