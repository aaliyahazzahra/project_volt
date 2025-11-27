// import 'package:flutter/material.dart';
// import 'package:project_volt/core/constants/app_color.dart';
// import 'package:project_volt/data/SQF/models/user_model.dart';
// import 'package:project_volt/data/auth_data_source.dart';
// import 'package:project_volt/features/1_auth/SQF/authenticator.dart';
// import 'package:project_volt/features/3_profile/about_page.dart';
// import 'package:project_volt/features/3_profile/SQF/edit_profile_page.dart';
// import 'package:project_volt/features/3_profile/ganti_password.dart';
// import 'package:project_volt/features/3_profile/widgets/badge_showcase.dart';
// import 'package:project_volt/features/3_profile/widgets/profile_header_card.dart';
// import 'package:project_volt/features/3_profile/SQF/section_header.dart';
// import 'package:project_volt/features/3_profile/widgets/settings_group.dart';
// import 'package:project_volt/features/3_profile/widgets/settings_list_tile.dart';
// import 'package:project_volt/features/3_profile/widgets/settings_switch_tile.dart';

// class ProfilePage extends StatefulWidget {
//   final UserModel user;
//   const ProfilePage({super.key, required this.user});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final AuthDataSource _authDataSource = AuthDataSource();

//   late bool _isMahasiswa;

//   // State Dummy untuk Toggle Switch
//   bool _isDarkMode = false;
//   bool _isNotificationOn = true;
//   bool _isSoundOn = true;
//   bool _isHapticOn = true;

//   @override
//   void initState() {
//     super.initState();
//     _isMahasiswa = widget.user.role == UserRole.mahasiswa.toString();
//   }

//   Color get _roleColor =>
//       _isMahasiswa ? AppColor.kAccentColor : AppColor.kPrimaryColor;

//   // LOGIKA SESI (Logout)
//   Future<void> _logout() async {
//     final bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Keluar'),
//         content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text('Batal', style: TextStyle(color: AppColor.kTextColor)),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text(
//               'Keluar',
//               style: TextStyle(color: AppColor.kErrorColor),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       await _authDataSource.logout();
//       if (mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const Authenticator()),
//           (route) => false,
//         );
//       }
//     }
//   }

//   // LOGIKA NAVIGASI
//   void _navigateToEditProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditProfilePage(user: widget.user),
//       ),
//     );
//   }

//   void _navigateToChangePassword() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => GantiPasswordPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.kBackgroundColor,
//       appBar: AppBar(
//         title: const Text(
//           "Profil Saya",
//           style: TextStyle(
//             color: AppColor.kTextColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: AppColor.kAppBar,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. KARTU PROFIL UTAMA
//             ProfileHeaderCard(
//               user: widget.user,
//               onEdit: _navigateToEditProfile,
//               roleColor: _roleColor,
//             ),

//             const SizedBox(height: 20),

//             // 2. PENCAPAIAN SAYA (Khusus Mahasiswa)
//             if (_isMahasiswa) ...[
//               SectionHeader(
//                 title: "Pencapaian Saya",
//                 roleColor: _roleColor,
//                 onSeeAll: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Halaman Badge Lengkap")),
//                   );
//                 },
//               ),
//               const SizedBox(height: 10),
//               BadgeShowcase(),
//               const SizedBox(height: 24),
//             ],

//             // 3. LIST PENGATURAN

//             // GROUP 1: AKUN
//             SettingsGroup(
//               title: "Akun",
//               children: [
//                 SettingsListTile(
//                   icon: Icons.edit_outlined,
//                   title: "Edit Profil",
//                   roleColor: _roleColor,
//                   onTap: _navigateToEditProfile,
//                 ),
//                 _buildDivider(),

//                 SettingsListTile(
//                   icon: Icons.lock_outline,
//                   title: "Keamanan Akun",
//                   roleColor: _roleColor,
//                   onTap: _navigateToChangePassword,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // GROUP 2: PREFERENSI APLIKASI
//             SettingsGroup(
//               title: "Preferensi Aplikasi",
//               children: [
//                 SettingsSwitchTile(
//                   icon: Icons.dark_mode_outlined,
//                   title: "Tampilan Gelap",
//                   roleColor: _roleColor,
//                   value: _isDarkMode,
//                   onChanged: (val) => setState(() => _isDarkMode = val),
//                 ),
//                 _buildDivider(),

//                 SettingsSwitchTile(
//                   icon: Icons.notifications_outlined,
//                   title: "Notifikasi",
//                   roleColor: _roleColor,
//                   value: _isNotificationOn,
//                   onChanged: (val) => setState(() => _isNotificationOn = val),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // GROUP 3: SIMULASI VOLT
//             SettingsGroup(
//               title: "Simulasi VOLT",
//               children: [
//                 SettingsSwitchTile(
//                   icon: Icons.volume_up_outlined,
//                   title: "Efek Suara Simulasi",
//                   roleColor: _roleColor,
//                   value: _isSoundOn,
//                   onChanged: (val) => setState(() => _isSoundOn = val),
//                 ),

//                 _buildDivider(),
//                 SettingsSwitchTile(
//                   icon: Icons.vibration,
//                   title: "Getaran Haptic",
//                   roleColor: _roleColor,
//                   value: _isHapticOn,
//                   onChanged: (val) => setState(() => _isHapticOn = val),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // GROUP 4: INFO
//             SettingsGroup(
//               title: "Info",
//               children: [
//                 SettingsListTile(
//                   icon: Icons.info_outline,
//                   title: "Tentang Aplikasi",
//                   roleColor: _roleColor,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const AboutPage(),
//                       ),
//                     );
//                   },
//                 ),

//                 _buildDivider(),
//                 SettingsListTile(
//                   icon: Icons.help_outline,
//                   title: "Bantuan & FAQ",
//                   roleColor: _roleColor,
//                   onTap: () {},
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             // GROUP 5: KELUAR (Tombol Full Width)
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _logout,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColor.kErrorColor.withOpacity(0.1),
//                   foregroundColor: AppColor.kErrorColor,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 icon: const Icon(Icons.logout),
//                 label: const Text(
//                   "Keluar Aplikasi",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   // Garis pemisah antar item
//   Widget _buildDivider() {
//     return Divider(
//       height: 1,
//       thickness: 1,

//       color: AppColor.kDividerColor,
//       indent: 60,
//     );
//   }
// }
