// lib/features/4_kelas/view/Firebase/tugas_detail_mhs_firebase.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
// Import halaman pengumpulan tugas
import 'package:project_volt/features/4_kelas/view/Firebase/tugas_submission_firebase_page.dart';

class TugasDetailMhsFirebase extends StatefulWidget {
  final TugasFirebaseModel tugas;
  final UserFirebaseModel user; // User Mahasiswa

  const TugasDetailMhsFirebase({
    super.key,
    required this.tugas,
    required this.user,
  });

  @override
  State<TugasDetailMhsFirebase> createState() => _TugasDetailMhsFirebaseState();
}

class _TugasDetailMhsFirebaseState extends State<TugasDetailMhsFirebase> {
  // Flag ini akan disetel TRUE jika Mahasiswa berhasil submit/update tugas
  // di halaman TugasSubmissionFirebasePage
  bool _submisiUpdated = false;

  // --- LOGIC NAVIGASI KE SUBMISI (Menyelesaikan TODO) ---

  void _navigateToSubmissionPage() async {
    // Navigasi ke halaman pengumpulan tugas dan tunggu hasilnya
    // Hasil 'true' akan didapatkan jika Mahasiswa berhasil submit/update
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TugasSubmissionFirebasePage(tugas: widget.tugas, user: widget.user),
      ),
    );

    // Jika Mahasiswa berhasil submit/update, set flag untuk refresh di parent widget
    if (result == true && mounted) {
      setState(() {
        _submisiUpdated = true;
      });
      // 💡 TODO TAMBAHAN: Anda bisa memuat ulang status submisi Mahasiswa di sini
      // jika ingin mengupdate UI di halaman ini sebelum di-pop.
    }
  }

  // --- WIDGET BUILDER ---

  Widget _buildTugasInfo() {
    final TugasFirebaseModel tugas = widget.tugas;

    final String tenggatFormatted = tugas.tglTenggat != null
        ? DateFormat('EEEE, dd MMM yyyy HH:mm').format(tugas.tglTenggat!)
        : 'Tidak ada tenggat waktu';

    final bool isSimulasi = tugas.simulasiId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tugas.judul,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.kPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: Colors.redAccent,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              "Tenggat: $tenggatFormatted",
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
        if (isSimulasi)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                Icon(
                  Icons.developer_board,
                  color: AppColor.kAccentColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Tugas berupa Proyek Simulasi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.kAccentColor,
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: 30),

        const Text(
          "Instruksi Tugas:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          tugas.deskripsi ??
              "Tidak ada deskripsi/instruksi yang diberikan oleh Dosen.",
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppColor.kTextColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        //    TODO SELESAI: Kirim sinyal perubahan ke halaman parent (TugasTabMhsFirebase)
        Navigator.of(context).pop(_submisiUpdated);
      },
      child: Scaffold(
        backgroundColor: AppColor.kBackgroundColor,
        appBar: AppBar(
          title: Text(widget.tugas.judul),
          backgroundColor: AppColor.kAccentColor,
          foregroundColor: AppColor.kWhiteColor,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTugasInfo(),

              const SizedBox(height: 40),

              // ⭐️ CTA UTAMA: KE HALAMAN SUBMISI (Menyelesaikan TODO)
              ElevatedButton.icon(
                onPressed: _navigateToSubmissionPage,
                icon: const Icon(Icons.assignment_turned_in_outlined),
                label: const Text('Kerjakan dan Kumpulkan Tugas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.kAccentColor,
                  foregroundColor: AppColor.kWhiteColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 💡 TODO TAMBAHAN: Tampilkan status submisi Mahasiswa di sini
              // Status: Belum Dikerjakan / Sudah Dinilai (85/100)
            ],
          ),
        ),
      ),
    );
  }
}
