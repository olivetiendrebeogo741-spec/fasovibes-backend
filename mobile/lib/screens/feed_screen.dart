import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../models/artiste.dart';
import '../models/video.dart';
import '../services/artiste_service.dart';
import '../services/storage_service.dart';
import '../services/video_service.dart';
import 'artist_profile_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<VideoModel> _videos = [];
  bool _loading = true;
  String? _error;
  Set<String> _likedIds = {};

  @override
  void initState() {
    super.initState();
    _initLikes();
    _load();
  }

  Future<void> _initLikes() async {
    final saved = await StorageService.getLikedVideoIds();
    if (mounted) setState(() => _likedIds = saved);
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final videos = await VideoService.getAll();
      videos.shuffle();
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
        StorageService.saveLikedVideoIds(_likedIds);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Contenu principal
          _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange))
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
                            onArtistTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArtistProfileScreen(
                                  artisteRealId: _videos[index].artisteRealId,
                                  artisteName: _videos[index].artisteId,
                                ),
                              ),
                            ),
                          ),
                        ),

          // Icône recherche en haut à droite
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _ArtistSearchScreen(),
                    ),
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  final VideoModel video;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onArtistTap;

  const _VideoCard({
    required this.video,
    required this.isLiked,
    required this.onLike,
    required this.onArtistTap,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard>
    with SingleTickerProviderStateMixin {
  late VideoModel _video;
  late AnimationController _likeAnim;
  late Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _video = widget.video;
    _likeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _likeScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _likeAnim, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_VideoCard old) {
    super.didUpdateWidget(old);
    // Sync le compteur de likes depuis le parent sans écraser les commentaires locaux
    if (widget.video.likes != _video.likes) {
      setState(() => _video = _video.copyWith(likes: widget.video.likes));
    }
  }

  @override
  void dispose() {
    _likeAnim.dispose();
    super.dispose();
  }

  void _handleLike() {
    if (!widget.isLiked) _likeAnim.forward(from: 0.0);
    widget.onLike();
  }

  void _onShare() {
    final videoUrl = _video.videoUrl.startsWith('http')
        ? _video.videoUrl
        : '${ApiConstants.baseUrl}${_video.videoUrl}';
    Share.share(
      'Regarde "${_video.titre}" par @${_video.artisteId} sur FasoVibes!\n$videoUrl',
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
                                    backgroundColor: Colors.orange,
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
                            color: posting ? Colors.grey : Colors.orange,
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

  @override
  Widget build(BuildContext context) {
    final artistInitial =
        _video.artisteId.isNotEmpty ? _video.artisteId[0].toUpperCase() : 'A';

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
              child: Icon(Icons.play_circle_fill,
                  size: 80, color: Colors.white12),
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
                GestureDetector(
                  onTap: widget.onArtistTap,
                  child: Row(
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
                        '@${_video.artisteId}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _video.titre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _relativeTime(_video.createdAt),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
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
                _SidebarAvatar(
                    initial: artistInitial, onTap: widget.onArtistTap),
                const SizedBox(height: 24),
                // Like avec animation
                GestureDetector(
                  onTap: _handleLike,
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _likeScale,
                        child: Icon(
                          widget.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              widget.isLiked ? Colors.orange : Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_video.likes}',
                        style: TextStyle(
                          color:
                              widget.isLiked ? Colors.orange : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SidebarAction(
                  icon: Icons.chat_bubble_rounded,
                  label: '${_video.commentaires.length}',
                  onTap: () => _showComments(context),
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                _SidebarAction(
                  icon: Icons.share_rounded,
                  label: 'Partager',
                  onTap: _onShare,
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
  final VoidCallback? onTap;
  const _SidebarAvatar({required this.initial, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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

// ── Artist Search Screen ──────────────────────────────────────────────────────

class _ArtistSearchScreen extends StatefulWidget {
  const _ArtistSearchScreen();

  @override
  State<_ArtistSearchScreen> createState() => _ArtistSearchScreenState();
}

class _ArtistSearchScreenState extends State<_ArtistSearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  List<ArtisteModel> _all = [];
  List<ArtisteModel> _results = [];
  bool _loading = true;
  bool _searched = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadArtists() async {
    try {
      final artists = await ArtisteService.getAll();
      if (mounted) setState(() { _all = artists; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _loadError = e.toString(); });
    }
  }

  void _search() {
    FocusScope.of(context).unfocus();
    final q = _ctrl.text.trim().toLowerCase();
    setState(() {
      _searched = true;
      _results = q.isEmpty
          ? _all
          : _all.where((a) => a.nom.toLowerCase().contains(q)).toList();
    });
  }

  String _photoUrl(String path) =>
      path.startsWith('http') ? path : '${ApiConstants.baseUrl}$path';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundBlack),
      appBar: AppBar(
        backgroundColor: Color(AppColors.surfaceDark),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Rechercher',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            color: Color(AppColors.surfaceDark),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'Nom de l\'artiste...',
                      hintStyle: TextStyle(color: Color(AppColors.textGrey)),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white38),
                      suffixIcon: _ctrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Colors.white38, size: 18),
                              onPressed: () {
                                _ctrl.clear();
                                setState(() {
                                  _results = [];
                                  _searched = false;
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Color(AppColors.backgroundBlack),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.primaryOrange),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _loading ? null : _search,
                  child: const Text('Rechercher',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Résultats
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange))
                : _loadError != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off,
                                size: 56, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            Text('Erreur de chargement',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(_loadError!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(AppColors.textGrey),
                                    fontSize: 12)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                  _loadError = null;
                                });
                                _loadArtists();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Réessayer'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color(AppColors.primaryOrange)),
                            ),
                          ],
                        ),
                      )
                : !_searched
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64,
                                color: Color(AppColors.textGrey)),
                            const SizedBox(height: 12),
                            Text('Tape un nom et clique Rechercher',
                                style: TextStyle(
                                    color: Color(AppColors.textGrey))),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 56,
                                    color: Color(AppColors.textGrey)),
                                const SizedBox(height: 12),
                                Text('Aucun artiste trouvé',
                                    style: TextStyle(
                                        color: Color(AppColors.textGrey))),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _results.length,
                            separatorBuilder: (_, __) =>
                                const Divider(color: Colors.white10, height: 1),
                            itemBuilder: (_, i) {
                              final a = _results[i];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                leading: a.photoProfil != null
                                    ? CircleAvatar(
                                        radius: 24,
                                        backgroundImage: NetworkImage(
                                            _photoUrl(a.photoProfil!)),
                                      )
                                    : CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            Color(AppColors.primaryOrange),
                                        child: Text(
                                          a.nom.isNotEmpty
                                              ? a.nom[0].toUpperCase()
                                              : 'A',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      ),
                                title: Text(a.nom,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                                subtitle: a.genre != null
                                    ? Text(a.genre!,
                                        style: TextStyle(
                                            color: Color(AppColors.textGrey),
                                            fontSize: 12))
                                    : null,
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white24, size: 14),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ArtistProfileScreen(
                                      artisteRealId: a.id,
                                      artisteName: a.nom,
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
