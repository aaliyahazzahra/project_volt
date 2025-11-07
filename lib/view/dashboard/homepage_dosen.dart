import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/view/kelas/dosen/create_class.dart';
import 'package:project_volt/view/kelas/class_detail_page.dart';
import 'package:project_volt/widgets/class_list.dart';
import 'package:project_volt/widgets/emptystate.dart';

class HomepageDosen extends StatefulWidget {
  final UserModel user;
  const HomepageDosen({super.key, required this.user});

  @override
  State<HomepageDosen> createState() => _HomepageDosenState();
}

class _HomepageDosenState extends State<HomepageDosen> {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: User ID tidak ditemukan.")),
        );
      }
      return;
    }

    final dataKelas = await DbHelper.getKelasByDosen(widget.user.id!);
    final dataProfil = await DbHelper.getDosenProfile(widget.user.id!);
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

  void _navigateToBuatKelas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateClass(user: widget.user)),
    ).then((newKelas) {
      // Muat ulang daftar kelas agar data baru tampil
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
                    color: Colors.grey[200],
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
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: newKelas.kodeKelas),
                          );
                          messenger.showSnackBar(
                            SnackBar(content: Text("Kode berhasil disalin!")),
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
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // fungsi untuk navigasi detail
  void _navigateToDetail(KelasModel kelas) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassDetailPage(kelas: kelas, user: widget.user),
      ),
    );

    // Cek jika ada sinyal 'true'
    if (result == true && mounted) {
      setState(() => _isLoading = true);
      _loadData(); // Muat ulang
    }
  }

  void _showProfileWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Harap lengkapi NIDN/NIDK dan Kampus Anda di menu Profil.',
        ),
        backgroundColor: Colors.orange[700],
      ),
    );
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
          ? Center(child: CircularProgressIndicator())
          : _daftarKelas.isEmpty
          ? EmptyStateWidget(
              icon: Icons.menu_book,
              title: "Selamat Datang,\n${widget.user.namaLengkap}",
              message:
                  "Anda belum membuat kelas. Silakan buat kelas dengan menekan tombol (+).",
            )
          : ClassList(daftarKelas: _daftarKelas, onKelasTap: _navigateToDetail),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProfileComplete
            ? _navigateToBuatKelas
            : _showProfileWarning,
        backgroundColor: _isProfileComplete
            ? AppColor.kPrimaryColor
            : Colors.grey,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
