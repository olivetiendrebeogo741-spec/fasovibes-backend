import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

const _base = Color(0xFF2A2A2A);
const _highlight = Color(0xFF3D3D3D);

Widget _box({double? w, double? h, double radius = 8, BoxShape shape = BoxShape.rectangle}) =>
    Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(radius) : null,
        shape: shape,
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
//  Feed — cartes vidéo TikTok
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerFeed extends StatelessWidget {
  const ShimmerFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: Stack(
        children: [
          Container(color: Colors.white10),
          // Sidebar droite
          Positioned(
            right: 12,
            bottom: h * 0.15,
            child: Column(
              children: [
                _box(w: 44, h: 44, shape: BoxShape.circle),
                const SizedBox(height: 18),
                _box(w: 44, h: 44, shape: BoxShape.circle),
                const SizedBox(height: 18),
                _box(w: 44, h: 44, shape: BoxShape.circle),
                const SizedBox(height: 18),
                _box(w: 44, h: 44, shape: BoxShape.circle),
              ],
            ),
          ),
          // Infos bas gauche
          Positioned(
            left: 16,
            bottom: h * 0.12,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(w: 120, h: 14, radius: 7),
                const SizedBox(height: 8),
                _box(w: 200, h: 12, radius: 6),
                const SizedBox(height: 6),
                _box(w: 80, h: 10, radius: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Artist Profile
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerArtistProfile extends StatelessWidget {
  const ShimmerArtistProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(height: 240, color: Colors.white),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(w: 160, h: 16, radius: 8),
                  const SizedBox(height: 8),
                  _box(w: 240, h: 12, radius: 6),
                  const SizedBox(height: 8),
                  _box(w: 100, h: 12, radius: 6),
                  const SizedBox(height: 20),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statShimmer(),
                      _statShimmer(),
                      _statShimmer(),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Tab bar
            Container(height: 44, color: Colors.white),
            const SizedBox(height: 8),
            // Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (_, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statShimmer() => Column(
    children: [
      _box(w: 40, h: 16, radius: 8),
      const SizedBox(height: 4),
      _box(w: 60, h: 10, radius: 5),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Artist Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerDashboard extends StatelessWidget {
  const ShimmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header artiste
            Row(
              children: [
                _box(w: 72, h: 72, shape: BoxShape.circle),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(w: 140, h: 16, radius: 8),
                      const SizedBox(height: 8),
                      _box(w: 90, h: 12, radius: 6),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Stats 2x2
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              itemBuilder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            // Tab bar
            Container(height: 40, decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 16),
            // Grid cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Search — liste d'artistes
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerSearchList extends StatelessWidget {
  const ShimmerSearchList({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Row(
          children: [
            _box(w: 52, h: 52, shape: BoxShape.circle),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(h: 14, radius: 7),
                  const SizedBox(height: 6),
                  _box(w: 100, h: 11, radius: 5),
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
//  Profile screen — vérification login
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerProfile extends StatelessWidget {
  const ShimmerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _box(w: 90, h: 90, shape: BoxShape.circle),
            const SizedBox(height: 16),
            _box(w: 160, h: 16, radius: 8),
            const SizedBox(height: 10),
            _box(w: 110, h: 12, radius: 6),
          ],
        ),
      ),
    );
  }
}
