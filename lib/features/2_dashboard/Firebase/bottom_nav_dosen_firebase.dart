import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/features/2_dashboard/Firebase/homepage_dosen_firebase.dart';
import 'package:project_volt/features/3_profile/Firebase/profile_page_firebase.dart';
import 'package:project_volt/features/5_simulasi/create_simulasi_firebase_page.dart';

class BottomNavDosenFirebase extends StatefulWidget {
  final UserFirebaseModel user;
  const BottomNavDosenFirebase({super.key, required this.user});

  @override
  State<BottomNavDosenFirebase> createState() => _BottomNavDosenFirebaseState();
}

class _BottomNavDosenFirebaseState extends State<BottomNavDosenFirebase> {
  int _tabIndex = 0; // indeks awal
  final PageController controller = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: controller,
          children: [
            HomepageDosenFirebase(user: widget.user),
            CreateSimulasiFirebasePage(kelasId: kelasId),
            ProfilePageFirebase(user: widget.user),
          ],
        ),
        bottomNavigationBar: BottomBarBubble(
          backgroundColor: AppColor.kWhiteColor,
          color: AppColor.kPrimaryColor,
          selectedIndex: _tabIndex,
          items: [
            BottomBarItem(iconData: Icons.assignment, label: 'Kelas'),
            BottomBarItem(iconData: Icons.memory, label: 'Simulasi'),
            BottomBarItem(iconData: Icons.group, label: 'Profil'),
          ],
          onSelect: (newIndex) {
            _tabIndex = newIndex;
            controller.jumpToPage(newIndex);
            // setState(() {});
          },
        ),
      ),
    );
  }
}
