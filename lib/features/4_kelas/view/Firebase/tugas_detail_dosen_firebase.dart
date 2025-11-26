// lib/features/4_kelas/view/Firebase/tugas_detail_dosen_firebase.dart (MODIFIED)

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
// Import Model dan Services Firebase
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/service/tugas_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/edit_tugas_firebase_page.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/tugas_submisi_list_tab_firebase.dart';
import 'package:project_volt/widgets/dialogs/confirmation_dialog_helper.dart';
//    IMPORT BARU: Tab daftar submisi yang sudah dipecah

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
    // ... (logic navigasi tetap sama)
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
    // ... (logic refresh tetap sama)
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
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) print("Error refreshing Tugas data: $e");
    }
  }

  // Widget untuk Tab 1 (Info Tugas)
  Widget _buildInfoTugasTab(TugasFirebaseModel tugas) {
    String tenggat = "Tidak ada tenggat waktu.";
    Color tenggatColor = Colors.grey[600]!;
    if (tugas.tglTenggat != null) {
      try {
        final tgl = tugas.tglTenggat!;
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

  Future<void> _deleteTugas() async {
    // 1. Tampilkan dialog konfirmasi
    final bool? confirm = await showConfirmationDialog(
      context: context,
      title: 'Hapus Tugas',
      content:
          'Apakah Anda yakin ingin menghapus tugas "${_currentTugasData.judul}"? Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'HAPUS',
      confirmColor: AppColor.kErrorColor,
    );

    if (confirm == true) {
      if (_currentTugasData.tugasId == null) return;

      try {
        // 2. Panggil service delete
        await _tugasService.deleteTugas(_currentTugasData.tugasId!);

        // 3. Keluar dari halaman dengan sinyal refresh
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          // Asumsi: Anda memiliki fungsi _showSnackbar di sini

          _showSnackbar("Gagal menghapus tugas: $e", ContentType.failure);
        }
      }
    }
  }

  void _showSnackbar(String message, ContentType type) {
    final snackBarContent = AwesomeSnackbarContent(
      title: type == ContentType.success ? "Sukses" : "Error",
      message: message.replaceAll('Exception: ', ''),
      contentType: type,
    );

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: snackBarContent,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
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
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColor.kErrorColor,
                ),
                onPressed: _deleteTugas,
                tooltip: 'Hapus Tugas',
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

              //    KOREKSI: Gunakan widget SubmisiListTab yang sudah dipecah
              SubmisiListTab(tugasId: _currentTugasData.tugasId!),
            ],
          ),
        ),
      ),
    );
  }
}
