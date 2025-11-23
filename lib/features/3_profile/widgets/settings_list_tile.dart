import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';

class SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color roleColor;

  const SettingsListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,

      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: roleColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: roleColor, size: 20),
      ),

      // Title
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColor.kTextColor,
        ),
      ),

      // Trailing Icon
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColor.kDisabledColor,
        size: 20,
      ),
    );
  }
}
