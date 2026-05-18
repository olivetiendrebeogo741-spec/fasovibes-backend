import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shimmer/shimmer.dart';
import '../config/constants.dart';
import '../models/artiste.dart';
import '../models/music.dart';
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
  List<MusicModel> _tracks = [];
  bool _loadingTracks = true;
  String? _errorTracks;
  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTracks() async {
    if (mounted) setState(() { _loadingTracks = true; _errorTracks = null; });
    try {
      final list = await MusicService.getAll();
      final shuffled = List<MusicModel>.from(list)..shuffle();
      if (mounted) setState(() { _tracks = shuffled; _loadingTracks = false; });
    } catch (e) {
      if (mounted) setState(() { _errorTracks = e.toString(); _loadingTracks = false; });
    }
  }

  Future<void> _load() => _loadTracks();

  // Artistes extraits directement depuis les tracks (même source → IDs corrects)
  List<ArtisteModel> get _artistes {
    final seen = <String>{};
    final result = <ArtisteModel>[];
    for (final t in _tracks) {
      if (t.artisteRealId.isNotEmpty && seen.add(t.artisteRealId)) {
        result.add(ArtisteModel(
          id: t.artisteRealId,
          nom: t.artisteId,
          photoProfil: t.artistePhotoUrl,
        ));
      }
    }
    return result;
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
      .where((t) => t.artisteRealId == artiste.id)
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
    final artistes = _filteredArtistes;
    final tracks   = _filteredTracks;

    return CustomScrollView(
      slivers: [
        // ── Section Artistes ─────────────────────────────────────────────
        _SliverSectionHeader(
          title: 'Artistes populaires',
          trailing: _loadingTracks ? '' : '${artistes.length} artistes',
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 155,
            child: _loadingTracks
                ? _ShimmerArtistes()
                : artistes.isEmpty
                    ? const Center(
                        child: Text('Aucun artiste',
                            style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // ── Section Albums et singles populaires ─────────────────────────
        _SliverSectionHeader(
          title: 'Albums et singles populaires',
          trailing: _loadingTracks ? '' : '${tracks.length} titres',
        ),
        _loadingTracks
            ? SliverToBoxAdapter(child: _ShimmerAlbums())
            : _errorTracks != null
                ? SliverToBoxAdapter(
                    child: Center(
                      child: TextButton.icon(
                        onPressed: _loadTracks,
                        icon: const Icon(Icons.refresh, color: Colors.orange),
                        label: const Text('Réessayer',
                            style: TextStyle(color: Colors.orange)),
                      ),
                    ),
                  )
                : tracks.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(
                          child: Text('Aucun morceau',
                              style: TextStyle(color: Colors.white38)),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
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
                            childAspectRatio: 0.82,
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

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'À l\'instant';
  if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
  if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
  if (diff.inDays < 30) return 'Il y a ${(diff.inDays / 7).floor()} sem.';
  if (diff.inDays < 365) return 'Il y a ${(diff.inDays / 30).floor()} mois';
  return 'Il y a ${(diff.inDays / 365).floor()} an(s)';
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
        width: 110,
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            artiste.photoProfil != null
                ? CircleAvatar(
                    radius: 52,
                    backgroundImage: NetworkImage(artiste.photoProfil!),
                    onBackgroundImageError: (_, __) {},
                    backgroundColor: Colors.orange,
                  )
                : _ArtistePlaceholder(initial: artiste.nom.isNotEmpty
                    ? artiste.nom[0].toUpperCase()
                    : 'A'),
            const SizedBox(height: 8),
            Text(
              artiste.nom,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (artiste.genre != null)
              Text(
                artiste.genre!,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
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
      radius: 52,
      backgroundColor: Colors.orange,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Album Card (scroll horizontal Spotify-style)
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
              borderRadius: BorderRadius.circular(10),
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
          Text(
            track.titre,
            style: TextStyle(
              color: Color(AppColors.textWhite),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            track.artisteId,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time,
                          size: 11, color: Colors.white24),
                      const SizedBox(width: 3),
                      Text(
                        _relativeTime(track.createdAt),
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
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time,
                                  size: 13, color: Colors.white38),
                              const SizedBox(width: 4),
                              Text(
                                _relativeTime(_current.createdAt),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Shimmer — Artistes (cercles horizontaux)
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerArtistes extends StatelessWidget {
  const _ShimmerArtistes();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2A2A2A),
      highlightColor: const Color(0xFF3D3D3D),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          width: 110,
          margin: const EdgeInsets.only(right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 70,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 48,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shimmer — Albums (grille 2 colonnes)
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerAlbums extends StatelessWidget {
  const _ShimmerAlbums();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2A2A2A),
      highlightColor: const Color(0xFF3D3D3D),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (_, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 80,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
