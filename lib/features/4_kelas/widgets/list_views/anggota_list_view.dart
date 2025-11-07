import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/models/user_model.dart';

class AnggotaListView extends StatelessWidget {
  final List<UserModel> daftarAnggota;
  final Function(UserModel)? onAnggotaTap;

  const AnggotaListView({
    super.key,
    required this.daftarAnggota,
    this.onAnggotaTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: daftarAnggota.length,
      itemBuilder: (context, index) {
        final anggota = daftarAnggota[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColor.kIconBgColor,
              child: Icon(Icons.person_outline, color: AppColor.kPrimaryColor),
            ),
            title: Text(
              anggota.namaLengkap,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(anggota.nim ?? "NIM belum diatur"),
            onTap: () {
              // Hanya panggil fungsi jika onTap tidak null
              if (onAnggotaTap != null) {
                onAnggotaTap!(anggota);
              }
            },
          ),
        );
      },
    );
  }
}
