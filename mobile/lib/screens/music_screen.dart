import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config/constants.dart';
import '../models/artiste.dart';
import '../models/music.dart';
import '../services/artiste_service.dart';
import '../services/music_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MusicScreen — page unique avec sections Artistes + Albums
// ─────────────────────────────────────────────────────────────────────────────

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  List<ArtisteModel> _artistes = [];
  List<MusicModel> _tracks = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ArtisteService.getAll(),
        MusicService.getAll(),
      ]);
      if (mounted) {
        setState(() {
          _artistes = results[0] as List<ArtisteModel>;
          _tracks   = results[1] as List<MusicModel>;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<MusicModel> get _filteredTracks {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _tracks;
    return _tracks.where((t) =>
        t.titre.toLowerCase().contains(q) ||
        t.artisteId.toLowerCase().contains(q)).toList();
  }

  List<ArtisteModel> get _filteredArtistes {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _artistes;
    return _artistes.where((a) => a.nom.toLowerCase().contains(q)).toList();
  }

  List<MusicModel> _tracksForArtiste(ArtisteModel artiste) => _tracks
      .where((t) =>
          t.artisteId == artiste.id ||
          t.artisteId.toLowerCase() == artiste.nom.toLowerCase())
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundBlack),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      child: Row(
        children: [
          const Text(
            'Musique',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white38, size: 22),
            onPressed: _load,
          ),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.orange));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 56, color: Colors.orange),
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(color: Colors.white54),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _load,
              child: const Text('Réessayer',
                  style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );
    }

    final artistes = _filteredArtistes;
    final tracks   = _filteredTracks;

    return CustomScrollView(
      slivers: [
        // ── Section Artistes populaires ──────────────────────────────────
        if (artistes.isNotEmpty) ...[
          _SliverSectionHeader(
            title: 'Artistes populaires',
            trailing: '${artistes.length} artistes',
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: artistes.length,
                itemBuilder: (_, i) => _ArtisteChip(
                  artiste: artistes[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArtistDetailScreen(
                        artiste: artistes[i],
                        songs: _tracksForArtiste(artistes[i]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],

        // ── Section Albums et singles populaires ─────────────────────────
        _SliverSectionHeader(
          title: 'Albums et singles populaires',
          trailing: '${tracks.length} titres',
        ),
        tracks.isEmpty
            ? const SliverFillRemaining(
                child: Center(
                  child: Text('Aucun résultat',
                      style: TextStyle(color: Colors.white38)),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final t = tracks[i];
                      return _AlbumCard(
                        track: t,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerScreen(
                              track: t,
                              playlist: tracks,
                              initialIndex: i,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: tracks.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.80,
                  ),
                ),
              ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _fmtStreams(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M écoutes';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K écoutes';
  return '$n écoute${n > 1 ? 's' : ''}';
}

// ─────────────────────────────────────────────────────────────────────────────
//  Section Header Sliver
// ─────────────────────────────────────────────────────────────────────────────

class _SliverSectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SliverSectionHeader({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(trailing,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Artiste Chip (scroll horizontal)
// ─────────────────────────────────────────────────────────────────────────────

class _ArtisteChip extends StatelessWidget {
  final ArtisteModel artiste;
  final VoidCallback onTap;

  const _ArtisteChip({required this.artiste, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            artiste.photoProfil != null
                ? CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(artiste.photoProfil!),
                    onBackgroundImageError: (_, __) {},
                    backgroundColor: Colors.orange,
                  )
                : _ArtistePlaceholder(initial: artiste.nom.isNotEmpty
                    ? artiste.nom[0].toUpperCase()
                    : 'A'),
            const SizedBox(height: 6),
            Text(
              artiste.nom,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistePlaceholder extends StatelessWidget {
  final String initial;
  const _ArtistePlaceholder({required this.initial});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 32,
      backgroundColor: Colors.orange,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Album Card (GridView 2 colonnes)
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumCard extends StatelessWidget {
  final MusicModel track;
  final VoidCallback onTap;

  const _AlbumCard({required this.track, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: track.coverImg != null
                  ? Image.network(
                      track.coverImg!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const _CoverPlaceholder(),
                    )
                  : const _CoverPlaceholder(),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              track.titre,
              style: TextStyle(
                color: Color(AppColors.textWhite),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              track.artisteId,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (track.streams > 0)
            Padding(
              padding: const EdgeInsets.only(left: 2, top: 1),
              child: Row(
                children: [
                  const Icon(Icons.headphones, size: 10, color: Colors.white24),
                  const SizedBox(width: 3),
                  Text(
                    _fmtStreams(track.streams),
                    style: const TextStyle(color: Colors.white24, fontSize: 10),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Cover Placeholder
// ─────────────────────────────────────────────────────────────────────────────

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

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
      child: const Center(
        child: Icon(Icons.music_note, color: Colors.orange, size: 36),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Artist Detail Screen
// ─────────────────────────────────────────────────────────────────────────────

class ArtistDetailScreen extends StatelessWidget {
  final ArtisteModel artiste;
  final List<MusicModel> songs;

  const ArtistDetailScreen(
      {super.key, required this.artiste, required this.songs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundBlack),
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar avec fond dégradé ──────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF141414),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Fond : photo artiste ou dégradé orange
                  artiste.photoProfil != null
                      ? Image.network(
                          artiste.photoProfil!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFF6B00),
                                  Color(0xFF1A1A1A)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF6B00),
                                Color(0xFF0A0A0A)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                  // Dégradé bas pour lisibilité
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(AppColors.backgroundBlack),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Infos artiste centrées en bas
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 16,
                    child: Row(
                      children: [
                        artiste.photoProfil != null
                            ? CircleAvatar(
                                radius: 36,
                                backgroundImage:
                                    NetworkImage(artiste.photoProfil!),
                                backgroundColor: Colors.orange,
                              )
                            : CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.orange,
                                child: Text(
                                  artiste.nom.isNotEmpty
                                      ? artiste.nom[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                artiste.nom,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (artiste.genre != null)
                                Text(artiste.genre!,
                                    style: const TextStyle(
                                        color: Colors.orange, fontSize: 13)),
                              Text(
                                '${songs.length} morceau${songs.length > 1 ? 'x' : ''}',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bio ───────────────────────────────────────────────────────
          if (artiste.bio != null && artiste.bio!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  artiste.bio!,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            ),

          // ── Titre section ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Morceaux',
                style: TextStyle(
                  color: Color(AppColors.textWhite),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ── Liste des chansons ────────────────────────────────────────
          songs.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.music_off,
                            size: 48, color: Colors.white24),
                        SizedBox(height: 12),
                        Text('Aucun morceau disponible',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 14)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final song = songs[i];
                        return _SongTile(
                          track: song,
                          index: i + 1,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlayerScreen(
                                track: song,
                                playlist: songs,
                                initialIndex: i,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: songs.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Song Tile (dans ArtistDetailScreen)
// ─────────────────────────────────────────────────────────────────────────────

class _SongTile extends StatelessWidget {
  final MusicModel track;
  final int index;
  final VoidCallback onTap;

  const _SongTile(
      {required this.track, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            // Numéro ou cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 52,
                height: 52,
                child: track.coverImg != null
                    ? Image.network(track.coverImg!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _CoverPlaceholder())
                    : const _CoverPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.titre,
                    style: TextStyle(
                      color: Color(AppColors.textWhite),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    track.artisteId,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  if (track.streams > 0)
                    Row(
                      children: [
                        const Icon(Icons.headphones,
                            size: 11, color: Colors.white24),
                        const SizedBox(width: 3),
                        Text(
                          _fmtStreams(track.streams),
                          style: const TextStyle(
                              color: Colors.white24, fontSize: 11),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_outline,
                color: Colors.orange, size: 28),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Player Screen
// ─────────────────────────────────────────────────────────────────────────────

class PlayerScreen extends StatefulWidget {
  final MusicModel track;
  final List<MusicModel> playlist;
  final int initialIndex;

  const PlayerScreen({
    super.key,
    required this.track,
    required this.playlist,
    required this.initialIndex,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final AudioPlayer _player;
  late MusicModel _current;
  late int _currentIndex;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  late List<MusicModel> _playlist;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _current = widget.track;
    _currentIndex = widget.initialIndex;
    _playlist = List<MusicModel>.from(widget.playlist);

    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPlayerComplete.listen((_) => _playNext());

    _playTrack(_current);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playTrack(MusicModel track) async {
    setState(() {
      _current = track;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    await _player.play(UrlSource(track.audioUrl));
    // Incrémenter le compteur d'écoutes
    final newCount = await MusicService.stream(track.id);
    if (mounted && newCount > 0) {
      setState(() {
        _current = _current.copyWith(streams: newCount);
        _playlist[_currentIndex] = _current;
      });
    }
  }

  Future<void> _togglePlay() async {
    _isPlaying ? await _player.pause() : await _player.resume();
  }

  void _playNext() {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      _playTrack(_playlist[_currentIndex]);
    }
  }

  void _playPrev() {
    if (_position.inSeconds > 3) {
      _player.seek(Duration.zero);
      return;
    }
    if (_currentIndex > 0) {
      _currentIndex--;
      _playTrack(_playlist[_currentIndex]);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final hasPrev = _currentIndex > 0;
    final hasNext = _currentIndex < _playlist.length - 1;

    return Scaffold(
      backgroundColor: Color(AppColors.backgroundBlack),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text('Lecture en cours',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Cover ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _current.coverImg != null
                      ? Image.network(
                          _current.coverImg!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              const _CoverPlaceholder(),
                        )
                      : const _CoverPlaceholder(),
                ),
              ),
            ),

            // ── Infos ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _current.titre,
                          style: TextStyle(
                            color: Color(AppColors.textWhite),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(_current.artisteId,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 14)),
                        if (_current.streams > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.headphones,
                                    size: 13, color: Colors.white38),
                                const SizedBox(width: 4),
                                Text(
                                  _fmtStreams(_current.streams),
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.favorite_border,
                      color: Colors.white24, size: 24),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Slider ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.orange,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.orange,
                      overlayColor: Colors.orange.withValues(alpha: 0.2),
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _duration.inSeconds > 0
                          ? _position.inSeconds
                              .toDouble()
                              .clamp(0.0, _duration.inSeconds.toDouble())
                          : 0.0,
                      max: _duration.inSeconds > 0
                          ? _duration.inSeconds.toDouble()
                          : 1.0,
                      onChanged: (v) =>
                          _player.seek(Duration(seconds: v.toInt())),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(_position),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                        Text(_fmt(_duration),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Contrôles ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous_rounded,
                        color: hasPrev ? Colors.white : Colors.white24,
                        size: 40),
                    onPressed: hasPrev ? _playPrev : null,
                  ),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next_rounded,
                        color: hasNext ? Colors.white : Colors.white24,
                        size: 40),
                    onPressed: hasNext ? _playNext : null,
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
