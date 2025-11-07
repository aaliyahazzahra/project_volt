import 'package:flutter/material.dart';
import 'package:project_volt/common_widgets/emptystate.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/database/db_helper.dart';
import 'package:project_volt/data/models/kelas_model.dart';
import 'package:project_volt/data/models/tugas_model.dart';
import 'package:project_volt/data/models/user_model.dart';
import 'package:project_volt/features/4_kelas/view/tugas_detail_mhs.dart';
import 'package:project_volt/features/4_kelas/widgets/list_views/tugas_list_view.dart';

class TugasTabMhs extends StatefulWidget {
  final KelasModel kelas;
  final UserModel user;
  const TugasTabMhs({super.key, required this.kelas, required this.user});

  @override
  State<TugasTabMhs> createState() => _TugasTabMhsState();
}

class _TugasTabMhsState extends State<TugasTabMhs> {
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

  void _navigateToDetailTugas(TugasModel tugas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TugasDetailMhs(tugas: tugas, user: widget.user),
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
          ? Center(child: CircularProgressIndicator())
          : _daftarTugas.isEmpty
          ? EmptyStateWidget(
              icon: Icons.assignment_late_outlined,
              title: "Belum Ada Tugas",
              message: "Dosen Anda belum memposting tugas apapun di kelas ini.",
            )
          : TugasListView(
              daftarTugas: _daftarTugas,
              onTugasTap: _navigateToDetailTugas,
            ),
    );
  }
}
