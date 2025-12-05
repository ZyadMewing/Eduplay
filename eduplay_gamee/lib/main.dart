import 'package:flutter/material.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Wajib ada jika main() async
  await AudioManager.instance.init(); // Siapkan Audio
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App ditutup atau di-pause → Stop musik
      AudioManager.instance.stopBGM();
    } else if (state == AppLifecycleState.resumed) {
      // App dibuka kembali → Resume musik
      if (AudioManager.instance.isMusicOn) {
        AudioManager.instance.playBGM();
      }
    }
  }

  // Cek User Logic (Simpel)
  Future<bool> _isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // <--- INI YANG MENGHILANGKAN TULISAN DEBUG
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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
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
