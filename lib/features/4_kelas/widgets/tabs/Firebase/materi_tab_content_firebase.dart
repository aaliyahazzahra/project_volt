import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/materi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/materi_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/create_materi_page.dart';
import 'package:project_volt/features/4_kelas/widgets/list_views/materi_list_view.dart';
import 'package:project_volt/widgets/emptystate.dart';

class MateriTabContentFirebase extends StatefulWidget {
  final KelasFirebaseModel kelas;
  final UserFirebaseModel user;
  final bool isDosen;

  const MateriTabContentFirebase({
    super.key,
    required this.kelas,
    required this.user,
    required this.isDosen,
  });

  @override
  State<MateriTabContentFirebase> createState() =>
      _MateriTabContentFirebaseState();
}

class _MateriTabContentFirebaseState extends State<MateriTabContentFirebase> {
  // 🔥 INISIASI SERVICE FIREBASE
  final MateriFirebaseService _materiService = MateriFirebaseService();

  List<MateriFirebaseModel> _daftarMateri = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMateri();
  }

  Future<void> _loadMateri() async {
    // 🔥 UBAH ID: Menggunakan kelasId (String)
    final String? kelasId = widget.kelas.kelasId;

    if (kelasId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // 🔥 PANGGIL SERVICE FIREBASE
      final data = await _materiService.getMateriByKelas(kelasId);

      if (mounted) {
        setState(() {
          _daftarMateri = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading materials: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        // Opsional: tampilkan snackbar error
      }
    }
  }

  void _navigateToCreateMateri() async {
    // 🔥 UBAH ID: Menggunakan kelasId (String)
    final String? kelasId = widget.kelas.kelasId;
    if (kelasId == null) return;

    final result = await Navigator.push(
      context,
      // ASUMSI: CreateMateriPage menerima String kelasId
      MaterialPageRoute(
        builder: (context) => CreateMateriPage(kelasId: kelasId),
      ),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true); // Tunjukkan loading saat refresh
      _loadMateri();
    }
  }

  void _navigateToDetailMateri(MateriFirebaseModel materi) {
    // TODO: Navigasi ke MateriDetailPage (Pastikan menerima MateriFirebaseModel)
    print("TODO: Navigasi ke MateriDetailPage untuk ${materi.judul}");
  }

  @override
  Widget build(BuildContext context) {
    final Color rolePrimaryColor = widget.isDosen
        ? AppColor.kPrimaryColor
        : AppColor.kAccentColor;

    return Scaffold(
      backgroundColor: AppColor.kWhiteColor,

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: rolePrimaryColor))
          : _daftarMateri.isEmpty
          ? EmptyStateWidget(
              icon: Icons.menu_book_outlined,
              title: "Belum Ada Materi",
              message: widget.isDosen
                  ? "Tekan tombol (+) di bawah untuk memposting materi pertama."
                  : "Dosen Anda belum memposting materi apapun di kelas ini.",
              iconColor: rolePrimaryColor,
            )
          : MateriListView(
              daftarMateri: _daftarMateri,
              onMateriTap: _navigateToDetailMateri,
              roleColor: rolePrimaryColor,
            ),

      floatingActionButton: widget.isDosen
          ? FloatingActionButton(
              onPressed: _navigateToCreateMateri,
              backgroundColor: AppColor.kPrimaryColor,
              tooltip: 'Posting Materi Baru',
              child: const Icon(Icons.add, color: AppColor.kWhiteColor),
            )
          : null,
    );
  }
}
