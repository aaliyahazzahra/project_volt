import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_image.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/user_management_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/class_detail_firebase_page.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/class_list_firebase.dart';
import 'package:project_volt/widgets/dialogs/confirmation_dialog_helper.dart';
import 'package:project_volt/widgets/emptystate.dart';

class HomepageMhsFirebase extends StatefulWidget {
  final UserFirebaseModel user;
  const HomepageMhsFirebase({super.key, required this.user});

  @override
  State<HomepageMhsFirebase> createState() => _HomepageMhsFirebaseState();
}

class _HomepageMhsFirebaseState extends State<HomepageMhsFirebase> {
  final UserManagementFirebaseService _userManagementService =
      UserManagementFirebaseService();

  List<KelasFirebaseModel> _daftarKelas = [];
  bool _isLoading = true;

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
    final String userUid = widget.user.uid;

    try {
      final dataKelas = await _userManagementService.getKelasByMahasiswa(
        userUid,
      );

      if (mounted) {
        setState(() {
          _daftarKelas = dataKelas;
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

  void _navigateToDetail(KelasFirebaseModel kelas) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ClassDetailFirebasePage(kelas: kelas, user: widget.user),
      ),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);
      _loadData(); // Refresh setelah kembali
    }
  }

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
          backgroundColor: AppColor.kLightAccentColor,

          title: const Text(
            'Gabung Kelas Baru',
            style: TextStyle(
              color: AppColor.kTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _kodeController,
            decoration: InputDecoration(
              hintText: "Masukkan Kode Kelas",
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColor.kAccentColor,
                  width: 2.0,
                ),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColor.kDividerColor),
              ),
              hintStyle: const TextStyle(color: AppColor.kTextSecondaryColor),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(
                  color: AppColor.kAccentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Gabung',
                style: TextStyle(
                  color: AppColor.kAccentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                final String userUid = widget.user.uid;

                if (_kodeController.text.isEmpty) {
                  _showSnackbar(
                    "Kode kelas tidak boleh kosong",
                    ContentType.warning,
                  );
                  return;
                }

                try {
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
      confirmColor: AppColor.kErrorColor,
    );

    // Jika pengguna menekan 'Keluar' (confirm == true)
    if (confirm == true) {
      final String userUid = widget.user.uid;
      final String? kelasId = kelas.kelasId;
      if (kelasId == null) return;

      try {
        await _userManagementService.leaveKelas(userUid, kelasId);

        if (mounted) {
          _showSnackbar("Anda berhasil keluar dari kelas", ContentType.success);
          setState(() => _isLoading = true);
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          _showSnackbar("Gagal keluar kelas: $e", ContentType.failure);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColorMhs,
      appBar: AppBar(
        title: const Text(
          "Ruang Kelas",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kAccentColor,
        foregroundColor: AppColor.kWhiteColor,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColor.kAccentColor),
            )
          : _daftarKelas.isEmpty
          ? EmptyStateWidget(
              imagePath: AppImages.kelasmhs,
              title: "Selamat Datang,\n${widget.user.namaLengkap}",
              message:
                  "Anda belum bergabung dengan kelas manapun. Silakan gabung kelas dengan menekan tombol (+).",
            )
          : ClassListFirebase(
              daftarKelas: _daftarKelas,
              onKelasTap: _navigateToDetail,
              isDosen: false,
              onMenuAction: _handleMenuAction,
              roleColor: AppColor.kAccentColor,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGabungKelasDialog,
        backgroundColor: AppColor.kAccentColor,
        tooltip: 'Gabung Kelas Baru',
        child: const Icon(Icons.add, color: AppColor.kWhiteColor),
      ),
    );
  }
}
