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

  // --- FUNGSI MENANG ---
  Future<void> _handleWin() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Tambah Permata
    int currentGems = prefs.getInt('totalGems') ?? 0;
    await prefs.setInt('totalGems', currentGems + 5);

    // 2. Unlock Level (Pakai max agar aman)
    int currentMax = prefs.getInt('mathMaxLevel') ?? 1;
    await prefs.setInt('mathMaxLevel', max(currentMax, _level + 0));

    // 3. Misi Harian
    int currentDaily = prefs.getInt('dailyMathProgress') ?? 0;
    await prefs.setInt('dailyMathProgress', currentDaily + 1);

    // 4. STREAK NAIK (+1)
    int streak = prefs.getInt('currentStreak') ?? 0;
    await prefs.setInt('currentStreak', streak + 1);
  }

  // --- FUNGSI KALAH (Logika Penyelamatan) ---
  void _handleStreakLoss(String reason) async {
    _timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    int currentStreak = prefs.getInt('currentStreak') ?? 0;
    int currentGems = prefs.getInt('totalGems') ?? 0;

    // Jika streak 0, game over biasa
    if (currentStreak == 0) {
      _showGameOverDialog(reason, 0, currentGems, false);
      return;
    }
    // Jika ada streak, tawarkan opsi bayar
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
              // Gambar telur pecah/sedih (Gunakan Icon jika gambar belum ada)
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
          // TOMBOL RESET
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('currentStreak', 0); // Reset Streak
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

          // TOMBOL BAYAR 300
          if (canRestore)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gems >= 300 ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
              ),
              onPressed: gems >= 300
                  ? () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('totalGems', gems - 300); // Bayar
                      // Streak TIDAK di-reset
                      if (context.mounted) {
                        Navigator.pop(context); // Tutup dialog
                        Navigator.pop(context); // Keluar level
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Pet Selamat! -300 💎"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  : null, // Disable kalau miskin
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
      _questionText = "$num1 $_currentFruit + $num2 $_currentFruit = ?";
    } else if (op == 1) {
      if (num1 < num2) {
        int temp = num1;
        num1 = num2;
        num2 = temp;
      }
      _correctAnswer = num1 - num2;
      _questionText = "$num1 $_currentFruit - $num2 $_currentFruit = ?";
    } else {
      num1 = Random().nextInt(10) + 2;
      num2 = Random().nextInt(5) + 2;
      _correctAnswer = num1 * num2;
      _questionText = "$num1 $_currentFruit x $num2 $_currentFruit = ?";
    }

    List<int> options = [_correctAnswer];
    while (options.length < 4) {
      int dev = Random().nextInt(20) - 10;
      int wrong = _correctAnswer + dev;
      if (wrong >= 0 && wrong != _correctAnswer && !options.contains(wrong))
        options.add(wrong);
      else {
        int fb = Random().nextInt(50) + 1;
        if (!options.contains(fb) && fb != _correctAnswer) options.add(fb);
      }
    }
    options.shuffle();
    _answerOptions = options;
  }

  void _checkAnswer(int selectedAnswer) {
    if (selectedAnswer == _correctAnswer) {

      // --- LOGIKA SUARA PINTAR ---
      if (_isBossLevel) {
        // Kalau Boss kalah, bunyikan suara Menang Besar!
        AudioManager.instance.playSfx('win.mp3'); 
      } else {
        // Kalau level biasa, cukup suara "Ting"
        AudioManager.instance.playSfx('correct.mp3'); 
      }

      setState(() => _showGemNotif = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showGemNotif = false);
      });

      _handleWin(); // Win

      setState(() => _level++);
      _startLevel();
    } else {
      _handleStreakLoss("Jawaban Salah!");
      AudioManager.instance.playSfx('wrong.mp3'); // Loss
    }
  }

  // DESAIN

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

              // Timer
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
              const SizedBox(height: 10),

              // Notif Permata
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

              // Boss Visual
              if (_isBossLevel)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    children: [
                      const Text(
                        "KALAHKAN BOS SOAL!",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                        ),
                      ),
                    ],
                  ),
                ),

              // Papan Soal
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
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
                  children: [
                    Text(
                      _questionText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                            : "Hitung jumlah $_currentFruit",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Jawaban Grid
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.8,
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
