import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  List<dynamic> _tracks = [];
  bool _loading = true;
  int? _playingIndex;

  @override
  void initState() {
    super.initState();
    _fetchMusic();
  }

  Future<void> _fetchMusic() async {
    try {
      final res = await http.get(
        Uri.parse('https://fasovibes-backend.onrender.com/music'),
      );
      if (res.statusCode == 200) {
        setState(() => _tracks = json.decode(res.body));
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Musique',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF121212),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _tracks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_off, size: 64, color: Colors.orange),
                      SizedBox(height: 16),
                      Text(
                        'Aucun morceau disponible',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _tracks.length,
                  itemBuilder: (context, index) {
                    final track = _tracks[index];
                    final isPlaying = _playingIndex == index;
                    return _TrackTile(
                      track: track,
                      isPlaying: isPlaying,
                      onTap: () => setState(() {
                        _playingIndex = isPlaying ? null : index;
                      }),
                    );
                  },
                ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final Map<String, dynamic> track;
  final bool isPlaying;
  final VoidCallback onTap;

  const _TrackTile({
    required this.track,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isPlaying ? Colors.orange.withValues(alpha: 0.15) : const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          backgroundImage: track['coverImg'] != null
              ? NetworkImage(track['coverImg'])
              : null,
          child: track['coverImg'] == null
              ? const Icon(Icons.music_note, color: Colors.white)
              : null,
        ),
        title: Text(
          track['titre'] ?? 'Sans titre',
          style: TextStyle(
            color: isPlaying ? Colors.orange : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          track['artisteId'] ?? 'Artiste inconnu',
          style: const TextStyle(color: Colors.white54),
        ),
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
