import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/view/kelas/dosen/class_detail.dart';
import 'package:project_volt/view/kelas/dosen/create_class.dart';
import 'package:project_volt/widgets/class_list.dart';
import 'package:project_volt/widgets/emptystate.dart';

class HomepageDosen extends StatefulWidget {
  final UserModel user;
  const HomepageDosen({super.key, required this.user});

  @override
  State<HomepageDosen> createState() => _HomepageDosenState();
}

class _HomepageDosenState extends State<HomepageDosen> {
  List<KelasModel> _daftarKelas = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    if (widget.user.id == null) {
      if (mounted) {
        setState(() => _isLoading = false);
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

  // Fungsi untuk navigasi & refresh data
  void _navigateToBuatKelas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateClass(user: widget.user)),
    ).then((_) {
      // agar data baru tampil
      setState(() => _isLoading = true);
      _loadKelas();
    });
  }

  // Fungsi Untuk Navigasi Detail
  void _navigateToDetail(KelasModel kelas) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClassDetail(kelas: kelas)),
    );
    print("Buka detail untuk kelas ID: ${kelas.id}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Daftar Kelas Saya",
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _daftarKelas.isEmpty
          ? EmptyStateWidget(
              icon: Icons.menu_book,
              title: "Selamat Datang,\n${widget.user.namaLengkap}",
              message:
                  "Anda belum membuat kelas. Silakan buat kelas dengan menekan tombol (+).",
            )
          : ClassList(daftarKelas: _daftarKelas, onKelasTap: _navigateToDetail),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToBuatKelas,
        backgroundColor: AppColor.kPrimaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
