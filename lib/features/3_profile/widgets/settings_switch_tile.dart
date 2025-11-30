import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color roleColor;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,

      activeThumbColor: roleColor,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),

      // Ikon
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: roleColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),

        child: Icon(icon, color: roleColor, size: 20),
      ),

      // Judul
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColor.kTextColor,
        ),
      ),
    );
  }
}
