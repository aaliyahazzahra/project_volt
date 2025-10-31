import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  // Warna-warna yang sesuai dengan desain
  final Color kBackgroundColor = Color(0xFFFEF5E7); // Oranye sangat muda
  final Color kPrimaryColor = Color(0xFFE67E22); // Oranye (Disesuaikan)
  final Color kIconBgColor = Color(0xFFD6EAF8); // Biru muda
  final Color kIconColor = Color(0xFFE67E22); // Oranye (Sama dengan primary)
  final Color kTextColor = Color(0xFF34495E);
  final Color kTextSecondaryColor = Color(0xFF566573);

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,

      appBar: AppBar(
        title: Text(
          "Beranda",
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: kBackgroundColor,
      ),

      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: kIconBgColor,
              child: Icon(Icons.menu_book, size: 55, color: kIconColor),
            ),
            SizedBox(height: 24),

            Text(
              "Selamat Datang, Nama!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                "Anda belum bergabung di kelas mana pun. Minta kode kelas dari dosen Anda untuk memulai.",
                style: TextStyle(
                  fontSize: 16,
                  color: kTextSecondaryColor,
                  height: 1.4, // Jarak antar baris
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                print("Tombol Gabung Kelas ditekan!");
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Gabung Kelas"),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // Buat rounded
                ),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
