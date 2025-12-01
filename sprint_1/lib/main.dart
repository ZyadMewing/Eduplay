// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Cek apakah pengguna sudah pernah mendaftar sebelumnya
  Future<bool> _isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    // Jika nama pengguna tersimpan, berarti sudah terdaftar
    return prefs.getString('userName') != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduPlay Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins', // Anda bisa menambahkan custom font
      ),
      home: FutureBuilder<bool>(
        future: _isUserRegistered(),
        builder: (context, snapshot) {
          // Tampilkan loading spinner selagi memeriksa data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // Jika data sudah dicek
          if (snapshot.hasData && snapshot.data == true) {
            // Jika sudah terdaftar, langsung ke HomeScreen
            return const HomeScreen();
          } else {
            // Jika belum terdaftar, ke RegistrationScreen
            return const RegistrationScreen();
          }
        },
      ),
    );
  }
}