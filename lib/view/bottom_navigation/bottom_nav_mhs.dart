import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
import 'package:bottom_bar_matu/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/view/dashboard/homepage_mhs.dart';
import 'package:project_volt/view/dashboard/simulasi.dart';
import 'package:project_volt/view/profile/profile_page.dart';

class BottomNavMhs extends StatefulWidget {
  final UserModel user;
  const BottomNavMhs({super.key, required this.user});

  @override
  State<BottomNavMhs> createState() => _BottomNavMhsState();
}

class _BottomNavMhsState extends State<BottomNavMhs> {
  int _tabIndex = 0; // indeks awal

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      HomepageMhs(user: widget.user),
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
            BottomBarItem(iconData: Icons.assignment, label: 'Tugas'),
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
