import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/model/tugas_model.dart';

class TugasListView extends StatelessWidget {
  final List<TugasModel> daftarTugas;
  final Function(TugasModel) onTugasTap;

  const TugasListView({
    super.key,
    required this.daftarTugas,
    required this.onTugasTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: daftarTugas.length,
      itemBuilder: (context, index) {
        final tugas = daftarTugas[index];

        // Format tanggal tenggat
        String tenggat = "Tidak ada tenggat.";
        if (tugas.tglTenggat != null) {
          try {
            // Ubah string ISO kembali ke DateTime
            final tgl = DateTime.parse(tugas.tglTenggat!);
            // Format ke 'dd MMM yyyy, HH:mm' (misal: 25 Des 2024, 14:30)
            tenggat =
                "Tenggat: ${DateFormat('d MMM y, HH:mm', 'id_ID').format(tgl)}";
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
            onTap: () => onTugasTap(tugas),
          ),
        );
      },
    );
  }
}
