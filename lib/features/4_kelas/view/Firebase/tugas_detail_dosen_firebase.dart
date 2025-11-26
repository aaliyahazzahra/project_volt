import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/submisi_firebase_model.dart';
//  Import Model dan Services Firebase
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/submisi_firebase_service.dart';
import 'package:project_volt/data/firebase/service/tugas_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/edit_tugas_firebase_page.dart';
import 'package:project_volt/widgets/emptystate.dart';

// Helper Class (diulang di sini agar Tab List bisa diakses jika di-split file)
// Asumsi SubmisiDetailFirebase didefinisikan di service, kita definisikan ulang strukturnya di sini
class SubmisiDetailFirebase {
  final SubmisiFirebaseModel submisi;
  final UserFirebaseModel mahasiswa;
  SubmisiDetailFirebase({required this.submisi, required this.mahasiswa});
}

class TugasDetailDosenFirebase extends StatefulWidget {
  final TugasFirebaseModel tugas;
  const TugasDetailDosenFirebase({super.key, required this.tugas});

  @override
  State<TugasDetailDosenFirebase> createState() =>
      _TugasDetailDosenFirebaseState();
}

// -------------------------------------------------------------------
// --- STATE UTAMA (Info & Navigasi) ---
// -------------------------------------------------------------------

class _TugasDetailDosenFirebaseState extends State<TugasDetailDosenFirebase> {
  late TugasFirebaseModel _currentTugasData;
  bool _dataTelahDiubah = false;

  final TugasFirebaseService _tugasService = TugasFirebaseService();

  @override
  void initState() {
    super.initState();
    _currentTugasData = widget.tugas;
  }

  void _navigateToEditTugas() async {
    final isSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTugasFirebasePage(tugas: _currentTugasData),
      ),
    );

    if (isSuccess == true && mounted) {
      _dataTelahDiubah = true;
      _refreshTugasData();
    }
  }

  Future<void> _refreshTugasData() async {
    final String? tugasId = _currentTugasData.tugasId;
    if (tugasId == null) return;

    try {
      final updatedTugas = await _tugasService.getTugasById(tugasId);

      if (mounted) {
        if (updatedTugas != null) {
          setState(() {
            _currentTugasData = updatedTugas;
          });
        } else {
          // Tugas sudah dihapus
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) print("Error refreshing Tugas data: $e");
    }
  }

  // Widget untuk Tab 1 (Info Tugas) - Diambil dari kode Anda
  Widget _buildInfoTugasTab(TugasFirebaseModel tugas) {
    String tenggat = "Tidak ada tenggat waktu.";
    Color tenggatColor = Colors.grey[600]!;
    if (tugas.tglTenggat != null) {
      try {
        final tgl = tugas.tglTenggat!; // tglTenggat sekarang adalah DateTime
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

    // Asumsi: Tugas Firebase Model sudah memiliki properti simulasiId
    final isSimulasi = tugas.simulasiId != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: tenggatColor,
                size: 16,
              ),
              const SizedBox(width: 8),
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
          // 🎯 Tampilan status Simulasi
          if (isSimulasi)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.developer_board,
                    color: AppColor.kAccentColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Tugas berupa Proyek Simulasi",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColor.kAccentColor,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 32),
          const Text(
            "Deskripsi Tugas:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
                icon: const Icon(Icons.edit_note),
                onPressed: _navigateToEditTugas,
                tooltip: 'Edit Tugas',
              ),
            ],
            bottom: TabBar(
              labelColor: AppColor.kPrimaryColor,
              unselectedLabelColor: AppColor.kTextSecondaryColor,
              indicatorColor: AppColor.kPrimaryColor,
              tabs: const [
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
              _SubmisiListTab(tugasId: _currentTugasData.tugasId!),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// --- WIDGET TAB SUBMISI (Integrasi Daftar dan Navigasi Penilaian) ---
// -------------------------------------------------------------------

class _SubmisiListTab extends StatefulWidget {
  final String tugasId;
  const _SubmisiListTab({required this.tugasId});

  @override
  State<_SubmisiListTab> createState() => _SubmisiListTabState();
}

class _SubmisiListTabState extends State<_SubmisiListTab> {
  final SubmisiFirebaseService _submisiService = SubmisiFirebaseService();
  late Future<List<SubmisiDetailFirebase>> _futureSubmisi;

  @override
  void initState() {
    super.initState();
    _loadSubmisi();
  }

  void _loadSubmisi() {
    _futureSubmisi = _submisiService.getSubmisiDetailByTugas(widget.tugasId);
  }

  // 🎯 FUNGSI AKTIF: Navigasi ke halaman penilaian
  void _navigateToSubmisiDetail(SubmisiDetailFirebase detail) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmisiDetailFirebase(detail: detail),
      ),
    );

    // Refresh daftar jika penilaian berhasil (result == true)
    if (result == true && mounted) {
      setState(() {
        _loadSubmisi();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubmisiDetailFirebase>>(
      future: _futureSubmisi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final daftarSubmisi = snapshot.data ?? [];

        if (daftarSubmisi.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.group_off_outlined,
            title: "Belum Ada Submisi",
            message: "Belum ada mahasiswa yang mengumpulkan tugas ini.",
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: daftarSubmisi.length,
          itemBuilder: (context, index) {
            final item = daftarSubmisi[index];
            final bool dinilai =
                item.submisi.nilai != null && item.submisi.status == 'DINILAI';
            final Color statusColor = dinilai
                ? Colors.green[700]!
                : Colors.orange[700]!;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColor.kIconBgColor,
                  child: Text(
                    item.mahasiswa.namaLengkap.substring(0, 1),
                    style: TextStyle(
                      color: AppColor.kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  item.mahasiswa.namaLengkap ?? 'Mahasiswa',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item.mahasiswa.nimNidn ??
                      item.mahasiswa.email ??
                      'Tidak ada data',
                ),
                trailing: Chip(
                  label: Text(
                    dinilai
                        ? "Nilai: ${item.submisi.nilai}"
                        : "Status: ${item.submisi.status}",
                    style: TextStyle(
                      color: statusColor,
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
