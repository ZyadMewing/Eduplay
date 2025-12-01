// lib/screens/mini_game_screen.dart
import 'package:flutter/material.dart';

class MiniGameScreen extends StatelessWidget {
  final String gameMode;
  final int stage;
  final int level;

  const MiniGameScreen({
    super.key,
    required this.gameMode,
    required this.stage,
    required this.level,
  });

  // Fungsi untuk menampilkan dialog kemenangan
  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan tap di luar
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🎉 Level Selesai! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Anda berhasil menyelesaikan tantangan ini!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),
              // TODO: US007 - Tampilkan Permata yang Didapat di sini
              const Text(
                '+10 Permata',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              // Kembali ke Pemilihan Level atau Stage
              onPressed: () {
                // Pop dua kali untuk kembali dari MiniGameScreen dan LevelSelectionScreen
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
              },
              child: const Text('Lanjut Petualangan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$gameMode - Stage $stage - Level $level'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selamat Bermain!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Di sini akan muncul konten mini-game edukatif (misalnya: tebak gambar atau susun kata) sebagai bagian dari level.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 50),
              // Tombol Simulasi Penyelesaian Game
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Simulasi Selesai Level & Dapat Permata'),
                onPressed: () => _showCompletionDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}