import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_image.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/materi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/materi_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/create_materi_firebase_page.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/materi_detail_mhs_firebase.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/list_views/materi_list_view_firebase.dart';
import 'package:project_volt/widgets/emptystate.dart';

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

  final MateriFirebaseService _materiFirebaseService = MateriFirebaseService();

  void _navigateToCreateMateri(BuildContext context) async {
    final String? kelasId = kelas.kelasId;
    if (kelasId == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMateriFirebasePage(kelasId: kelasId),
      ),
    );
  }

  void _navigateToDetailMateri(
    BuildContext context,
    MateriFirebaseModel materi,
  ) {
    if (materi.materiId == null) {
      print("Error: Materi ID is null.");
      return;
    }

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

    if (kelasId == null) {
      return const Center(child: Text("ID Kelas tidak valid."));
    }

    return Scaffold(
      backgroundColor: AppColor.kWhiteColor,

      body: StreamBuilder<List<MateriFirebaseModel>>(
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

          final daftarMateri = snapshot.data ?? [];

          // 3. Tangani Data Kosong
          if (daftarMateri.isEmpty) {
            return EmptyStateWidget(
              imagePath: AppImages.materidosen,
              title: "Belum Ada Materi",
              message: isDosen
                  ? "Tekan tombol (+) di bawah untuk menambah materi baru."
                  : "Dosen Anda belum memposting materi apapun di kelas ini.",
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
