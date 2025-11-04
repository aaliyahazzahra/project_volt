import 'package:flutter/material.dart';

class Simulasi extends StatelessWidget {
  // Warna-warna yang sesuai dengan desain
  final Color kBackgroundColor = Color(0xFFFEF5E7); // Oranye sangat muda
  final Color kPrimaryColor = Color(0xFFE67E22); // Oranye (Disesuaikan)
  final Color kIconBgColor = Color(0xFFD6EAF8); // Biru muda
  final Color kIconColor = Color(0xFFE67E22); // Oranye (Sama dengan primary)
  final Color kTextColor = Color(0xFF34495E);
  final Color kTextSecondaryColor = Color(0xFF566573);

  Simulasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,

      appBar: AppBar(
        title: Text(
          "SIMULASI",
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: kBackgroundColor,
      ),
    );
  }
}
