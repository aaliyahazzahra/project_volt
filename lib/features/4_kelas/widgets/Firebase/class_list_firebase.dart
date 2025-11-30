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

  // Card Gradient Collection
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
    // Dynamic menu background color based on role
    final Color menuBackgroundColor = isDosen
        ? AppColor
              .kLightPrimaryColor // Solid Light Orange (Dosen)
        : AppColor.kLightAccentColor; // Solid Light Blue (Mahasiswa)

    // Dynamic card background color based on role
    final Color cardBackgroundColor = isDosen
        ? AppColor
              .kBackgroundColor // Beige/Krem (Dosen)
        : AppColor.kBackgroundColorMhs; // Light Blue (Mahasiswa)

    // Text colors for contrast
    final Color classNameColor = AppColor.kTextColor;
    final Color classCodeColor = AppColor.kTextSecondaryColor;
    final Color footerTextColor = AppColor.kTextSecondaryColor;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: daftarKelas.length,
      itemBuilder: (context, index) {
        final kelas = daftarKelas[index];

        // IMPORTANT LOGIC: Calculate a unique hash based on the class name to determine gradient color.
        int uniqueNameValue = kelas.namaKelas.codeUnits.fold(
          0,
          (result, unit) => result + unit,
        );

        // Modulus to cycle through the gradient options
        int gradientIndex = uniqueNameValue % _cardGradients.length;

        final gradient = _cardGradients[gradientIndex];

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 4,
          color: cardBackgroundColor, // Dynamic card background color
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => onKelasTap(kelas),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GRADIENT BANNER SECTION
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
                        color:
                            menuBackgroundColor, // Solid menu background color
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
                          // Base Menu: Copy Code
                          List<PopupMenuEntry<String>> menus = [
                            _buildPopupMenuItem(
                              value: 'Salin Kode',
                              icon: Icons.copy,
                              label: 'Copy Code',
                              color: AppColor
                                  .kTextColor, // Dark text/icon for contrast
                            ),
                          ];

                          // If DOSEN, Add Edit & Delete Menu
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
                                label: 'Delete',
                                color: AppColor.kErrorColor,
                              ),
                            ]);
                          }
                          // If MAHASISWA (Student), Add Leave Class Menu
                          else {
                            menus.add(
                              _buildPopupMenuItem(
                                value: 'Keluar Kelas',
                                icon: Icons.exit_to_app,
                                label: 'Leave Class',
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

                // CLASS INFO SECTION
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
                          color: classNameColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${kelas.kodeKelas}',
                        style: TextStyle(
                          fontSize: 14,
                          color: classCodeColor,
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

                // // FOOTER INFO (Member Count)
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                //   child: Row(
                //     children: [
                //       Icon(
                //         Icons.people_outline,
                //         size: 20,
                //         color: footerTextColor, // Dynamic color
                //       ),
                //       const SizedBox(width: 8),
                //       Text(
                //         // Use jumlahMahasiswa property from the model
                //         '${kelas.jumlahMahasiswa ?? 0} Students',
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: footerTextColor, // Dynamic color
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to build PopupMenuItem for cleaner code
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
