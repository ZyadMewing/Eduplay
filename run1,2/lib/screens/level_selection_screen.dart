import 'package:flutter/material.dart';
import 'package:eduplay_game/mgame/mini_game_screen.dart'; // File untuk US005 - Mini Game

class LevelSelectionScreen extends StatelessWidget {
  final String gameMode;
  final int stage;
  const LevelSelectionScreen({
    super.key,
    required this.gameMode,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$gameMode - Stage $stage: Pilih Level')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Level yang tersedia di Stage $stage ($gameMode)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Placeholder Tombol Level 1
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MiniGameScreen(
                      gameMode: gameMode,
                      stage: stage,
                      level: 1, // Memasukkan informasi level
                    ),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'TODO: Implementasi Mini Game (US005) dimulai dari sini!',
                    ),
                  ),
                );
              },
              child: const Text('Level 1'),
            ),
            const SizedBox(height: 10),
            // Placeholder Tombol Level 2
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MiniGameScreen(
                      gameMode: gameMode,
                      stage: stage,
                      level: 2, // Memasukkan informasi level
                    ),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'TODO: Implementasi Mini Game (US005) dimulai dari sini!',
                    ),
                  ),
                );
              },
              child: const Text('Level 2'),
            ),
            // ... Tambahkan Level 3, 4, 5, dll.
          ],
        ),
      ),
    );
  }
}
