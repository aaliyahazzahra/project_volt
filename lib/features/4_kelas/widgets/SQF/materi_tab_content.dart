import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_image.dart';
import 'package:project_volt/data/SQF/database/db_helper.dart';
import 'package:project_volt/data/SQF/models/kelas_model.dart';
import 'package:project_volt/data/SQF/models/materi_model.dart';
import 'package:project_volt/data/SQF/models/user_model.dart';
import 'package:project_volt/features/4_kelas/view/create_materi_page.dart';
import 'package:project_volt/features/4_kelas/widgets/SQF/list_views/materi_list_view.dart';
import 'package:project_volt/widgets/emptystate.dart';
// TODO: Buat halaman CreateMateriPage
// import 'package:project_volt/view/kelas/dosen/create_materi_page.dart';

class MateriTabContent extends StatefulWidget {
  final KelasModel kelas;
  final UserModel user;
  final bool isDosen;

  const MateriTabContent({
    super.key,
    required this.kelas,
    required this.user,
    required this.isDosen,
  });

  @override
  State<MateriTabContent> createState() => _MateriTabContentState();
}

class _MateriTabContentState extends State<MateriTabContent> {
  List<MateriModel> _daftarMateri = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMateri();
  }

  Future<void> _loadMateri() async {
    if (widget.kelas.id == null) return;
    final data = await DbHelper.getMateriByKelas(widget.kelas.id!);
    if (mounted) {
      setState(() {
        _daftarMateri = data;
        _isLoading = false;
      });
    }
  }

  void _navigateToCreateMateri() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMateriPage(kelasId: widget.kelas.id!),
      ),
    );

    if (result == true && mounted) {
      _loadMateri();
    }
  }

  void _navigateToDetailMateri(MateriModel materi) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => MateriDetailPage(materi: materi, isDosen: widget.isDosen),
    //   ),
    // ).then((_) => _loadMateri()); // Refresh jika ada edit/delete
    print("TODO: Navigasi ke MateriDetailPage");
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
              imagePath: AppImages.materidosen,
              // icon: Icons.menu_book_outlined,
              title: "Belum Ada Materi",
              message: widget.isDosen
                  ? "Tekan tombol (+) di bawah untuk menambah materi baru."
                  : "Dosen Anda belum memposting materi apapun di kelas ini.",
              // iconColor: rolePrimaryColor,
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
