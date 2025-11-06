import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/widgets/anggota_list_view.dart';
import 'package:project_volt/widgets/emptystate.dart';

class AnggotaTabContent extends StatefulWidget {
  final KelasModel kelas;
  const AnggotaTabContent({super.key, required this.kelas});

  @override
  State<AnggotaTabContent> createState() => _AnggotaTabContentState();
}

class _AnggotaTabContentState extends State<AnggotaTabContent> {
  List<UserModel> _daftarAnggota = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnggota();
  }

  Future<void> _loadAnggota() async {
    if (widget.kelas.id == null) return;
    final data = await DbHelper.getAnggotaByKelas(widget.kelas.id!);
    if (mounted) {
      setState(() {
        _daftarAnggota = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _daftarAnggota.isEmpty
          ? EmptyStateWidget(
              icon: Icons.group_off_outlined,
              title: "Belum Ada Anggota",
              message: "Belum ada mahasiswa yang bergabung dengan kelas ini.",
            )
          : AnggotaListView(
              daftarAnggota: _daftarAnggota,
              // onAnggotaTap: _handleAnggotaTap,
            ),
    );
  }
}
