import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/models/materi_model.dart';

class MateriListView extends StatelessWidget {
  final List<MateriModel> daftarMateri;
  final Function(MateriModel) onMateriTap;
  final Color roleColor;

  const MateriListView({
    super.key,
    required this.daftarMateri,
    required this.onMateriTap,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: daftarMateri.length,
      itemBuilder: (context, index) {
        final materi = daftarMateri[index];

        // Format tanggal posting
        String tglPosting = "";
        try {
          final tgl = DateTime.parse(materi.tglPosting);
          tglPosting = "Diposting: ${DateFormat.yMd().add_Hm().format(tgl)}";
        } catch (e) {
          tglPosting = "Format tanggal salah.";
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
              child: Icon(Icons.menu_book, color: roleColor),
            ),
            title: Text(
              materi.judul,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              tglPosting,
              style: const TextStyle(color: AppColor.kTextSecondaryColor),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppColor.kTextSecondaryColor,
            ),
            onTap: () => onMateriTap(materi),
          ),
        );
      },
    );
  }
}
