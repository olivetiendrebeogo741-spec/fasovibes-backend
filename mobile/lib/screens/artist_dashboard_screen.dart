import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../config/constants.dart';
import '../models/music.dart';
import '../models/video.dart';
import '../services/dashboard_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_input_field.dart';

class ArtistDashboardScreen extends StatefulWidget {
  final bool embedded;
  final VoidCallback? onLogout;

  const ArtistDashboardScreen({super.key, this.embedded = false, this.onLogout});

  @override
  State<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends State<ArtistDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<MusicModel> _musics = [];
  List<VideoModel> _videos = [];
  bool _loading = true;
  String _artistName = '';
  String? _artistPhoto;
  Uint8List? _artistPhotoBytes;

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
      final user = await StorageService.getUser();
      final results = await Future.wait([
        DashboardService.getMyMusic(),
        DashboardService.getMyVideos(),
      ]);
      if (mounted) {
        setState(() {
          _artistName = user['nom'] ?? 'Artiste';
          _musics = results[0] as List<MusicModel>;
          _videos = results[1] as List<VideoModel>;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _totalLikes => _videos.fold(0, (sum, v) => sum + v.likes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundBlack),
      floatingActionButton: _buildFab(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildStatsGrid()),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Color(AppColors.primaryOrange),
                      labelColor: Color(AppColors.primaryOrange),
                      unselectedLabelColor: Color(AppColors.textGrey),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.white10,
                      tabs: const [
                        Tab(text: 'Mes Musiques'),
                        Tab(text: 'Mes Vidéos'),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _MusicTab(
                    musics: _musics,
                    onDelete: (id) => _deleteMusic(id),
                    onEdit: (music) => _showEditMusicDialog(music),
                  ),
                  _VideoTab(
                    videos: _videos,
                    onDelete: (id) => _deleteVideo(id),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          widget.embedded ? 16 : 20,
          widget.embedded ? 16 : 56,
          20,
          24),
      decoration: BoxDecoration(
        color: Color(AppColors.surfaceDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!widget.embedded)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          if (!widget.embedded) const SizedBox(width: 8),
          GestureDetector(
            onTap: _pickProfilePhoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _artistPhotoBytes != null
                    ? CircleAvatar(
                        radius: 32,
                        backgroundImage: MemoryImage(_artistPhotoBytes!),
                      )
                    : _artistPhoto != null
                        ? CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(_artistPhoto!),
                          )
                        : CircleAvatar(
                            radius: 32,
                            backgroundColor: Color(AppColors.primaryOrange),
                            child: Text(
                              _artistName.isNotEmpty ? _artistName[0].toUpperCase() : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(AppColors.primaryOrange),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(Icons.camera_alt, size: 11, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _artistName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mon Dashboard',
                  style: TextStyle(
                    color: Color(AppColors.primaryOrange),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _load,
          ),
          if (widget.embedded)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white38, size: 20),
              onPressed: _logout,
            ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await StorageService.clear();
    widget.onLogout?.call();
  }

  Future<void> _pickProfilePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() => _artistPhotoBytes = result.files.single.bytes);
    }
  }

  // ── Stats Grid ───────────────────────────────────────────────────────────────

  Widget _buildStatsGrid() {
    return Container(
      color: Color(AppColors.backgroundBlack),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatCard(icon: Icons.music_note, value: '${_musics.length}', label: 'Titres'),
          const SizedBox(width: 12),
          _StatCard(icon: Icons.video_collection, value: '${_videos.length}', label: 'Vidéos'),
          const SizedBox(width: 12),
          _StatCard(icon: Icons.favorite, value: '$_totalLikes', label: 'Likes Totaux'),
        ],
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────────

  Widget _buildFab() {
    return FloatingActionButton(
      backgroundColor: Color(AppColors.primaryOrange),
      onPressed: () {
        if (_tabController.index == 0) {
          _showAddMusicSheet();
        } else {
          _showAddVideoSheet();
        }
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // ── Add Music (file picker) ────────────────────────────────────────────────

  void _showAddMusicSheet() {
    final titreCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedPath;
    String? selectedName;
    String? coverPath;
    String? coverName;

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(AppColors.surfaceDark),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Icon(Icons.music_note, color: Color(AppColors.primaryOrange), size: 22),
                    const SizedBox(width: 10),
                    const Text('Ajouter un morceau',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 20),
                  AppInputField(
                    controller: titreCtrl,
                    label: 'Titre du morceau',
                    icon: Icons.title,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Titre obligatoire' : null,
                  ),
                  const SizedBox(height: 14),
                  // Audio file picker
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.audio,
                      );
                      if (result != null && result.files.single.path != null) {
                        setSheet(() {
                          selectedPath = result.files.single.path;
                          selectedName = result.files.single.name;
                        });
                      }
                    },
                    child: _FilePicker(
                      icon: selectedPath != null ? Icons.audio_file : Icons.folder_open,
                      label: selectedName ?? 'Choisir un fichier audio',
                      selected: selectedPath != null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Cover image picker
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );
                      if (result != null && result.files.single.path != null) {
                        setSheet(() {
                          coverPath = result.files.single.path;
                          coverName = result.files.single.name;
                        });
                      }
                    },
                    child: _FilePicker(
                      icon: coverPath != null ? Icons.image : Icons.add_photo_alternate_outlined,
                      label: coverName ?? 'Ajouter une photo de couverture (optionnel)',
                      selected: coverPath != null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.primaryOrange),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        if (selectedPath == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Choisis un fichier audio'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        try {
                          final music = await DashboardService.uploadMusic(
                            titre: titreCtrl.text.trim(),
                            filePath: selectedPath!,
                            coverPath: coverPath,
                          );
                          if (mounted) setState(() => _musics.insert(0, music));
                          _showSnack('Morceau ajouté !', success: true);
                        } catch (e) {
                          _showSnack(e.toString());
                        }
                      },
                      child: const Text('Ajouter',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Add Video (file picker) ────────────────────────────────────────────────

  void _showAddVideoSheet() {
    final titreCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedPath;
    String? selectedName;

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(AppColors.surfaceDark),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Icon(Icons.video_call, color: Color(AppColors.primaryOrange), size: 22),
                    const SizedBox(width: 10),
                    const Text('Ajouter une vidéo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 20),
                  AppInputField(
                    controller: titreCtrl,
                    label: 'Titre de la vidéo',
                    icon: Icons.title,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Titre obligatoire' : null,
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.video,
                      );
                      if (result != null && result.files.single.path != null) {
                        setSheet(() {
                          selectedPath = result.files.single.path;
                          selectedName = result.files.single.name;
                        });
                      }
                    },
                    child: _FilePicker(
                      icon: selectedPath != null ? Icons.video_file : Icons.folder_open,
                      label: selectedName ?? 'Choisir une vidéo depuis la galerie',
                      selected: selectedPath != null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.primaryOrange),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        if (selectedPath == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Choisis une vidéo'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        try {
                          final video = await DashboardService.uploadVideo(
                            titre: titreCtrl.text.trim(),
                            filePath: selectedPath!,
                          );
                          if (mounted) setState(() => _videos.insert(0, video));
                          _showSnack('Vidéo ajoutée !', success: true);
                        } catch (e) {
                          _showSnack(e.toString());
                        }
                      },
                      child: const Text('Ajouter',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Edit Music ────────────────────────────────────────────────────────────────

  void _showEditMusicDialog(MusicModel music) {
    final titreCtrl = TextEditingController(text: music.titre);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(AppColors.surfaceDark),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Icon(Icons.edit, color: Color(AppColors.primaryOrange), size: 22),
                const SizedBox(width: 10),
                const Text('Modifier le morceau',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 20),
              AppInputField(
                controller: titreCtrl,
                label: 'Titre',
                icon: Icons.title,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Titre obligatoire' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.primaryOrange),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(context);
                    _showSnack('Modification bientôt disponible.', success: true);
                  },
                  child: const Text('Modifier',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  Future<void> _deleteMusic(String id) async {
    final confirmed = await _confirmDelete('ce morceau');
    if (!confirmed) return;
    try {
      await DashboardService.deleteMusic(id);
      if (mounted) setState(() => _musics.removeWhere((m) => m.id == id));
      _showSnack('Morceau supprimé.', success: true);
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<void> _deleteVideo(String id) async {
    final confirmed = await _confirmDelete('cette vidéo');
    if (!confirmed) return;
    try {
      await DashboardService.deleteVideo(id);
      if (mounted) setState(() => _videos.removeWhere((v) => v.id == id));
      _showSnack('Vidéo supprimée.', success: true);
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<bool> _confirmDelete(String label) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Color(AppColors.surfaceDark),
            title: const Text('Confirmer',
                style: TextStyle(color: Colors.white)),
            content: Text('Supprimer $label ?',
                style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler',
                      style: TextStyle(color: Colors.white54))),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Supprimer',
                      style: TextStyle(color: Colors.redAccent))),
            ],
          ),
        ) ??
        false;
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : Colors.redAccent,
    ));
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Color(AppColors.surfaceDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Color(AppColors.primaryOrange), size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(color: Color(AppColors.textGrey), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Music Tab ─────────────────────────────────────────────────────────────────

class _MusicTab extends StatelessWidget {
  final List<MusicModel> musics;
  final void Function(String id) onDelete;
  final void Function(MusicModel music) onEdit;

  const _MusicTab(
      {required this.musics, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (musics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 56, color: Color(AppColors.textGrey)),
            const SizedBox(height: 12),
            Text('Aucun morceau pour l\'instant',
                style: TextStyle(color: Color(AppColors.textGrey))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: musics.length,
      itemBuilder: (_, i) {
        final music = musics[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Color(AppColors.surfaceDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(AppColors.primaryOrange),
              backgroundImage:
                  music.coverImg != null ? NetworkImage(music.coverImg!) : null,
              child: music.coverImg == null
                  ? const Icon(Icons.music_note, color: Colors.white, size: 18)
                  : null,
            ),
            title: Text(music.titre,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
            subtitle: Text(music.audioUrl,
                style: TextStyle(
                    color: Color(AppColors.textGrey), fontSize: 11),
                overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      color: Color(AppColors.primaryOrange), size: 20),
                  onPressed: () => onEdit(music),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: () => onDelete(music.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Video Tab ─────────────────────────────────────────────────────────────────

class _VideoTab extends StatelessWidget {
  final List<VideoModel> videos;
  final void Function(String id) onDelete;

  const _VideoTab({required this.videos, required this.onDelete});

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
            Text('Aucune vidéo pour l\'instant',
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
      itemBuilder: (_, i) {
        final video = videos[i];
        return _VideoThumbnail(video: video, onDelete: onDelete);
      },
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final VideoModel video;
  final void Function(String id) onDelete;

  const _VideoThumbnail({required this.video, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: Center(
                child: Icon(Icons.play_circle_fill,
                    size: 44, color: Colors.white.withValues(alpha: 0.4)),
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
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => onDelete(video.id),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── File Picker Row ───────────────────────────────────────────────────────────

class _FilePicker extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _FilePicker({required this.icon, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(AppColors.backgroundBlack),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? Color(AppColors.primaryOrange) : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: selected ? Color(AppColors.primaryOrange) : Colors.white38,
              size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white38,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (selected)
            Icon(Icons.check_circle,
                color: Color(AppColors.primaryOrange), size: 18),
        ],
      ),
    );
  }
}

// ── TabBar Delegate ───────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Color(AppColors.backgroundBlack),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _TabBarDelegate old) => old.tabBar != tabBar;
}
