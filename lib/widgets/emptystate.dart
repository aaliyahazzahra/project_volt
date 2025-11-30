import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';

class EmptyStateWidget extends StatelessWidget {
  // final IconData icon;
  final String title;
  final String message;
  // final Color? iconColor;
  final String imagePath;

  const EmptyStateWidget({
    super.key,
    // required this.icon,
    required this.title,
    required this.message,
    // this.iconColor,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // CircleAvatar(
            //   radius: 55,
            //   backgroundColor: AppColor.kIconBgColor,
            //   child: Icon(
            //     icon,
            //     size: 55,
            //     // color: iconColor ?? AppColor.kPrimaryColor,
            //   ),
            // ),
            Image.asset(imagePath, height: 350),
            // SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.kTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            // SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.kTextSecondaryColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
