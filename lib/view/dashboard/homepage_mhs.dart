import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/view/kelas/class_detail_page.dart';
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
  bool _isProfileComplete = false;

  // untuk dialog "Gabung Kelas"
  final TextEditingController _kodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _kodeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.user.id == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: User ID tidak ditemukan.")),
        );
      }
      return;
    }

    final dataKelas = await DbHelper.getKelasByMahasiswa(widget.user.id!);
    final dataProfil = await DbHelper.getMahasiswaProfile(widget.user.id!);
    bool profileComplete =
        dataProfil != null &&
        (dataProfil['nim'] != null && dataProfil['nim'].isNotEmpty) &&
        (dataProfil['nama_kampus'] != null &&
            dataProfil['nama_kampus'].isNotEmpty);

    if (mounted) {
      setState(() {
        _daftarKelas = dataKelas;
        _isProfileComplete = profileComplete;
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
  void _navigateToDetail(KelasModel kelas) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassDetailPage(kelas: kelas, user: widget.user),
      ),
    );

    if (result == true && mounted) {
      _loadData();
    }

    print("Buka detail untuk kelas ID: ${kelas.id}");
  }

  // dialog gabung kelas
  Future<void> _showGabungKelasDialog() async {
    _kodeController.clear();
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
                Navigator.of(context).pop();

                if (hasil.startsWith("Sukses:")) {
                  setState(() => _isLoading = true);
                  _loadData();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showProfileWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Harap lengkapi NIM dan Kampus Anda di menu Profil.'),
        backgroundColor: Colors.orange[700],
      ),
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
            color: AppColor.kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kAppBar,
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
        onPressed: _isProfileComplete
            ? _showGabungKelasDialog
            : _showProfileWarning,
        backgroundColor: AppColor.kPrimaryColor,
        tooltip: 'Gabung Kelas Baru',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
