import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/common_widgets/emptystate.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/database/db_helper.dart';
import 'package:project_volt/data/models/kelas_model.dart';
import 'package:project_volt/data/models/user_model.dart';
import 'package:project_volt/features/4_kelas/view/class_detail_page.dart';
import 'package:project_volt/features/4_kelas/widgets/class_list.dart';
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

        final snackBarContent = AwesomeSnackbarContent(
          title: "Error",
          message: "User ID tidak ditemukan.",
          contentType: ContentType.warning,
        );

        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: snackBarContent,
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
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
        final mainMessenger = ScaffoldMessenger.of(context);

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

                // Jika kode kosong
                if (_kodeController.text.isEmpty) {
                  final snackBarContent = AwesomeSnackbarContent(
                    title: "Peringatan",
                    message: "Kode kelas tidak boleh kosong",
                    contentType: ContentType.warning,
                  );
                  final snackBar = SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: snackBarContent,
                  );

                  mainMessenger
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                  return;
                }

                // Panggil DB Helper
                final String hasil = await DbHelper.joinKelas(
                  widget.user.id!,
                  _kodeController.text,
                );
                if (!mounted) return;

                // Tutup dialog
                Navigator.of(context).pop();

                // Siapkan konten snackbar
                AwesomeSnackbarContent snackBarContent;

                if (hasil.startsWith("Sukses:")) {
                  // Jika berhasil
                  snackBarContent = AwesomeSnackbarContent(
                    title: "Berhasil!",
                    message: hasil,
                    contentType: ContentType.success,
                  );

                  // Refresh list HANYA jika sukses
                  setState(() => _isLoading = true);
                  _loadData();
                } else {
                  // Kode salah / Sudah gabung
                  snackBarContent = AwesomeSnackbarContent(
                    title: "Gagal Bergabung",

                    message: hasil,
                    contentType: ContentType.failure,
                  );
                }

                // Buat SnackBar
                final snackBar = SnackBar(
                  elevation: 0,
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  content: snackBarContent,
                );

                mainMessenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              },
            ),
          ],
        );
      },
    );
  }

  void _showProfileWarning() {
    final snackBarContent = AwesomeSnackbarContent(
      title: "Peringatan",
      message: "Harap lengkapi menu Profil.",
      contentType: ContentType.warning,
    );

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: snackBarContent,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
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
        backgroundColor: _isProfileComplete
            ? AppColor.kPrimaryColor
            : Colors.grey,
        tooltip: 'Gabung Kelas Baru',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
