import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

class AnggotaListViewFirebase extends StatelessWidget {
  final List<UserFirebaseModel> daftarAnggota;
  final Function(UserFirebaseModel)? onAnggotaTap;
  final Color roleColor;

  const AnggotaListViewFirebase({
    super.key,
    required this.daftarAnggota,
    this.onAnggotaTap,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: daftarAnggota.length,
      itemBuilder: (context, index) {
        final anggota = daftarAnggota[index];

        //  Logika Subtitle: NIM/NIDN (jika ada) atau Email
        final String subtitleText = anggota.nimNidn?.isNotEmpty == true
            ? anggota.nimNidn! // Gunakan NIM/NIDN jika ada
            : anggota.email ?? 'Email tidak tersedia'; // Fallback ke email

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
              child: Icon(Icons.person_outline, color: roleColor),
            ),
            title: Text(
              //  Menggunakan namaLengkap, fallback ke Email jika namaLengkap hilang
              anggota.namaLengkap.isNotEmpty
                  ? anggota.namaLengkap
                  : (anggota.email ?? 'Pengguna'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColor.kTextColor,
              ),
            ),
            subtitle: Text(
              subtitleText, //  Menggunakan properti nimNidn
              style: TextStyle(color: AppColor.kTextSecondaryColor),
            ),
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
