// features/4_kelas/view/Firebase/materi_tab_content_firebase.dart

import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/materi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/materi_firebase_service.dart'; // Import Service
import 'package:project_volt/features/4_kelas/view/Firebase/create_materi_firebase_page.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/materi_detail_mhs_firebase.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/list_views/materi_list_view_firebase.dart';
import 'package:project_volt/widgets/emptystate.dart';

// Diubah dari StatefulWidget menjadi StatelessWidget
class MateriTabContentFirebase extends StatelessWidget {
  final KelasFirebaseModel kelas;
  final UserFirebaseModel user;
  final bool isDosen;

  MateriTabContentFirebase({
    super.key,
    required this.kelas,
    required this.user,
    required this.isDosen,
  });

  // INISIASI SERVICE FIREBASE (sekali saja)
  final MateriFirebaseService _materiFirebaseService = MateriFirebaseService();

  // Fungsi navigasi dipindah ke StatelessWidget
  void _navigateToCreateMateri(BuildContext context) async {
    final String? kelasId = kelas.kelasId;
    if (kelasId == null) return;

    // Tidak perlu memanggil _loadMateri() lagi, karena StreamBuilder akan otomatis refresh
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMateriFirebasePage(kelasId: kelasId),
      ),
    );
  }

  // void _navigateToDetailMateri(MateriFirebaseModel materi) {
  //   MaterialPageRoute(
  //     // GANTI: Panggil ClassDetailPage versi Firebase
  //     builder: (context) =>
  //         MateriDetailMhsFirebase(materiId: materi.materiId!, user: user),
  //   );
  //   print("TODO: Navigasi ke MateriDetailPage untuk ${materi.judul}");
  // }

  void _navigateToDetailMateri(
    BuildContext context,
    MateriFirebaseModel materi,
  ) {
    if (materi.materiId == null) {
      print("Error: Materi ID is null.");
      return;
    }

    // 🎯 PERBAIKAN: Lakukan navigasi dengan Navigator.push()
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MateriDetailMhsFirebase(materiId: materi.materiId!, user: user),
      ),
    );
    print("Navigasi ke MateriDetailPage untuk ${materi.judul}");
  }

  @override
  Widget build(BuildContext context) {
    final String? kelasId = kelas.kelasId;
    final Color rolePrimaryColor = isDosen
        ? AppColor.kPrimaryColor
        : AppColor.kAccentColor;

    // Cek ID Kelas
    if (kelasId == null) {
      return const Center(child: Text("ID Kelas tidak valid."));
    }

    return Scaffold(
      backgroundColor: AppColor.kWhiteColor,

      // Menggunakan StreamBuilder untuk data Real-time
      body: StreamBuilder<List<MateriFirebaseModel>>(
        // Panggil Stream dari Service
        stream: _materiFirebaseService.getMateriStreamByKelas(kelasId),
        builder: (context, snapshot) {
          // 1. Tangani Error
          if (snapshot.hasError) {
            return Center(
              child: Text("Terjadi kesalahan: ${snapshot.error.toString()}"),
            );
          }

          // 2. Tangani Loading (saat pertama kali terhubung)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: rolePrimaryColor),
            );
          }

          // Data sudah siap, pastikan tidak null (walaupun harusnya tidak jika stream berhasil)
          final daftarMateri = snapshot.data ?? [];

          // 3. Tangani Data Kosong
          if (daftarMateri.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.menu_book_outlined,
              title: "Belum Ada Materi",
              message: isDosen
                  ? "Tekan tombol (+) di bawah untuk memposting materi pertama."
                  : "Dosen Anda belum memposting materi apapun di kelas ini.",
              iconColor: rolePrimaryColor,
            );
          }

          // 4. Tampilkan Data
          return MateriListViewFirebase(
            daftarMateri: daftarMateri,
            onMateriTap: (materi) {
              _navigateToDetailMateri(context, materi);
            },
            roleColor: rolePrimaryColor,
          );
        },
      ),

      floatingActionButton: isDosen
          ? FloatingActionButton(
              onPressed: () => _navigateToCreateMateri(context),
              backgroundColor: AppColor.kPrimaryColor,
              tooltip: 'Posting Materi Baru',
              child: const Icon(Icons.add, color: AppColor.kWhiteColor),
            )
          : null,
    );
  }
}
