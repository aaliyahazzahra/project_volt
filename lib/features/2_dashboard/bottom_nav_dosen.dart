import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/models/user_model.dart';
import 'package:project_volt/features/2_dashboard/homepage_dosen.dart';
import 'package:project_volt/features/3_profile/profile_page.dart';
import 'package:project_volt/features/5_simulasi/simulasi.dart';

class BottomNavDosen extends StatefulWidget {
  final UserModel user;
  const BottomNavDosen({super.key, required this.user});

  @override
  State<BottomNavDosen> createState() => _BottomNavDosenState();
}

class _BottomNavDosenState extends State<BottomNavDosen> {
  int _tabIndex = 0; // indeks awal

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      HomepageDosen(user: widget.user),
      Simulasi(),
      ProfilePage(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _widgetOptions[_tabIndex],
        bottomNavigationBar: BottomBarBubble(
          color: AppColor.kSecondaryColor,
          selectedIndex: _tabIndex,
          items: [
            BottomBarItem(iconData: Icons.assignment, label: 'Kelas'),
            BottomBarItem(iconData: Icons.memory, label: 'Simulasi'),
            BottomBarItem(iconData: Icons.group, label: 'Profil'),
          ],
          onSelect: (newIndex) {
            setState(() {
              _tabIndex = newIndex;
            });
          },
        ),
      ),
    );
  }
}
