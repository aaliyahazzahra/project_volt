import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';

class GantiPasswordPage extends StatelessWidget {
  const GantiPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Ganti Password",
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
        elevation: 0,
      ),
      body: Center(child: Text("Halaman Ganti Password (Belum dibuat)")),
    );
  }
}
