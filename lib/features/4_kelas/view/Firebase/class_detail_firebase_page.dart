import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/kelas_firebase_service.dart';
import 'package:project_volt/data/firebase/service/user_management_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/edit_class_firebase_page.dart';
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

  final KelasFirebaseService _kelasService = KelasFirebaseService();
  final UserManagementFirebaseService _userManagementService =
      UserManagementFirebaseService();

  @override
  void initState() {
    super.initState();
    _currentKelasData = widget.kelas;
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
      _refreshKelasData();
    }
  }

  Future<void> _refreshKelasData() async {
    final String? kelasId = widget.kelas.kelasId;
    if (kelasId == null) return;

    try {
      final updatedKelas = await _kelasService.getKelasById(kelasId);

      if (!mounted) return;

      if (updatedKelas != null) {
        setState(() {
          _currentKelasData = updatedKelas;
        });
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar("Gagal memuat ulang data kelas: $e", ContentType.failure);
      }
    }
  }

  // ----------------------------------------------------
  // FUNGSI KHUSUS MAHASISWA
  // ----------------------------------------------------

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
      final String userUid = widget.user.uid;
      final String? kelasId = _currentKelasData.kelasId;

      if (kelasId == null) {
        _showSnackbar(
          "ID pengguna atau kelas tidak ditemukan.",
          ContentType.failure,
        );
        return;
      }

      try {
        await _userManagementService.leaveKelas(userUid, kelasId);

        if (mounted) {
          _showSnackbar("Anda berhasil keluar dari kelas", ContentType.success);
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

        if (_isDosen && _dataEdited) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: DefaultTabController(
        length: 3,
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
                    IconButton(
                      icon: const Icon(Icons.edit_note),
                      onPressed: _navigateToEditKelas,
                      tooltip: 'Edit Deskripsi',
                    ),
                  ]
                : [
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
              isScrollable: false,
              tabs: const [
                Tab(icon: Icon(Icons.info_outline), text: "Info"),
                Tab(icon: Icon(Icons.menu_book), text: "Materi"),
                Tab(icon: Icon(Icons.assignment), text: "Tugas"),
              ],
            ),
          ),

          body: TabBarView(
            children: [
              // Tab 1: Info
              InfoTabContentFirebase(
                kelas: _currentKelasData,
                roleColor: rolePrimaryColor,
              ),

              // Tab 2: Materi
              MateriTabContentFirebase(
                kelas: _currentKelasData,
                user: widget.user,
                isDosen: _isDosen,
              ),

              // Tab 3: Tugas
              _isDosen
                  ? TugasTabContentFirebase(
                      user: widget.user,
                      kelas: _currentKelasData,
                    )
                  : TugasTabMhsFirebase(
                      kelas: _currentKelasData,
                      user: widget.user,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
