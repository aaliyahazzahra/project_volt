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
  int _tabIndex = 0; // indeks awal

  final PageController controller = PageController();
  late UserFirebaseModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  void _updateCurrentUser(UserFirebaseModel updatedUser) {
    setState(() {
      _currentUser = updatedUser;
      print("Wrapper State Updated: ${updatedUser.nimNidn}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // body: _widgetOptions[_tabIndex],
        body: PageView(
          controller: controller,
          children: [
            HomepageMhsFirebase(user: _currentUser),
            CreateSimulasiFirebasePage(user: _currentUser),
            ProfilePageFirebase(
              user: _currentUser,
              onUpdate: _updateCurrentUser,
            ),
          ],
        ),
        bottomNavigationBar: BottomBarBubble(
          backgroundColor: AppColor.kWhiteColor,
          color: AppColor.kAccentColor,
          selectedIndex: _tabIndex,
          items: [
            BottomBarItem(iconData: Icons.assignment, label: 'Kelas'),
            BottomBarItem(iconData: Icons.memory, label: 'Simulasi'),
            BottomBarItem(iconData: Icons.group, label: 'Profil'),
          ],
          onSelect: (newIndex) {
            _tabIndex = newIndex;
            controller.jumpToPage(newIndex);
          },
        ),
      ),
    );
  }
}
