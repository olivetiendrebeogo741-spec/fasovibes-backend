class CommentaireModel {
  final String auteurId;
  final String texte;
  final DateTime date;

  const CommentaireModel({
    required this.auteurId,
    required this.texte,
    required this.date,
  });

  factory CommentaireModel.fromJson(Map<String, dynamic> json) => CommentaireModel(
        auteurId: json['auteurId'] ?? '',
        texte: json['texte'] ?? '',
        date: json['date'] != null ? DateTime.tryParse(json['date']) ?? DateTime.now() : DateTime.now(),
      );
}

class VideoModel {
  final String id;
  final String titre;
  final String artisteId;
  final String videoUrl;
  final int likes;
  final List<CommentaireModel> commentaires;

  const VideoModel({
    required this.id,
    required this.titre,
    required this.artisteId,
    required this.videoUrl,
    required this.likes,
    required this.commentaires,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        id: (json['_id'] ?? '').toString(),
        titre: json['titre'] ?? '',
        artisteId: json['artisteId'] is Map
            ? json['artisteId']['nom'] ?? ''
            : json['artisteId'] ?? '',
        videoUrl: json['videoUrl'] ?? '',
        likes: json['likes'] ?? 0,
        commentaires: (json['commentaires'] as List<dynamic>? ?? [])
            .map((c) => CommentaireModel.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  VideoModel copyWith({int? likes}) => VideoModel(
        id: id,
        titre: titre,
        artisteId: artisteId,
        videoUrl: videoUrl,
        likes: likes ?? this.likes,
        commentaires: commentaires,
      );
}
