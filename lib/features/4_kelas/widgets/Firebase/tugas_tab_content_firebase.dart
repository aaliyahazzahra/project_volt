import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_image.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/tugas_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/create_tugas_firebase_page.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/tugas_detail_dosen_firebase.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/list_views/tugas_list_view_firebase.dart';
import 'package:project_volt/widgets/emptystate.dart';

class TugasTabContentFirebase extends StatefulWidget {
  final KelasFirebaseModel kelas;
  final Color rolePrimaryColor = AppColor.kPrimaryColor;
  final UserFirebaseModel user; // Sudah benar

  const TugasTabContentFirebase({
    super.key,
    required this.kelas,
    required this.user,
  });

  @override
  State<TugasTabContentFirebase> createState() =>
      _TugasTabContentFirebaseState();
}

class _TugasTabContentFirebaseState extends State<TugasTabContentFirebase> {
  // INISIASI SERVICE FIREBASE
  final TugasFirebaseService _tugasService = TugasFirebaseService();

  // ❗ HAPUS STATE LIST DAN LOADING: StreamBuilder akan mengurus ini
  // List<TugasFirebaseModel> _daftarTugas = [];
  // bool _isLoading = true;

  // HAPUS initState dan _loadTugas karena data diurus oleh StreamBuilder

  // ------------------------------------------------------------------
  // ❗ HAPUS FUNGSI YANG TIDAK DIGUNAKAN LAGI (Karena diganti StreamBuilder)
  // ------------------------------------------------------------------

  /*
  @override
  void initState() {
    super.initState();
    // ❗ Tidak perlu memanggil _loadTugas di sini lagi
  }

  void _refreshTugasList() {
    // ❗ Tidak perlu memanggil _loadTugas lagi, StreamBuilder otomatis refresh
  }
  
  Future<void> _loadTugas() async {
    // ❗ Hapus seluruh fungsi ini
  }
  */

  // ------------------------------------------------------------------
  // FUNGSI NAVIGASI TETAP ADA (Disesuaikan agar tidak memanggil refresh manual)
  // ------------------------------------------------------------------

  // UPDATE LOGIKA NAVIGASI DETAIL (Tidak perlu async/await/refresh)
  void _navigateToDetailTugas(TugasFirebaseModel tugas) {
    // Navigasi tidak perlu mengembalikan data karena Stream sudah real-time
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TugasDetailDosenFirebase(tugas: tugas),
      ),
      // ❗ Tidak perlu .then((_) { _refreshTugasList(); }) lagi
    );
  }

  // UPDATE LOGIKA NAVIGASI CREATE
  void _navigateToCreateTugas() {
    final String? kelasId = widget.kelas.kelasId;
    if (kelasId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateTugasFirebasePage(kelasId: kelasId, user: widget.user),
      ),
    );
    // ❗ Tidak perlu .then((_) { _refreshTugasList(); }) lagi,
    // karena saat kembali, StreamBuilder otomatis mendeteksi tugas baru.
  }

  @override
  Widget build(BuildContext context) {
    final Color rolePrimaryColor = AppColor.kPrimaryColor;
    final String? kelasId = widget.kelas.kelasId;

    if (kelasId == null) {
      return const Center(
        child: Text(
          'ID Kelas tidak valid',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.kWhiteColor,
      // ------------------------------------------------------------------
      //   PERBAIKAN UTAMA: GANTI Future/setState dengan StreamBuilder
      // ------------------------------------------------------------------
      body: StreamBuilder<List<TugasFirebaseModel>>(
        // Panggil fungsi Stream yang sudah kita perbaiki
        stream: _tugasService.getTugasStreamByKelas(kelasId),

        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: rolePrimaryColor),
            );
          }

          // 2. Error State
          if (snapshot.hasError) {
            print("Stream Error: ${snapshot.error}");
            return Center(
              child: Text(
                'Gagal memuat data tugas: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          // 3. Data Loaded / Empty State
          // Data List<TugasFirebaseModel> yang otomatis diperbarui
          final listTugas = snapshot.data ?? [];

          if (listTugas.isEmpty) {
            // Empty State dari tangkapan layar awal
            return EmptyStateWidget(
              imagePath: AppImages.tugasdosen,
              // icon: Icons.assignment_late_outlined,
              title: "Belum Ada Tugas",
              message:
                  "Tekan tombol (+) di bawah untuk membuat tugas pertama di kelas ini.",
              // iconColor: rolePrimaryColor,
            );
          }

          // 4. Tampilkan Daftar Tugas
          return TugasListViewFirebase(
            daftarTugas: listTugas,
            onTugasTap: _navigateToDetailTugas,
            roleColor: rolePrimaryColor,
          );
        },
      ),

      // ------------------------------------------------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTugas,
        backgroundColor: AppColor.kPrimaryColor,
        tooltip: 'Buat Tugas Baru',
        child: const Icon(Icons.add, color: AppColor.kWhiteColor),
      ),
    );
  }
}
