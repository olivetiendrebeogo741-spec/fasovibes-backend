class VideoModel {
  final String id;
  final String titre;
  final String artisteId;
  final String videoUrl;
  final int likes;
  final List<dynamic> commentaires;

  VideoModel({
    required this.id,
    required this.titre,
    required this.artisteId,
    required this.videoUrl,
    required this.likes,
    required this.commentaires,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        id: json['_id'] ?? '',
        titre: json['titre'] ?? '',
        artisteId: json['artisteId'] ?? '',
        videoUrl: json['videoUrl'] ?? '',
        likes: json['likes'] ?? 0,
        commentaires: json['commentaires'] ?? [],
      );
}
