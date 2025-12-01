import 'package:flutter/material.dart';
import 'level_selection_screen.dart'; // Akan kita buat di bawah

class StageSelectionScreen extends StatelessWidget {
  final String gameMode; // 'Puzzle' atau 'Susun Kata'
  const StageSelectionScreen({super.key, required this.gameMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Stage - $gameMode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Stages untuk $gameMode',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Placeholder Tombol Stage 1
            ElevatedButton(
              onPressed: () {
                // Navigasi ke Pemilihan Level
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LevelSelectionScreen(
                      gameMode: gameMode,
                      stage: 1, // Stage yang dipilih
                    ),
                  ),
                );
              },
              child: const Text('Stage 1: Pengenalan Bentuk'),
            ),
            // ... Tambahkan Stage 2, Stage 3, dll.
          ],
        ),
      ),
    );
  }
}