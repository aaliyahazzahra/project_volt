import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
//  Import Model dan Services Firebase
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/service/submisi_firebase_service.dart'; // Import service Submisi
import 'package:project_volt/data/firebase/service/tugas_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/edit_tugas_firebase_page.dart';
import 'package:project_volt/widgets/emptystate.dart';

class TugasDetailDosenFirebase extends StatefulWidget {
  final TugasFirebaseModel tugas;
  const TugasDetailDosenFirebase({super.key, required this.tugas});

  @override
  State<TugasDetailDosenFirebase> createState() =>
      _TugasDetailDosenFirebaseState();
}

class _TugasDetailDosenFirebaseState extends State<TugasDetailDosenFirebase> {
  late TugasFirebaseModel _currentTugasData;
  bool _dataTelahDiubah = false;

  //  INISIASI SERVICE
  final TugasFirebaseService _tugasService = TugasFirebaseService();

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
        builder: (context) => EditTugasFirebasePage(tugas: _currentTugasData),
      ),
    );

    if (isSuccess == true && mounted) {
      _dataTelahDiubah = true;
      _refreshTugasData();
    }
  }

  //  UPDATE LOGIKA REFRESH DATA (Menggunakan FirebaseService)
  Future<void> _refreshTugasData() async {
    // Pastikan ID tugas (String) tersedia
    final String? tugasId = _currentTugasData.tugasId;
    if (tugasId == null) return;

    try {
      // Panggil service untuk mendapatkan 1 data tugas
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
      // Handle error refresh
      if (mounted) print("Error refreshing Tugas data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        // Kirim sinyal perubahan ke halaman parent (TugasTabContent)
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
              //  UBAH TIPE ID: Menggunakan tugasId (String)
              _SubmisiListTab(tugasId: _currentTugasData.tugasId!),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Tab 1 (Info) - Tetap sama, hanya menggunakan model Firebase
  Widget _buildInfoTugasTab(TugasFirebaseModel tugas) {
    // ... (Logika format tanggal tetap sama)
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (Tampilan Judul, Tenggat, Deskripsi)
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
}

//   Widget untuk Tab 2 (Submisi)
class _SubmisiListTab extends StatefulWidget {
  //  UBAH TIPE ID: tugasId dari int ke String
  final String tugasId;
  const _SubmisiListTab({required this.tugasId});

  @override
  State<_SubmisiListTab> createState() => _SubmisiListTabState();
}

class _SubmisiListTabState extends State<_SubmisiListTab> {
  //  UBAH TIPE MODEL: SubmisiDetail -> SubmisiDetailFirebase
  late Future<List<SubmisiDetailFirebase>> _futureSubmisi;
  //  INISIASI SERVICE
  final SubmisiFirebaseService _submisiService = SubmisiFirebaseService();

  @override
  void initState() {
    super.initState();
    _loadSubmisi();
  }

  void _loadSubmisi() {
    //  Panggil service Firebase dengan ID string
    _futureSubmisi = _submisiService.getSubmisiDetailByTugas(widget.tugasId);
  }

  //  UBAH TIPE MODEL: SubmisiDetail -> SubmisiDetailFirebase
  void _navigateToSubmisiDetail(SubmisiDetailFirebase detail) {
    // TODO: (Poin #5) Arahkan ke halaman penilaian
    print("TODO: Buka halaman nilai untuk ${detail.mahasiswa.namaLengkap}");
    // Navigator.push(context, MaterialPageRoute(
    //    builder: (context) => SubmisiDetailPage(detail: detail)
    // )).then((_) => _loadSubmisi()); // Refresh jika ada penilaian
  }

  @override
  Widget build(BuildContext context) {
    //  UBAH TIPE MODEL: FutureBuilder<List<SubmisiDetailFirebase>>
    return FutureBuilder<List<SubmisiDetailFirebase>>(
      future: _futureSubmisi,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.group_off_outlined,
            title: "Belum Ada Submisi",
            message: "Belum ada mahasiswa yang mengumpulkan tugas ini.",
          );
        }

        final daftarSubmisi = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: daftarSubmisi.length,
          itemBuilder: (context, index) {
            final item = daftarSubmisi[index];
            final bool dinilai =
                item.submisi.nilai != null && item.submisi.nilai! > 0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColor.kIconBgColor,
                  child: Icon(
                    Icons.person_outline,
                    color: AppColor.kPrimaryColor,
                  ),
                ),
                //  Menggunakan namaLengkap dari model UserFirebaseModel
                title: Text(
                  item.mahasiswa.namaLengkap ??
                      item.mahasiswa.namaLengkap ??
                      'Mahasiswa',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                //  Menggunakan nimNidn dari model UserFirebaseModel
                subtitle: Text(
                  item.mahasiswa.nimNidn ??
                      item.mahasiswa.email ??
                      'Tidak ada data',
                ),
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
