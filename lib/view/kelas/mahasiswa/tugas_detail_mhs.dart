import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/model/tugas_model.dart';

class TugasDetailMhs extends StatelessWidget {
  final TugasModel tugas;
  const TugasDetailMhs({super.key, required this.tugas});

  // Helper untuk memformat tanggal
  String _formatTenggat(String? tglTenggat) {
    if (tglTenggat == null) {
      return "Tidak ada tenggat waktu.";
    }
    try {
      final tgl = DateTime.parse(tglTenggat);
      return "Tenggat: ${DateFormat.yMd().add_Hm().format(tgl)}";
    } catch (e) {
      return "Format tanggal salah.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String tenggatFormatted = _formatTenggat(tugas.tglTenggat);

    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Detail Tugas",
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tugas.judul,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColor.kTextColor,
              ),
            ),
            SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.red[700],
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  tenggatFormatted,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Divider(height: 32),

            Text(
              "Deskripsi Tugas:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              tugas.deskripsi != null && tugas.deskripsi!.isNotEmpty
                  ? tugas.deskripsi!
                  : "(Tidak ada deskripsi)",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
            Divider(height: 32),

            _buildSubmissionSection(), //masih placeholder
          ],
        ),
      ),
    );
  }

  // Widget pengumpulan tugas
  Widget _buildSubmissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pengumpulan Tugas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: Colors.grey[600],
              ),
              SizedBox(height: 12),
              Text(
                "Fitur 'Submit Tugas' belum tersedia.",
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: null, // Nonaktifkan tombol
                icon: Icon(Icons.link),
                label: Text("Upload File (Coming Soon)"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
