import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/SQF/database/db_helper.dart';
import 'package:project_volt/data/SQF/models/tugas_model.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/tugas_detail_mhs_firebase.dart';
import 'package:project_volt/features/4_kelas/widgets/list_views/tugas_list_view.dart';
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
  List<TugasModel> _daftarTugas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTugas();
  }

  Future<void> _loadTugas() async {
    if (widget.kelas.id == null) return;
    final data = await DbHelper.getTugasByKelas(widget.kelas.id!);
    if (mounted) {
      setState(() {
        _daftarTugas = data;
        _isLoading = false;
      });
    }
  }

  void _navigateToDetailTugas(TugasFirebaseModel tugas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TugasDetailMhsFirebase(tugas: tugas, user: widget.user),
      ),
    ).then((_) {
      // TODO: Tambahkan 'result'
      // status 'sudah dikerjakan', lalu panggil _loadTugas()
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
          : TugasListView(
              daftarTugas: _daftarTugas,
              onTugasTap: _navigateToDetailTugas,
              roleColor: AppColor.kAccentColor,
            ),
    );
  }
}
