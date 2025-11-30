// file: AboutPage.dart

import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_image.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Helper untuk membuka URL (Memerlukan package url_launcher)
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
        title: const Text(
          "Tentang Aplikasi",
          style: TextStyle(
            color: AppColor.kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kAppBar,
        iconTheme: const IconThemeData(color: AppColor.kTextColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            _buildHeader(),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Tentang VOLT"),
                  _buildDescriptionCard(),

                  const SizedBox(height: 24),

                  _buildSectionTitle("Pengembang"),
                  _buildDeveloperCard(context),

                  const SizedBox(height: 24),

                  _buildSectionTitle("Open Source Libraries"),
                  Text(
                    "Aplikasi ini dibangun menggunakan teknologi open source berikut:",
                    style: TextStyle(
                      color: AppColor.kTextSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTechStack(),

                  const SizedBox(height: 40),

                  _buildFooter(),

                  const SizedBox(height: 30),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.kWhiteColor,
            boxShadow: [
              BoxShadow(
                // Shadow menggunakan warna branding
                color: AppColor.kPrimaryColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Image.asset(
            AppImages.volt,
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.bolt,
                size: 60,
                color: AppColor.kPrimaryColor,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "VOLT - Virtual Logic Trainer",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.kTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            // Mengganti Colors.grey.shade200
            color: AppColor.kDividerColor,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Text(
            "v1.0.2",

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
        style: const TextStyle(
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // Shadow menggunakan kBlackColor
            color: AppColor.kBlackColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        "VOLT adalah aplikasi LMS inovatif yang mengintegrasikan manajemen kelas dengan simulasi gerbang logika digital secara real-time. \n\nAplikasi ini memudahkan Dosen dalam mengajar dan Mahasiswa dalam bereksperimen dengan rangkaian logika seperti AND, OR, NOT, NAND, dan NOR.",
        style: TextStyle(fontSize: 14, height: 1.6, color: AppColor.kTextColor),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // Shadow menggunakan kBlackColor
            color: AppColor.kBlackColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                // Background avatar menggunakan warna branding
                backgroundColor: AppColor.kPrimaryColor.withOpacity(0.1),
                child: const Text(
                  "AA",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColor.kPrimaryColor,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Aaliyah Azzahra",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.kTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
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
          const SizedBox(height: 20),
          // Menggunakan kDividerColor
          const Divider(color: AppColor.kDividerColor),
          const SizedBox(height: 10),
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
            // Ikon sosial menggunakan warna branding
            Icon(icon, color: AppColor.kPrimaryColor, size: 24),
            const SizedBox(height: 4),
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
      "shared_preferences",
      "awesome_snackbar_content",
      "bottom_bar_matu",
      "flutter_colorpicker",
      "animated_gradient",
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: libraries.map((lib) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          // Mengganti Colors.grey[400]
          const Icon(Icons.school, size: 20, color: AppColor.kDisabledColor),
          const SizedBox(height: 8),
          Text(
            "Diajukan sebagai Tugas Akhir di PPKD Jakarta Pusat",
            style: TextStyle(
              fontSize: 11,
              // Mengganti Colors.grey[500]
              color: AppColor.kTextSecondaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Instruktur: Andrea Surya Habibie",
            // Mengganti Colors.grey[500]
            style: TextStyle(fontSize: 11, color: AppColor.kTextSecondaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            "© 2025 Aaliyah Azzahra. All Rights Reserved.",
            // Mengganti Colors.grey[400]
            style: TextStyle(fontSize: 10, color: AppColor.kDisabledColor),
          ),
        ],
      ),
    );
  }
}
