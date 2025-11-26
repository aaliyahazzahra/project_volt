import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/kelas_firebase_service.dart';
import 'package:project_volt/data/firebase/service/user_management_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/edit_class_firebase_page.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/anggota_tab_content_firebase.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/info_tab_content_firebase.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/materi_tab_content_firebase.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/tugas_tab_content_firebase.dart';
import 'package:project_volt/features/4_kelas/widgets/Firebase/tugas_tab_mhs_firebase.dart';

class ClassDetailFirebasePage extends StatefulWidget {
  final KelasFirebaseModel kelas;
  final UserFirebaseModel user;

  const ClassDetailFirebasePage({
    super.key,
    required this.kelas,
    required this.user,
  });

  @override
  State<ClassDetailFirebasePage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailFirebasePage> {
  late KelasFirebaseModel _currentKelasData;
  late bool _isDosen;
  bool _dataEdited = false;

  //  INISIASI FIREBASE SERVICES
  final KelasFirebaseService _kelasService = KelasFirebaseService();
  final UserManagementFirebaseService _userManagementService =
      UserManagementFirebaseService();

  @override
  void initState() {
    super.initState();
    _currentKelasData = widget.kelas;
    // ASUMSI: role dosen disimpan sebagai string 'dosen' di UserFirebaseModel
    _isDosen = widget.user.role == 'dosen';
  }

  // ----------------------------------------------------
  // FUNGSI KHUSUS DOSEN
  // ----------------------------------------------------
  void _navigateToEditKelas() async {
    final isSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClassFirebasePage(kelas: _currentKelasData),
      ),
    );

    if (isSuccess == true && mounted) {
      setState(() {
        _dataEdited = true;
      });
      // Panggil fungsi refresh setelah edit sukses
      _refreshKelasData();
    }
  }

  //  UPDATE LOGIKA REFRESH DATA (Menggunakan FirebaseService)
  Future<void> _refreshKelasData() async {
    // Pastikan ID kelas tersedia dan bertipe String
    final String? kelasId = widget.kelas.kelasId;
    if (kelasId == null) return;

    try {
      // Panggil service untuk mendapatkan 1 data kelas
      final updatedKelas = await _kelasService.getKelasById(
        kelasId,
      ); // ASUMSI: Anda tambahkan getKelasById ke KelasFirebaseService

      if (!mounted) return;

      if (updatedKelas != null) {
        setState(() {
          _currentKelasData = updatedKelas;
        });
      } else {
        // Jika kelas dihapus saat user mengedit (null), keluar dari halaman
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted)
        _showSnackbar("Gagal memuat ulang data kelas: $e", ContentType.failure);
    }
  }

  // ----------------------------------------------------
  // FUNGSI KHUSUS MAHASISWA
  // ----------------------------------------------------

  //  UPDATE LOGIKA KELUAR KELAS (Menggunakan UserManagementFirebaseService)
  Future<void> _exitClass() async {
    // 1. Tampilkan Dialog Konfirmasi
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Kelas'),
        content: Text(
          'Apakah Anda yakin ingin keluar dari kelas "${_currentKelasData.namaKelas}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: TextStyle(
                color: _isDosen
                    ? AppColor.kPrimaryColor
                    : AppColor.kAccentColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColor.kErrorColor),
            ),
          ),
        ],
      ),
    );

    // 2. Jika dikonfirmasi, panggil Service Firebase
    if (confirm == true && mounted) {
      final String? userUid = widget.user.uid;
      final String? kelasId = _currentKelasData.kelasId;

      if (userUid == null || kelasId == null) {
        _showSnackbar(
          "ID pengguna atau kelas tidak ditemukan.",
          ContentType.failure,
        );
        return;
      }

      try {
        //  Panggil service leaveKelas yang sudah dikonversi
        await _userManagementService.leaveKelas(userUid, kelasId);

        if (mounted) {
          _showSnackbar("Anda berhasil keluar dari kelas", ContentType.success);
          // Keluar dari halaman detail dan refresh daftar kelas di homepage
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          _showSnackbar(
            "Gagal keluar kelas: ${e.toString().replaceAll('Exception: ', '')}",
            ContentType.warning,
          );
        }
      }
    }
  }

  // Helper untuk menampilkan Awesome Snackbar
  void _showSnackbar(String message, ContentType type) {
    final snackBarContent = AwesomeSnackbarContent(
      title: type == ContentType.success ? "Sukses" : "Peringatan",
      message: message,
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

  @override
  Widget build(BuildContext context) {
    // ... (Logika warna UI tetap sama)
    final Color rolePrimaryColor = _isDosen
        ? AppColor.kPrimaryColor
        : AppColor.kAccentColor;
    final Color roleLightBgColor = _isDosen
        ? AppColor.kBackgroundColor
        : AppColor.kLightAccentColor;

    final Color scaffoldBgColor = roleLightBgColor;
    final Color appBarBgColor = AppColor.kBackgroundColor;

    final TextStyle appBarTitleStyle = TextStyle(
      color: rolePrimaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );
    final IconThemeData appBarIconTheme = IconThemeData(
      color: AppColor.kTextColor,
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;

        // Jika data diedit oleh Dosen, beri sinyal ke halaman sebelumnya untuk refresh
        if (_isDosen && _dataEdited) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: scaffoldBgColor,
          appBar: AppBar(
            backgroundColor: appBarBgColor,
            titleTextStyle: appBarTitleStyle,
            iconTheme: appBarIconTheme,
            actionsIconTheme: appBarIconTheme,
            title: Text(_currentKelasData.namaKelas),

            actions: _isDosen
                ? [
                    // Dosen: Tombol Edit
                    IconButton(
                      icon: const Icon(Icons.edit_note),
                      onPressed: _navigateToEditKelas,
                      tooltip: 'Edit Deskripsi',
                    ),
                  ]
                : [
                    // Mahasiswa: Popup Menu (Keluar Kelas)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'keluar_kelas') {
                          _exitClass();
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'keluar_kelas',
                              child: Text('Keluar dari kelas'),
                            ),
                          ],
                    ),
                  ],

            // Tabs
            bottom: TabBar(
              labelColor: rolePrimaryColor,
              unselectedLabelColor: AppColor.kTextSecondaryColor,
              indicatorColor: rolePrimaryColor,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.info_outline), text: "Info"),
                Tab(icon: Icon(Icons.menu_book), text: "Materi"),
                Tab(icon: Icon(Icons.assignment), text: "Tugas"),
                Tab(icon: Icon(Icons.group_outlined), text: "Anggota"),
              ],
            ),
          ),

          body: TabBarView(
            children: [
              // Tab 1: Info (SAMA)
              InfoTabContentFirebase(
                kelas: _currentKelasData,
                roleColor: rolePrimaryColor,
              ),

              // Tab 2: Materi (SAMA)
              MateriTabContentFirebase(
                kelas: _currentKelasData,
                user: widget.user,
                isDosen: _isDosen,
              ),

              // Tab 3: Tugas (BERBEDA)
              _isDosen
                  ? TugasTabContentFirebase(
                      user: widget.user,
                      kelas: _currentKelasData,
                    )
                  : TugasTabMhsFirebase(
                      kelas: _currentKelasData,
                      user: widget.user,
                    ),

              // Tab 4: Anggota (SAMA)
              AnggotaTabContentFirebase(
                kelas: _currentKelasData,
                rolePrimaryColor: rolePrimaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
