// File: project_volt/features/1_auth/auth_splash_screen.dart

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart'; //  Tambah ini untuk cek Auth
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_image.dart'; // Asumsi path AppImages sudah benar
import 'package:project_volt/core/utils/Firebase/preference_handler_firebase.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/features/1_auth/SQF/authenticator.dart';
import 'package:project_volt/features/2_dashboard/Firebase/bottom_nav_dosen_firebase.dart';
import 'package:project_volt/features/2_dashboard/Firebase/bottom_nav_mhs_firebase.dart'; // Asumsi ini adalah halaman Login/Register

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
    // Animasi akan dimulai segera
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
    // 1. Ambil data sesi lokal
    final UserFirebaseModel? savedUser =
        await PreferenceHandlerFirebase.getUser();

    if (!mounted) return;

    // Default navigasi jika sesi gagal
    Widget nextPage = const Authenticator();

    // Cek apakah ada data lokal dan UID
    if (savedUser != null && savedUser.uid != null) {
      // 2. Cek apakah sesi Firebase Auth masih aktif
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.uid == savedUser.uid) {
        // Sesi VALID: Ambil role dari data lokal
        final String userRole = savedUser.role ?? '';

        if (userRole == 'mahasiswa') {
          nextPage = BottomNavMhsFirebase(user: savedUser);
        } else if (userRole == 'dosen') {
          nextPage = BottomNavDosenFirebase(user: savedUser);
        } else {
          // Role tidak dikenal, arahkan ke Login
          nextPage = const Authenticator();
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

    // Navigasi ke halaman yang ditentukan
    _navigateAndRemove(nextPage);
  }

  // Helper untuk navigasi
  void _navigateAndRemove(Widget page) {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => page),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan Splash Screen kustom Anda
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: AnimatedCrossFade(
              //  Menggunakan asset kustom & animasi Anda
              firstChild: Image.asset(AppImages.vAja, height: 250),
              secondChild: Image.asset(AppImages.volt, height: 200),
              crossFadeState: _showFullLogo
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(seconds: 2),
              // Durasi animasi yang sudah Anda tentukan
              firstCurve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              secondCurve: const Interval(0.6, 1.0, curve: Curves.easeIn),
            ),
          ),
          const SizedBox(height: 16),
          // Tambahkan CircularProgressIndicator di bawah logo saat sesi dicek (opsional)
          // const Padding(
          //   padding: EdgeInsets.only(top: 20.0),
          //   child: CircularProgressIndicator(),
          // )
        ],
      ),
    );
  }
}
