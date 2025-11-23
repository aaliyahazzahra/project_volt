import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';

class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isLocked;

  const BadgeIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isLocked ? AppColor.kDisabledColor : color;
    final Color backgroundColor = isLocked
        ? AppColor.kDividerColor
        : color.withOpacity(0.1);
    final Color textColor = isLocked
        ? AppColor.kDisabledColor
        : AppColor.kTextColor;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 32, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
