import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  int? _selectedAvatarIndex;
  String? _nameError;

  final List<String> _avatars = [
    'assets/images/avatar1.png',
    'assets/images/avatar2.png',
    'assets/images/avatar3.png',
  ];

  bool _validateName(String name) {
    if (name.length < 4) {
      setState(() => _nameError = "Minimal 4 huruf ya!");
      return false;
    }
    final validCharacters = RegExp(r'^[a-zA-Z ]+$');
    if (!validCharacters.hasMatch(name)) {
      setState(() => _nameError = "Hanya huruf, tanpa angka/simbol");
      return false;
    }
    setState(() => _nameError = null);
    return true;
  }

  void _submitProfile() async {
    String name = _nameController.text.trim();
    if (_validateName(name) && _selectedAvatarIndex != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', name);
      await prefs.setInt('avatarIndex', _selectedAvatarIndex!);
      await prefs.setBool('showTutorial', true);
      await prefs.setInt('totalGems', 0);
      await prefs.setStringList('ownedAvatars', ['0', '1', '2']); 

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else if (_selectedAvatarIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih avatarmu dulu kawan!"), 
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)], // Gradasi Biru Langit
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO / JUDUL
                  const Icon(Icons.rocket_launch_rounded, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    "EduPlay",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black26, offset: Offset(2,2), blurRadius: 4)]
                    ),
                  ),
                  const Text(
                    "Siap Berpetualang?",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 40),

                  // KARTU FORMULIR
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // INPUT NAMA
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: 'Nama Panggilan',
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            hintText: "Contoh: Budi",
                            errorText: _nameError,
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                          ),
                          onChanged: (value) => _validateName(value.trim()),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        const Text(
                          "Pilih Karaktermu",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                        const SizedBox(height: 15),

                        // PILIHAN AVATAR
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(_avatars.length, (index) {
                            bool isSelected = _selectedAvatarIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedAvatarIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.blueAccent : Colors.transparent,
                                  boxShadow: isSelected 
                                    ? [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)] 
                                    : [],
                                ),
                                child: CircleAvatar(
                                  radius: isSelected ? 35 : 30, // Efek membesar saat dipilih
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: AssetImage(_avatars[index]),
                                ),
                              ),
                            );
                          }),
                        ),
                        
                        const SizedBox(height: 40),

                        // TOMBOL MULAI
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: (_nameError == null && _nameController.text.length >= 4 && _selectedAvatarIndex != null) 
                                ? _submitProfile 
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C6FF), // Warna Biru Cerah
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            child: const Text(
                              "MULAI SEKARANG 🚀",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}