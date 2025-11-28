import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/features/2_dashboard/Firebase/homepage_dosen_firebase.dart';
import 'package:project_volt/features/3_profile/Firebase/profile_page_firebase.dart';
import 'package:project_volt/features/5_simulasi/create_simulasi_firebase_page.dart';

// Ganti import ini dengan yang sesuai di proyek Anda
// import 'package:project_volt/core/constants/app_color.dart';
// import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
// import 'package:project_volt/features/2_dashboard/Firebase/homepage_dosen_firebase.dart';
// import 'package:project_volt/features/3_profile/Firebase/profile_page_firebase.dart';
// import 'package:project_volt/features/5_simulasi/create_simulasi_firebase_page.dart';

class BottomNavDosenFirebase extends StatefulWidget {
  final dynamic user; // Gunakan tipe data yang sesuai
  const BottomNavDosenFirebase({super.key, required this.user});

  @override
  State<BottomNavDosenFirebase> createState() => _BottomNavDosenFirebaseState();
}

class _BottomNavDosenFirebaseState extends State<BottomNavDosenFirebase> {
  int _tabIndex = 0; // indeks awal

  // Definisikan list halaman
  late final List<Widget> _widgetOptions = <Widget>[
    HomepageDosenFirebase(user: widget.user), // Index 0: Kelas
    // Gunakan SimulasiWrapper jika Anda menerapkan Keep Alive di file terpisah
    CreateSimulasiFirebasePage(user: widget.user), // Index 1: Simulasi
    ProfilePageFirebase(user: widget.user), // Index 2: Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- SOLUSI: IndexedStack (TIDAK ADA SWIPE) ---
      body: IndexedStack(
        // IndexedStack hanya menampilkan widget yang sesuai dengan index saat ini
        index: _tabIndex,
        children: _widgetOptions,
      ),

      // ------------------------------------------------
      bottomNavigationBar: BottomBarBubble(
        color: Colors.blue, // Ganti dengan AppColor.kPrimaryColor
        selectedIndex: _tabIndex,
        items: [
          BottomBarItem(iconData: Icons.assignment, label: 'Kelas'),
          BottomBarItem(iconData: Icons.memory, label: 'Simulasi'),
          BottomBarItem(iconData: Icons.group, label: 'Profil'),
        ],
        onSelect: (newIndex) {
          // Hanya perlu setState untuk mengubah index IndexedStack
          setState(() {
            _tabIndex = newIndex;
          });
        },
      ),
    );
  }
}
