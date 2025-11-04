import 'dart:async'; // Butuh untuk timer

import 'package:flutter/material.dart';
import 'package:project_volt/bottomnavigator/bottom_nav_dosen.dart';
import 'package:project_volt/bottomnavigator/bottom_nav_mhs.dart';
import 'package:project_volt/constant/app_image.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/preferences/shared_preferences.dart';
import 'package:project_volt/view/login_register/authenticator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // state untuk animasi
  bool _showFullLogo = false;

  @override
  void initState() {
    super.initState();
    _startAnimationAndNavigation();
  }

  void _startAnimationAndNavigation() {
    // timer animasi

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showFullLogo = true;
        });
      }
    });

    Timer(const Duration(seconds: 5), () {
      _cekSession();
    });
  }

  // Logika untuk mengecek session
  Future<void> _cekSession() async {
    UserModel? user = await PreferenceHandler.getUser();

    if (!mounted) return;

    if (user != null) {
      // User sudah login, cek role-nya
      String userRole = user.role;

      if (userRole == UserRole.mahasiswa.toString()) {
        // Arahkan ke Dashboard Mahasiswa
        _navigateAndRemove(BottomNavMhs(user: user));
      } else if (userRole == UserRole.dosen.toString()) {
        // Arahkan ke Dashboard Dosen
        _navigateAndRemove(BottomNavDosen(user: user));
      } else {
        // Role tidak dikenal, arahkan ke Login
        _navigateAndRemove(Authenticator());
      }
    } else {
      // User belum login, arahkan ke halaman Authenticator
      _navigateAndRemove(Authenticator());
    }
  }

  // Helper untuk navigasi
  void _navigateAndRemove(Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: AnimatedCrossFade(
              firstChild: Image.asset(
                AppImages.vAja, // Gambar "V"
                height: 250,
              ),
              secondChild: Image.asset(
                AppImages.volt, // Gambar "VOLT"
                height: 200,
              ),
              crossFadeState: _showFullLogo
                  ? CrossFadeState
                        .showSecond // Tampilkan VOLT
                  : CrossFadeState.showFirst, // Tampilkan V
              duration: const Duration(seconds: 2),
              firstCurve: Interval(0.0, 0.5, curve: Curves.easeOut),
              secondCurve: Interval(0.6, 1.0, curve: Curves.easeIn),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
