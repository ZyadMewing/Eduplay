// lib/screens/home_screen.dart
import 'package:eduplay_game/game/puzzle_game.dart';
import 'package:eduplay_game/game/word_game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  int _avatarIndex = 0;
  bool _showTutorial = false;

  final List<String> _avatars = [
    'assets/images/avatar1.png',
    'assets/images/avatar2.png',
    'assets/images/avatar3.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileAndTutorialStatus();
  }

  // Ambil data profil dan cek apakah tutorial perlu ditampilkan
  void _loadProfileAndTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Pengguna';
      _avatarIndex = prefs.getInt('avatarIndex') ?? 0;
      _showTutorial = prefs.getBool('showTutorial') ?? false;
    });
  }

  // Fungsi untuk menutup tutorial dan menyimpannya agar tidak muncul lagi
  void _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showTutorial', false);
    setState(() {
      _showTutorial = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Stack digunakan untuk menumpuk widget tutorial di atas layar utama
    return Stack(
      children: [
        // Lapisan 1: Halaman Utama
        Scaffold(
          appBar: AppBar(
            title: Text('Selamat Datang, $_userName!'),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: AssetImage(_avatars[_avatarIndex]),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.store), onPressed: () {}),
              IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pilih Petualangan Belajarmu!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  // Tombol Mode Game Puzzle
                  ElevatedButton.icon(
                    icon: const Icon(Icons.extension),
                    label: const Text('Mode Game Puzzle'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const PuzzleModeScreen()),
                      );
                      // Navigasi ke game puzzle
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tombol Mode Game Susun Kata
                  ElevatedButton.icon(
                    icon: const Icon(Icons.sort_by_alpha),
                    label: const Text('Mode Susun Kata'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SusunKataModeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Lapisan 2: Tutorial (hanya muncul jika _showTutorial true)
        if (_showTutorial) _buildTutorialOverlay(),
      ],
    );
  }

  // Widget untuk membangun tampilan tutorial
  Widget _buildTutorialOverlay() {
    return Material(
      color: Colors.black.withOpacity(0.75),
      child: Stack(
        children: [
          // Teks penjelasan untuk tombol mode game
          Positioned(
            top:
                MediaQuery.of(context).size.height * 0.5 -
                50, // Sesuaikan posisi
            left: 20,
            right: 20,
            child: const Text(
              'Ini adalah pilihan mode game.\n Kamu bisa memilih Puzzle atau Susun Kata untuk mulai belajar!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          // Teks penjelasan untuk ikon toko dan pengaturan
          const Positioned(
            top: 60,
            right: 20,
            child: Text(
              'Di sini ada Toko Avatar dan Pengaturan',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          // Tombol untuk melewati tutorial
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _dismissTutorial,
                child: const Text('Mengerti! (Lewati)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
