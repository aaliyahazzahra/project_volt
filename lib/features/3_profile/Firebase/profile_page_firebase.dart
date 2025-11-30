import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/auth_data_source.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/features/1_auth/Firebase/authenticator_firebase.dart';
import 'package:project_volt/features/3_profile/Firebase/edit_profile_firebase_page.dart';
import 'package:project_volt/features/3_profile/Firebase/widgets/profile_header_card_firebase.dart';
import 'package:project_volt/features/3_profile/about_page.dart';
import 'package:project_volt/features/1_auth/Firebase/password_management_page.dart';
import 'package:project_volt/features/3_profile/widgets/settings_group.dart';
import 'package:project_volt/features/3_profile/widgets/settings_list_tile.dart';
import 'package:project_volt/features/3_profile/widgets/settings_switch_tile.dart';
import 'package:project_volt/widgets/dialogs/confirmation_dialog_helper.dart';

class ProfilePageFirebase extends StatefulWidget {
  final UserFirebaseModel user;
  const ProfilePageFirebase({super.key, required this.user});

  @override
  State<ProfilePageFirebase> createState() => _ProfilePageFirebaseState();
}

class _ProfilePageFirebaseState extends State<ProfilePageFirebase> {
  final AuthDataSource _authDataSource = AuthDataSource();

  late bool _isMahasiswa;

  // State Dummy untuk Toggle Switch
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Membandingkan langsung dengan string 'mahasiswa'
    // agar logika boolean ini benar (True jika Mahasiswa, False jika Dosen)
    _isMahasiswa = widget.user.role == 'mahasiswa';
  }

  // LOGIKA WARNA SESUAI INSTRUKSI:
  // Mahasiswa -> Biru (kPrimaryColor)
  // Dosen    -> Orange (kAccentColor)
  Color get _roleColor =>
      _isMahasiswa ? AppColor.kPrimaryColor : AppColor.kAccentColor;

  // LOGIKA SESI (Logout)
  Future<void> _logout() async {
    final bool? confirm = await showConfirmationDialog(
      context: context,
      title: 'Keluar',
      content: 'Apakah Anda yakin ingin keluar dari akun ini?',
      confirmText: 'Keluar',
      confirmColor: AppColor.kErrorColor,
    );

    if (confirm == true) {
      await _authDataSource.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthenticatorFirebase(),
          ),
          (route) => false,
        );
      }
    }
  }

  // LOGIKA NAVIGASI
  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileFirebasePage(user: widget.user),
      ),
    );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordManagementPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background TETAP (Tidak berubah sesuai role)
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(
            color: AppColor.kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // AppBar TETAP (Tidak berubah sesuai role)
        backgroundColor: AppColor.kAppBar,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KARTU PROFIL UTAMA (Menggunakan _roleColor)
            ProfileHeaderCardFirebase(
              user: widget.user,
              onEdit: _navigateToEditProfile,
              roleColor: _roleColor, // Biru (Mhs) atau Orange (Dosen)
            ),

            const SizedBox(height: 20),

            // 2. LIST PENGATURAN

            // GROUP 1: AKUN
            SettingsGroup(
              title: "Akun",
              children: [
                SettingsListTile(
                  icon: Icons.edit_outlined,
                  title: "Edit Profil",
                  roleColor: _roleColor,
                  onTap: _navigateToEditProfile,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // GROUP 2: PREFERENSI APLIKASI
            SettingsGroup(
              title: "Preferensi Aplikasi",
              children: [
                SettingsSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: "Tampilan Gelap",
                  roleColor: _roleColor, // Icon & Switch berubah warna
                  value: _isDarkMode,
                  onChanged: (val) => setState(() => _isDarkMode = val),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // GROUP 3: INFO
            SettingsGroup(
              title: "Info",
              children: [
                SettingsListTile(
                  icon: Icons.info_outline,
                  title: "Tentang Aplikasi",
                  roleColor: _roleColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Spacer(),

            // GROUP 4: KELUAR (Tombol Full Width)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.kErrorColor.withOpacity(0.1),
                  foregroundColor: AppColor.kErrorColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Keluar Aplikasi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // // Garis pemisah antar item
  // Widget _buildDivider() {
  //   return const Divider(
  //     height: 1,
  //     thickness: 1,
  //     color: AppColor.kDividerColor,
  //     indent: 60,
  //   );
  // }
}
