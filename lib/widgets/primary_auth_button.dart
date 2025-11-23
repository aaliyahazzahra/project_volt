import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';

class PrimaryAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final bool isLoading;

  const PrimaryAuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = backgroundColor ?? AppColor.kAccentColor;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColor.kWhiteColor,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColor.kWhiteColor,
                strokeWidth: 3,
              ),
            )
          : Text(
              text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
