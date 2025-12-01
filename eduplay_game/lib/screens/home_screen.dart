import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'level_selection_screen.dart';
import 'avatar_shop_screen.dart';
import 'achievements_screen.dart';
import 'daily_missions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  int _avatarIndex = 0;
  int _totalGems = 0;
  
  final List<String> _avatars = [
    'assets/images/avatar1.png', 'assets/images/avatar2.png', 'assets/images/avatar3.png',
    'assets/images/avatar4.png', 'assets/images/avatar5.png', 'assets/images/avatar6.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Petualang';
      _avatarIndex = prefs.getInt('avatarIndex') ?? 0;
      _totalGems = prefs.getInt('totalGems') ?? 0;
    });
  }

  void _refreshData() => _loadProfile();

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pengaturan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(leading: const Icon(Icons.music_note, color: Colors.blue), title: const Text("Musik"), trailing: Switch(value: true, onChanged: (v) {})),
            ListTile(leading: const Icon(Icons.volume_up, color: Colors.blue), title: const Text("Suara Efek"), trailing: Switch(value: true, onChanged: (v) {})),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding vertikal sedikit dikurangi
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align item ke atas
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // KIRI: Profil & Nama (TIDAK BERUBAH)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => const AvatarShopScreen()));
                            _refreshData();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: (_avatarIndex < _avatars.length) 
                                  ? AssetImage(_avatars[_avatarIndex]) 
                                  : const AssetImage('assets/images/avatar1.png'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Halo,", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(_userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    
                    // KANAN: Gems | Toko | (Settings & Misi)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align ke atas agar sejajar
                      children: [
                        // 1. PENCAPAIAN
                         GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementsScreen())),
                          child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle), child: const Icon(Icons.emoji_events, color: Colors.white, size: 20)),
                        ),
                        const SizedBox(width: 8),

                        // 2. Toko (TIDAK BERUBAH POSISI)
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => const AvatarShopScreen()));
                            _refreshData();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                            child: const Icon(Icons.store, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 3. Gems (TIDAK BERUBAH POSISI)
                        Container(
                          margin: const EdgeInsets.only(top: 5), // Sedikit turun biar center dengan ikon bulat
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(30)),
                          child: Row(children: [const Icon(Icons.diamond, color: Colors.cyanAccent, size: 14), const SizedBox(width: 4), Text("$_totalGems", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]),
                        ),
                        const SizedBox(width: 8),

                        // 4. KOLOM: SETTINGS (ATAS) & MISI (BAWAH)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Settings
                            GestureDetector(
                              onTap: _openSettings,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.settings, color: Colors.blue, size: 20),
                              ),
                            ),
                            
                            const SizedBox(height: 10), // Jarak Antara Settings dan Misi

                            // Tombol Misi Harian (BARU DI SINI)
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyMissionScreen()));
                                _refreshData(); // Refresh gem kalau abis klaim
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Colors.deepPurpleAccent, shape: BoxShape.circle),
                                child: const Icon(Icons.assignment, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),
              
              // LOGO
              Column(
                children: [
                  const Icon(Icons.school, size: 80, color: Colors.white),
                  Text("EduPlay", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, shadows: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(2, 2), blurRadius: 4)], fontFamily: "Rounded")),
                  const Text("Petualangan Belajar", style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
              const Spacer(),
              
              // GAME CARDS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    _buildGameCard("Logika Matematika", Icons.calculate_rounded, const Color(0xFFFFA726), const Color(0xFFFF7043), () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const LevelSelectionScreen(gameType: 'MATH')));
                        _refreshData();
                      }),
                    const SizedBox(height: 20),
                    _buildGameCard("Susun Kata", Icons.extension_rounded, const Color(0xFFAB47BC), const Color(0xFF8E24AA), () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const LevelSelectionScreen(gameType: 'WORD')));
                        _refreshData();
                      }),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  
   Widget _buildGameCard(String title, IconData icon, Color color1, Color color2, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: color2.withValues(alpha: 0.5), offset: const Offset(0, 8), blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 30)),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}