import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 24),

            _buildAcademicProfileCard(),
            SizedBox(height: 24),

            _buildOptionItem(icon: Icons.lock_outline, text: "Ganti Password"),
            SizedBox(height: 12),
            _buildOptionItem(
              icon: Icons.notifications_none,
              text: "Notifikasi",
            ),
            SizedBox(height: 24),

            _buildOptionItem(
              icon: Icons.logout,
              text: "Keluar",
              onTap: () {
                print("Tombol Keluar ditekan");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColor.kWhiteColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColor.kPrimaryColor,
            child: Icon(Icons.person, size: 30, color: AppColor.kWhiteColor),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ahmad Rizki",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.kTextColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "user@email.com",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColor.kSecondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicProfileCard() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColor.kBlueCardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lengkapi Profil Akademik Anda",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.kTextColor,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "NIM",
            style: TextStyle(
              color: AppColor.kTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          _buildTextField("Masukkan NIM"),
          SizedBox(height: 16),
          Text(
            "Institusi/Universitas",
            style: TextStyle(
              color: AppColor.kTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          _buildTextField("Contoh: Universitas Indonesia"),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.kPrimaryColor,
              foregroundColor: AppColor.kWhiteColor,
              minimumSize: Size(double.infinity, 50), // Lebar penuh, tinggi 50
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Text("Simpan Perubahan"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hintText) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: AppColor.kWhiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          // borderSide: BorderSide.none, // Hilangkan border
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String text,
    // Color color = AppColor.kTextColor, // Warna default
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.kWhiteColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        onTap: onTap ?? () {},
        leading: Icon(icon, color: AppColor.kBlueCardColor),
        title: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColor.kBackgroundColor,
          ),
        ),
      ),
    );
  }
}
