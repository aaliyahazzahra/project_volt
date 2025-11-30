import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';

class TugasListViewFirebase extends StatelessWidget {
  final List<TugasFirebaseModel> daftarTugas;
  final Function(TugasFirebaseModel) onTugasTap;
  final Color roleColor;

  const TugasListViewFirebase({
    super.key,
    required this.daftarTugas,
    required this.onTugasTap,
    required this.roleColor,
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

        // 1. Tentukan warna default (jika tidak ada tenggat)
        Color tenggatColor = Colors.grey[600] ?? Colors.grey;

        if (tugas.tglTenggat != null) {
          try {
            final tgl = tugas.tglTenggat!;
            tenggat = "Tenggat: ${DateFormat.yMd().add_Hm().format(tgl)}";

            final now = DateTime.now();

            if (now.isAfter(tgl)) {
              tenggatColor = Colors.red[700] ?? Colors.red;
            } else if (tgl.isBefore(now.add(const Duration(days: 3)))) {
              tenggatColor = Colors.orange[800] ?? Colors.orange;
            } else {
              tenggatColor = Colors.green[700] ?? Colors.green;
            }
          } catch (e) {
            tenggat = "Format tanggal salah.";
            tenggatColor = Colors.red;
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColor.kBackgroundColor,

          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColor.kIconBgColor,
              child: Icon(Icons.assignment, color: roleColor),
            ),
            title: Text(
              tugas.judul,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              tenggat,
              style: TextStyle(
                color: tenggatColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => onTugasTap(tugas),
          ),
        );
      },
    );
  }
}
