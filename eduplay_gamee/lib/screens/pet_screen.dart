import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentStreak = prefs.getInt('currentStreak') ?? 0;
    });
  }

  String _getPetImage() {
    if (_currentStreak < 5) return 'assets/images/pet_egg.png';
    if (_currentStreak < 15) return 'assets/images/pet_baby.png';
    if (_currentStreak < 30) return 'assets/images/pet_teen.png';
    return 'assets/images/pet_master.png';
  }

  String _getPetStatus() {
    if (_currentStreak < 5) return 'Telur Misterius';
    if (_currentStreak < 15) return 'Bayi Naga';
    if (_currentStreak < 30) return 'Naga Penjaga';
    return 'RAJA NAGA';
  }

  String _getPetDesc() {
    if (_currentStreak < 5) return 'Teruslah menang untuk\nmenetaskan telur ini!';
    if (_currentStreak < 15) return 'Dia butuh latihan!\nJangan biarkan streak putus.';
    if (_currentStreak < 30) return 'Naga ini semakin kuat.\nSedikit lagi menuju evolusi!';
    return 'Luar biasa!\nKamu adalah Master Naga sejati.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3), 
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand, 
        children: [
          // 1. GAMBAR PET (FULL SCREEN & ZOOMED)
          Positioned.fill(
            child: Transform.scale(
              scale: 1.1, // ZOOM 10% AGAR LEBIH BESAR
              child: Image.asset(
                _getPetImage(),
                fit: BoxFit.cover, // Memenuhi layar
                alignment: Alignment.center, // Fokus ke tengah
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.teal, Colors.greenAccent],
                      ),
                    ),
                    child: const Center(child: Icon(Icons.pets, size: 100, color: Colors.white54)),
                  );
                },
              ),
            ),
          ),

          // 2. GRADASI GELAP (ATAS & BAWAH SAJA)
          // Agar teks terbaca, tapi bagian tengah tetap bening untuk lihat Pet
          const Column(
            children: [
              Expanded(
                flex: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent], // Hitam di atas
                    ),
                  ),
                  child: SizedBox.expand(),
                ),
              ),
              Expanded(flex: 2, child: SizedBox()), // BAGIAN TENGAH KOSONG (TRANSPARAN)
              Expanded(
                flex: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87], // Hitam di bawah
                    ),
                  ),
                  child: SizedBox.expand(),
                ),
              ),
            ],
          ),

          // 3. UI INFORMASI (SAFE AREA)
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pisah Atas & Bawah
              children: [
                
                // --- BAGIAN ATAS: NAMA & DESKRIPSI ---
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: Column(
                    children: [
                      // Status (Nama Pet)
                      Text(
                        _getPetStatus(),
                        style: const TextStyle(
                          fontSize: 36, // Font Besar
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [Shadow(color: Colors.black, blurRadius: 15)],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Deskripsi
                      Text(
                        _getPetDesc(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.4,
                          shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- BAGIAN BAWAH: STREAK & PROGRESS ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge Streak
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange, // Warna Oranye Mencolok
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(color: Colors.orange.withValues(alpha: 0.6), blurRadius: 15, spreadRadius: 2)
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              "Streak: $_currentStreak",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // Progress Bar Evolusi
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Evolusi Berikutnya", style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const Icon(Icons.bolt, color: Colors.cyanAccent, size: 16),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (_currentStreak % 15) / 15,
                              minHeight: 12,
                              color: Colors.cyanAccent,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}