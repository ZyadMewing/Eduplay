import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

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

  // --- DATABASE SOAL 100+ ---
  final List<List<String>> _allNormalSentences = [
    ["SAYA", "SUKA", "MAKAN"],
    ["IBU", "BELI", "SAYUR"],
    ["AYAH", "BACA", "KORAN"],
    ["ADIK", "MAIN", "BOLA"],
    ["KUCING", "MINUM", "SUSU"],
    ["BURUNG", "TERBANG", "TINGGI"],
    ["BUNGA", "MAWAR", "MERAH"],
    ["LANGIT", "WARNA", "BIRU"],
    ["GURU", "MENGAJAR", "KAMI"],
    ["KITA", "BELAJAR", "KODING"],
    ["RODA", "SEPEDA", "DUA"],
    ["SAPI", "MAKAN", "RUMPUT"],
    ["HUJAN", "TURUN", "DERAS"],
    ["MATAHARI", "TERBIT", "PAGI"],
    ["IKAN", "BERENANG", "AIR"],
    ["POHON", "TUMBUH", "BESAR"],
    ["MEJA", "KAYU", "JATI"],
    ["LAMPU", "NYALA", "TERANG"],
    ["BUKU", "JENDELA", "DUNIA"],
    ["RAJIN", "PANGKAL", "PANDAI"],
    ["GIGI", "BERSIH", "SEHAT"],
    ["RAMBUT", "HITAM", "LEBAT"],
    ["SEPATU", "BARU", "SAYA"],
    ["BAJU", "INI", "BAGUS"],
    ["JANGAN", "BUANG", "SAMPAH"],
    ["CUCI", "TANGAN", "KAMU"],
    ["MAKAN", "NASI", "GORENG"],
    ["MINUM", "JUS", "JERUK"],
    ["TIDUR", "MALAM", "CEPAT"],
    ["BANGUN", "PAGI", "SEGAR"],
    ["AYAM", "GORENG", "ENAK"],
    ["BEBEK", "BERENANG", "KOLAM"],
    ["KELINCI", "LOMPAT", "JAUH"],
    ["ULAR", "PANJANG", "SEKALI"],
    ["GAJAH", "TELINGA", "LEBAR"],
    ["SEMUT", "KECIL", "KUAT"],
    ["LEBAH", "HASILKAN", "MADU"],
    ["NYAMUK", "TERBANG", "MALAM"],
    ["CICAK", "MERAYAP", "DINDING"],
    ["KODOK", "LOMPAT", "AIR"],
    ["MOBIL", "RODA", "EMPAT"],
    ["KERETA", "API", "PANJANG"],
    ["PESAWAT", "TERBANG", "AWAN"],
    ["KAPAL", "LAUT", "BESAR"],
    ["HELIKOPTER", "BALING", "BALING"],
    ["PINTU", "RUMAH", "TERBUKA"],
    ["JENDELA", "KACA", "BENING"],
    ["LANTAI", "BERSIH", "MENGKILAP"],
    ["ATAP", "RUMAH", "TINGGI"],
    ["PAGAR", "RUMAH", "HIJAU"],
    ["PENSIL", "UNTUK", "MENULIS"],
    ["PENGHAPUS", "KARET", "PUTIH"],
    ["TAS", "SEKOLAH", "BARU"],
    ["SERAGAM", "MERAH", "PUTIH"],
    ["BENDERA", "TIANG", "TINGGI"],
    ["LONCENG", "SEKOLAH", "BERBUNYI"],
    ["ISTIRAHAT", "MAKAN", "BEKAL"],
    ["PULANG", "SEKOLAH", "SIANG"],
    ["PR", "HARUS", "DIKERJAKAN"],
    ["NILAI", "UJIAN", "BAGUS"],
    ["PISANG", "KUNING", "MANIS"],
    ["ANGGUR", "UNGU", "KECIL"],
    ["SEMANGKA", "MERAH", "SEGAR"],
    ["DURIAN", "BAU", "MENYENGAT"],
    ["KELAPA", "MUDA", "SEGAR"],
    ["WORTEL", "MAKANAN", "KELINCI"],
    ["BAYAM", "SAYUR", "HIJAU"],
    ["TOMAT", "MERAH", "BULAT"],
    ["CABAI", "RASANYA", "PEDAS"],
    ["GARAM", "RASANYA", "ASIN"],
    ["GULA", "RASANYA", "MANIS"],
    ["KOPI", "RASANYA", "PAHIT"],
    ["ES", "KRIM", "DINGIN"],
    ["TEH", "HANGAT", "MANIS"],
    ["SUSU", "SAPI", "SEGAR"],
    ["BOLA", "SEPAK", "BUNDAR"],
    ["RAKET", "BULU", "TANGKIS"],
    ["JARING", "GAWANG", "PUTIH"],
    ["KOLAM", "RENANG", "BIRU"],
    ["LARI", "PAGI", "SEHAT"],
    ["GUNUNG", "TINGGI", "SEKALI"],
    ["PANTAI", "PASIR", "PUTIH"],
    ["LAUT", "LUAS", "BIRU"],
    ["SUNGAI", "AIR", "MENGALIR"],
    ["AIR", "TERJUN", "INDAH"],
    ["HUTAN", "POHON", "LEBAT"],
    ["SAWAH", "PADI", "HIJAU"],
    ["TAMAN", "BUNGA", "CANTIK"],
    ["KEBUN", "BUAH", "SEGAR"],
    ["DESA", "DAMAI", "TENTERAM"],
  ];

  final List<List<String>> _allBossSentences = [
    ["INDONESIA", "TANAH", "AIR", "BETA"],
    ["PANCASILA", "DASAR", "NEGARA", "KITA"],
    ["BHINNEKA", "TUNGGAL", "IKA", "BERBEDA"],
    ["SATU", "NUSA", "SATU", "BANGSA"],
    ["MERAH", "PUTIH", "BENDERA", "KITA"],
    ["MAJU", "TAK", "GENTAR", "MEMBELA"],
    ["BELAJAR", "WAKTU", "KECIL", "UKIR", "BATU"],
    ["HEMAT", "PANGKAL", "KAYA", "RAYA"],
    ["BERSIH", "PANGKAL", "SEHAT", "SELALU"],
    ["BUKU", "ADALAH", "JENDELA", "DUNIA"],
  ];

  List<String> _targetSentence = [];
  List<String> _shuffledOptions = [];
  final List<String> _userAnswer = [];
  bool _isBossLevel = false;

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

  // --- LOGIKA SAVE AGRESIF ---
  Future<void> _checkAndSaveProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Permata
    int currentGems = prefs.getInt('totalGems') ?? 0;
    await prefs.setInt('totalGems', currentGems + 5);

    // 2. BUKA LEVEL SELANJUTNYA
    int savedMaxLevel = prefs.getInt('wordMaxLevel') ?? 1;
    int nextLevelToUnlock = _level + 0;
    // Gunakan max() agar level selalu maju
    int newMaxLevel = max(savedMaxLevel, nextLevelToUnlock);

    await prefs.setInt('wordMaxLevel', newMaxLevel);

    // 3. Misi Harian
    int currentDaily = prefs.getInt('dailyWordProgress') ?? 0;
    await prefs.setInt('dailyWordProgress', currentDaily + 1);
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
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _handleGameOver("Waktu Habis!");
          }
        });
      }
    });
  }

  void _handleGameOver(String message) {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Gagal! ❌"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
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
      // Notif
      setState(() => _showGemNotif = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showGemNotif = false);
      });

      // Save
      _checkAndSaveProgress();

      // Next Level
      setState(() => _level++);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _startLevel();
      });
    } else {
      _handleGameOver("Susunan Salah!");
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
