import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_image.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/tugas_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/tugas_detail_mhs_firebase.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/list_views/tugas_list_view_firebase.dart';
import 'package:project_volt/widgets/emptystate.dart';

class TugasTabMhsFirebase extends StatefulWidget {
  final KelasFirebaseModel kelas;
  final UserFirebaseModel user;
  const TugasTabMhsFirebase({
    super.key,
    required this.kelas,
    required this.user,
  });

  @override
  State<TugasTabMhsFirebase> createState() => _TugasTabMhsFirebaseState();
}

class _TugasTabMhsFirebaseState extends State<TugasTabMhsFirebase> {
  // INISIASI SERVICE FIREBASE
  final TugasFirebaseService _tugasService = TugasFirebaseService();

  // ❗ HAPUS: State tidak diperlukan karena StreamBuilder mengelola data
  // List<TugasFirebaseModel> _daftarTugas = [];
  // bool _isLoading = true;

  // ❗ HAPUS: initState dan _loadTugas karena data diurus oleh StreamBuilder

  // @override
  // void initState() {
  //   super.initState();
  //   _loadTugas();
  // }

  // Future<void> _loadTugas() async { ... HAPUS FUNGSI INI ... }

  // ------------------------------------------------------------------
  // FUNGSI NAVIGASI (Disesuaikan)
  // ------------------------------------------------------------------

  void _navigateToDetailTugas(TugasFirebaseModel tugas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TugasDetailMhsFirebase(tugas: tugas, user: widget.user),
      ),
    ).then((result) {
      // Walaupun data utama (daftar tugas) real-time,
      // kita tetap perlu me-refresh jika ada status Mahasiswa
      // yang berubah di halaman detail (misalnya, status "Sudah Submit").
      // Namun, jika status submisi Mahasiswa tersimpan di koleksi terpisah
      // dan *ListView* Mahasiswa tidak perlu menampilkannya,
      // panggilan ini mungkin tidak diperlukan.

      // JIKA STATUS SUBMISI MAHASISWA HARUS REFRESH:
      // if (result == true && mounted) {
      //   // Panggil fungsi *one-time fetch* atau me-refresh tampilan
      //   // jika ada status tambahan yang harus diambil (ini skenario kompleks).
      //   // Untuk saat ini, kita akan asumsikan data yang ditampilkan di List
      //   // cukup dicakup oleh Stream, dan tidak perlu refresh manual.
      // }

      // KARENA MENGGUNAKAN STREAM: Panggilan ini umumnya tidak diperlukan lagi
      // kecuali untuk data sekunder yang tidak di-stream.
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? kelasId = widget.kelas.kelasId;
    final Color accentColor = AppColor.kAccentColor;

    if (kelasId == null) {
      return const Center(
        child: Text(
          'ID Kelas tidak valid',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Container(
      color: AppColor.kWhiteColor,
      // ------------------------------------------------------------------
      //   PERBAIKAN UTAMA: GANTI Future/setState dengan StreamBuilder
      // ------------------------------------------------------------------
      child: StreamBuilder<List<TugasFirebaseModel>>(
        // Panggil fungsi Stream yang sudah kita perbaiki
        stream: _tugasService.getTugasStreamByKelas(kelasId),

        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentColor));
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
          final listTugas = snapshot.data ?? [];

          if (listTugas.isEmpty) {
            // Empty State
            return EmptyStateWidget(
              imagePath: AppImages.tugasdosen,
              // icon: Icons.assignment_late_outlined,
              title: "Belum Ada Tugas",
              message: "Dosen Anda belum memposting tugas apapun di kelas ini.",
              // iconColor: accentColor,
            );
          }

          // 4. Tampilkan Daftar Tugas
          // TugasListViewFirebase kini otomatis akan diperbarui saat
          // Dosen menambah tugas baru.
          return TugasListViewFirebase(
            daftarTugas: listTugas,
            onTugasTap: _navigateToDetailTugas,
            roleColor: accentColor,
          );
        },
      ),
    );
  }
}
