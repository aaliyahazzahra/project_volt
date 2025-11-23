import 'package:flutter/material.dart';
import 'package:project_volt/widgets/emptystate.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/database/db_helper.dart';
import 'package:project_volt/data/models/kelas_model.dart';
import 'package:project_volt/data/models/user_model.dart';
import 'package:project_volt/features/4_kelas/widgets/list_views/anggota_list_view.dart';

class AnggotaTabContent extends StatefulWidget {
  final KelasModel kelas;
  final Color rolePrimaryColor;
  const AnggotaTabContent({
    super.key,
    required this.kelas,
    required this.rolePrimaryColor,
  });

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
      backgroundColor: AppColor.kWhiteColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: widget.rolePrimaryColor),
            )
          : _daftarAnggota.isEmpty
          ? EmptyStateWidget(
              icon: Icons.group_off_outlined,
              title: "Belum Ada Anggota",
              message: "Belum ada mahasiswa yang bergabung dengan kelas ini.",
              iconColor: widget.rolePrimaryColor,
            )
          : AnggotaListView(
              daftarAnggota: _daftarAnggota,
              // onAnggotaTap: _handleAnggotaTap,
              roleColor: widget.rolePrimaryColor,
            ),
    );
  }
}
