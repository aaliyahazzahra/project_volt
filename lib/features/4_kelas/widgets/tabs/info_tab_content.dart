import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/models/kelas_model.dart';

class InfoTabContent extends StatelessWidget {
  final KelasModel kelas;
  final Color roleColor;

  const InfoTabContent({
    super.key,
    required this.kelas,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.kDividerColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.kWhiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.kBlackColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "KODE KELAS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColor.kTextSecondaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () =>
                        _copyToClipboard(context, kelas.kodeKelas, roleColor),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: roleColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            kelas.kodeKelas,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: roleColor,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.copy, size: 20, color: roleColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ketuk kode untuk menyalin",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.kDisabledColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Tentang Kelas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.kTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.kWhiteColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.kDividerColor),
              ),
              child: Text(
                kelas.deskripsi != null && kelas.deskripsi!.isNotEmpty
                    ? kelas.deskripsi!
                    : "Belum ada deskripsi untuk kelas ini.",
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColor.kTextColor,
                ),
                textAlign: TextAlign.justify,
              ),
            ),

            // --- OPSIONAL: Metadata Tambahan (Bisa ditambah nanti) ---
            // Misal: Nama Dosen, Jadwal, Ruangan, SKS
            // Biarkan kosong dulu kalau data belum ada
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, Color themeColor) {
    Clipboard.setData(ClipboardData(text: text));

    final snackBarContent = AwesomeSnackbarContent(
      title: "Disalin!",
      message: "Kode kelas berhasil disalin ke clipboard.",
      contentType: ContentType.success,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: snackBarContent,
        ),
      );
  }
}
