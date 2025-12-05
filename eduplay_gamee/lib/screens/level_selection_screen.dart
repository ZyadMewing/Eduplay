import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/word_question_loader.dart';
import 'math_game_screen.dart';
import 'word_game_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  final String gameType; // 'MATH' atau 'WORD'

  const LevelSelectionScreen({super.key, required this.gameType});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  int _unlockedLevel = 1;
  int _maxLevels = 50; // Default, akan diupdate dari JSON
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnlockedLevel();
  }

  Future<void> _loadUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();

    // KUNCI HARUS SAMA: 'mathMaxLevel' dan 'wordMaxLevel'
    String key = widget.gameType == 'MATH' ? 'mathMaxLevel' : 'wordMaxLevel';

    // Load jumlah soal dari JSON
    int totalQuestions = 50; // Default
    if (widget.gameType == 'WORD') {
      try {
        final normalQuestions = await WordQuestionLoader.getNormalQuestions();
        final bossQuestions = await WordQuestionLoader.getBossQuestions();
        totalQuestions = normalQuestions.length + bossQuestions.length;
      } catch (e) {
        debugPrint('Error loading word questions: $e');
      }
    }

    setState(() {
      _unlockedLevel = prefs.getInt(key) ?? 1;
      _maxLevels = totalQuestions;
      _isLoading = false;
    });

    debugPrint(
      'Level Terbuka ($key): $_unlockedLevel / $_maxLevels',
    ); // Cek di debug console
  }

  void _navigateToGame(int level) async {
    // Kita gunakan 'await' agar saat kembali, kode di bawahnya jalan
    if (widget.gameType == 'MATH') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MathGameScreen(startLevel: level),
        ),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WordGameScreen(startLevel: level),
        ),
      );
    }
    // PAKSA REFRESH SAAT KEMBALI DARI GAME
    _loadUnlockedLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameType == 'MATH' ? "Level Logika" : "Level Kata"),
        backgroundColor: widget.gameType == 'MATH'
            ? Colors.orange
            : Colors.deepPurple,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "Level Terbuka: $_unlockedLevel", // Tampilkan angka biar jelas
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: _maxLevels,
                      itemBuilder: (context, index) {
                        int level = index + 1;
                        bool isLocked = level > _unlockedLevel;
                        bool isBoss = level % 10 == 0;

                        return InkWell(
                          onTap: isLocked ? null : () => _navigateToGame(level),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLocked
                                  ? Colors.grey.shade300
                                  : (isBoss
                                        ? Colors.red
                                        : (widget.gameType == 'MATH'
                                              ? Colors.orange
                                              : Colors.deepPurple)),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isLocked
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: isLocked
                                  ? Icon(
                                      Icons.lock,
                                      color: Colors.grey.shade500,
                                      size: 20,
                                    )
                                  : Text(
                                      "$level",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
