import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';

class SectionHeaderFirebase extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final Color roleColor;

  const SectionHeaderFirebase({
    super.key,
    required this.title,
    this.onSeeAll,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.kTextColor,
          ),
        ),

        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            child: Text(
              "Lihat Semua >",
              style: TextStyle(
                fontSize: 12,
                color: roleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
