import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/utils/preference_handler.dart';
import 'package:project_volt/data/models/user_model.dart';
import 'package:project_volt/features/1_auth/authenticator.dart';
import 'package:project_volt/features/3_profile/about_page.dart';
import 'package:project_volt/features/3_profile/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool _isMahasiswa;

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
      await PreferenceHandler.removeUser();
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
  void initState() {
    super.initState();
    _isMahasiswa = widget.user.role == UserRole.mahasiswa.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Profil Saya",
          style: TextStyle(
            color: AppColor.kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kAppBar,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColor.kTextColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Fitur Pengaturan akan segera hadir!")),
              );
            },
            tooltip: 'Pengaturan',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildProfileHeader(),

            SizedBox(height: 12),
            if (_isMahasiswa) ...[
              _buildOptionItem(
                icon: Icons.star,
                text: "Badge Saya",
                // onTap: () {},
              ),
              SizedBox(height: 12),
            ],
            SizedBox(height: 12),
            _buildOptionItem(
              icon: Icons.info_outline,
              text: "Tentang Aplikasi",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
            Spacer(),
            _buildOptionItem(
              icon: Icons.logout,
              text: "Keluar",
              onTap: _logout,
              color: AppColor.kErrorColor,
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final bool isDosen = widget.user.role == UserRole.dosen.toString();
    final String roleText = isDosen ? "Dosen" : "Mahasiswa";
    final Color roleColor = isDosen
        ? (AppColor.colorDosen)
        : AppColor.kPrimaryColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.0),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.namaLengkap,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.kTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                SizedBox(height: 4),
                Text(
                  widget.user.email,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: roleColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    roleText,
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 16),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.kPrimaryColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColor.kPrimaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColor.kPrimaryColor,
                  ),
                ),
              ),

              Positioned(
                right: 0,
                top: 0,
                child: Material(
                  color: AppColor.kWhiteColor,
                  shape: CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: _navigateToEditProfile,
                    customBorder: CircleBorder(),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColor.kPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String text,
    Color color = AppColor.kTextColor,
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
          color: color == AppColor.kTextColor ? AppColor.kPrimaryColor : color,
        ),
        title: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      ),
    );
  }
}
