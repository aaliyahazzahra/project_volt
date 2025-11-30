import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_image.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/kelas_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/class_detail_firebase_page.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/create_class_firebase_page.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/edit_class_firebase_page.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/class_list_firebase.dart';
import 'package:project_volt/widgets/emptystate.dart';

//  UBAH NAMA CLASS & ARGUMENT MODEL
class HomepageDosenFirebase extends StatefulWidget {
  final UserFirebaseModel user;
  const HomepageDosenFirebase({super.key, required this.user});

  @override
  State<HomepageDosenFirebase> createState() => _HomepageDosenFirebaseState();
}

class _HomepageDosenFirebaseState extends State<HomepageDosenFirebase> {
  //  INISIASI SERVICE FIREBASE
  final KelasFirebaseService _kelasService = KelasFirebaseService();

  List<KelasFirebaseModel> _daftarKelas = []; //  UBAH TIPE LIST
  bool _isLoading = true;
  // bool _isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String userUid = widget.user.uid;

    //  Cek Kelengkapan Profil dari Model Sesi (nimNidn dan namaKampus sudah ada di user object)
    // bool profileComplete =
    //     widget.user.nimNidn?.isNotEmpty == true &&
    //     widget.user.namaKampus?.isNotEmpty == true;

    //  Ambil Data Kelas dari Firestore
    try {
      final dataKelas = await _kelasService.getKelasByDosen(userUid);

      if (mounted) {
        setState(() {
          _daftarKelas = dataKelas;
          // _isProfileComplete = profileComplete;
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
      title: type == ContentType.success ? "Sukses" : "Error",
      message: message.replaceAll('Exception: ', ''),
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

  //  UBAH TIPE MODEL
  void _handleMenuAction(String action, KelasFirebaseModel kelas) {
    switch (action) {
      case 'Salin Kode':
        _copyClassCode(kelas.kodeKelas);
        break;
      case 'Edit':
        _navigateToEditClass(kelas);
        break;
      case 'Hapus':
        _showDeleteConfirmDialog(kelas);
        break;
    }
  }

  void _copyClassCode(String kode) {
    Clipboard.setData(ClipboardData(text: kode));

    // PERBAIKAN SNACKBAR: Gunakan _showSnackbar untuk konsistensi
    _showSnackbar("Kode kelas disalin ke clipboard", ContentType.success);
  }

  //  UBAH TIPE MODEL & WIDGET
  void _navigateToEditClass(KelasFirebaseModel kelas) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditClassFirebasePage(kelas: kelas), //  Widget Firebase
      ),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);
      _loadData();
    }
  }

  //  UBAH TIPE MODEL
  Future<void> _showDeleteConfirmDialog(KelasFirebaseModel kelas) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Hapus Kelas?',
            // Mengganti Colors.red dengan kErrorColor
            style: TextStyle(color: AppColor.kErrorColor),
          ),
          content: Text(
            'Anda yakin ingin menghapus kelas "${kelas.namaKelas}"?\nData tidak dapat dikembalikan.',
          ),
          actions: <Widget>[
            TextButton(
              // Warna tombol Batal
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColor.kTextColor),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              // Mengganti Colors.red dengan kErrorColor
              child: const Text(
                'Hapus',
                style: TextStyle(color: AppColor.kErrorColor),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  setState(() => _isLoading = true);

                  //  Panggil delete dari service Firebase (ID adalah kelasId)
                  await _kelasService.deleteKelas(kelas.kelasId!);

                  if (mounted) {
                    // PERBAIKAN SNACKBAR: Gunakan _showSnackbar untuk konsistensi
                    _showSnackbar(
                      "Kelas berhasil dihapus",
                      ContentType.success,
                    );
                    _loadData();
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
                  _showSnackbar(
                    "Gagal menghapus kelas: $e",
                    ContentType.failure,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToBuatKelas() {
    Navigator.push(
      context,
      //  Panggil CreateClass versi Firebase
      MaterialPageRoute(
        builder: (context) => CreateClassFirebasePage(user: widget.user),
      ),
    ).then((newKelas) {
      setState(() => _isLoading = true);
      _loadData();

      //  UBAH TIPE MODEL: newKelas sekarang bertipe KelasFirebaseModel
      if (newKelas != null && newKelas is KelasFirebaseModel) {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          _showSuccessDialog(newKelas, messenger);
        }
      }
    });
  }

  //  UBAH TIPE MODEL
  Future<void> _showSuccessDialog(
    KelasFirebaseModel newKelas,
    ScaffoldMessengerState messenger,
  ) async {
    // Logika showSuccessDialog tetap sama, hanya tipe datanya disesuaikan.
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kelas Berhasil Dibuat!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Kelas "${newKelas.namaKelas}" telah dibuat.'),
                const SizedBox(height: 20),
                const Text(
                  'Bagikan kode ini ke mahasiswa Anda:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.kDividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SelectableText(
                        newKelas.kodeKelas,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Salin Kode',
                        color: AppColor.kPrimaryColor, // Warna Dosen
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: newKelas.kodeKelas),
                          );
                          _showSnackbar(
                            "Kode berhasil disalin",
                            ContentType.success,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tutup',
                style: TextStyle(color: AppColor.kPrimaryColor), // Warna Dosen
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //  UBAH TIPE MODEL & WIDGET
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
      _loadData();
    }
  }

  // void _showProfileWarning() {
  //   _showSnackbar(
  //     "Harap lengkapi Profil (NIDN/NIDK dan Kampus) sebelum membuat kelas.",
  //     ContentType.warning,
  //   );
  // }

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
              child: CircularProgressIndicator(color: AppColor.kPrimaryColor),
            )
          : _daftarKelas.isEmpty
          ? EmptyStateWidget(
              imagePath: AppImages.kelasdosen,
              // icon: Icons.menu_book,
              //  Menggunakan namaLengkap dari user firebase
              title: "Selamat Datang,\n${widget.user.namaLengkap}",
              message:
                  "Anda belum membuat kelas. Silakan buat kelas dengan menekan tombol (+).",
              // iconColor: AppColor.kPrimaryColor,
            )
          : ClassListFirebase(
              //  Menggunakan ClassListFirebase
              daftarKelas: _daftarKelas,
              onKelasTap: _navigateToDetail,
              isDosen: true,
              onMenuAction: _handleMenuAction,
              roleColor: AppColor.kPrimaryColor,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToBuatKelas,
        backgroundColor: AppColor.kPrimaryColor,
        // backgroundColor: _isProfileComplete
        //     ? AppColor.kPrimaryColor
        //     : AppColor.kDisabledColor,
        child: const Icon(Icons.add, color: AppColor.kWhiteColor),
      ),
    );
  }
}
