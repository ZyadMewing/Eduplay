import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_manager.dart'; // IMPORT AUDIO MANAGER

// IMPORT HALAMAN LAIN
import 'level_selection_screen.dart';
import 'avatar_shop_screen.dart';
import 'achievements_screen.dart';
import 'daily_mission_screen.dart';
import 'pet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  int _avatarIndex = 0;
  int _totalGems = 0;
  bool _showTutorial = false;
  int _tutorialStep = 0;

  final GlobalKey _keyProfile = GlobalKey();
  final GlobalKey _keyShop = GlobalKey();
  final GlobalKey _keyPet = GlobalKey();
  final GlobalKey _keyMissions = GlobalKey();
  final GlobalKey _keyGame = GlobalKey();

  final List<String> _avatars = [
    'assets/images/avatar1.png',
    'assets/images/avatar2.png',
    'assets/images/avatar3.png',
    'assets/images/avatar4.png',
    'assets/images/avatar5.png',
    'assets/images/avatar6.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // NYALAKAN MUSIK SAAT MASUK HOME
    AudioManager.instance.playBGM();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Petualang';
      _avatarIndex = prefs.getInt('avatarIndex') ?? 0;
      _totalGems = prefs.getInt('totalGems') ?? 0;
      _showTutorial = prefs.getBool('showTutorial') ?? false;
    });
  }

  void _refreshData() => _loadProfile();

  void _nextStep() {
    AudioManager.instance.playSfx('click.mp3'); // SUARA KLIK
    setState(() => _tutorialStep++);
    if (_tutorialStep > 4) _finishTutorial();
  }

  void _finishTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showTutorial', false);
    setState(() {
      _showTutorial = false;
      _tutorialStep = 0;
    });
  }

  void _openSettings() {
    AudioManager.instance.playSfx('click.mp3'); // SUARA KLIK
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        // Pakai StatefulBuilder agar switch berubah real-time
        builder: (context, setStateModal) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Pengaturan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.blue),
                  title: const Text("Musik"),
                  trailing: Switch(
                    value: AudioManager.instance.isMusicOn,
                    onChanged: (v) {
                      AudioManager.instance.toggleMusic(v);
                      setStateModal(() {}); // Update tampilan switch
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.volume_up, color: Colors.blue),
                  title: const Text("Suara Efek"),
                  trailing: Switch(
                    value: AudioManager.instance.isSfxOn,
                    onChanged: (v) {
                      AudioManager.instance.toggleSfx(v);
                      setStateModal(() {}); // Update tampilan switch
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            key: _keyProfile,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  AudioManager.instance.playSfx(
                                    'click.mp3',
                                  ); // KLIK
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AvatarShopScreen(),
                                    ),
                                  );
                                  _refreshData();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage:
                                        (_avatarIndex < _avatars.length)
                                        ? AssetImage(_avatars[_avatarIndex])
                                        : const AssetImage(
                                            'assets/images/avatar1.png',
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Halo,",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      _userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          key: _keyShop,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCircleButton(
                              icon: Icons.emoji_events,
                              color: Colors.amber,
                              onTap: () {
                                AudioManager.instance.playSfx('click.mp3');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AchievementsScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            _buildCircleButton(
                              icon: Icons.store,
                              color: Colors.orange,
                              onTap: () async {
                                AudioManager.instance.playSfx('click.mp3');
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AvatarShopScreen(),
                                  ),
                                );
                                _refreshData();
                              },
                            ),
                            const SizedBox(width: 6),
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.diamond,
                                    color: Colors.cyanAccent,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "$_totalGems",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildCircleButton(
                                  icon: Icons.settings,
                                  color: Colors.white,
                                  iconColor: Colors.blue,
                                  onTap: _openSettings,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  key: _keyMissions,
                                  child: _buildCircleButton(
                                    icon: Icons.assignment,
                                    color: Colors.deepPurpleAccent,
                                    onTap: () async {
                                      AudioManager.instance.playSfx(
                                        'click.mp3',
                                      );
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const DailyMissionScreen(),
                                        ),
                                      );
                                      _refreshData();
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  key: _keyPet,
                                  child: _buildCircleButton(
                                    icon: Icons.pets,
                                    color: Colors.teal,
                                    onTap: () {
                                      AudioManager.instance.playSfx(
                                        'click.mp3',
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PetScreen(),
                                        ),
                                      );
                                    },
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
                  Column(
                    children: [
                      const Icon(Icons.school, size: 80, color: Colors.white),
                      Text(
                        "EduPlay",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                          fontFamily: "Rounded",
                        ),
                      ),
                      const Text(
                        "Petualangan Belajar",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    key: _keyGame,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        _buildGameCard(
                          "Logika Matematika",
                          Icons.calculate_rounded,
                          const Color(0xFFFFA726),
                          const Color(0xFFFF7043),
                          () async {
                            AudioManager.instance.playSfx('click.mp3');
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LevelSelectionScreen(
                                      gameType: 'MATH',
                                    ),
                              ),
                            );
                            _refreshData();
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildGameCard(
                          "Susun Kata",
                          Icons.extension_rounded,
                          const Color(0xFFAB47BC),
                          const Color(0xFF8E24AA),
                          () async {
                            AudioManager.instance.playSfx('click.mp3');
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LevelSelectionScreen(
                                      gameType: 'WORD',
                                    ),
                              ),
                            );
                            _refreshData();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        if (_showTutorial) _buildSmartTutorial(),
      ],
    );
  }

  // --- LOGIKA SMART TUTORIAL ---
  Widget _buildSmartTutorial() {
    GlobalKey? targetKey;
    String title = "";
    String text = "";
    bool isTop = false;

    switch (_tutorialStep) {
      case 0:
        targetKey = _keyProfile;
        title = "Halo, $_userName!";
        text = "Ini profil kamu. Ketuk fotomu untuk mengganti Avatar di Toko.";
        isTop = false;
        break;
      case 1:
        targetKey = _keyShop;
        title = "Ekonomi & Toko";
        text = "Kumpulkan Permata 💎 untuk membeli Avatar keren di sini!";
        isTop = false;
        break;
      case 2:
        targetKey = _keyMissions;
        title = "Misi Harian";
        text = "Selesaikan tugas setiap hari untuk dapat hadiah tambahan.";
        isTop = false;
        break;
      case 3:
        targetKey = _keyPet;
        title = "Peliharaan (Pet)";
        text = "Rawat nagamu! Dia akan tumbuh jika kamu rajin menang.";
        isTop = false;
        break;
      case 4:
        targetKey = _keyGame;
        title = "Mulai Bermain";
        text =
            "Pilih game favoritmu di sini. Hati-hati, jika kalah, streak pet akan hilang!";
        isTop = true;
        break;
    }

    RenderBox? renderBox =
        targetKey?.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox();

    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;

    return Stack(
      children: [
        // 1. Background Gelap Berlubang
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.85),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Positioned(
                top: offset.dy - 5,
                left: offset.dx - 5,
                width: size.width + 10,
                height: size.height + 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Kartu Penjelasan (DIBUNGKUS MATERIAL AGAR TIDAK ADA GARIS KUNING)
        Positioned(
          top: isTop ? (offset.dy - 170) : (offset.dy + size.height + 20),
          left: 20,
          right: 20,
          child: Material(
            // <--- INI PERBAIKANNYA
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _nextStep,
                      child: Text(
                        _tutorialStep == 4 ? "Mulai >" : "Lanjut >",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }

  Widget _buildGameCard(
    String title,
    IconData icon,
    Color color1,
    Color color2,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color2.withValues(alpha: 0.5),
              offset: const Offset(0, 8),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
