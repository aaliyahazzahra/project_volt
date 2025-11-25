import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/SQF/database/db_helper.dart';
import 'package:project_volt/data/SQF/models/kelas_model.dart';
import 'package:project_volt/data/SQF/models/tugas_model.dart';
import 'package:project_volt/features/4_kelas/view/create_tugas_page.dart';
import 'package:project_volt/features/4_kelas/view/tugas_detail_dosen.dart';
import 'package:project_volt/features/4_kelas/widgets/list_views/tugas_list_view.dart';
import 'package:project_volt/widgets/emptystate.dart';

class TugasTabContent extends StatefulWidget {
  final KelasModel kelas;
  final Color rolePrimaryColor = AppColor.kPrimaryColor;
  const TugasTabContent({super.key, required this.kelas});

  @override
  State<TugasTabContent> createState() => _TugasTabContentState();
}

class _TugasTabContentState extends State<TugasTabContent> {
  List<TugasModel> _daftarTugas = [];
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

  void _navigateToDetailTugas(TugasModel tugas) async {
    final bool? isDataChanged = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TugasDetailDosen(tugas: tugas)),
    );

    if (isDataChanged == true && mounted) {
      _refreshTugasList();
    }
  }

  void _navigateToCreateTugas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTugasPage(kelasId: widget.kelas.id!),
      ),
    ).then((_) {
      setState(() => _isLoading = true);
      _loadTugas();
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
          : TugasListView(
              daftarTugas: _daftarTugas,
              onTugasTap: _navigateToDetailTugas,
              roleColor: rolePrimaryColor,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTugas,
        backgroundColor: AppColor.kPrimaryColor,
        tooltip: 'Buat Tugas Baru',
        child: Icon(Icons.add, color: AppColor.kWhiteColor),
      ),
    );
  }
}
