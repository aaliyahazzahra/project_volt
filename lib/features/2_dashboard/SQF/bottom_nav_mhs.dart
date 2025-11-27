// import 'package:bottom_bar_matu/bottom_bar/bottom_bar_bubble.dart';
// import 'package:bottom_bar_matu/bottom_bar_item.dart';
// import 'package:flutter/material.dart';
// import 'package:project_volt/core/constants/app_color.dart';
// import 'package:project_volt/data/SQF/models/user_model.dart';
// import 'package:project_volt/features/2_dashboard/SQF/homepage_mhs.dart';
// import 'package:project_volt/features/3_profile/SQF/profile_page.dart';
<<<<<<< HEAD
=======
// import 'package:project_volt/features/5_simulasi/simulasi_page.dart';
>>>>>>> 33c44999616857edee8623a8da896b25f5c7144e

// class BottomNavMhs extends StatefulWidget {
//   final UserModel user;
//   const BottomNavMhs({super.key, required this.user});

//   @override
//   State<BottomNavMhs> createState() => _BottomNavMhsState();
// }

// class _BottomNavMhsState extends State<BottomNavMhs> {
//   int _tabIndex = 0; // indeks awal

//   final PageController controller = PageController();
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         // body: _widgetOptions[_tabIndex],
//         body: PageView(
//           controller: controller,
//           children: [
//             HomepageMhs(user: widget.user),
//             SimulationPage(),
//             ProfilePage(user: widget.user),
//           ],
//         ),
//         bottomNavigationBar: BottomBarBubble(
//           backgroundColor: AppColor.kWhiteColor,
//           color: AppColor.kAccentColor,
//           selectedIndex: _tabIndex,
//           items: [
//             BottomBarItem(iconData: Icons.assignment, label: 'Kelas'),
//             BottomBarItem(iconData: Icons.memory, label: 'Simulasi'),
//             BottomBarItem(iconData: Icons.group, label: 'Profil'),
//           ],
//           onSelect: (newIndex) {
//             _tabIndex = newIndex;
//             controller.jumpToPage(newIndex);
//           },
//         ),
//       ),
//     );
//   }
// }
