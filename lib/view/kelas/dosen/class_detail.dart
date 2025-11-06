import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/view/kelas/dosen/anggota_tab_content.dart';
import 'package:project_volt/view/kelas/dosen/edit_class.dart';
import 'package:project_volt/view/kelas/dosen/tugas_tab_content.dart';

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

  void _navigateToEditKelas() async {
    final isSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClass(kelas: _currentKelasData),
      ),
    );

    if (isSuccess == true && mounted) {
      _refreshKelasData();
    }
  }

  Future<void> _refreshKelasData() async {
    final updatedKelas = await DbHelper.getKelasById(widget.kelas.id!);

    if (!mounted) return;

    if (updatedKelas != null) {
      setState(() {
        _currentKelasData = updatedKelas;
      });
    } else {
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kode Kelas:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.kIconBgColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectableText(
                  _currentKelasData.kodeKelas,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy_all_outlined),
                  tooltip: 'Salin Kode',
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: _currentKelasData.kodeKelas),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Kode berhasil disalin!")),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColor.kWhiteColor,
        appBar: AppBar(
          backgroundColor: AppColor.kBackgroundColor,

          titleTextStyle: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),

          iconTheme: IconThemeData(color: AppColor.kTextColor),

          actionsIconTheme: IconThemeData(color: AppColor.kTextColor),

          title: Text(_currentKelasData.namaKelas),
          actions: [
            IconButton(
              icon: Icon(Icons.edit_note),
              onPressed: _navigateToEditKelas,
              tooltip: 'Edit Deskripsi',
            ),
          ],

          bottom: TabBar(
            labelColor: AppColor.kPrimaryColor,
            unselectedLabelColor: AppColor.kTextSecondaryColor,
            indicatorColor: AppColor.kPrimaryColor,

            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: "Info"),
              Tab(icon: Icon(Icons.assignment), text: "Tugas"),
              Tab(icon: Icon(Icons.group_outlined), text: "Anggota"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            _buildInfoTab(),

            TugasTabContent(kelas: _currentKelasData),

            AnggotaTabContent(kelas: _currentKelasData),
          ],
        ),
      ),
    );
  }
}
