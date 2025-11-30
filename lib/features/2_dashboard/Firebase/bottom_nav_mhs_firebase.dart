import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/features/2_dashboard/Firebase/homepage_mhs_firebase.dart';
import 'package:project_volt/features/3_profile/Firebase/profile_page_firebase.dart';
import 'package:project_volt/features/5_simulasi/create_simulasi_firebase_page.dart';

class BottomNavMhsFirebase extends StatefulWidget {
  final UserFirebaseModel user;
  const BottomNavMhsFirebase({super.key, required this.user});

  @override
  State<BottomNavMhsFirebase> createState() => _BottomNavMhsFirebaseState();
}

class _BottomNavMhsFirebaseState extends State<BottomNavMhsFirebase> {
  // pakai ValueNotifier biar konsisten sama dosen
  final ValueNotifier<int> _tabIndex = ValueNotifier<int>(0);

  // PageController tetap dipakai
  final PageController controller = PageController(initialPage: 0);

  late final List<Widget> _widgetOptions = <Widget>[
    HomepageMhsFirebase(user: widget.user), // Index 0: Kelas
    CreateSimulasiFirebasePage(
      user: widget.user,
      kelasId: null,
    ), // Index 1: Simulasi
    ProfilePageFirebase(user: widget.user), // Index 2: Profil
  ];

  @override
  void dispose() {
    controller.dispose();
    _tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _tabIndex,
      builder: (context, currentIndex, _) {
        return Scaffold(
          body: PageView(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(), // no swipe
            children: _widgetOptions,
            // kalau nanti physics diubah (swipe aktif), index tetap sync
            onPageChanged: (page) {
              _tabIndex.value = page;
            },
          ),
          bottomNavigationBar: BottomBarBubble(
            backgroundColor: AppColor.kWhiteColor,
            color: AppColor.kAccentColor,
            selectedIndex: currentIndex,
            items: [
              BottomBarItem(iconData: Icons.assignment, label: 'Kelas'),
              BottomBarItem(iconData: Icons.memory, label: 'Simulasi'),
              BottomBarItem(iconData: Icons.group, label: 'Profil'),
            ],
            onSelect: (newIndex) {
              // tanpa setState
              _tabIndex.value = newIndex;
              controller.jumpToPage(newIndex);
            },
          ),
        );
      },
    );
  }
}
