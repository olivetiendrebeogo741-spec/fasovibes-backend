import 'package:flutter/material.dart';
import '../models/video.dart';
import '../services/video_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<VideoModel> _videos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final videos = await VideoService.getAll();
      if (mounted) setState(() => _videos = videos);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'FasoVibes',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : _videos.isEmpty
                  ? const _EmptyState()
                  : PageView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _videos.length,
                      itemBuilder: (context, index) => _VideoCard(
                        video: _videos[index],
                        onLike: () => _onLike(index),
                      ),
                    ),
    );
  }

  Future<void> _onLike(int index) async {
    try {
      final updated = await VideoService.like(_videos[index].id);
      if (mounted) setState(() => _videos[index] = updated);
    } catch (_) {}
  }
}

class _VideoCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onLike;

  const _VideoCard({required this.video, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          const Center(child: Icon(Icons.play_circle_fill, size: 80, color: Colors.white24)),
          Positioned(
            bottom: 80,
            left: 16,
            right: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.titre,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('@${video.artisteId}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Positioned(
            bottom: 80,
            right: 12,
            child: Column(
              children: [
                GestureDetector(
                  onTap: onLike,
                  child: const Icon(Icons.favorite_border, color: Colors.white, size: 32),
                ),
                Text('${video.likes}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 16),
                Text(
                  '${video.commentaires.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const Icon(Icons.comment, color: Colors.white, size: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text('Aucune vidéo pour l\'instant', style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Réessayer', style: TextStyle(color: Colors.orange))),
        ],
      ),
    );
  }
}
