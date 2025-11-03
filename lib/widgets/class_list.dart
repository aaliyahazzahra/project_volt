import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/model/kelas_model.dart';

class ClassList extends StatelessWidget {
  final List<KelasModel> daftarKelas;
  final Function(KelasModel) onKelasTap;

  const ClassList({
    super.key,
    required this.daftarKelas,
    required this.onKelasTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: daftarKelas.length,
      itemBuilder: (context, index) {
        final kelas = daftarKelas[index];
        final namaKelas = kelas.namaKelas;

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColor.kPrimaryColor,
              child: Text(
                namaKelas.isNotEmpty ? namaKelas[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              namaKelas,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Kode Kelas: ${kelas.kodeKelas}"),

            onTap: () => onKelasTap(kelas),
          ),
        );
      },
    );
  }
}
