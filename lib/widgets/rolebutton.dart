import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart'; // Pastikan ini diimpor

class RoleButtonfirebase extends StatelessWidget {
  const RoleButtonfirebase({
    super.key,
    required this.text,
    required this.icon,
    required this.role,
    required this.isSelected,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final UserRole role;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = (role == UserRole.mahasiswa)
        ? AppColor.kAccentColor
        : AppColor.kPrimaryColor;

    // Tentukan warna teks berdasarkan status terpilih
    final Color textColor = isSelected
        ? AppColor.kLightTextColor
        : AppColor.kTextColor;

    // Konten utama tombol (Icon di atas Text)
    final Widget buttonContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize:
          MainAxisSize.min, // Penting agar kolom tidak memakan ruang berlebihan
      children: [
        Icon(
          icon,
          // Warna ikon mengikuti textColor
          color: textColor,
          size: 24, // Ukuran ikon standar
        ),
        const SizedBox(height: 4),
        // --- PERBAIKAN: GUNAKAN FITTEDBOX DI SINI ---
        FittedBox(
          fit: BoxFit.scaleDown, // Skala teks ke bawah jika ruang sempit
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1, // Memastikan teks selalu satu baris
            style: TextStyle(
              // Warna teks mengikuti textColor
              color: textColor,
              fontSize:
                  14, // Ukuran font default yang sedikit lebih kecil mungkin membantu
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // ---------------------------------------------
      ],
    );

    return isSelected
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedColor,
              // foregroundColor tidak diperlukan karena warna teks diatur di buttonContent
              minimumSize: const Size(
                double.infinity,
                70,
              ), // Naikkan minimumSize karena kita pakai Column
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ), // Padding internal
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: buttonContent, // Masukkan konten yang sudah diperbaiki
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColor.kWhiteColor,
              // foregroundColor tidak diperlukan
              minimumSize: const Size(
                double.infinity,
                70,
              ), // Naikkan minimumSize
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ), // Padding internal
              side: const BorderSide(color: AppColor.kDividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: buttonContent, // Masukkan konten yang sudah diperbaiki
          );
  }
}
