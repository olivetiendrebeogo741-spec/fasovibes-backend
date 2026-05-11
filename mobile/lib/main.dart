import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/feed_screen.dart';
import 'screens/music_screen.dart';
import 'screens/profile_screen.dart';

void main() => runApp(const FasoVibesApp());

class FasoVibesApp extends StatelessWidget {
  const FasoVibesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FasoVibes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(primary: Colors.orange),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      ),
      home: const _SplashGate(),
      routes: {
        '/home': (_) => const MainNavigation(),
      },
    );
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final loggedIn = await StorageService.isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      body: Center(child: CircularProgressIndicator(color: Colors.orange)),
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
          BottomNavigationBarItem(icon: Icon(Icons.video_collection), label: 'Vidéos'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Musique'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
