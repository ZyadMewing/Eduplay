import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  // Singleton (Satu instance untuk seluruh aplikasi)
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  static AudioManager get instance => _instance;

  final AudioPlayer _bgmPlayer = AudioPlayer(); // Khusus Musik Latar
  final AudioPlayer _sfxPlayer = AudioPlayer(); // Khusus Efek Suara

  bool _isMusicOn = true;
  bool _isSfxOn = true;

  // Inisialisasi (Panggil saat aplikasi mulai)
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('isMusicOn') ?? true;
    _isSfxOn = prefs.getBool('isSfxOn') ?? true;

    if (_isMusicOn) {
      playBGM();
    }
  }

  // --- MUSIK LATAR (BGM) ---
  void playBGM() async {
    if (!_isMusicOn) return;

    try {
      // Set volume musik agak kecil (40%) biar tidak berisik
      await _bgmPlayer.setVolume(0.7);
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop); // Ulang terus

      // Coba load dan mainkan
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
      print("🎵 Berhasil memutar BGM"); // Cek di Debug Console
    } catch (e) {
      print("❌ Gagal memutar BGM: $e"); // Ini akan memberitahu kenapa error
    }
  }

  void stopBGM() async {
    await _bgmPlayer.stop();
  }

  // Dispose (Panggil saat aplikasi ditutup)
  Future<void> dispose() async {
    await _bgmPlayer.stop();
    await _bgmPlayer.release();
    await _sfxPlayer.stop();
    await _sfxPlayer.release();
  }

  void toggleMusic(bool value) async {
    _isMusicOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicOn', value);

    if (_isMusicOn) {
      playBGM();
    } else {
      stopBGM();
    }
  }

  // --- EFEK SUARA (SFX) ---
  void playSfx(String fileName) async {
    if (!_isSfxOn) return;

    // Stop sfx sebelumnya jika ada (biar tidak tumpang tindih parah)
    await _sfxPlayer.stop();
    await _sfxPlayer.setVolume(1.0); // Volume full
    await _sfxPlayer.play(AssetSource('audio/$fileName'));
  }

  void toggleSfx(bool value) async {
    _isSfxOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSfxOn', value);
  }

  // Getters untuk UI Switch
  bool get isMusicOn => _isMusicOn;
  bool get isSfxOn => _isSfxOn;
}
