import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/music.dart';
import '../services/music_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen>
    with SingleTickerProviderStateMixin {
  List<MusicModel> _tracks = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  int _categoryIndex = 0; // 0 = Chansons, 1 = Artistes
  late TabController _tabController;

  final TextEditingController _searchCtrl = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  String? _playingId;
  bool _isPlaying = false;
  MusicModel? _currentTrack;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() => _categoryIndex = _tabController.index);
    });
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
    _tabController.dispose();
    _searchCtrl.dispose();
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
    setState(() { _playingId = track.id; _currentTrack = track; });
    await _player.play(UrlSource(track.audioUrl));
  }

  List<MusicModel> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _tracks;
    return _tracks.where((t) =>
        t.titre.toLowerCase().contains(q) ||
        t.artisteId.toLowerCase().contains(q)).toList();
  }

  List<String> get _uniqueArtists {
    final q = _query.trim().toLowerCase();
    final artists = _tracks.map((t) => t.artisteId).toSet().toList();
    if (q.isEmpty) return artists;
    return artists.where((a) => a.toLowerCase().contains(q)).toList();
  }

  List<MusicModel> tracksForArtist(String artistId) =>
      _tracks.where((t) => t.artisteId == artistId).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            _buildHeader(),

            // ── Search bar ──────────────────────────────────────────────────
            _buildSearchBar(),
            const SizedBox(height: 8),

            // ── Onglets Chansons / Artistes ──────────────────────────────────
            _buildTabBar(),

            // ── Contenu ──────────────────────────────────────────────────────
            Expanded(child: _buildContent()),

            // ── Mini player ──────────────────────────────────────────────────
            if (_playingId != null && _currentTrack != null)
              _MiniPlayer(
                track: _currentTrack!,
                isPlaying: _isPlaying,
                onToggle: () => _togglePlay(_currentTrack!),
                onClose: () async {
                  await _player.stop();
                  setState(() { _playingId = null; _currentTrack = null; });
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const Text(
            'Musique',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
            onPressed: _load,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Rechercher titre ou artiste…',
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1C1C1C),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        tabs: const [
          Tab(text: 'Chansons'),
          Tab(text: 'Artistes'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }
    if (_error != null) {
      return _ErrorWidget(message: _error!, onRetry: _load);
    }
    if (_categoryIndex == 0) {
      return _buildSongsGrid();
    } else {
      return _buildArtistsList();
    }
  }

  // ── Grille des chansons ──────────────────────────────────────────────────────

  Widget _buildSongsGrid() {
    final tracks = _filtered;
    if (tracks.isEmpty) {
      return const Center(
        child: Text('Aucun résultat', style: TextStyle(color: Colors.white38)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: tracks.length,
      itemBuilder: (_, i) {
        final t = tracks[i];
        final isActive = _playingId == t.id;
        return _SongCard(
          track: t,
          isActive: isActive,
          isPlaying: isActive && _isPlaying,
          onTap: () => _togglePlay(t),
        );
      },
    );
  }

  // ── Liste des artistes ───────────────────────────────────────────────────────

  Widget _buildArtistsList() {
    final artists = _uniqueArtists;
    if (artists.isEmpty) {
      return const Center(
        child: Text('Aucun artiste trouvé', style: TextStyle(color: Colors.white38)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      itemCount: artists.length,
      itemBuilder: (_, i) {
        final artistId = artists[i];
        final songs = tracksForArtist(artistId);
        return _ArtistRow(
          artistId: artistId,
          songs: songs,
          playingId: _playingId,
          isPlaying: _isPlaying,
          onTap: (track) => _togglePlay(track),
        );
      },
    );
  }
}

// ── Song Card ─────────────────────────────────────────────────────────────────

class _SongCard extends StatelessWidget {
  final MusicModel track;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTap;

  const _SongCard({
    required this.track,
    required this.isActive,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? Colors.orange : Colors.white10,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    track.coverImg != null
                        ? Image.network(track.coverImg!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _CoverPlaceholder())
                        : _CoverPlaceholder(),
                    // Overlay lecture
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                    // Icône play/pause
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          key: ValueKey(isPlaying),
                          size: 44,
                          color: isActive
                              ? Colors.orange
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Infos
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.titre,
                    style: TextStyle(
                      color: isActive ? Colors.orange : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artisteId,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A1000), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.music_note, color: Colors.orange, size: 36),
    );
  }
}

// ── Artist Row ────────────────────────────────────────────────────────────────

class _ArtistRow extends StatelessWidget {
  final String artistId;
  final List<MusicModel> songs;
  final String? playingId;
  final bool isPlaying;
  final void Function(MusicModel) onTap;

  const _ArtistRow({
    required this.artistId,
    required this.songs,
    required this.playingId,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = artistId.isNotEmpty ? artistId[0].toUpperCase() : 'A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entête artiste
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orange,
                  child: Text(initial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(artistId,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text('${songs.length} morceau${songs.length > 1 ? 'x' : ''}',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Miniatures des chansons en scroll horizontal
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: songs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = songs[i];
                final active = playingId == s.id;
                return GestureDetector(
                  onTap: () => onTap(s),
                  child: Container(
                    width: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active ? Colors.orange : Colors.white10,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          s.coverImg != null
                              ? Image.network(s.coverImg!, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _CoverPlaceholder())
                              : _CoverPlaceholder(),
                          Center(
                            child: Icon(
                              active && isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Player ───────────────────────────────────────────────────────────────

class _MiniPlayer extends StatelessWidget {
  final MusicModel track;
  final bool isPlaying;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  const _MiniPlayer({
    required this.track,
    required this.isPlaying,
    required this.onToggle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        border: Border(top: BorderSide(color: Colors.orange.withValues(alpha: 0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cover
          ClipRRect(
            child: Container(
              width: 68,
              height: 68,
              child: track.coverImg != null
                  ? Image.network(track.coverImg!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _CoverPlaceholder())
                  : _CoverPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          // Titre + artiste
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.titre,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(track.artisteId,
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          // Play/pause
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: Colors.orange,
              size: 36,
            ),
            onPressed: onToggle,
          ),
          // Fermer
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white38, size: 20),
            onPressed: onClose,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 56, color: Colors.orange),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: Colors.white54),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(
              onPressed: onRetry,
              child: const Text('Réessayer',
                  style: TextStyle(color: Colors.orange))),
        ],
      ),
    );
  }
}
