// import 'package:flutter/material.dart';
// import 'package:project_volt/kelas/anggotakelas.dart';
// import 'package:project_volt/kelas/forumkelas.dart';
// import 'package:project_volt/kelas/tugaskelas.dart';

// class DashboardKelas extends StatelessWidget {
//   const DashboardKelas({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         body: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
//           child: Column(
//             children: [
//               // Bagian Header
//               SizedBox(height: 16),
//               Text(
//                 "Nama Kelas",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent,
//                 ),
//               ),
//               SizedBox(height: 20),

//               // Bagian TabBar
//               Container(
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(25.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: TabBar(
//                   indicator: BoxDecoration(
//                     color: Colors.blueAccent,
//                     borderRadius: BorderRadius.circular(25.0),
//                   ),
//                   labelColor: Colors.white,
//                   unselectedLabelColor: Colors.grey,
//                   tabs: [
//                     Tab(text: 'Tugas'),
//                     Tab(text: 'Forum'),
//                     Tab(text: 'Anggota'),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),

//               // Bagian Form
//               SizedBox(
//                 height: 500,
//                 child: TabBarView(
//                   children: [
//                     // Halaman 1: Form Login
//                     TugasKelas(),

//                     // Halaman 2: Form Registrasi
//                     ForumKelas(),

//                     // Halaman 2: Form Registrasi
//                     AnggotaKelas(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
