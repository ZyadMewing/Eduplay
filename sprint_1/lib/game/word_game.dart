import 'package:flutter/material.dart';
import 'package:eduplay_game/screens/stage_selection_screen.dart';

class SusunKataModeScreen extends StatelessWidget {
  const SusunKataModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Susun Kata'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Memuat Modul Game Susun Kata...',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // Navigasi Otomatis ke Pemilihan Stage (Sesuai alur di Dokumen Backlog)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StageSelectionScreen(gameMode: 'Susun Kata'),
                  ),
                );
              },
              child: const Text('Lanjutkan ke Pemilihan Stage'),
            ),
          ],
        ),
      ),
    );
  }
}