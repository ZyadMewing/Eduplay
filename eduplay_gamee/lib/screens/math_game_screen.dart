import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_manager.dart';

class MathGameScreen extends StatefulWidget {
  final int startLevel;
  const MathGameScreen({super.key, required this.startLevel});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  late int _level;
  int _timeLeft = 60;
  Timer? _timer;
  bool _showGemNotif = false;

  String _questionText = "";
  int _correctAnswer = 0;
  List<int> _answerOptions = [];
  bool _isBossLevel = false;

  final List<String> _fruits = [
    "🍎",
    "🍌",
    "🍇",
    "🍊",
    "🍓",
    "🍉",
    "🍍",
    "🍒",
    "🍄",
    "🥑",
  ];
  String _currentFruit = "🍎";

  @override
  void initState() {
    super.initState();
    _level = widget.startLevel;
    _startLevel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- LOGIKA MENANG ---
  Future<void> _handleWin() async {
    final prefs = await SharedPreferences.getInstance();

    int currentGems = prefs.getInt('totalGems') ?? 0;
    await prefs.setInt('totalGems', currentGems + 5);

    int currentMax = prefs.getInt('mathMaxLevel') ?? 1;
    await prefs.setInt('mathMaxLevel', max(currentMax, _level + 0));

    int currentDaily = prefs.getInt('dailyMathProgress') ?? 0;
    await prefs.setInt('dailyMathProgress', currentDaily + 1);

    int streak = prefs.getInt('currentStreak') ?? 0;
    await prefs.setInt('currentStreak', streak + 1);
  }

  // --- LOGIKA KALAH ---
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
                "Pet akan kembali jadi telur!\nStreak $streakLoss hilang.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ] else
              const Text("Jangan menyerah, coba lagi!"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('currentStreak', 0);
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
                      await prefs.setInt('totalGems', gems - 300);
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
      _generateQuestion();
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

  String _generateFruitDisplay(int count) {
    if (count > 15) {
      return "$count $_currentFruit";
    }
    return _currentFruit * count;
  }

  void _generateQuestion() {
    _currentFruit = _fruits[Random().nextInt(_fruits.length)];
    int op = Random().nextInt(_level > 10 ? 3 : 2);
    int num1, num2;

    if (_isBossLevel) {
      num1 = Random().nextInt(30) + 10;
      num2 = Random().nextInt(10) + 5;
    } else {
      int range = 5 + _level;
      num1 = Random().nextInt(range) + 2;
      num2 = Random().nextInt(range) + 2;
    }

    if (op == 0) {
      _correctAnswer = num1 + num2;
      _questionText =
          "${_generateFruitDisplay(num1)}\n+\n${_generateFruitDisplay(num2)}\n= ?";
    } else if (op == 1) {
      if (num1 < num2) {
        int temp = num1;
        num1 = num2;
        num2 = temp;
      }
      _correctAnswer = num1 - num2;
      _questionText =
          "${_generateFruitDisplay(num1)}\n-\n${_generateFruitDisplay(num2)}\n= ?";
    } else {
      num1 = Random().nextInt(8) + 2;
      num2 = Random().nextInt(4) + 2;
      _correctAnswer = num1 * num2;
      _questionText =
          "${_generateFruitDisplay(num1)}\nx\n${_generateFruitDisplay(num2)}\n= ?";
    }

    List<int> options = [_correctAnswer];
    while (options.length < 4) {
      int dev = Random().nextInt(20) - 10;
      int wrong = _correctAnswer + dev;
      if (wrong >= 0 && wrong != _correctAnswer && !options.contains(wrong)) {
        options.add(wrong);
      } else {
        int fb = Random().nextInt(50) + 1;
        if (!options.contains(fb) && fb != _correctAnswer) options.add(fb);
      }
    }
    options.shuffle();
    _answerOptions = options;
  }

  void _checkAnswer(int selectedAnswer) {
    if (selectedAnswer == _correctAnswer) {
      if (_isBossLevel) {
        AudioManager.instance.playSfx('win.mp3');
      } else {
        AudioManager.instance.playSfx('correct2.mp3');
      }

      setState(() => _showGemNotif = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showGemNotif = false);
      });

      _handleWin();
      setState(() => _level++);
      _startLevel();
    } else {
      _handleStreakLoss("Jawaban Salah!");
      AudioManager.instance.playSfx('wrong.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    var backgroundDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _isBossLevel
            ? [const Color(0xFF800000), const Color(0xFFDC143C)]
            : [const Color(0xFFFF9966), const Color(0xFFFF5E62)],
      ),
    );

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
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isBossLevel
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "BOSS FIGHT!",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.local_fire_department, color: Colors.orange),
                ],
              )
            : Text(
                "LEVEL $_level",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(2, 2),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
      ),
      body: Container(
        decoration: backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // TIMER & NOTIF
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _isBossLevel ? Colors.red.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: _isBossLevel
                          ? Border.all(color: Colors.redAccent, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          color: _isBossLevel || _timeLeft < 10
                              ? Colors.redAccent
                              : Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "$_timeLeft s",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: _isBossLevel ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (_showGemNotif)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
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

              const SizedBox(height: 10),

              // --- AREA SOAL (PERBAIKAN UTAMA) ---
              // Menggunakan Expanded agar papan soal mengisi ruang yang ada
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isBossLevel
                        ? const Color(0xFFA30000)
                        : const Color(0xFF8D6E63),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isBossLevel
                          ? const Color(0xFFFF4500)
                          : const Color(0xFF5D4037),
                      width: _isBossLevel ? 6 : 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isBossLevel
                            ? Colors.redAccent.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 10),
                        blurRadius: _isBossLevel ? 20 : 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Tengahkan isi papan
                    children: [
                      if (_isBossLevel)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            "KALAHKAN BOS!",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                      // Area Teks Soal (Bisa discroll jika panjang)
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Text(
                              _questionText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _isBossLevel
                              ? "Cepat! Waktu terbatas!"
                              : "Hitung total buah",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- GRID JAWABAN (FIXED) ---
              Container(
                height: 180, // Tinggi pas untuk 2 baris tombol
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.only(bottom: 20),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 2.2, // Tombol agak pipih agar muat
                  ),
                  itemCount: _answerOptions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _checkAnswer(_answerOptions[index]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isBossLevel
                              ? Colors.red.shade100
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(0, 5),
                              blurRadius: 0,
                            ),
                          ],
                          border: _isBossLevel
                              ? Border.all(color: Colors.red, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            "${_answerOptions[index]}",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _isBossLevel
                                  ? Colors.red.shade900
                                  : Colors.orange,
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
      ),
    );
  }
}
