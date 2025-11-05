import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/view/kelas/mahasiswa/tugas_tab_mhs.dart';

// TODO: Buat halaman TugasTabMahasiswa
// TODO: Buat halaman AnggotaTabMahasiswa

class ClassDetailMhs extends StatefulWidget {
  final KelasModel kelas;
  final UserModel user;

  const ClassDetailMhs({super.key, required this.kelas, required this.user});

  @override
  State<ClassDetailMhs> createState() => _ClassDetailMhsState();
}

class _ClassDetailMhsState extends State<ClassDetailMhs> {
  late KelasModel _currentKelasData;

  @override
  void initState() {
    super.initState();
    _currentKelasData = widget.kelas;
  }

  Widget _buildInfoTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kode Kelas:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _currentKelasData.kodeKelas,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.kPrimaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Deskripsi:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _currentKelasData.deskripsi != null &&
                      _currentKelasData.deskripsi!.isNotEmpty
                  ? _currentKelasData.deskripsi!
                  : "(Tidak ada deskripsi)",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.kelas.namaKelas),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: "Info"),
              Tab(icon: Icon(Icons.assignment_outlined), text: "Tugas"),
              Tab(icon: Icon(Icons.group_outlined), text: "Anggota"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Halaman Info
            _buildInfoTab(),

            // Tab 2: Halaman Tugas (Masih placeholder)
            TugasTabMhs(kelas: widget.kelas),

            // Tab 3: Halaman Anggota (Masih placeholder)
            Center(child: Text("Daftar Anggota Kelas (Belum dibuat)")),
          ],
        ),
      ),
    );
  }
}
