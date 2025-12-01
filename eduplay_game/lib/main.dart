import 'package:flutter/material.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Cek User Logic (Simpel)
  Future<bool> _isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // <--- INI YANG MENGHILANGKAN TULISAN DEBUG
      title: 'EduPlay',
      theme: ThemeData(
        fontFamily: 'Poppins', // Jika punya font custom, atau hapus baris ini
        primarySwatch: Colors.blue,
        useMaterial3: true, // Gunakan Material 3 agar UI lebih modern
      ),
      home: FutureBuilder<bool>(
        future: _isUserRegistered(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data == true) {
            return const HomeScreen();
          } else {
            return const RegistrationScreen();
          }
        },
      ),
    );
  }
}