// [FILE BARU: .../view/kelas/widget/info_tab_content.dart]

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/models/kelas_model.dart';

class InfoTabContent extends StatelessWidget {
  final KelasModel kelas;

  const InfoTabContent({super.key, required this.kelas});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.kWhiteColor,
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
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
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SelectableText(
                    kelas.kodeKelas,
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
                      Clipboard.setData(ClipboardData(text: kelas.kodeKelas));
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
              kelas.deskripsi != null && kelas.deskripsi!.isNotEmpty
                  ? kelas.deskripsi!
                  : "(Tidak ada deskripsi)",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
