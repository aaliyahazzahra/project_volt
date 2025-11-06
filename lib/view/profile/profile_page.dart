import 'package:flutter/material.dart';

import 'package:project_volt/view/profile/edit_profile_page.dart';

import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/utils/preference_handler.dart';
import 'package:project_volt/view/login_register/authenticator.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // fungsi Logout
  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Keluar'),
        content: Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await PreferenceHandler.removeUser(); // Hapus session
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Authenticator()),
          (route) => false,
        );
      }
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Profil Saya",
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColor.kPrimaryColor),
            onPressed: _navigateToEditProfile,
            tooltip: 'Ubah Profil Akademik',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildProfileHeader(),

            SizedBox(height: 12),
            _buildOptionItem(
              icon: Icons.star,
              text: "Badge Saya",
              // onTap: _navigateToGantiPassword,
            ),
            SizedBox(height: 12),
            _buildOptionItem(
              icon: Icons.info_outline,
              text: "Tentang Aplikasi",
              // onTap: _logout,
            ),
            Spacer(),
            _buildOptionItem(
              icon: Icons.logout,
              text: "Keluar",
              onTap: _logout,
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Widget Profile
  Widget _buildProfileHeader() {
    final bool isDosen = widget.user.role == UserRole.dosen.toString();
    final String roleText = isDosen ? "Dosen" : "Mahasiswa";
    final Color roleColor = isDosen
        ? (AppColor.colorDosen)
        : AppColor.kPrimaryColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: AppColor.kWhiteColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. FOTO
          CircleAvatar(
            radius: 40, //
            backgroundColor: AppColor.kPrimaryColor,
            child: Icon(Icons.person, size: 40, color: AppColor.kBlueCardColor),
          ),
          SizedBox(height: 16), // Jarak
          // 2. NAMA
          Text(
            widget.user.namaLengkap,
            style: TextStyle(
              fontSize: 20, // Font lebih besar
              fontWeight: FontWeight.bold,
              color: AppColor.kTextColor,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),

          // 3. EMAIL
          Text(
            widget.user.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16), // Jarak
          // --- 6. BADGE BARU ---
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: roleColor.withOpacity(0.5)),
            ),
            child: Text(
              roleText,
              style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Tombol Opsi (Reusable) ---
  Widget _buildOptionItem({
    required IconData icon,
    required String text,
    // Color color = AppColor.kTextColor,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.kWhiteColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          // color: color == AppColor.kTextColor ? AppColor.kPrimaryColor : color,
        ),
        title: Text(
          text,
          // style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      ),
    );
  }
}
