// lib/screens/registration_screen.dart
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
  int? _selectedAvatarIndex; // Nullable int untuk melacak avatar yang dipilih

  final List<String> _avatars = [
    'assets/images/avatar1.png',
    'assets/images/avatar2.png',
    'assets/images/avatar3.png',
  ];

  // Cek apakah form sudah valid (nama diisi dan avatar dipilih)
  bool _isFormValid() {
    return _nameController.text.trim().isNotEmpty && _selectedAvatarIndex != null;
  }

  // Fungsi untuk menyimpan data dan melanjutkan
  void _submitProfile() async {
    if (_isFormValid()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text.trim());
      await prefs.setInt('avatarIndex', _selectedAvatarIndex!);
      // Set flag untuk menampilkan tutorial saat pertama kali ke home
      await prefs.setBool('showTutorial', true); 

      // Pindah ke HomeScreen dan hapus layar ini dari tumpukan navigasi
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selamat Datang di EduPlay!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Buat profilmu untuk memulai petualangan.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              // Kolom Input Nama
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Masukkan Nama Kamu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (value) => setState(() {}), // Update state untuk enable/disable tombol
              ),
              const SizedBox(height: 30),

              const Text(
                'Pilih Avatarmu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // Pilihan Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_avatars.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedAvatarIndex == index
                              ? Colors.blueAccent
                              : Colors.transparent,
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(_avatars[index]),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // Tombol Lanjutkan
              ElevatedButton(
                onPressed: _isFormValid() ? _submitProfile : null, // Tombol disable jika form tidak valid
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Lanjutkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}