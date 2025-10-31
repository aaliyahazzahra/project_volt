import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/view/kelas/dosen/buat_kelas.dart';

// TODO: Buat halaman DetailKelasPage

class HomepageDosen extends StatefulWidget {
  final UserModel user;
  const HomepageDosen({super.key, required this.user});

  @override
  State<HomepageDosen> createState() => _HomepageDosenState();
}

class _HomepageDosenState extends State<HomepageDosen> {
  List<Map<String, dynamic>> _daftarKelas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  // Fungsi untuk mengambil data kelas dari DB
  Future<void> _loadKelas() async {
    if (widget.user.id == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: User ID tidak ditemukan.")),
        );
      }
      return;
    }

    final data = await DbHelper.getKelasByDosen(widget.user.id!);
    if (mounted) {
      setState(() {
        _daftarKelas = data;
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk navigasi Drefresh data
  void _navigateToBuatKelas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BuatKelas(user: widget.user)),
    ).then((_) {
      // Muat ulang daftar kelas agar data baru tampil
      setState(() {
        _isLoading = true; // Tampilkan loading indicator
      });
      _loadKelas();
    });
  }

  Widget _buildEmptyState() {
    return SizedBox(
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
            "Selamat Datang,\n${widget.user.email}",
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
              "Anda belum membuat kelas. Silakan buat kelas dengan menekan tombol (+), lalu bagikan kode kepada mahasiswa Anda untuk memulai.",
              style: TextStyle(
                fontSize: 16,
                color: AppColor.kTextSecondaryColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk tampilan "ADA DATA" (ListView)
  Widget _buildKelasList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _daftarKelas.length,
      itemBuilder: (context, index) {
        final kelas = _daftarKelas[index];
        final namaKelas = kelas['nama_kelas'] ?? 'Tanpa Judul';

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColor.kPrimaryColor,
              child: Text(
                namaKelas[0].toUpperCase(), // Ambil huruf pertama
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              namaKelas,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Kode Kelas: ${kelas['kode_kelas']}"),
            onTap: () {
              // 8. Navigasi ke halaman detail kelas
              // TODO: Buat halaman DetailKelasPage
              // Halaman ini mungkin akan berisi BottomNavKelas
              /*
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailKelasPage(
                    kelasId: kelas['id'],
                    namaKelas: namaKelas,
                  ),
                ),
              );
              */
              print("Buka detail untuk kelas ID: ${kelas['id']}");
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Daftar Kelas Saya", // Judul diganti
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
      ),
      // 9. Logika Tampilan Body
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _daftarKelas.isEmpty
          ? _buildEmptyState() // Tampilkan pesan kosong
          : _buildKelasList(), // Tampilkan daftar kelas
      // 10. FAB sekarang memanggil fungsi navigasi
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToBuatKelas,
        backgroundColor: AppColor.kPrimaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
