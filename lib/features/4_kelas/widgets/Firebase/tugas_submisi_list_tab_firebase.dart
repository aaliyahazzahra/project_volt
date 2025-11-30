// lib/features/4_kelas/widgets/tabs/tugas_submisi_list_tab.dart

import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_image.dart';
// Import dependencies Service dan Model
import 'package:project_volt/data/firebase/service/submisi_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/submisi_detail_dosen_firebase.dart';
import 'package:project_volt/widgets/emptystate.dart';

// Catatan: SubmisiDetailFirebase harus diimpor/didefinisikan di file submisi_firebase_service.dart
// (sesuai kode yang Anda berikan sebelumnya)

class SubmisiListTab extends StatefulWidget {
  final String tugasId;

  const SubmisiListTab({super.key, required this.tugasId});

  @override
  State<SubmisiListTab> createState() => _SubmisiListTabState();
}

class _SubmisiListTabState extends State<SubmisiListTab> {
  final SubmisiFirebaseService _submisiService = SubmisiFirebaseService();
  // Menggunakan tipe List<SubmisiDetailFirebase> yang merupakan join data Submisi dan User
  late Future<List<SubmisiDetailFirebase>> _futureSubmisi;

  @override
  void initState() {
    super.initState();
    _loadSubmisi();
  }

  void _loadSubmisi() {
    // Memanggil fungsi relasional untuk mendapatkan detail Submisi dan Mahasiswa
    _futureSubmisi = _submisiService.getSubmisiDetailByTugas(widget.tugasId);
  }

  // Koreksi Error Navigasi yang Ditemukan Sebelumnya
  void _navigateToSubmisiDetail(SubmisiDetailFirebase detail) async {
    // Navigasi ke halaman detail penilaian
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // Panggil Widget Halaman Penilaian yang benar (SubmisiDetailPage sesuai dengan kode keempat Anda)
        builder: (context) => SubmisiDetailPage(detail: detail),
      ),
    );

    // Jika hasil pop dari halaman detail adalah true, lakukan refresh list
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
            imagePath: AppImages.tugasdosen,
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
                    style: const TextStyle(
                      color: AppColor.kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  item.mahasiswa.namaLengkap,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item.mahasiswa.nimNidn ?? "NIM/NIDN tidak tersedia",
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
