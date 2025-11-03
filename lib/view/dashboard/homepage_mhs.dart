import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/view/kelas/mahasiswa/class_detail_mhs.dart';
import 'package:project_volt/widgets/class_list.dart';
import 'package:project_volt/widgets/emptystate.dart';
// TODO: Buat halaman DetailKelasMahasiswa

class HomepageMhs extends StatefulWidget {
  final UserModel user;
  const HomepageMhs({super.key, required this.user});

  @override
  State<HomepageMhs> createState() => _HomepageMhsState();
}

class _HomepageMhsState extends State<HomepageMhs> {
  List<KelasModel> _daftarKelas = [];
  bool _isLoading = true;

  // untuk dialog "Gabung Kelas"
  final TextEditingController _kodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKelasGabungan();
  }

  @override
  void dispose() {
    _kodeController.dispose();
    super.dispose();
  }

  Future<void> _loadKelasGabungan() async {
    if (widget.user.id == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: User ID tidak ditemukan.")),
        );
      }
      return;
    }

    final data = await DbHelper.getKelasByMahasiswa(widget.user.id!);
    if (mounted) {
      setState(() {
        _daftarKelas = data;
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  // navigasi ke detail
  void _navigateToDetail(KelasModel kelas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassDetailMhs(kelas: kelas, user: widget.user),
      ),
    );

    print("Buka detail untuk kelas ID: ${kelas.id}");
  }

  // dialog gabung kelas
  Future<void> _showGabungKelasDialog() async {
    _kodeController.clear(); // agar bersih setiap dialog dibuka
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gabung Kelas Baru'),
          content: TextField(
            controller: _kodeController,
            decoration: InputDecoration(hintText: "Masukkan Kode Kelas"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Gabung'),
              onPressed: () async {
                if (widget.user.id == null) return;
                if (_kodeController.text.isEmpty) {
                  _showMessage('Kode kelas tidak boleh kosong', isError: true);
                  return;
                }

                // Panggil DB Helper
                final String hasil = await DbHelper.joinKelas(
                  widget.user.id!,
                  _kodeController.text,
                );
                if (!mounted) return;

                // Tampilkan hasil
                _showMessage(hasil, isError: hasil.startsWith("Error:"));
                Navigator.of(context).pop(); // Tutup dialog
                // Jika sukses, refresh daftar kelas
                if (hasil.startsWith("Sukses:")) {
                  setState(() => _isLoading = true);
                  _loadKelasGabungan();
                }
              },
            ),
          ],
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
          "Ruang Kelas",
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
              icon: Icons.school_outlined,
              title: "Selamat Datang,\n${widget.user.namaLengkap}",
              message:
                  "Anda belum bergabung dengan kelas manapun. Silakan gabung kelas dengan menekan tombol (+).",
            )
          : ClassList(daftarKelas: _daftarKelas, onKelasTap: _navigateToDetail),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGabungKelasDialog, // <-- Memanggil dialog
        backgroundColor: AppColor.kPrimaryColor,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Gabung Kelas Baru',
      ),
    );
  }
}
