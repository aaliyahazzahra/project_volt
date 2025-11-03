import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/model/kelas_model.dart';

import 'package:project_volt/view/kelas/dosen/edit_class.dart';

class ClassDetail extends StatefulWidget {
  final KelasModel kelas;

  const ClassDetail({super.key, required this.kelas});

  @override
  State<ClassDetail> createState() => _ClassDetailState();
}

class _ClassDetailState extends State<ClassDetail> {
  late KelasModel _currentKelasData;

  @override
  void initState() {
    super.initState();
    _currentKelasData = widget.kelas;
  }

  void _navigateToEdit() async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClass(kelas: _currentKelasData),
      ),
    );

    if (updatedData != null && mounted) {
      if (updatedData is KelasModel) {
        setState(() {
          _currentKelasData = updatedData;
        });
      }
    }
  }

  Widget _buildInfoTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kode Kelas: ${_currentKelasData.kodeKelas}",
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
          title: Text(_currentKelasData.namaKelas),
          actions: [
            IconButton(
              icon: Icon(Icons.edit_note),
              onPressed: _navigateToEdit,
              tooltip: 'Edit Deskripsi',
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: "Info"),
              Tab(icon: Icon(Icons.assignment), text: "Tugas"),
              Tab(icon: Icon(Icons.group_outlined), text: "Anggota"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Halaman Info
            _buildInfoTab(),

            // Tab 2: Halaman Tugas (Placeholder)
            Center(child: Text("Daftar Tugas (Belum dibuat)")),

            // Tab 3: Halaman Anggota (Placeholder)
            Center(child: Text("Daftar Anggota (Belum dibuat)")),
          ],
        ),
      ),
    );
  }
}
