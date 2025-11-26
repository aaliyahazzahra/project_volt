import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

import 'package:project_volt/data/firebase/service/tugas_firebase_service.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';

import 'package:project_volt/features/4_kelas/view/Firebase/create_tugas_firebase_page.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/tugas_detail_dosen_firebase.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/list_views/tugas_list_view_firebase.dart';
import 'package:project_volt/widgets/emptystate.dart';

// Di dalam class TugasTabContentFirebase

class TugasTabContentFirebase extends StatefulWidget {
  final KelasFirebaseModel kelas;
  final Color rolePrimaryColor = AppColor.kPrimaryColor;

  //    KOREKSI 1: TAMBAHKAN PROPERTI USER
  final UserFirebaseModel user;

  const TugasTabContentFirebase({
    super.key,
    required this.kelas,
    required this.user, //    JADIKAN REQUIRED DI KONSTRUKTOR
  });

  @override
  State<TugasTabContentFirebase> createState() =>
      _TugasTabContentFirebaseState();
}

class _TugasTabContentFirebaseState extends State<TugasTabContentFirebase> {
  //  INISIASI SERVICE FIREBASE
  final TugasFirebaseService _tugasService = TugasFirebaseService();

  //  UBAH TIPE LIST: TugasModel -> TugasFirebaseModel
  List<TugasFirebaseModel> _daftarTugas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTugas();
  }

  void _refreshTugasList() {
    setState(() => _isLoading = true);
    _loadTugas();
  }

  //  UPDATE LOGIKA LOAD DATA (Menggunakan FirebaseService)
  Future<void> _loadTugas() async {
    final String? kelasId = widget.kelas.kelasId;

    if (kelasId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      //  PANGGIL SERVICE FIREBASE dengan kelasId (String)
      final data = await _tugasService.getTugasByKelas(kelasId);

      if (mounted) {
        setState(() {
          _daftarTugas = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Tampilkan pesan error jika perlu
        print("Error loading tasks: $e");
      }
    }
  }

  //  UPDATE LOGIKA NAVIGASI DETAIL (Menggunakan model dan widget Firebase)
  void _navigateToDetailTugas(TugasFirebaseModel tugas) async {
    final bool? isDataChanged = await Navigator.push(
      context,
      MaterialPageRoute(
        //  GANTI: Panggil widget Detail Dosen versi Firebase
        builder: (context) => TugasDetailDosenFirebase(tugas: tugas),
      ),
    );

    if (isDataChanged == true && mounted) {
      _refreshTugasList();
    }
  }

  //  UPDATE LOGIKA NAVIGASI CREATE (Menggunakan widget Firebase)
  void _navigateToCreateTugas() {
    final String? kelasId = widget.kelas.kelasId;
    if (kelasId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        //  GANTI: Panggil widget Create Tugas versi Firebase
        builder: (context) => CreateTugasFirebasePage(
          kelasId: kelasId,
          //    KOREKSI: Akses User Model melalui widget
          user: widget.user,
        ),
      ),
    ).then((_) {
      _refreshTugasList(); // Selalu refresh setelah kembali
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color rolePrimaryColor = AppColor.kPrimaryColor;
    return Scaffold(
      backgroundColor: AppColor.kWhiteColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: rolePrimaryColor))
          : _daftarTugas.isEmpty
          ? EmptyStateWidget(
              icon: Icons.assignment_late_outlined,
              title: "Belum Ada Tugas",
              message:
                  "Tekan tombol (+) di bawah untuk membuat tugas pertama di kelas ini.",
              iconColor: rolePrimaryColor,
            )
          : TugasListViewFirebase(
              //  Menggunakan TugasListView versi Firebase
              daftarTugas: _daftarTugas,
              onTugasTap: _navigateToDetailTugas,
              roleColor: rolePrimaryColor,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTugas,
        backgroundColor: AppColor.kPrimaryColor,
        tooltip: 'Buat Tugas Baru',
        child: const Icon(Icons.add, color: AppColor.kWhiteColor),
      ),
    );
  }
}
