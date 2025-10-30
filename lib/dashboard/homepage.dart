import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/kelas/dashboard_kelas.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,

      appBar: AppBar(
        title: Text(
          "Beranda",
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
      ),

      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: AppColor.kIconBgColor,
              child: Icon(
                Icons.menu_book,
                size: 55,
                color: AppColor.kPrimaryColor,
              ),
            ),
            SizedBox(height: 24),

            Text(
              "Selamat Datang, Nama!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.kTextColor,
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
                  color: AppColor.kTextSecondaryColor,
                  height: 1.4, // Jarak antar baris
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardKelas()),
                );
                print("Tombol Gabung Kelas ditekan!");
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Gabung Kelas"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.kPrimaryColor,
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
