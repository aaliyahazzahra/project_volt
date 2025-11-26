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

  // 1. KOLEKSI WARNA (GRADIENT)
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
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: daftarKelas.length,
      itemBuilder: (context, index) {
        final kelas = daftarKelas[index];

        // menjumlahkan kode ASCII setiap huruf di nama kelas.
        int nilaiUnikNama = kelas.namaKelas.codeUnits.fold(
          0,
          (hasil, huruf) => hasil + huruf,
        );

        // Modulus (%) supaya angkanya pas dengan jumlah pilihan warna kita
        int indexWarna = nilaiUnikNama % _cardGradients.length;

        // Pilih warna berdasarkan hasil hitungan di atas
        final gradient = _cardGradients[indexWarna];

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 4,
          color: AppColor.kBackgroundColor,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => onKelasTap(kelas),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BAGIAN BANNER
                Stack(
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(gradient: gradient),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColor.kWhiteColor,
                        ),
                        onSelected: (value) {
                          if (onMenuAction != null) {
                            onMenuAction!(value, kelas);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          // List Menu Dasar
                          List<PopupMenuEntry<String>> menus = [
                            const PopupMenuItem(
                              value: 'Salin Kode',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.copy,
                                    size: 20,
                                    color: AppColor.kTextColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Salin Kode'),
                                ],
                              ),
                            ),
                          ];

                          // Jika DOSEN, Tambah Menu Edit & Hapus
                          if (isDosen) {
                            menus.addAll([
                              const PopupMenuItem(
                                value: 'Edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: AppColor.kTextColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'Hapus',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: AppColor.kErrorColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Hapus',
                                      style: TextStyle(
                                        color: AppColor.kErrorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                          }
                          // Jika MAHASISWA, Tambah Menu Keluar (Opsional)
                          else {
                            menus.add(
                              const PopupMenuItem(
                                value: 'Keluar Kelas',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.exit_to_app,
                                      size: 20,
                                      color: AppColor.kErrorColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Keluar',
                                      style: TextStyle(
                                        color: AppColor.kErrorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return menus;
                        },
                      ),
                    ),
                  ],
                ),

                //INFO KELAS
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kelas.namaKelas,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.kTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kode: ${kelas.kodeKelas}",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColor.kTextSecondaryColor,
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
                        color: AppColor.kTextSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "30 Mahasiswa", // dummy
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColor.kTextColor,
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
}
