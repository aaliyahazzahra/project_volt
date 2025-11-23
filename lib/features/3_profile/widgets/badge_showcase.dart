import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/features/3_profile/widgets/badge_icon.dart';

class BadgeShowcase extends StatelessWidget {
  const BadgeShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.kBlackColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BadgeIcon(
            icon: Icons.emoji_events,
            color: AppColor.kBadgeGold,
            label: "Ahli Listrik",
          ),

          BadgeIcon(
            icon: Icons.bolt,
            color: AppColor.kBadgeSilver,
            label: "Tegangan Tinggi",
          ),

          BadgeIcon(
            icon: Icons.lock,
            color: AppColor.kDisabledColor,
            label: "Terkunci",
            isLocked: true,
          ),
        ],
      ),
    );
  }
}
