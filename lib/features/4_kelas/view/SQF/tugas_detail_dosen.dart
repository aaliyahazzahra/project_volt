import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/widgets/emptystate.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/database/db_helper.dart';
import 'package:project_volt/data/models/tugas_model.dart';
import 'package:project_volt/features/4_kelas/view/edit_tugas_page.dart';
// TODO: Buat halaman SubmisiDetailPage (untuk Poin #5 nanti)

class TugasDetailDosen extends StatefulWidget {
  final TugasModel tugas;
  const TugasDetailDosen({super.key, required this.tugas});

  @override
  State<TugasDetailDosen> createState() => _TugasDetailDosenState();
}

class _TugasDetailDosenState extends State<TugasDetailDosen> {
  late TugasModel _currentTugasData;
  bool _dataTelahDiubah = false;

  @override
  void initState() {
    super.initState();
    _currentTugasData = widget.tugas;
  }

  // Navigasi ke Halaman Edit
  void _navigateToEditTugas() async {
    final isSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTugasPage(tugas: _currentTugasData),
      ),
    );

    if (isSuccess == true && mounted) {
      _dataTelahDiubah = true;
      _refreshTugasData();
    }
  }

  // Refresh data jika ada perubahan
  Future<void> _refreshTugasData() async {
    final updatedTugas = await DbHelper.getTugasById(_currentTugasData.id!);
    if (mounted) {
      if (updatedTugas != null) {
        setState(() {
          _currentTugasData = updatedTugas;
        });
      } else {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        Navigator.of(context).pop(_dataTelahDiubah);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColor.kWhiteColor,
          appBar: AppBar(
            title: Text(_currentTugasData.judul),
            backgroundColor: AppColor.kBackgroundColor,
            titleTextStyle: TextStyle(
              color: AppColor.kPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            iconTheme: IconThemeData(color: AppColor.kTextColor),
            actions: [
              IconButton(
                icon: Icon(Icons.edit_note),
                onPressed: _navigateToEditTugas,
                tooltip: 'Edit Tugas',
              ),
            ],
            bottom: TabBar(
              labelColor: AppColor.kPrimaryColor,
              unselectedLabelColor: AppColor.kTextSecondaryColor,
              indicatorColor: AppColor.kPrimaryColor,
              tabs: [
                Tab(icon: Icon(Icons.info_outline), text: "Info Tugas"),
                Tab(
                  icon: Icon(Icons.group_outlined),
                  text: "Submisi Mahasiswa",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Tab 1: Info Tugas
              _buildInfoTugasTab(_currentTugasData),

              // Tab 2: Daftar Submisi
              _SubmisiListTab(tugasId: _currentTugasData.id!),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Tab 1 (Info)
  Widget _buildInfoTugasTab(TugasModel tugas) {
    // Gunakan helper format tanggal
    String tenggat = "Tidak ada tenggat waktu.";
    Color tenggatColor = Colors.grey[600]!;
    if (tugas.tglTenggat != null) {
      try {
        final tgl = DateTime.parse(tugas.tglTenggat!);
        tenggat = "Tenggat: ${DateFormat.yMd().add_Hm().format(tgl)}";

        final now = DateTime.now();
        if (now.isAfter(tgl)) {
          tenggatColor = Colors.red[700]!;
        } else if (tgl.isBefore(now.add(const Duration(days: 3)))) {
          tenggatColor = Colors.orange[800]!;
        } else {
          tenggatColor = Colors.green[700]!;
        }
      } catch (e) {
        tenggat = "Format tanggal salah.";
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tugas.judul,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColor.kTextColor,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: tenggatColor,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                tenggat,
                style: TextStyle(
                  fontSize: 14,
                  color: tenggatColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Divider(height: 32),
          Text(
            "Deskripsi Tugas:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            tugas.deskripsi != null && tugas.deskripsi!.isNotEmpty
                ? tugas.deskripsi!
                : "(Tidak ada deskripsi)",
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

//  Widget untuk Tab 2 (Submisi)
class _SubmisiListTab extends StatefulWidget {
  final int tugasId;
  const _SubmisiListTab({required this.tugasId});

  @override
  State<_SubmisiListTab> createState() => _SubmisiListTabState();
}

class _SubmisiListTabState extends State<_SubmisiListTab> {
  late Future<List<SubmisiDetail>> _futureSubmisi;

  @override
  void initState() {
    super.initState();
    _loadSubmisi();
  }

  void _loadSubmisi() {
    _futureSubmisi = DbHelper.getSubmisiDetailByTugas(widget.tugasId);
  }

  void _navigateToSubmisiDetail(SubmisiDetail detail) {
    // TODO: (Poin #5) Arahkan ke halaman penilaian
    print("TODO: Buka halaman nilai untuk ${detail.mahasiswa.namaLengkap}");
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => SubmisiDetailPage(detail: detail)
    // )).then((_) => _loadSubmisi()); // Refresh jika ada penilaian
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubmisiDetail>>(
      future: _futureSubmisi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.group_off_outlined,
            title: "Belum Ada Submisi",
            message: "Belum ada mahasiswa yang mengumpulkan tugas ini.",
          );
        }

        final daftarSubmisi = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: daftarSubmisi.length,
          itemBuilder: (context, index) {
            final item = daftarSubmisi[index];
            final bool dinilai =
                item.submisi.nilai != null && item.submisi.nilai! > 0;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColor.kIconBgColor,
                  child: Icon(
                    Icons.person_outline,
                    color: AppColor.kPrimaryColor,
                  ),
                ),
                title: Text(
                  item.mahasiswa.namaLengkap,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item.nim ?? item.mahasiswa.email),
                trailing: Chip(
                  label: Text(
                    dinilai ? "Nilai: ${item.submisi.nilai}" : "Belum Dinilai",
                    style: TextStyle(
                      color: dinilai ? Colors.green[800] : Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: dinilai
                      ? Colors.green[100]
                      : Colors.orange[100],
                ),
                onTap: () => _navigateToSubmisiDetail(item),
              ),
            );
          },
        );
      },
    );
  }
}
