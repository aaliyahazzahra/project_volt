import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/features/2_dashboard/Firebase/homepage_mhs_firebase.dart';
import 'package:project_volt/features/3_profile/Firebase/profile_page_firebase.dart';
import 'package:project_volt/features/5_simulasi/create_simulasi_firebase_page.dart';
// Asumsi import untuk UserFirebaseModel dan AppColor sudah tersedia
// Asumsi import untuk HomepageMhsFirebase, CreateSimulasiFirebasePage,
// ProfilePageFirebase, dan BottomBarBubble sudah tersedia

class BottomNavMhsFirebase extends StatefulWidget {
  final UserFirebaseModel user;
  const BottomNavMhsFirebase({super.key, required this.user});

  @override
  State<BottomNavMhsFirebase> createState() => _BottomNavMhsFirebaseState();
}

class _BottomNavMhsFirebaseState extends State<BottomNavMhsFirebase> {
  int _tabIndex = 0; // indeks awal: 0 = Kelas, 1 = Simulasi, 2 = Profil

  // 1. TAMBAHKAN: Deklarasi PageController
  final PageController controller = PageController();

  // Definisikan list halaman
  late final List<Widget> _widgetOptions = <Widget>[
    HomepageMhsFirebase(user: widget.user), // Index 0: Kelas
    CreateSimulasiFirebasePage(
      // Index 1: Simulasi
      user: widget.user,
      // Tidak ada kelasId/template saat masuk dari navigasi utama Mhs
      kelasId: null,
    ),
    ProfilePageFirebase(user: widget.user), // Index 2: Profil
  ];

  @override
  void dispose() {
    // 5. TAMBAHKAN: Disposal PageController
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. MODIFIKASI: Mengganti IndexedStack dengan PageView
      body: PageView(
        controller: controller,
        // 4. TAMBAHKAN: Menonaktifkan Swipe
        physics: const NeverScrollableScrollPhysics(),
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomBarBubble(
        // Catatan: Properti color/backgroundColor bisa disesuaikan lagi.
        backgroundColor: AppColor.kWhiteColor,
        color: AppColor.kAccentColor,
        selectedIndex: _tabIndex,
        items: [
          BottomBarItem(iconData: Icons.assignment, label: 'Kelas'),
          BottomBarItem(iconData: Icons.memory, label: 'Simulasi'),
          BottomBarItem(iconData: Icons.group, label: 'Profil'),
        ],
        onSelect: (newIndex) {
          // 3. MODIFIKASI: Tambahkan setState dan logika navigasi PageController
          setState(() {
            _tabIndex = newIndex;
          });
          // Mengubah halaman pada PageView
          controller.jumpToPage(newIndex);
        },
      ),
    );
  }
}
