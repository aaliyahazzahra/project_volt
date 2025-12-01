import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/auth_data_source.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/features/1_auth/Firebase/authenticator_firebase.dart';
import 'package:project_volt/features/3_profile/Firebase/edit_profile_firebase_page.dart';
import 'package:project_volt/features/3_profile/Firebase/widgets/profile_header_card_firebase.dart';
import 'package:project_volt/features/3_profile/about_page.dart';
import 'package:project_volt/features/3_profile/widgets/settings_group.dart';
import 'package:project_volt/features/3_profile/widgets/settings_list_tile.dart';
import 'package:project_volt/widgets/dialogs/confirmation_dialog_helper.dart';

class ProfilePageFirebase extends StatefulWidget {
  final UserFirebaseModel user;
  const ProfilePageFirebase({super.key, required this.user});

  @override
  State<ProfilePageFirebase> createState() => _ProfilePageFirebaseState();
}

class _ProfilePageFirebaseState extends State<ProfilePageFirebase> {
  final AuthDataSource _authDataSource = AuthDataSource();

  late UserFirebaseModel _currentUser;
  late bool _isDosen; // True if the user role is 'dosen'

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _isDosen = _currentUser.role == 'dosen';
  }

  /// Determines the primary color based on user role.
  Color get _roleColor =>
      _isDosen ? AppColor.kPrimaryColor : AppColor.kAccentColor;

  /// Determines the scaffold background color based on user role.
  Color get _scaffoldBgColor =>
      _isDosen ? AppColor.kBackgroundColor : AppColor.kBackgroundColorMhs;

  /// Determines the appbar background color based on user role.
  Color get _appBarColor => _isDosen ? AppColor.kAppBar : AppColor.kAccentColor;

  /// Determines the appbar title color based on user role.
  Color get _appBarTitleColor =>
      _isDosen ? AppColor.kTextColor : AppColor.kWhiteColor;

  /// Handles the logout process after confirmation.
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
        // Navigate to the login page and clear the navigation stack
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

  /// Navigates to the Edit Profile page and updates the local user data on return.
  void _navigateToEditProfile() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileFirebasePage(user: _currentUser),
      ),
    );

    if (updatedUser != null && updatedUser is UserFirebaseModel) {
      setState(() {
        _currentUser = updatedUser;
        _isDosen = _currentUser.role == 'dosen';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          "Profil Saya",
          style: TextStyle(
            color: _appBarTitleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _appBarColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColor.kTextColor),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            ProfileHeaderCardFirebase(
              user: _currentUser,
              onEdit: _navigateToEditProfile,
              roleColor: _roleColor,
            ),

            const SizedBox(height: 20),

            // Settings Groups

            // GROUP: Akun
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

            // GROUP: Info
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

            // Logout Button
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
}
