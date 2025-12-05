import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math'; // max
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_manager.dart';
import '../services/word_question_loader.dart';

class WordGameScreen extends StatefulWidget {
  final int startLevel;
  const WordGameScreen({super.key, required this.startLevel});

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen> {
  late int _level;
  int _timeLeft = 60;
  Timer? _timer;
  bool _showGemNotif = false;

  late List<List<String>> _allNormalSentences = [];
  late List<List<String>> _allBossSentences = [];

  List<String> _targetSentence = [];
  List<String> _shuffledOptions = [];
  List<String> _userAnswer = [];
  bool _isBossLevel = false;

  @override
  void initState() {
    super.initState();
    _level = widget.startLevel;
    _loadQuestionsAndStart();
  }

  Future<void> _loadQuestionsAndStart() async {
    _allNormalSentences = await WordQuestionLoader.getNormalQuestions();
    _allBossSentences = await WordQuestionLoader.getBossQuestions();
    if (mounted) {
      _startLevel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- LOGIKA SAVE ---
  Future<void> _handleWin() async {
    final prefs = await SharedPreferences.getInstance();

    int currentGems = prefs.getInt('totalGems') ?? 0;
    await prefs.setInt('totalGems', currentGems + 5);

    int currentMax = prefs.getInt('wordMaxLevel') ?? 1;
    int nextLevel = _level + 0;
    await prefs.setInt('wordMaxLevel', max(currentMax, nextLevel));

    int currentDaily = prefs.getInt('dailyWordProgress') ?? 0;
    await prefs.setInt('dailyWordProgress', currentDaily + 1);

    // Streak Naik
    int streak = prefs.getInt('currentStreak') ?? 0;
    await prefs.setInt('currentStreak', streak + 1);
  }

  void _handleStreakLoss(String reason) async {
    _timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    int currentStreak = prefs.getInt('currentStreak') ?? 0;
    int currentGems = prefs.getInt('totalGems') ?? 0;

    if (currentStreak == 0) {
      _showGameOverDialog(reason, 0, currentGems, false);
      return;
    }
    _showGameOverDialog(reason, currentStreak, currentGems, true);
  }

  void _showGameOverDialog(
    String reason,
    int streakLoss,
    int gems,
    bool canRestore,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "YAAH KALAH! 😭",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reason, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (canRestore) ...[
              const Icon(Icons.heart_broken, size: 50, color: Colors.redAccent),
              const SizedBox(height: 10),
              Text(
                "Pet kamu akan kembali jadi telur!\nStreak $streakLoss hilang.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ] else
              const Text("Coba lagi ya!"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('currentStreak', 0); // RESET
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Relakan (Reset)",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          if (canRestore)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gems >= 300 ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
              ),
              onPressed: gems >= 300
                  ? () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('totalGems', gems - 300); // BAYAR
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Pet Selamat! -300 💎"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  : null,
              child: const Column(
                children: [
                  Text("Selamatkan"),
                  Text("300 💎", style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _startLevel() {
    setState(() {
      _isBossLevel = (_level % 10 == 0);
      _timeLeft = _isBossLevel ? 30 : 60;

      if (_isBossLevel) {
        int bossIndex = (_level ~/ 10) - 1;
        _targetSentence =
            _allBossSentences[bossIndex % _allBossSentences.length];
      } else {
        _targetSentence =
            _allNormalSentences[(_level - 1) % _allNormalSentences.length];
      }
      _shuffledOptions = List.from(_targetSentence);
      _shuffledOptions.shuffle();
      _userAnswer.clear();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0)
            _timeLeft--;
          else
            _handleStreakLoss("Waktu Habis!");
        });
      }
    });
  }

  void _onOptionTap(String word) {
    setState(() {
      _userAnswer.add(word);
      _shuffledOptions.remove(word);
    });
    if (_shuffledOptions.isEmpty) _checkResult();
  }

  void _resetAnswer() {
    setState(() {
      _shuffledOptions.addAll(_userAnswer);
      _userAnswer.clear();
      _shuffledOptions.shuffle();
    });
  }

  void _checkResult() {
    String joinedUser = _userAnswer.join(" ");
    String joinedTarget = _targetSentence.join(" ");

    if (joinedUser == joinedTarget) {

          // --- LOGIKA SUARA PINTAR ---
      if (_isBossLevel) {
        // Kalau Boss kalah, bunyikan suara Menang Besar!
        AudioManager.instance.playSfx('win.mp3'); 
      } else {
        // Kalau level biasa, cukup suara "Ting"
        AudioManager.instance.playSfx('correct2.mp3'); 
      }

      setState(() => _showGemNotif = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showGemNotif = false);
      });

      _handleWin(); // Win

      setState(() => _level++);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _startLevel();
      });
    } else {
      _handleStreakLoss("Susunan Salah!");
      AudioManager.instance.playSfx('wrong.mp3'); // Loss
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Color> bgColors = _isBossLevel
        ? [const Color(0xFF451010), const Color(0xFF801515)]
        : [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "LEVEL $_level",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  value: 1,
                  color: Colors.white30,
                ),
                CircularProgressIndicator(
                  value: _timeLeft / (_isBossLevel ? 30 : 60),
                  color: _timeLeft < 10 ? Colors.red : Colors.greenAccent,
                ),
                Text(
                  "$_timeLeft",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              if (_isBossLevel)
                const Text(
                  "BOSS FIGHT!",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

              // Notifikasi Banner
              AnimatedOpacity(
                opacity: _showGemNotif ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "+5",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.diamond, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Kotak Jawaban
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: _userAnswer.isEmpty
                    ? const Center(
                        child: Text(
                          "Ketuk kata di bawah untuk menyusun kalimat",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: _userAnswer.map((word) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              word,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),

              if (_userAnswer.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  label: const Text(
                    "Ulangi",
                    style: TextStyle(color: Colors.white70),
                  ),
                  onPressed: _resetAnswer,
                ),

              const Spacer(),

              // Pilihan Kata (Tiles)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: _shuffledOptions.map((word) {
                    return GestureDetector(
                      onTap: () => _onOptionTap(word),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          word,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
