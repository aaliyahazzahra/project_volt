import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/model/tugas_model.dart';
import 'package:project_volt/view/kelas/mahasiswa/tugas_detail_mhs.dart';
import 'package:project_volt/widgets/emptystate.dart';

class TugasTabMhs extends StatefulWidget {
  final KelasModel kelas;
  const TugasTabMhs({super.key, required this.kelas});

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

  Widget _buildTugasList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _daftarTugas.length,
      itemBuilder: (context, index) {
        final tugas = _daftarTugas[index];

        String tenggat = "Tidak ada tenggat.";
        if (tugas.tglTenggat != null) {
          try {
            final tgl = DateTime.parse(tugas.tglTenggat!);
            tenggat = "Tenggat: ${DateFormat.yMd().add_Hm().format(tgl)}";
          } catch (e) {
            tenggat = "Format tanggal salah.";
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColor.kIconBgColor,
              child: Icon(Icons.assignment, color: AppColor.kPrimaryColor),
            ),
            title: Text(
              tugas.judul,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              tenggat,
              style: TextStyle(
                color: tugas.tglTenggat == null ? Colors.grey : Colors.red[700],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TugasDetailMhs(tugas: tugas),
                ),
              );
              print("Buka detail tugas: ${tugas.judul}");
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.kBackgroundColor,
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _daftarTugas.isEmpty
          ? EmptyStateWidget(
              icon: Icons.assignment_late_outlined,
              title: "Belum Ada Tugas",
              message: "Dosen Anda belum memposting tugas apapun di kelas ini.",
            )
          : _buildTugasList(),
    );
  }
}
