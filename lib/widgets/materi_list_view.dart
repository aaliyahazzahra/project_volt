import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/model/materi_model.dart';

class MateriListView extends StatelessWidget {
  final List<MateriModel> daftarMateri;
  final Function(MateriModel) onMateriTap;

  const MateriListView({
    super.key,
    required this.daftarMateri,
    required this.onMateriTap,
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
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColor.kIconBgColor,
              child: Icon(Icons.menu_book, color: AppColor.kPrimaryColor),
            ),
            title: Text(
              materi.judul,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              tglPosting,
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () => onMateriTap(materi),
          ),
        );
      },
    );
  }
}
