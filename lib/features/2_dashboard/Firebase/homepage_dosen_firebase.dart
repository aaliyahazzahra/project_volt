import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
// Import model Kelas yang sudah diadaptasi untuk Firebase/Firestore
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/kelas_firebase_service.dart';
import 'package:project_volt/features/4_kelas/view/Firebase/class_detail_firebase_page.dart';
import 'package:project_volt/features/4_kelas/view/create_class_page.dart';
import 'package:project_volt/features/4_kelas/view/edit_class_page.dart';
import 'package:project_volt/features/4_kelas/widgets/class_list.dart';
import 'package:project_volt/widgets/emptystate.dart';

class HomepageDosenFirebase extends StatefulWidget {
  final UserFirebaseModel user;
  const HomepageDosenFirebase({super.key, required this.user});

  @override
  State<HomepageDosenFirebase> createState() => _HomepageDosenFirebaseState();
}

class _HomepageDosenFirebaseState extends State<HomepageDosenFirebase> {
  // 🔥 GANTI: Gunakan service Firebase untuk Kelas
  final KelasFirebaseService _kelasService = KelasFirebaseService();

  // 🔥 GANTI: Sesuaikan List dengan model Firebase
  List<KelasFirebaseModel> _daftarKelas = [];
  bool _isLoading = true;
  bool _isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Cek User ID
    if (widget.user.uid == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Tampilkan Error Snack Bar
        _showErrorSnackbar("User ID tidak ditemukan");
      }
      return;
    }

    // 2. 🔥 Ambil Data Kelas dari Firestore
    try {
      final dataKelas = await _kelasService.getKelasByDosen(widget.user.uid!);

      // 3. 🔥 Cek Kelengkapan Profil dari Model Sesi
      // Menggunakan data yang sudah dimuat ke UserFirebaseModel saat login.
      bool profileComplete =
          widget.user.nimNidn != null &&
          (widget.user.nimNidn?.isNotEmpty ?? false) &&
          widget.user.namaKampus != null &&
          (widget.user.namaKampus?.isNotEmpty ?? false);

      if (mounted) {
        setState(() {
          _daftarKelas = dataKelas;
          _isProfileComplete = profileComplete;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Menangani error saat mengambil data dari Firestore
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar("Gagal memuat data kelas: $e");
      }
    }
  }

  void _showErrorSnackbar(String message) {
    final snackBarContent = AwesomeSnackbarContent(
      title: "Error",
      message: message,
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

  // 🔥 UBAH TIPE MODEL: Sesuaikan KelasModel ke KelasModelFirebase
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

    final snackBarContent = AwesomeSnackbarContent(
      title: "Disalin",
      message: "Kode kelas '$kode' disalin ke clipboard",
      contentType: ContentType.success,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: snackBarContent,
      ),
    );
  }

  // 🔥 UBAH TIPE MODEL
  void _navigateToEditClass(KelasFirebaseModel kelas) async {
    final result = await Navigator.push(
      context,
      // ASUMSI: EditClass menerima KelasModelFirebase
      MaterialPageRoute(builder: (context) => EditClass(kelas: kelas)),
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);
      _loadData();
    }
  }

  // 🔥 UBAH TIPE MODEL
  Future<void> _showDeleteConfirmDialog(KelasFirebaseModel kelas) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Hapus Kelas?',
            style: TextStyle(color: Colors.red),
          ),
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

                  // 🔥 Panggil delete dari service Firebase
                  await _kelasService.deleteKelas(kelas.id!);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Kelas berhasil dihapus")),
                    );
                    _loadData();
                  }
                } catch (e) {
                  setState(() => _isLoading = false);
                  _showErrorSnackbar("Gagal menghapus kelas: $e");
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
      // ASUMSI: CreateClass menerima UserFirebaseModel
      MaterialPageRoute(builder: (context) => CreateClass(user: widget.user)),
    ).then((newKelas) {
      setState(() => _isLoading = true);
      _loadData();

      // 🔥 UBAH TIPE MODEL: newKelas sekarang harus bertipe KelasModelFirebase
      if (newKelas != null && newKelas is KelasFirebaseModel) {
        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          _showSuccessDialog(newKelas, messenger);
        }
      }
    });
  }

  // 🔥 UBAH TIPE MODEL
  Future<void> _showSuccessDialog(
    KelasFirebaseModel newKelas,
    ScaffoldMessengerState messenger,
  ) async {
    // Logika showSuccessDialog tetap sama, hanya tipe datanya disesuaikan.
    // ... (kode dialog sukses)
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
                          // Tutup dialog setelah salin (opsional)
                          // Navigator.of(context).pop();
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

  // 🔥 UBAH TIPE MODEL
  void _navigateToDetail(KelasFirebaseModel kelas) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // ASUMSI: ClassDetailPage menerima KelasModelFirebase
        builder: (context) =>
            ClassDetailFirebasePage(kelas: kelas, user: widget.user),
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
      message:
          "Harap lengkapi Profil (NIDN/NIM dan Kampus) sebelum membuat kelas.",
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
              icon: Icons.menu_book,
              title:
                  "Selamat Datang,\n${widget.user.namaLengkap}", // 🔥 Ganti ke namaLengkap
              message:
                  "Anda belum membuat kelas. Silakan buat kelas dengan menekan tombol (+).",
              iconColor: AppColor.kPrimaryColor,
            )
          : ClassList(
              // 🔥 UBAH TIPE LIST
              daftarKelas: _daftarKelas,
              onKelasTap: _navigateToDetail,
              isDosen: true,
              onMenuAction: _handleMenuAction,
            ),
      floatingActionButton: FloatingActionButton(
        // Logika disempurnakan untuk memeriksa kelengkapan profil
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
