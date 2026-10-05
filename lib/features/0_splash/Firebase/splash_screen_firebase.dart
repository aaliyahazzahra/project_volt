import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_volt/app/session_controller.dart';
import 'package:project_volt/core/constants/app_image.dart';
import 'package:project_volt/core/utils/Firebase/preference_handler_firebase.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:provider/provider.dart';

class SplashScreenFirebase extends StatefulWidget {
  const SplashScreenFirebase({super.key});

  @override
  State<SplashScreenFirebase> createState() => _SplashScreenFirebaseState();
}

class _SplashScreenFirebaseState extends State<SplashScreenFirebase> {
  bool _showFullLogo = false;

  @override
  void initState() {
    super.initState();
    _startAnimationAndNavigation();
  }

  void _startAnimationAndNavigation() {
    // Timer 1: Mulai animasi logo setelah 2 detik
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showFullLogo = true;
        });
      }
    });

    // Timer 2: Lakukan pengecekan sesi setelah 5 detik (memberi waktu animasi selesai)
    Timer(const Duration(seconds: 5), () {
      _cekSession();
    });
  }

  //  Logika Gabungan: Cek Sesi Lokal + Cek Firebase Auth
  Future<void> _cekSession() async {
    final session = context.read<SessionController>();

    // 1. Ambil data sesi lokal
    final UserFirebaseModel? savedUser =
        await PreferenceHandlerFirebase.getUser();

    if (!mounted) return;

    // Cek apakah ada data lokal dan UID
    if (savedUser != null) {
      // 2. Cek apakah sesi Firebase Auth masih aktif
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.uid == savedUser.uid) {
        // Sesi VALID: hanya role yang dikenal yang masuk ke aplikasi
        final String userRole = savedUser.role;

        if (userRole == 'mahasiswa' || userRole == 'dosen') {
          session.signIn(savedUser);
        }
      } else {
        // Sesi Lokal ada, tapi Firebase Auth sudah logout/token kadaluarsa.
        // Arahkan ke Login dan pastikan sesi lokal dihapus (jika perlu, oleh Authenticator)
        await FirebaseAuth.instance.signOut();
      }
    } else {
      // Tidak ada data lokal sama sekali, arahkan ke Login
      // Pastikan juga logout dari Firebase Auth untuk berjaga-jaga
      await FirebaseAuth.instance.signOut();
    }

    // Navigasi: router mengarahkan ke /beranda jika sesi aktif
    if (!mounted) return;
    context.go(session.isSignedIn ? '/beranda' : '/login');
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
              firstChild: Image.asset(AppImages.vAja, height: 250),
              secondChild: Image.asset(AppImages.volt, height: 200),
              crossFadeState: _showFullLogo
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(seconds: 2),
              firstCurve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              secondCurve: const Interval(0.6, 1.0, curve: Curves.easeIn),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
