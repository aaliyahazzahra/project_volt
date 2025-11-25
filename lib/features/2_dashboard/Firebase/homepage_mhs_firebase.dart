import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/SQF/models/kelas_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/kelas_data_source.dart';
import 'package:project_volt/features/4_kelas/view/class_detail_page.dart';
import 'package:project_volt/features/4_kelas/widgets/class_list.dart';
import 'package:project_volt/widgets/emptystate.dart';

// TODO: Buat halaman DetailKelasMahasiswa

class HomepageMhsFirebase extends StatefulWidget {
  final UserFirebaseModel user;
  const HomepageMhsFirebase({super.key, required this.user});

  @override
  State<HomepageMhsFirebase> createState() => _HomepageMhsFirebaseState();
}

class _HomepageMhsFirebaseState extends State<HomepageMhsFirebase> {
  final KelasDataSource _kelasDataSource = KelasDataSource();

  List<KelasModel> _daftarKelas = [];
  bool _isLoading = true;
  bool _isProfileComplete = false;

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

    final dataKelas = await _kelasDataSource.getKelasByMahasiswa(
      widget.user.id!,
    );
    final dataProfil = await _kelasDataSource.getMahasiswaProfile(
      widget.user.id!,
    );

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

  void _handleMenuAction(String action, KelasModel kelas) {
    if (action == 'Salin Kode') {
      Clipboard.setData(ClipboardData(text: kelas.kodeKelas));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kode kelas disalin"),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    } else if (action == 'Keluar Kelas') {
      _showExitClassDialog(kelas);
    }
  }

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
              child: Text(
                'Batal',
                style: TextStyle(color: AppColor.kAccentColor),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Gabung',
                style: TextStyle(color: AppColor.kAccentColor),
              ),
              onPressed: () async {
                if (widget.user.id == null) return;

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

                final String hasil = await _kelasDataSource.joinKelas(
                  widget.user.id!,
                  _kodeController.text,
                );
                if (!mounted) return;

                Navigator.of(context).pop();

                AwesomeSnackbarContent snackBarContent;

                if (hasil.startsWith("Sukses:")) {
                  snackBarContent = AwesomeSnackbarContent(
                    title: "Berhasil!",
                    message: hasil,
                    contentType: ContentType.success,
                  );

                  setState(() => _isLoading = true);
                  _loadData();
                } else {
                  snackBarContent = AwesomeSnackbarContent(
                    title: "Gagal Bergabung",
                    message: hasil,
                    contentType: ContentType.failure,
                  );
                }

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

  Future<void> _showExitClassDialog(KelasModel kelas) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Keluar Kelas'),
          content: Text(
            'Apakah Anda yakin ingin keluar dari kelas "${kelas.namaKelas}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();

                if (widget.user.id == null || kelas.id == null) return;

                try {
                  final deletedRows = await _kelasDataSource.leaveKelas(
                    widget.user.id!,
                    kelas.id!,
                  );

                  if (mounted) {
                    final snackBarContent = AwesomeSnackbarContent(
                      title: "Sukses",
                      message: deletedRows > 0
                          ? "Anda berhasil keluar dari kelas"
                          : "Gagal keluar kelas. Data tidak ditemukan.",
                      contentType: ContentType.success,
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: snackBarContent,
                        ),
                      );

                    setState(() => _isLoading = true);
                    _loadData();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal keluar kelas: $e")),
                    );
                  }
                }
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
          ? Center(
              child: CircularProgressIndicator(color: AppColor.kAccentColor),
            )
          : _daftarKelas.isEmpty
          ? EmptyStateWidget(
              icon: Icons.school_outlined,
              title: "Selamat Datang,\n${widget.user.namaLengkap}",
              iconColor: AppColor.kAccentColor,
              message:
                  "Anda belum bergabung dengan kelas manapun. Silakan gabung kelas dengan menekan tombol (+).",
            )
          : ClassList(
              daftarKelas: _daftarKelas,
              onKelasTap: _navigateToDetail,
              isDosen: false,
              onMenuAction: _handleMenuAction,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProfileComplete
            ? _showGabungKelasDialog
            : _showProfileWarning,
        backgroundColor: _isProfileComplete
            ? AppColor.kAccentColor
            : AppColor.kDisabledColor,
        tooltip: 'Gabung Kelas Baru',
        child: Icon(Icons.add, color: AppColor.kWhiteColor),
      ),
    );
  }
}
