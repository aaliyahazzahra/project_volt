// import 'package:bottom_bar_matu/bottom_bar_matu.dart';
// import 'package:flutter/material.dart';
// import 'package:project_volt/constant/app_color.dart';
// import 'package:project_volt/view/kelas/mahasiswa/anggotakelas.dart';
// import 'package:project_volt/view/kelas/mahasiswa/forumkelas.dart';
// import 'package:project_volt/view/kelas/mahasiswa/tugaskelas.dart';

// class BottomNavKelas extends StatefulWidget {
//   const BottomNavKelas({super.key});

//   @override
//   State<BottomNavKelas> createState() => _BottomNavKelasState();
// }

// class _BottomNavKelasState extends State<BottomNavKelas> {
//   int _tabIndex = 0; // indeks awal

//   static const List<Widget> _widgetOptions = [
//     TugasKelas(),
//     ForumKelas(),
//     AnggotaKelas(),
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Beranda",
//           style: TextStyle(
//             color: AppColor.kPrimaryColor,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: AppColor.kBackgroundColor,
//       ),
//       body: _widgetOptions[_tabIndex],
//       bottomNavigationBar: BottomBarBubble(
//         selectedIndex: _tabIndex,
//         items: [
//           BottomBarItem(iconData: Icons.assignment, label: 'Tugas'),
//           BottomBarItem(iconData: Icons.forum, label: 'Forum'),
//           BottomBarItem(iconData: Icons.group, label: 'Anggota'),
//         ],
//         onSelect: (newIndex) {
//           setState(() {
//             _tabIndex = newIndex;
//           });
//         },
//       ),
//     );
//   }
// }
