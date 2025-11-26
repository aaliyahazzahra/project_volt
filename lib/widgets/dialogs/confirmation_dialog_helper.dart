import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmText,
  Color confirmColor = AppColor.kPrimaryColor,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Batal', style: TextStyle(color: AppColor.kTextColor)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText, style: TextStyle(color: confirmColor)),
        ),
      ],
    ),
  );
}
