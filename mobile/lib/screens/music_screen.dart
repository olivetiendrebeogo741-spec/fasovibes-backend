import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/music.dart';
import '../services/music_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  List<MusicModel> _tracks = [];
  bool _loading = true;
  String? _error;

  final AudioPlayer _player = AudioPlayer();
  String? _playingId;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _load();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() { _playingId = null; _isPlaying = false; });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final tracks = await MusicService.getAll();
      if (mounted) setState(() => _tracks = tracks);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _togglePlay(MusicModel track) async {
    if (_playingId == track.id && _isPlaying) {
      await _player.pause();
      return;
    }
    if (_playingId == track.id && !_isPlaying) {
      await _player.resume();
      return;
    }
    setState(() => _playingId = track.id);
    await _player.play(UrlSource(track.audioUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Musique', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF121212),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : _tracks.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _tracks.length,
                      itemBuilder: (context, index) {
                        final track = _tracks[index];
                        final isActive = _playingId == track.id;
                        return _TrackTile(
                          track: track,
                          isPlaying: isActive && _isPlaying,
                          isActive: isActive,
                          onTap: () => _togglePlay(track),
                        );
                      },
                    ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final MusicModel track;
  final bool isPlaying;
  final bool isActive;
  final VoidCallback onTap;

  const _TrackTile({
    required this.track,
    required this.isPlaying,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isActive ? Colors.orange.withValues(alpha: 0.15) : const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          backgroundImage: track.coverImg != null ? NetworkImage(track.coverImg!) : null,
          child: track.coverImg == null ? const Icon(Icons.music_note, color: Colors.white) : null,
        ),
        title: Text(
          track.titre,
          style: TextStyle(color: isActive ? Colors.orange : Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(track.artisteId, style: const TextStyle(color: Colors.white54)),
        trailing: IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
            color: Colors.orange,
            size: 36,
          ),
          onPressed: onTap,
        ),
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
          Icon(Icons.music_off, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text('Aucun morceau disponible', style: TextStyle(color: Colors.white70, fontSize: 16)),
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
