import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  // Data Pemain
  int _mathLevel = 1;
  int _wordLevel = 1;
  int _gems = 0;
  
  // DAFTAR MISI / PENCAPAIAN
  final List<Map<String, dynamic>> _missions = [
    {
      "title": "Pemula Logika",
      "desc": "Capai Level 5 di Game Matematika",
      "type": "MATH",
      "target": 5,
      "icon": Icons.calculate,
    },
    {
      "title": "Master Hitung",
      "desc": "Capai Level 20 di Game Matematika",
      "type": "MATH",
      "target": 20,
      "icon": Icons.functions,
    },
    {
      "title": "Penyusun Kata",
      "desc": "Capai Level 5 di Game Susun Kata",
      "type": "WORD",
      "target": 5,
      "icon": Icons.abc,
    },
    {
      "title": "Kamus Berjalan",
      "desc": "Capai Level 20 di Game Susun Kata",
      "type": "WORD",
      "target": 20,
      "icon": Icons.menu_book,
    },
    {
      "title": "Tabungan Awal",
      "desc": "Kumpulkan 50 Permata",
      "type": "GEMS",
      "target": 50,
      "icon": Icons.savings,
    },
    {
      "title": "Sultan EduPlay",
      "desc": "Kumpulkan 200 Permata",
      "type": "GEMS",
      "target": 200,
      "icon": Icons.diamond,
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkProgress();
  }

  // Cek Data dari SharedPreferences
  Future<void> _checkProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mathLevel = prefs.getInt('mathMaxLevel') ?? 1;
      _wordLevel = prefs.getInt('wordMaxLevel') ?? 1;
      _gems = prefs.getInt('totalGems') ?? 0;
    });
  }

  // Fungsi untuk mengecek apakah misi sudah selesai
  bool _isUnlocked(Map<String, dynamic> mission) {
    String type = mission['type'];
    int target = mission['target'];

    if (type == 'MATH') return _mathLevel >= target;
    if (type == 'WORD') return _wordLevel >= target;
    if (type == 'GEMS') return _gems >= target;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pencapaian", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber, Colors.orangeAccent], // Background Emas
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _missions.length,
          itemBuilder: (context, index) {
            final mission = _missions[index];
            final bool unlocked = _isUnlocked(mission);

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: unlocked ? Colors.white : Colors.black.withValues(alpha: 0.2), // Putih jika unlock, Gelap jika lock
                borderRadius: BorderRadius.circular(15),
                boxShadow: unlocked 
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), offset: const Offset(0, 5), blurRadius: 5)]
                    : [],
                border: unlocked ? Border.all(color: Colors.orange, width: 2) : null,
              ),
              child: Row(
                children: [
                  // IKON PIALA
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: unlocked ? Colors.amber.shade100 : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      unlocked ? Icons.emoji_events : Icons.lock,
                      color: unlocked ? Colors.orange : Colors.grey.shade700,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // TEKS INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: unlocked ? Colors.black87 : Colors.white70,
                            decoration: unlocked ? null : TextDecoration.lineThrough, // Coret jika belum
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          mission['desc'],
                          style: TextStyle(
                            color: unlocked ? Colors.grey.shade700 : Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // STATUS TEKS
                  if (unlocked)
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}