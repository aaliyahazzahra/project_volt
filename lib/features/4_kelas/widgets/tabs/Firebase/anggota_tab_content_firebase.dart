import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
//  Import Service Manajemen Pengguna
import 'package:project_volt/data/firebase/service/user_management_firebase_service.dart';
import 'package:project_volt/features/4_kelas/widgets/tabs/Firebase/list_views/anggota_list_view_firebase.dart';
import 'package:project_volt/widgets/emptystate.dart';

class AnggotaTabContentFirebase extends StatefulWidget {
  final KelasFirebaseModel kelas;
  final Color rolePrimaryColor;
  const AnggotaTabContentFirebase({
    super.key,
    required this.kelas,
    required this.rolePrimaryColor,
  });

  @override
  State<AnggotaTabContentFirebase> createState() =>
      _AnggotaTabContentFirebaseState();
}

class _AnggotaTabContentFirebaseState extends State<AnggotaTabContentFirebase> {
  //  INISIASI SERVICE FIREBASE
  final UserManagementFirebaseService _userManagementService =
      UserManagementFirebaseService();

  List<UserFirebaseModel> _daftarAnggota = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnggota();
  }

  Future<void> _loadAnggota() async {
    //  UBAH ID: Menggunakan kelasId (String)
    final String? kelasId = widget.kelas.kelasId;

    if (kelasId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      //  PANGGIL SERVICE FIREBASE
      final data = await _userManagementService.getAnggotaByKelas(kelasId);

      if (mounted) {
        setState(() {
          _daftarAnggota = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error pemuatan data
      print("Error loading class members: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Mungkin tampilkan snackbar error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kWhiteColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: widget.rolePrimaryColor),
            )
          : _daftarAnggota.isEmpty
          ? EmptyStateWidget(
              icon: Icons.group_off_outlined,
              title: "Belum Ada Anggota",
              message: "Belum ada mahasiswa yang bergabung dengan kelas ini.",
              iconColor: widget.rolePrimaryColor,
            )
          : AnggotaListViewFirebase(
              daftarAnggota: _daftarAnggota,
              // onAnggotaTap: _handleAnggotaTap, // Jika diaktifkan
              roleColor: widget.rolePrimaryColor,
            ),
    );
  }
}
