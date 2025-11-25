import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/SQF/database/db_helper.dart';
import 'package:project_volt/data/SQF/models/kelas_model.dart';
import 'package:project_volt/data/SQF/models/user_model.dart';
import 'package:project_volt/features/4_kelas/view/edit_class_page.dart';
import 'package:project_volt/features/4_kelas/widgets/tabs/anggota_tab_content.dart';
import 'package:project_volt/features/4_kelas/widgets/tabs/info_tab_content.dart';
import 'package:project_volt/features/4_kelas/widgets/tabs/materi_tab_content.dart';
import 'package:project_volt/features/4_kelas/widgets/tabs/tugas_tab_content.dart';
import 'package:project_volt/features/4_kelas/widgets/tabs/tugas_tab_mhs.dart';

class ClassDetailPage extends StatefulWidget {
  final KelasModel kelas;
  final UserModel user;

  const ClassDetailPage({super.key, required this.kelas, required this.user});

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  late KelasModel _currentKelasData;
  late bool _isDosen;
  bool _dataEdited = false;

  @override
  void initState() {
    super.initState();
    _currentKelasData = widget.kelas;
    _isDosen = widget.user.role == UserRole.dosen.toString();
  }

  // fungsi khusus dosen
  void _navigateToEditKelas() async {
    final isSuccess = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditClass(kelas: _currentKelasData),
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
    final updatedKelas = await DbHelper.getKelasById(widget.kelas.id!);
    if (!mounted) return;

    if (updatedKelas != null) {
      setState(() {
        _currentKelasData = updatedKelas;
      });
    } else {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _exitClass() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Keluar Kelas'),
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

    if (confirm == true && mounted) {
      try {
        await DbHelper.leaveKelas(widget.user.id!, _currentKelasData.id!);

        if (mounted) {
          final snackBarContent = AwesomeSnackbarContent(
            title: "Sukses",
            message: "Anda berhasil keluar dari kelas",
            contentType: ContentType.success,
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
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          final snackBarContent = AwesomeSnackbarContent(
            title: "Peringatan",
            message: "Gagal keluar kelas: $e",
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
      }
    }
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
                    // Dosen
                    IconButton(
                      icon: Icon(Icons.edit_note),
                      onPressed: _navigateToEditKelas,
                      tooltip: 'Edit Deskripsi',
                    ),
                  ]
                : [
                    // Mahasiswa
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

            bottom: TabBar(
              labelColor: rolePrimaryColor,
              unselectedLabelColor: AppColor.kTextSecondaryColor,
              indicatorColor: rolePrimaryColor,
              isScrollable: true,
              tabs: [
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
              InfoTabContent(
                kelas: _currentKelasData,
                roleColor: rolePrimaryColor,
              ),

              // Tab 2: Materi (SAMA)
              MateriTabContent(
                kelas: _currentKelasData,
                user: widget.user,
                isDosen: _isDosen,
              ),

              // Tab 3: Tugas (BERBEDA)
              _isDosen
                  ? TugasTabContent(kelas: _currentKelasData)
                  : TugasTabMhs(kelas: _currentKelasData, user: widget.user),

              // Tab 4: Anggota (SAMA)
              AnggotaTabContent(
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
