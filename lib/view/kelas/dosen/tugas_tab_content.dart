import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/model/tugas_model.dart';
import 'package:project_volt/view/kelas/dosen/create_tugas_page.dart';
import 'package:project_volt/view/kelas/dosen/edit_tugas_page.dart';
import 'package:project_volt/widgets/emptystate.dart';
import 'package:project_volt/widgets/tugas_list_view.dart';

class TugasTabContent extends StatefulWidget {
  final KelasModel kelas;
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
    setState(() => _isLoading = true); // Nyalakan loading
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

  void _navigateToEditTugas(TugasModel tugas) async {
    final isSuccess = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTugasPage(tugas: tugas)),
    );

    if (isSuccess == true && mounted) {
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
    return Scaffold(
      backgroundColor: AppColor.kWhiteColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _daftarTugas.isEmpty
          ? EmptyStateWidget(
              icon: Icons.assignment_late_outlined,
              title: "Belum Ada Tugas",
              message:
                  "Tekan tombol (+) di bawah untuk membuat tugas pertama di kelas ini.",
            )
          : TugasListView(
              daftarTugas: _daftarTugas,
              onTugasTap: _navigateToEditTugas,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTugas,
        backgroundColor: AppColor.kPrimaryColor,
        tooltip: 'Buat Tugas Baru',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
