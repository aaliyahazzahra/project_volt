import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/dashboard/homepage.dart';
import 'package:project_volt/dashboard/profil.dart';

class BottomNavHomepage extends StatefulWidget {
  const BottomNavHomepage({super.key});

  @override
  State<BottomNavHomepage> createState() => _BottomNavHomepageState();
}

class _BottomNavHomepageState extends State<BottomNavHomepage> {
  int _tabIndex = 1; // indeks awal

  // final List<Widget> _pages = const [
  //   Center(child: Text("Halaman Saya (Indeks 0)")),
  //   Center(child: Text("Halaman Utama (Indeks 1)")),
  //   Center(child: Text("Halaman Suka (Indeks 2)")),
  // ];

  static const List<Widget> _widgetOptions = [
    HomePage(),
    HomePage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_tabIndex],

      bottomNavigationBar: CircleNavBar(
        activeIndex: _tabIndex,

        activeIcons: const [
          Icon(Icons.home, color: Colors.deepPurple),
          Icon(Icons.toc_outlined, color: Colors.deepPurple),
          Icon(Icons.person, color: Colors.deepPurple),
        ],
        inactiveIcons: const [
          Text("Dashboard"),
          Text("Simulasi"),
          Text("Profile"),
        ],
        color: Colors.white,
        circleColor: Colors.white,
        height: 60,
        circleWidth: 60,

        onTap: (newIndex) {
          setState(() {
            _tabIndex = newIndex;
          });
        },

        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        shadowColor: Colors.deepPurple,
        circleShadowColor: Colors.deepPurple,
        elevation: 10,
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue, Colors.red],
        ),
        circleGradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue, Colors.red],
        ),
      ),
    );
  }
}
