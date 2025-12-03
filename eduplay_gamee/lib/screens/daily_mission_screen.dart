import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyMissionScreen extends StatefulWidget {
  const DailyMissionScreen({super.key});

  @override
  State<DailyMissionScreen> createState() => _DailyMissionScreenState();
}

class _DailyMissionScreenState extends State<DailyMissionScreen> {
  bool _claimedLogin = false;
  int _mathProgress = 0;
  bool _claimedMath = false;
  int _wordProgress = 0;
  bool _claimedWord = false;

  @override
  void initState() {
    super.initState();
    _checkDailyReset();
  }

  Future<void> _checkDailyReset() async {
    final prefs = await SharedPreferences.getInstance();
    String lastDate = prefs.getString('missionDate') ?? '';
    String today = DateTime.now().toString().split(' ')[0]; // Format YYYY-MM-DD

    // LOGIKA PERBAIKAN BUG RESET:
    if (lastDate == '' || lastDate != today) {
      // Jika tanggal kosong (baru install) atau tanggal beda (ganti hari)
      
      if (lastDate != '') {
        // HANYA RESET JIKA SUDAH PERNAH ADA TANGGAL SEBELUMNYA (Ganti Hari)
        // Kalau lastDate kosong (baru main hari ini), JANGAN RESET progress yang barusan dimainkan.
        await prefs.setBool('claimedLogin', false);
        await prefs.setInt('dailyMathProgress', 0);
        await prefs.setBool('claimedMath', false);
        await prefs.setInt('dailyWordProgress', 0);
        await prefs.setBool('claimedWord', false);
      }
      
      // Update tanggal ke hari ini
      await prefs.setString('missionDate', today);
    }
    
    _loadMissionData();
  }

  Future<void> _loadMissionData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _claimedLogin = prefs.getBool('claimedLogin') ?? false;
      
      _mathProgress = prefs.getInt('dailyMathProgress') ?? 0;
      _claimedMath = prefs.getBool('claimedMath') ?? false;

      _wordProgress = prefs.getInt('dailyWordProgress') ?? 0;
      _claimedWord = prefs.getBool('claimedWord') ?? false;
    });
  }

  void _claimReward(String type, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int currentGems = prefs.getInt('totalGems') ?? 0;
    await prefs.setInt('totalGems', currentGems + amount);

    if (type == 'LOGIN') {
      await prefs.setBool('claimedLogin', true);
      setState(() => _claimedLogin = true);
    } else if (type == 'MATH') {
      await prefs.setBool('claimedMath', true);
      setState(() => _claimedMath = true);
    } else if (type == 'WORD') {
      await prefs.setBool('claimedWord', true);
      setState(() => _claimedWord = true);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 10), Text("Berhasil klaim +$amount 💎")]),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Misi Harian"), backgroundColor: Colors.deepPurpleAccent, foregroundColor: Colors.white),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.deepPurple.shade100, Colors.white])),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("Selesaikan 5 level hari ini!", textAlign: TextAlign.center, style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // MISI 1: LOGIN
            _buildMissionCard(
              title: "Login Harian",
              desc: "Masuk ke dalam game hari ini",
              icon: Icons.calendar_today,
              progress: 1, target: 1,
              reward: 10,
              isClaimed: _claimedLogin,
              onClaim: () => _claimReward('LOGIN', 10),
            ),

            // MISI 2: MATH (Target 5)
            _buildMissionCard(
              title: "Latihan Otak",
              desc: "Menangkan 5 Level Logika",
              icon: Icons.calculate,
              progress: _mathProgress, 
              target: 5, 
              reward: 20,
              isClaimed: _claimedMath,
              onClaim: () => _claimReward('MATH', 20),
            ),

            // MISI 3: WORD (Target 5)
            _buildMissionCard(
              title: "Ahli Bahasa",
              desc: "Menangkan 5 Level Susun Kata",
              icon: Icons.abc,
              progress: _wordProgress, 
              target: 5, 
              reward: 20,
              isClaimed: _claimedWord,
              onClaim: () => _claimReward('WORD', 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard({required String title, required String desc, required IconData icon, required int progress, required int target, required int reward, required bool isClaimed, required VoidCallback onClaim}) {
    bool isCompleted = progress >= target;
    double progressValue = (progress / target) > 1.0 ? 1.0 : (progress / target);

    return Card(
      elevation: 4, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.deepPurple.shade50, shape: BoxShape.circle), child: Icon(icon, color: Colors.deepPurple, size: 30)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(value: isCompleted ? 1.0 : progressValue, backgroundColor: Colors.grey.shade200, color: Colors.deepPurple, minHeight: 6, borderRadius: BorderRadius.circular(5)),
                  Text("$progress/$target Selesai", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            isClaimed
                ? const Icon(Icons.check_circle, color: Colors.green, size: 32)
                : ElevatedButton(
                    onPressed: isCompleted ? onClaim : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, disabledBackgroundColor: Colors.grey.shade300, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.diamond, size: 16, color: Colors.white), Text("+$reward", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]),
                  ),
          ],
        ),
      ),
    );
  }
}