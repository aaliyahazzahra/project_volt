import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/models/user_model.dart';

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
        ? AppColor.kAccentColor
        : AppColor.kPrimaryColor;

    return isSelected
        ? ElevatedButton.icon(
            icon: Icon(icon, color: AppColor.kTextColor),
            label: Text(text),
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedColor,
              foregroundColor: AppColor.kLightTextColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : OutlinedButton.icon(
            icon: Icon(icon),
            label: Text(text),
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColor.kWhiteColor,
              foregroundColor: AppColor.kTextColor,
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: AppColor.kDividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
  }
}
