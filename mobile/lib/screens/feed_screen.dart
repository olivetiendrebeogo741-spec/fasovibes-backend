import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Set<String> _likedIds = {};

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

  Future<void> _onLike(int index) async {
    final vid = _videos[index];
    if (_likedIds.contains(vid.id)) return;
    try {
      final updated = await VideoService.like(vid.id);
      if (mounted) {
        setState(() {
          _videos[index] = updated;
          _likedIds.add(vid.id);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: Colors.black,
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
                        isLiked: _likedIds.contains(_videos[index].id),
                        onLike: () => _onLike(index),
                      ),
                    ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final VideoModel video;
  final bool isLiked;
  final VoidCallback onLike;

  const _VideoCard({required this.video, required this.isLiked, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final artistInitial =
        video.artisteId.isNotEmpty ? video.artisteId[0].toUpperCase() : 'A';

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Vidéo placeholder
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A1A), Colors.black],
              ),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_fill, size: 80, color: Colors.white12),
            ),
          ),

          // Dégradé bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),

          // Infos vidéo bas gauche
          Positioned(
            bottom: 90,
            left: 16,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.orange,
                      child: Text(
                        artistInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '@${video.artisteId}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  video.titre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Sidebar droite style TikTok
          Positioned(
            bottom: 80,
            right: 12,
            child: Column(
              children: [
                _SidebarAvatar(initial: artistInitial),
                const SizedBox(height: 24),

                _SidebarAction(
                  icon: Icons.favorite,
                  label: '${video.likes}',
                  onTap: onLike,
                  color: isLiked ? Colors.orange : Colors.white,
                ),
                const SizedBox(height: 20),

                _SidebarAction(
                  icon: Icons.chat_bubble_rounded,
                  label: '${video.commentaires.length}',
                  onTap: () {},
                  color: Colors.white,
                ),
                const SizedBox(height: 20),

                _SidebarAction(
                  icon: Icons.share_rounded,
                  label: 'Partager',
                  onTap: () {},
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarAvatar extends StatelessWidget {
  final String initial;
  const _SidebarAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            color: Colors.orange,
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -8,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF4500),
            ),
            child: const Icon(Icons.add, size: 13, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _SidebarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _SidebarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
          Text('Aucune vidéo pour l\'instant',
              style: TextStyle(color: Colors.white70, fontSize: 16)),
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
          Text(message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: const Text('Réessayer',
                style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}
