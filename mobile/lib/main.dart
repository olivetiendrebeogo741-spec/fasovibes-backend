import 'package:flutter/material.dart';
import 'screens/feed_screen.dart';
import 'screens/music_screen.dart';
import 'screens/profile_screen.dart';

void main() => runApp(const FasoVibesApp());

class FasoVibesApp extends StatelessWidget {
  const FasoVibesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FasoVibes',
      debugShowCheckedModeBanner: false,
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    MusicScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'Vidéos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Musique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
