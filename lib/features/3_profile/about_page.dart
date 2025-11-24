import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_image.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Helper untuk membuka URL (Memerlukan package url_launcher)
  // Karena url_launcher tidak ada di pubspec Anda, fungsi ini hanya
  // menampilkan snackbar sebagai placeholder.
  void _launchURL(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Membuka: $url"), duration: Duration(seconds: 1)),
    );
    // TODO: Tambahkan 'url_launcher' di pubspec.yaml jika ingin link benar-benar bisa diklik
    // launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Tentang Aplikasi",
          style: TextStyle(
            color: AppColor.kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kAppBar,
        iconTheme: IconThemeData(color: AppColor.kTextColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),

            _buildHeader(),

            SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Tentang VOLT"),
                  _buildDescriptionCard(),

                  SizedBox(height: 24),

                  _buildSectionTitle("Pengembang"),
                  _buildDeveloperCard(context),

                  SizedBox(height: 24),

                  _buildSectionTitle("Open Source Libraries"),
                  Text(
                    "Aplikasi ini dibangun menggunakan teknologi open source berikut:",
                    style: TextStyle(
                      color: AppColor.kTextSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildTechStack(),

                  SizedBox(height: 40),

                  _buildFooter(),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.kWhiteColor,
            boxShadow: [
              BoxShadow(
                color: AppColor.kPrimaryColor.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Image.asset(
            AppImages.volt,
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.bolt, size: 60, color: AppColor.kPrimaryColor);
            },
          ),
        ),
        SizedBox(height: 16),
        Text(
          "VOLT",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColor.kPrimaryColor,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "v1.0.1",
            style: TextStyle(
              fontSize: 12,
              color: AppColor.kTextSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColor.kTextColor,
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        "VOLT adalah aplikasi LMS inovatif yang mengintegrasikan manajemen kelas dengan simulasi gerbang logika digital secara real-time. \n\nAplikasi ini memudahkan Dosen dalam mengajar dan Mahasiswa dalam bereksperimen dengan rangkaian logika seperti AND, OR, NOT, NAND, dan NOR.",
        style: TextStyle(fontSize: 14, height: 1.6, color: AppColor.kTextColor),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColor.kPrimaryColor.withOpacity(0.1),
                child: Text(
                  "AA",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColor.kPrimaryColor,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Aaliyah Azzahra",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.kTextColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "PPKD Jakarta Pusat",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColor.kTextSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Divider(color: AppColor.kDividerColor),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialButton(
                context,
                icon: Icons.email_outlined,
                label: "Email",
                onTap: () =>
                    _launchURL(context, "mailto:aaliyahazzahra02@gmail.com"),
              ),
              _buildSocialButton(
                context,
                icon: Icons.code,
                label: "GitHub",
                onTap: () =>
                    _launchURL(context, "https://github.com/aaliyahazzahra"),
              ),
              _buildSocialButton(
                context,
                icon: Icons.business,
                label: "LinkedIn",
                onTap: () => _launchURL(
                  context,
                  "https://www.linkedin.com/in/aaliyahazzahra",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          children: [
            Icon(icon, color: AppColor.kPrimaryColor, size: 24),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColor.kTextSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechStack() {
    final List<String> libraries = [
      "Flutter",
      "Dart",
      "sqflite",
      "provider",
      "uuid",
      "google_maps_flutter",
      "geolocator",
      "shared_preferences",
      "awesome_snackbar_content",
      "bottom_bar_matu",
      "persistent_bottom_nav_bar",
      "animated_gradient",
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: libraries.map((lib) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColor.kWhiteColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.kDividerColor),
          ),
          child: Text(
            lib,
            style: TextStyle(
              fontSize: 11,
              color: AppColor.kTextSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.school, size: 20, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text(
            "Diajukan sebagai Tugas Akhir di PPKD Jakarta Pusat",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Instruktur: Andrea Surya Habibie",
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          SizedBox(height: 20),
          Text(
            "© 2025 Aaliyah Azzahra. All Rights Reserved.",
            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
