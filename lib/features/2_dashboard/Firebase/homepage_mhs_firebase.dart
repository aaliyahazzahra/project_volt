// file: HomepageMhsFirebase.dart
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_volt/core/constants/app_color.dart';

//  Import Service Manajemen Pengguna Firebase
import 'package:project_volt/data/firebase/service/user_management_firebase_service.dart';

//  Import Model Firebase
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

//  Import Widget Firebase
import 'package:project_volt/features/4_kelas/view/Firebase/class_detail_firebase_page.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/class_list_firebase.dart';
import 'package:project_volt/widgets/dialogs/confirmation_dialog_helper.dart';
import 'package:project_volt/widgets/emptystate.dart';

//  UBAH NAMA CLASS & ARGUMENT MODEL: HomepageMhs -> HomepageMhsFirebase
class HomepageMhsFirebase extends StatefulWidget {
  final UserFirebaseModel user; //  GANTI: UserModel -> UserFirebaseModel
  const HomepageMhsFirebase({super.key, required this.user});

  @override
  State<HomepageMhsFirebase> createState() => _HomepageMhsFirebaseState();
}

class _HomepageMhsFirebaseState extends State<HomepageMhsFirebase> {
  //  INISIASI SERVICE FIREBASE
  final UserManagementFirebaseService _userManagementService =
      UserManagementFirebaseService();

  List<KelasFirebaseModel> _daftarKelas = []; //  UBAH TIPE LIST
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
    final String? userUid = widget.user.uid;

    // 1. Cek User ID
    if (userUid == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackbar("User ID tidak ditemukan.", ContentType.warning);
      }
      return;
    }

    // 2.  Cek Kelengkapan Profil dari Model Sesi (nimNidn dan namaKampus sudah ada di user object)
    bool profileComplete =
        widget.user.nimNidn?.isNotEmpty == true &&
        widget.user.namaKampus?.isNotEmpty == true;

    // 3.  Ambil Data Kelas yang Diikuti dari Firebase Service
    try {
      final dataKelas = await _userManagementService.getKelasByMahasiswa(
        userUid,
      );

      if (mounted) {
        setState(() {
          _daftarKelas = dataKelas;
          _isProfileComplete = profileComplete;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackbar("Gagal memuat data kelas: $e", ContentType.failure);
      }
    }
  }

  // Helper untuk menampilkan Awesome Snackbar
  void _showSnackbar(String message, ContentType type) {
    final snackBarContent = AwesomeSnackbarContent(
      title: type == ContentType.success ? "Sukses" : "Peringatan",
      message: message.replaceAll('Error: ', '').replaceAll('Exception: ', ''),
      contentType: type,
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

  //  UBAH TIPE MODEL: KelasModel -> KelasFirebaseModel
  void _navigateToDetail(KelasFirebaseModel kelas) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        //  GANTI: Panggil ClassDetailPage versi Firebase
        builder: (context) =>
            ClassDetailFirebasePage(kelas: kelas, user: widget.user),
      ),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);
      _loadData(); // Refresh setelah kembali
    }
  }

  //  UBAH TIPE MODEL: KelasModel -> KelasFirebaseModel
  void _handleMenuAction(String action, KelasFirebaseModel kelas) {
    if (action == 'Salin Kode') {
      Clipboard.setData(ClipboardData(text: kelas.kodeKelas));
      _showSnackbar("Kode kelas disalin", ContentType.success);
    } else if (action == 'Keluar Kelas') {
      _showExitClassDialog(kelas);
    }
  }

  Future<void> _showGabungKelasDialog() async {
    _kodeController.clear();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Gabung Kelas Baru'),
          content: TextField(
            controller: _kodeController,
            decoration: const InputDecoration(hintText: "Masukkan Kode Kelas"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(color: AppColor.kAccentColor), // Sudah benar
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Gabung',
                style: TextStyle(color: AppColor.kAccentColor), // Sudah benar
              ),
              onPressed: () async {
                final String? userUid = widget.user.uid;
                if (userUid == null) return;

                if (_kodeController.text.isEmpty) {
                  _showSnackbar(
                    "Kode kelas tidak boleh kosong",
                    ContentType.warning,
                  );
                  return;
                }

                try {
                  //  PANGGIL SERVICE FIREBASE: joinKelas
                  final String hasil = await _userManagementService.joinKelas(
                    userUid,
                    _kodeController.text.trim(),
                  );

                  if (!mounted) return;
                  Navigator.of(context).pop(); // Tutup dialog

                  if (hasil.startsWith("Sukses:")) {
                    _showSnackbar(
                      "Berhasil bergabung dengan kelas!",
                      ContentType.success,
                    );
                    setState(() => _isLoading = true);
                    _loadData(); // Refresh daftar kelas
                  } else {
                    _showSnackbar(hasil, ContentType.failure);
                  }
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  _showSnackbar("Terjadi kesalahan: $e", ContentType.failure);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showExitClassDialog(KelasFirebaseModel kelas) async {
    final bool? confirm = await showConfirmationDialog(
      context: context,
      title: 'Keluar Kelas',
      content:
          'Apakah Anda yakin ingin keluar dari kelas "${kelas.namaKelas}"?',
      confirmText: 'Keluar',
      confirmColor: AppColor.kErrorColor, //perubahan: Mengganti Colors.red
    );

    // Jika pengguna menekan 'Keluar' (confirm == true)
    if (confirm == true) {
      final String? userUid = widget.user.uid;
      final String? kelasId = kelas.kelasId;
      if (userUid == null || kelasId == null) return;

      try {
        // 🔥 PANGGIL SERVICE FIREBASE: leaveKelas
        await _userManagementService.leaveKelas(userUid, kelasId);

        if (mounted) {
          _showSnackbar("Anda berhasil keluar dari kelas", ContentType.success);
          // Tetap refresh data setelah sukses
          setState(() => _isLoading = true);
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          // Tampilkan snackbar error
          _showSnackbar("Gagal keluar kelas: $e", ContentType.failure);
        }
      }
    }
  }

  void _showProfileWarning() {
    _showSnackbar(
      "Harap lengkapi Profil (NIM dan Kampus) sebelum bergabung.",
      ContentType.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: const Text(
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
              child: CircularProgressIndicator(
                color: AppColor.kAccentColor,
              ), // Sudah benar
            )
          : _daftarKelas.isEmpty
          ? EmptyStateWidget(
              icon: Icons.school_outlined,
              title: "Selamat Datang,\n${widget.user.namaLengkap}",
              iconColor: AppColor.kAccentColor, // Sudah benar
              message:
                  "Anda belum bergabung dengan kelas manapun. Silakan gabung kelas dengan menekan tombol (+).",
            )
          : ClassListFirebase(
              //  Menggunakan ClassListFirebase
              daftarKelas: _daftarKelas,
              onKelasTap: _navigateToDetail,
              isDosen: false,
              onMenuAction: _handleMenuAction,
              roleColor: AppColor.kAccentColor, // Sudah benar
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProfileComplete
            ? _showGabungKelasDialog
            : _showProfileWarning,
        backgroundColor: _isProfileComplete
            ? AppColor
                  .kAccentColor // Sudah benar
            : AppColor.kDisabledColor,
        tooltip: 'Gabung Kelas Baru',
        child: const Icon(
          Icons.add,
          color: AppColor.kWhiteColor,
        ), // Sudah benar
      ),
    );
  }
}
