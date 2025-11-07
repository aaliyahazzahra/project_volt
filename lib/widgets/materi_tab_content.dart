import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/model/materi_model.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/view/materi/create_materi_page.dart';
import 'package:project_volt/widgets/emptystate.dart';
import 'package:project_volt/widgets/materi_list_view.dart';
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

    // Refresh list jika 'true' dikembalikan
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
    return Scaffold(
      backgroundColor: widget.isDosen
          ? AppColor.kWhiteColor
          : AppColor.kBackgroundColor,

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _daftarMateri.isEmpty
          ? EmptyStateWidget(
              icon: Icons.menu_book_outlined,
              title: "Belum Ada Materi",
              message: widget.isDosen
                  ? "Tekan tombol (+) di bawah untuk memposting materi pertama."
                  : "Dosen Anda belum memposting materi apapun di kelas ini.",
            )
          : MateriListView(
              daftarMateri: _daftarMateri,
              onMateriTap: _navigateToDetailMateri,
            ),

      floatingActionButton: widget.isDosen
          ? FloatingActionButton(
              onPressed: _navigateToCreateMateri,
              backgroundColor: AppColor.kPrimaryColor,
              tooltip: 'Posting Materi Baru',
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
