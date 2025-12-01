// lib/features/4_kelas/view/Firebase/tugas_detail_mhs_firebase.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/submisi_firebase_model.dart'; // <<< Import Model Submisi
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/submisi_firebase_service.dart'; // <<< Import Service Submisi
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
  // Service yang dibutuhkan
  final SubmisiFirebaseService _submisiService = SubmisiFirebaseService();

  // State untuk menyimpan data submisi Mahasiswa
  SubmisiFirebaseModel? _currentSubmisi;
  bool _isLoadingStatus = true;

  // Flag ini akan disetel TRUE jika Mahasiswa berhasil submit/update tugas
  bool _submisiUpdated = false;

  @override
  void initState() {
    super.initState();
    _loadSubmissionStatus(); // Panggil saat initState
  }

  // --- LOGIKA MUAT STATUS SUBMISI (Implementasi TODO Tambahan 1) ---

  Future<void> _loadSubmissionStatus() async {
    if (widget.tugas.tugasId == null) {
      if (mounted) setState(() => _isLoadingStatus = false);
      return;
    }

    // Set loading state
    if (mounted) setState(() => _isLoadingStatus = true);

    final submisi = await _submisiService.getSubmisiByTugasAndMahasiswa(
      widget.tugas.tugasId!,
      widget.user.uid,
    );

    if (mounted) {
      setState(() {
        _currentSubmisi = submisi;
        _isLoadingStatus = false;
      });
    }
  }

  // --- LOGIC NAVIGASI KE SUBMISI (Menyelesaikan TODO) ---

  void _navigateToSubmissionPage() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TugasSubmissionFirebasePage(tugas: widget.tugas, user: widget.user),
      ),
    );

    // Jika Mahasiswa berhasil submit/update, set flag dan MUAT ULANG STATUS
    if (result == true && mounted) {
      setState(() {
        _submisiUpdated = true;
      });
      //   TODO TAMBAHAN SELESAI: Memuat ulang status submisi Mahasiswa
      _loadSubmissionStatus();
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
            const Icon(
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
                const Icon(
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

  Widget _buildSubmissionStatusWidget() {
    if (_isLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentSubmisi == null) {
      return const Text(
        "Status: Belum Dikerjakan",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      );
    }

    // Tugas sudah disubmit
    final submisi = _currentSubmisi!;
    IconData icon;
    Color color;
    String statusText;

    if (submisi.nilai != null) {
      icon = Icons.star;
      color = Colors.amber.shade800;
      statusText = "Sudah Dinilai: ${submisi.nilai}/100";
    } else if (submisi.status == 'DISUBMIT') {
      icon = Icons.check_circle;
      color = Colors.green;
      // Cek apakah terlambat (Logika yang lebih kompleks mungkin diperlukan)
      statusText = "Diserahkan";
      if (widget.tugas.tglTenggat != null &&
          submisi.tglSubmit!.isAfter(widget.tugas.tglTenggat!)) {
        color = Colors.orange;
        statusText = "Diserahkan (Terlambat)";
      }
    } else {
      icon = Icons.warning;
      color = Colors.red;
      statusText = "Status: ${submisi.status ?? 'Tidak Diketahui'}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Status Submisi Anda:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        if (submisi.tglSubmit != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "Terakhir dikirim: ${DateFormat('dd MMM yyyy HH:mm').format(submisi.tglSubmit!)}",
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
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
        // Kirim sinyal perubahan ke halaman parent (TugasTabMhsFirebase)
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

              //   TODO TAMBAHAN SELESAI: Tampilkan status submisi Mahasiswa di sini
              _buildSubmissionStatusWidget(),

              const SizedBox(height: 20),

              // ⭐️ CTA UTAMA: KE HALAMAN SUBMISI
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
            ],
          ),
        ),
      ),
    );
  }
}
