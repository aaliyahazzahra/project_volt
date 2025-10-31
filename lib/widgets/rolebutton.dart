import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/model/user_model.dart';

class RoleButton extends StatelessWidget {
  const RoleButton({
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
        ? AppColor.colorMahasiswa
        : AppColor.colorDosen;

    return isSelected
        ? ElevatedButton.icon(
            // Style Tanda Terpilih
            icon: Icon(icon, color: Colors.grey[700]),
            label: Text(text),
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedColor,
              foregroundColor: const Color.fromARGB(
                255,
                255,
                227,
                227,
              ), // Teks jadi gelap
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : OutlinedButton.icon(
            // Style Tanda Tidak Terpilih
            icon: Icon(icon),
            label: Text(text),
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[700],
              minimumSize: Size(double.infinity, 50),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
  }
}
