import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvatarShopScreen extends StatefulWidget {
  const AvatarShopScreen({super.key});

  @override
  State<AvatarShopScreen> createState() => _AvatarShopScreenState();
}

class _AvatarShopScreenState extends State<AvatarShopScreen> {
  int _gems = 0;
  int _currentAvatarIndex = 0;
  List<String> _ownedAvatars = [];
  
  // Variable untuk menyimpan level tertinggi user
  int _maxMathLevel = 1;
  int _maxWordLevel = 1;

  final List<String> _allAvatars = [
    'assets/images/avatar1.png', 'assets/images/avatar2.png', 'assets/images/avatar3.png', // Gratis
    'assets/images/avatar4.png', // Unlock Lvl 10
    'assets/images/avatar5.png', // Unlock Lvl 20
    'assets/images/avatar6.png', // Unlock Lvl 30
  ];

  final List<int> _avatarPrices = [0, 0, 0, 100, 150, 200];

  // Level Syarat untuk membuka kunci (0 berarti langsung terbuka)
  final List<int> _unlockRequirements = [0, 0, 0, 10, 20, 30];

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gems = prefs.getInt('totalGems') ?? 0;
      _currentAvatarIndex = prefs.getInt('avatarIndex') ?? 0;
      _ownedAvatars = prefs.getStringList('ownedAvatars') ?? ['0', '1', '2'];
      
      // Ambil level tertinggi
      _maxMathLevel = prefs.getInt('mathMaxLevel') ?? 1;
      _maxWordLevel = prefs.getInt('wordMaxLevel') ?? 1;
    });
  }

  // Cek apakah user berhak melihat avatar ini
  // Syarat: Level Math ATAU Level Word sudah melewati syarat
  bool _isAvatarUnlockedByLevel(int requirement) {
    if (requirement == 0) return true;
    // Jika salah satu game sudah melewati boss level tersebut, maka terbuka
    return (_maxMathLevel > requirement) || (_maxWordLevel > requirement);
  }

  void _buyAvatar(int index) async {
    int price = _avatarPrices[index];
    if (_gems >= price) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _gems -= price;
        _ownedAvatars.add(index.toString());
      });
      await prefs.setInt('totalGems', _gems);
      await prefs.setStringList('ownedAvatars', _ownedAvatars);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Avatar berhasil dibeli! 🎉"), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permata tidak cukup! 💎"), backgroundColor: Colors.red),
      );
    }
  }

  void _equipAvatar(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('avatarIndex', index);
    setState(() => _currentAvatarIndex = index);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Avatar digunakan!"), duration: Duration(milliseconds: 500)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Toko Avatar"),
        backgroundColor: Colors.blueAccent,
        actions: [
           Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Chip(
                avatar: const Icon(Icons.diamond, color: Colors.cyanAccent),
                label: Text("$_gems", style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.blue.shade700,
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 16, mainAxisSpacing: 16,
        ),
        itemCount: _allAvatars.length,
        itemBuilder: (context, index) {
          bool isOwned = _ownedAvatars.contains(index.toString());
          bool isEquipped = _currentAvatarIndex == index;
          
          // Cek Syarat Level
          int requirement = _unlockRequirements[index];
          bool isUnlockedByLevel = _isAvatarUnlockedByLevel(requirement);

          return Card(
            elevation: 4,
            color: isUnlockedByLevel ? Colors.white : Colors.grey.shade300, // Gelapkan jika terkunci
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: isEquipped ? const BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: isUnlockedByLevel 
                          ? Image.asset(_allAvatars[index]) 
                          : Opacity(opacity: 0.3, child: Image.asset(_allAvatars[index])), // Transparan jika terkunci
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildActionButton(index, isOwned, isEquipped, isUnlockedByLevel, requirement),
                    ),
                  ],
                ),
                // Tampilkan Gembok Besar jika terkunci
                if (!isUnlockedByLevel)
                  const Positioned.fill(
                    child: Center(child: Icon(Icons.lock, size: 50, color: Colors.grey)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(int index, bool isOwned, bool isEquipped, bool isUnlockedByLevel, int requirement) {
    if (!isUnlockedByLevel) {
      // Tombol jika Terkunci Level
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(5)),
        child: Text(
          "Selesaikan\nBoss Lv $requirement",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    }

    if (isOwned) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: isEquipped ? Colors.green : Colors.blue, minimumSize: const Size(double.infinity, 36)),
        onPressed: isEquipped ? null : () => _equipAvatar(index),
        child: Text(isEquipped ? "Dipakai" : "Pakai", style: const TextStyle(color: Colors.white)),
      );
    } else {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 36)),
        onPressed: () => _buyAvatar(index),
        icon: const Icon(Icons.diamond, size: 16, color: Colors.white),
        label: Text("${_avatarPrices[index]}", style: const TextStyle(color: Colors.white)),
      );
    }
  }
}