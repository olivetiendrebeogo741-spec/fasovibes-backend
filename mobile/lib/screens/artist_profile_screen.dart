import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../models/artiste.dart';
import '../models/music.dart';
import '../models/video.dart';
import '../services/artiste_service.dart';
import '../services/music_service.dart';
import '../services/video_service.dart';

String _url(String path) {
  if (path.startsWith('http')) return path;
  return '${ApiConstants.baseUrl}$path';
}

class ArtistProfileScreen extends StatefulWidget {
  final String artisteRealId;
  final String artisteName;

  const ArtistProfileScreen({
    super.key,
    required this.artisteRealId,
    required this.artisteName,
  });

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ArtisteModel? _artiste;
  List<VideoModel> _videos = [];
  List<MusicModel> _musics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ArtisteService.getAll(),
        VideoService.getAll(),
        MusicService.getAll(),
      ]);

      final artistes = results[0] as List<ArtisteModel>;
      final allVideos = results[1] as List<VideoModel>;
      final allMusics = results[2] as List<MusicModel>;

      ArtisteModel? artiste;
      if (widget.artisteRealId.isNotEmpty) {
        artiste = artistes.cast<ArtisteModel?>().firstWhere(
              (a) => a?.id == widget.artisteRealId,
              orElse: () => null,
            );
      }
      artiste ??= artistes.cast<ArtisteModel?>().firstWhere(
            (a) => a?.nom == widget.artisteName,
            orElse: () => null,
          );

      final videos = allVideos
          .where((v) =>
              v.artisteRealId == widget.artisteRealId ||
              v.artisteId == widget.artisteName)
          .toList();

      final musics = allMusics
          .where((m) =>
              m.artisteRealId == widget.artisteRealId ||
              m.artisteId == widget.artisteName)
          .toList();

      if (mounted) {
        setState(() {
          _artiste = artiste;
          _videos = videos;
          _musics = musics;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundBlack),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange))
          : NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Color(AppColors.primaryOrange),
                      labelColor: Color(AppColors.primaryOrange),
                      unselectedLabelColor: Color(AppColors.textGrey),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.white10,
                      tabs: [
                        Tab(text: 'Vidéos (${_videos.length})'),
                        Tab(text: 'Musiques (${_musics.length})'),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _VideoGrid(videos: _videos),
                  _MusicGrid(musics: _musics),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final photo = _artiste?.photoProfil;
    final nom = _artiste?.nom ?? widget.artisteName;
    final genre = _artiste?.genre;
    final bio = _artiste?.bio;

    return Container(
      decoration: BoxDecoration(
        color: Color(AppColors.surfaceDark),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // AppBar row
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      '@$nom',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Profile info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                photo != null
                    ? CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(_url(photo)),
                      )
                    : CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(AppColors.primaryOrange),
                        child: Text(
                          nom.isNotEmpty ? nom[0].toUpperCase() : 'A',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nom,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      if (genre != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Color(AppColors.primaryOrange)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Color(AppColors.primaryOrange)
                                    .withValues(alpha: 0.4)),
                          ),
                          child: Text(genre,
                              style: TextStyle(
                                  color: Color(AppColors.primaryOrange),
                                  fontSize: 12)),
                        ),
                      ],
                      if (bio != null && bio.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          bio,
                          style: TextStyle(
                              color: Color(AppColors.textGrey), fontSize: 13),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Stats
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                _StatChip(
                    icon: Icons.video_collection,
                    value: '${_videos.length}',
                    label: 'Vidéos'),
                const SizedBox(width: 12),
                _StatChip(
                    icon: Icons.music_note,
                    value: '${_musics.length}',
                    label: 'Titres'),
                const SizedBox(width: 12),
                _StatChip(
                  icon: Icons.favorite,
                  value:
                      '${_videos.fold(0, (sum, v) => sum + v.likes)}',
                  label: 'Likes',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Chip ──────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Color(AppColors.backgroundBlack),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Color(AppColors.primaryOrange), size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(
                    color: Color(AppColors.textGrey), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ── Video Grid ─────────────────────────────────────────────────────────────────

class _VideoGrid extends StatelessWidget {
  final List<VideoModel> videos;
  const _VideoGrid({required this.videos});

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined,
                size: 56, color: Color(AppColors.textGrey)),
            const SizedBox(height: 12),
            Text('Aucune vidéo',
                style: TextStyle(color: Color(AppColors.textGrey))),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 9 / 12,
      ),
      itemCount: videos.length,
      itemBuilder: (_, i) => _ProfileVideoCard(
        video: videos[i],
        allVideos: videos,
        index: i,
      ),
    );
  }
}

class _ProfileVideoCard extends StatelessWidget {
  final VideoModel video;
  final List<VideoModel> allVideos;
  final int index;

  const _ProfileVideoCard({
    required this.video,
    required this.allVideos,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => _VideoScrollPage(
            videos: allVideos,
            initialIndex: index,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(AppColors.surfaceDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.play_circle_fill,
                      size: 44, color: Colors.white24),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(14)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.transparent
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(video.titre,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite,
                            color: Colors.redAccent, size: 12),
                        const SizedBox(width: 2),
                        Text('${video.likes}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Music Grid ─────────────────────────────────────────────────────────────────

class _MusicGrid extends StatelessWidget {
  final List<MusicModel> musics;
  const _MusicGrid({required this.musics});

  @override
  Widget build(BuildContext context) {
    if (musics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 56, color: Color(AppColors.textGrey)),
            const SizedBox(height: 12),
            Text('Aucun morceau',
                style: TextStyle(color: Color(AppColors.textGrey))),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemCount: musics.length,
      itemBuilder: (_, i) => _ProfileMusicCard(music: musics[i]),
    );
  }
}

class _ProfileMusicCard extends StatelessWidget {
  final MusicModel music;
  const _ProfileMusicCard({required this.music});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => _MusicPlayerPage(music: music),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(AppColors.surfaceDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: music.coverImg != null
                  ? Image.network(
                      _url(music.coverImg!),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverPlaceholder(),
                    )
                  : _coverPlaceholder(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(14)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.9),
                      Colors.transparent
                    ],
                  ),
                ),
                child: Text(
                  music.titre,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Center(
              child: SizedBox(
                width: 44,
                height: 44,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.black45, shape: BoxShape.circle),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        color: Color(AppColors.surfaceDark),
        child: Center(
          child: Icon(Icons.music_note,
              color: Color(AppColors.primaryOrange), size: 48),
        ),
      );
}

// ── Music Player Page ─────────────────────────────────────────────────────────

class _MusicPlayerPage extends StatefulWidget {
  final MusicModel music;
  const _MusicPlayerPage({required this.music});

  @override
  State<_MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<_MusicPlayerPage> {
  late AudioPlayer _player;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _playing = s == PlayerState.playing);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.play(UrlSource(_url(widget.music.audioUrl)));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: Color(AppColors.backgroundBlack),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Lecture',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(),
            // Cover art
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: widget.music.coverImg != null
                  ? Image.network(
                      _url(widget.music.coverImg!),
                      width: 260,
                      height: 260,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _cover(260),
                    )
                  : _cover(260),
            ),
            const SizedBox(height: 40),
            // Titre + artiste
            Text(
              widget.music.titre,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              widget.music.artisteId,
              style: TextStyle(
                  color: Color(AppColors.textGrey), fontSize: 15),
            ),
            const SizedBox(height: 40),
            // Barre de progression
            Slider(
              value: progress.toDouble(),
              onChanged: (v) => _player.seek(Duration(
                  milliseconds: (v * _duration.inMilliseconds).round())),
              activeColor: Color(AppColors.primaryOrange),
              inactiveColor: Colors.white24,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(_position),
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(_fmt(_duration),
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Contrôles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10,
                      color: Colors.white70, size: 36),
                  onPressed: () => _player.seek(Duration(
                      seconds: (_position.inSeconds - 10)
                          .clamp(0, _duration.inSeconds))),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () =>
                      _playing ? _player.pause() : _player.resume(),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                        color: Color(AppColors.primaryOrange),
                        shape: BoxShape.circle),
                    child: Icon(
                        _playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 34),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.forward_10,
                      color: Colors.white70, size: 36),
                  onPressed: () => _player.seek(Duration(
                      seconds: (_position.inSeconds + 10)
                          .clamp(0, _duration.inSeconds))),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _cover(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Color(AppColors.surfaceDark),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.music_note,
            color: Color(AppColors.primaryOrange), size: size * 0.4),
      );
}

// ── Video Scroll Page ─────────────────────────────────────────────────────────

class _VideoScrollPage extends StatefulWidget {
  final List<VideoModel> videos;
  final int initialIndex;

  const _VideoScrollPage(
      {required this.videos, required this.initialIndex});

  @override
  State<_VideoScrollPage> createState() => _VideoScrollPageState();
}

class _VideoScrollPageState extends State<_VideoScrollPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.videos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => _VideoPageItem(
              video: widget.videos[i],
              isActive: i == _currentIndex,
            ),
          ),
          SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Video Page Item ───────────────────────────────────────────────────────────

class _VideoPageItem extends StatefulWidget {
  final VideoModel video;
  final bool isActive;

  const _VideoPageItem({required this.video, required this.isActive});

  @override
  State<_VideoPageItem> createState() => _VideoPageItemState();
}

class _VideoPageItemState extends State<_VideoPageItem> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _showControls = true;
  late VideoModel _video;

  @override
  void initState() {
    super.initState();
    _video = widget.video;
    _initVideo();
  }

  @override
  void didUpdateWidget(_VideoPageItem old) {
    super.didUpdateWidget(old);
    if (widget.isActive != old.isActive) {
      widget.isActive ? _controller?.play() : _controller?.pause();
    }
  }

  void _onShare() {
    Share.share(
      'Regarde "${_video.titre}" par @${_video.artisteId} sur FasoVibes!\n'
      '${_url(_video.videoUrl)}',
    );
  }

  void _showComments(BuildContext context) {
    final textCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(AppColors.surfaceDark),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          bool posting = false;

          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            expand: false,
            builder: (_, scrollCtrl) => Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
                Text(
                  'Commentaires (${_video.commentaires.length})',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.white12, height: 20),
                // Liste
                Expanded(
                  child: _video.commentaires.isEmpty
                      ? const Center(
                          child: Text('Sois le premier à commenter !',
                              style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          itemCount: _video.commentaires.length,
                          itemBuilder: (_, i) {
                            final c = _video.commentaires[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        Color(AppColors.primaryOrange),
                                    child: Text(
                                      c.auteurId.isNotEmpty
                                          ? c.auteurId[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(c.texte,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${c.date.day}/${c.date.month}/${c.date.year}',
                                          style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                // Champ de saisie
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, 8, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ajouter un commentaire...',
                            hintStyle:
                                const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Color(AppColors.backgroundBlack),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: posting
                            ? null
                            : () async {
                                final text = textCtrl.text.trim();
                                if (text.isEmpty) return;
                                setSheet(() => posting = true);
                                try {
                                  final updated =
                                      await VideoService.addComment(
                                          _video.id, text);
                                  textCtrl.clear();
                                  if (mounted) {
                                    setState(() => _video = updated);
                                  }
                                  setSheet(() => posting = false);
                                } catch (_) {
                                  setSheet(() => posting = false);
                                }
                              },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: posting
                                ? Colors.grey
                                : Color(AppColors.primaryOrange),
                            shape: BoxShape.circle,
                          ),
                          child: posting
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _initVideo() async {
    final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(_url(widget.video.videoUrl)));
    await ctrl.initialize();
    if (!mounted) {
      ctrl.dispose();
      return;
    }
    ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    setState(() {
      _controller = ctrl;
      _initialized = true;
    });
    if (widget.isActive) ctrl.play();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Vidéo ou loader
            if (_initialized && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              const Center(
                  child: CircularProgressIndicator(color: Colors.orange)),

            // Info artiste + titre en bas gauche
            Positioned(
              bottom: 100,
              left: 16,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${_video.artisteId}',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _video.titre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Sidebar droite style TikTok
            Positioned(
              bottom: 90,
              right: 12,
              child: Column(
                children: [
                  _SideBtn(
                    icon: Icons.favorite,
                    label: '${_video.likes}',
                    color: Colors.redAccent,
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  _SideBtn(
                    icon: Icons.chat_bubble_rounded,
                    label: '${_video.commentaires.length}',
                    color: Colors.white,
                    onTap: () => _showComments(context),
                  ),
                  const SizedBox(height: 20),
                  _SideBtn(
                    icon: Icons.share_rounded,
                    label: 'Partager',
                    color: Colors.white,
                    onTap: _onShare,
                  ),
                ],
              ),
            ),

            // Contrôles en bas
            if (_showControls && _initialized && _controller != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final ctrl = _controller!;
    final playing = ctrl.value.isPlaying;
    final pos = ctrl.value.position;
    final dur = ctrl.value.duration;
    final progress = dur.inMilliseconds > 0
        ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Slider(
            value: progress.toDouble(),
            onChanged: (v) => ctrl.seekTo(
                Duration(milliseconds: (v * dur.inMilliseconds).round())),
            activeColor: Color(AppColors.primaryOrange),
            inactiveColor: Colors.white24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(pos),
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
              GestureDetector(
                onTap: () => playing ? ctrl.pause() : ctrl.play(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: Color(AppColors.primaryOrange),
                      shape: BoxShape.circle),
                  child: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 26),
                ),
              ),
              Text(_fmt(dur),
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Side Button ───────────────────────────────────────────────────────────────

class _SideBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SideBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Tab Delegate ───────────────────────────────────────────────────────────────

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabDelegate(this.tabBar);

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(
          color: Color(AppColors.backgroundBlack), child: tabBar);

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _TabDelegate old) => old.tabBar != tabBar;
}
