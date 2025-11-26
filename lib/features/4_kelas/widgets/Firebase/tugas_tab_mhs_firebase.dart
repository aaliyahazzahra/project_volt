import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
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
  final TugasFirebaseService _tugasService = TugasFirebaseService();
  List<TugasFirebaseModel> _daftarTugas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTugas();
  }

  // Di dalam class _TugasTabMhsFirebaseState

  Future<void> _loadTugas() async {
    // 1. Ambil ID kelas (gunakan properti yang benar: kelasId)
    final String? kelasId = widget.kelas.kelasId;

    if (kelasId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await _tugasService.getTugasByKelas(kelasId);

      if (mounted) {
        setState(() {
          _daftarTugas = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Error loading tasks from Firebase: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  // Di dalam class _TugasTabMhsFirebaseState

  void _navigateToDetailTugas(TugasFirebaseModel tugas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TugasDetailMhsFirebase(tugas: tugas, user: widget.user),
      ),
    ).then((result) {
      //    KOREKSI 1: Tangkap nilai balik sebagai 'result'

      //    KOREKSI 2: Cek apakah result adalah TRUE
      if (result == true && mounted) {
        // Panggil _loadTugas() untuk me-refresh daftar tugas
        // agar status submisi Mahasiswa terbaru terlihat.
        _loadTugas();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.kWhiteColor,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColor.kAccentColor),
            )
          : _daftarTugas.isEmpty
          ? EmptyStateWidget(
              icon: Icons.assignment_late_outlined,
              title: "Belum Ada Tugas",
              message: "Dosen Anda belum memposting tugas apapun di kelas ini.",
              iconColor: AppColor.kAccentColor,
            )
          : TugasListViewFirebase(
              daftarTugas: _daftarTugas,
              onTugasTap: _navigateToDetailTugas,
              roleColor: AppColor.kAccentColor,
            ),
    );
  }
}
