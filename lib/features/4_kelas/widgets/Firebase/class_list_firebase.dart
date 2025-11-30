// file: ClassListFirebase.dart (FINAL REFACTOR - PERBAIKAN)

import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';

class ClassListFirebase extends StatelessWidget {
  final List<KelasFirebaseModel> daftarKelas;
  final Function(KelasFirebaseModel) onKelasTap;
  final Function(String action, KelasFirebaseModel kelas)? onMenuAction;
  final bool isDosen;
  final Color roleColor;

  const ClassListFirebase({
    super.key,
    required this.daftarKelas,
    required this.onKelasTap,
    this.onMenuAction,
    this.isDosen = false,
    required this.roleColor,
  });

  // 1. KOLEKSI WARNA (GRADIENT) - Tetap menggunakan konstanta AppColor
  static final List<LinearGradient> _cardGradients = [
    const LinearGradient(
      colors: [AppColor.kAccentColor, AppColor.kDarkBlue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [AppColor.kLightPrimaryColor, AppColor.kPrimaryColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [AppColor.kLightSuccessColor, AppColor.kDarkSuccessColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [AppColor.kPurple, AppColor.kDarkPurple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [AppColor.kLightErrorColor, AppColor.kDarkErrorColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [AppColor.kTeal, AppColor.kDarkTeal],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [AppColor.kIndigo, AppColor.kDarkIndigo],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Tentukan warna latar belakang menu
    final Color menuBackgroundColor = isDosen
        ? AppColor.kLightPrimaryColor.withOpacity(0.95) // Orange Muda Dosen
        : AppColor.kBackgroundColorMhs.withOpacity(0.95); // Biru Muda Mahasiswa

    // Tentukan warna latar belakang kartu
    final Color cardBackgroundColor = isDosen
        ? AppColor.kLightPrimaryColor.withOpacity(0.1) // Lebih soft untuk dosen
        : AppColor.kLightAccentColor.withOpacity(0.1); // Lebih soft untuk mhs

    // Tentukan warna teks (Nama Kelas)
    final Color namaKelasColor = isDosen
        ? AppColor
              .kTextColor // Warna gelap untuk kontras di latar terang
        : AppColor.kDarkBlue; // Warna biru gelap untuk mhs

    // Tentukan warna teks (Kode Kelas)
    final Color kodeColor = isDosen
        ? AppColor.kTextSecondaryColor
        : AppColor.kSecondaryLightTextColor;

    // Tentukan warna ikon di footer dan teks jumlah mahasiswa
    final Color footerTextColor = isDosen
        ? AppColor.kTextSecondaryColor
        : AppColor.kSecondaryLightTextColor;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: daftarKelas.length,
      itemBuilder: (context, index) {
        final kelas = daftarKelas[index];

        // LOGIKA PENTING: Menghitung nilai unik nama untuk menentukan gradien warna.
        int nilaiUnikNama = kelas.namaKelas.codeUnits.fold(
          0,
          (hasil, huruf) => hasil + huruf,
        );

        // Modulus (%) supaya angkanya pas dengan jumlah pilihan warna
        int indexWarna = nilaiUnikNama % _cardGradients.length;

        // Pilih warna berdasarkan hasil hitungan di atas
        final gradient = _cardGradients[indexWarna];
        //

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 4,
          // Menggunakan warna latar belakang yang telah disesuaikan
          color: cardBackgroundColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => onKelasTap(kelas),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BAGIAN BANNER (Gradient)
                Stack(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(gradient: gradient),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: PopupMenuButton<String>(
                        // Mengatur warna latar belakang Popup Menu
                        color: menuBackgroundColor,
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColor
                              .kWhiteColor, // Ikon selalu putih di atas gradient
                        ),
                        onSelected: (value) {
                          if (onMenuAction != null) {
                            onMenuAction!(value, kelas);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          // List Menu Dasar (Salin Kode)
                          List<PopupMenuEntry<String>> menus = [
                            _buildPopupMenuItem(
                              value: 'Salin Kode',
                              icon: Icons.copy,
                              label: 'Salin Kode',
                              color: AppColor.kTextColor,
                            ),
                          ];

                          // Jika DOSEN, Tambah Menu Edit & Hapus (Logika tetap utuh)
                          if (isDosen) {
                            menus.addAll([
                              _buildPopupMenuItem(
                                value: 'Edit',
                                icon: Icons.edit,
                                label: 'Edit',
                                color: AppColor.kTextColor,
                              ),
                              _buildPopupMenuItem(
                                value: 'Hapus',
                                icon: Icons.delete,
                                label: 'Hapus',
                                color: AppColor.kErrorColor,
                              ),
                            ]);
                          }
                          // Jika MAHASISWA, Tambah Menu Keluar (Logika tetap utuh)
                          else {
                            menus.add(
                              _buildPopupMenuItem(
                                value: 'Keluar Kelas',
                                icon: Icons.exit_to_app,
                                label: 'Keluar',
                                color: AppColor.kErrorColor,
                              ),
                            );
                          }

                          return menus;
                        },
                      ),
                    ),
                  ],
                ),

                // INFO KELAS
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kelas.namaKelas,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: namaKelasColor, // Warna dinamis
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kode: ${kelas.kodeKelas}',
                        style: TextStyle(
                          fontSize: 14,
                          color: kodeColor, // Warna dinamis
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 24,
                  thickness: 0.5,
                  color: AppColor.kDividerColor,
                ),

                // FOOTER INFO
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 20,
                        color: footerTextColor, // Warna dinamis
                      ),
                      const SizedBox(width: 8),
                      Text(
                        // Menggunakan properti jumlahMahasiswa dari model
                        '${kelas.jumlahMahasiswa ?? 0} Mahasiswa',
                        style: TextStyle(
                          fontSize: 14,
                          color: footerTextColor, // Warna dinamis
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method untuk membuat PopupMenuItem agar kode lebih rapi
  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
