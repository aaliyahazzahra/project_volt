import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/SQF/models/kelas_model.dart';
import 'package:project_volt/data/SQF/models/user_model.dart';
import 'package:project_volt/data/kelas_data_source.dart';
import 'package:project_volt/features/4_kelas/view/class_detail_page.dart';
import 'package:project_volt/features/4_kelas/view/create_class_page.dart';
import 'package:project_volt/features/4_kelas/view/edit_class_page.dart';
import 'package:project_volt/features/4_kelas/widgets/class_list.dart';
import 'package:project_volt/widgets/emptystate.dart';

class HomepageDosen extends StatefulWidget {
  final UserModel user;
  const HomepageDosen({super.key, required this.user});

  @override
  State<HomepageDosen> createState() => _HomepageDosenState();
}

class _HomepageDosenState extends State<HomepageDosen> {
  final KelasDataSource _kelasDataSource = KelasDataSource();

  List<KelasModel> _daftarKelas = [];
  bool _isLoading = true;
  bool _isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.user.id == null) {
      if (mounted) {
        setState(() => _isLoading = false);

        final snackBarContent = AwesomeSnackbarContent(
          title: "Error",
          message: "User ID tidak ditemukan",
          contentType: ContentType.failure,
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
      return;
    }

    final dataKelas = await _kelasDataSource.getKelasByDosen(widget.user.id!);
    final dataProfil = await _kelasDataSource.getDosenProfile(widget.user.id!);

    bool profileComplete =
        dataProfil != null &&
        (dataProfil['nidn_nidk'] != null &&
            dataProfil['nidn_nidk'].isNotEmpty) &&
        (dataProfil['nama_kampus'] != null &&
            dataProfil['nama_kampus'].isNotEmpty);

    if (mounted) {
      setState(() {
        _daftarKelas = dataKelas;
        _isProfileComplete = profileComplete;
        _isLoading = false;
      });
    }
  }

  void _handleMenuAction(String action, KelasModel kelas) {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Kode kelas '$kode' disalin ke clipboard"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToEditClass(KelasModel kelas) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditClass(kelas: kelas)),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);
      _loadData();
    }
  }

  Future<void> _showDeleteConfirmDialog(KelasModel kelas) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Kelas?', style: TextStyle(color: Colors.red)),
          content: Text(
            'Anda yakin ingin menghapus kelas "${kelas.namaKelas}"?\nData tidak dapat dikembalikan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  setState(() => _isLoading = true);

                  await _kelasDataSource.deleteKelas(kelas.id!);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Kelas berhasil dihapus")),
                    );
                    _loadData();
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
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
      MaterialPageRoute(builder: (context) => CreateClass(user: widget.user)),
    ).then((newKelas) {
      setState(() => _isLoading = true);
      _loadData();

      if (newKelas != null && newKelas is KelasModel) {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          _showSuccessDialog(newKelas, messenger);
        }
      }
    });
  }

  Future<void> _showSuccessDialog(
    KelasModel newKelas,
    ScaffoldMessengerState messenger,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kelas Berhasil Dibuat!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Kelas "${newKelas.namaKelas}" telah dibuat.'),
                SizedBox(height: 20),
                Text(
                  'Bagikan kode ini ke mahasiswa Anda:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.kDividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SelectableText(
                        newKelas.kodeKelas,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy),
                        tooltip: 'Salin Kode',
                        color: AppColor.kPrimaryColor,
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: newKelas.kodeKelas),
                          );
                          final snackBarContent = AwesomeSnackbarContent(
                            title: "Sukses",
                            message: "Kode berhasil disalin",
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
                style: TextStyle(color: AppColor.kPrimaryColor),
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

  void _navigateToDetail(KelasModel kelas) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassDetailPage(kelas: kelas, user: widget.user),
      ),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);
      _loadData();
    }
  }

  void _showProfileWarning() {
    final snackBarContent = AwesomeSnackbarContent(
      title: "Peringatan",
      message: "Harap lengkapi menu Profil.",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
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
              icon: Icons.menu_book,
              title: "Selamat Datang,\n${widget.user.namaLengkap}",
              message:
                  "Anda belum membuat kelas. Silakan buat kelas dengan menekan tombol (+).",
              iconColor: AppColor.kPrimaryColor,
            )
          : ClassList(
              daftarKelas: _daftarKelas,
              onKelasTap: _navigateToDetail,
              isDosen: true,
              onMenuAction: _handleMenuAction,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProfileComplete
            ? _navigateToBuatKelas
            : _showProfileWarning,
        backgroundColor: _isProfileComplete
            ? AppColor.kPrimaryColor
            : AppColor.kDisabledColor,
        child: Icon(Icons.add, color: AppColor.kWhiteColor),
      ),
    );
  }
}
