// file: EditProfileFirebasePage.dart

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_data.dart' as AppData;
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
//  TAMBAH: Import Service Manajemen Pengguna
import 'package:project_volt/data/firebase/service/user_management_firebase_service.dart';

class EditProfileFirebasePage extends StatefulWidget {
  final UserFirebaseModel user;
  const EditProfileFirebasePage({super.key, required this.user});

  @override
  State<EditProfileFirebasePage> createState() =>
      _EditProfileFirebasePageState();
}

class _EditProfileFirebasePageState extends State<EditProfileFirebasePage> {
  final _formKey = GlobalKey<FormState>();

  //  INISIASI SERVICE FIREBASE
  final UserManagementFirebaseService _userManagementService =
      UserManagementFirebaseService();

  String? _selectedKampus;

  late TextEditingController _nomorIndukController;

  bool _isLoading = true;
  late bool _isDosen;
  String _nomorIndukLabel = "NIM";

  // Asumsi: Daftar kampus diimpor dari app_data.dart
  final List<String> daftarKampus = AppData.daftarKampus;

  @override
  void initState() {
    super.initState();
    _nomorIndukController = TextEditingController();

    // ASUMSI: role disimpan sebagai string 'dosen'
    _isDosen = widget.user.role == 'dosen';
    _nomorIndukLabel = _isDosen ? "NIDN/NIDK" : "NIM";

    _loadProfileData();
  }

  @override
  void dispose() {
    _nomorIndukController.dispose();
    super.dispose();
  }

  //  UPDATE: Menggunakan data dari model sesi (BUKAN query DB terpisah)
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Ambil data langsung dari UserFirebaseModel (yang dimuat saat login/AuthWrapper)
      final String? loadedNamaKampus = widget.user.namaKampus;
      final String? loadedNomorInduk = widget.user.nimNidn;

      // 2. Set State
      if (loadedNamaKampus != null && daftarKampus.contains(loadedNamaKampus)) {
        _selectedKampus = loadedNamaKampus;
      } else {
        _selectedKampus = null;
      }

      _nomorIndukController.text = loadedNomorInduk ?? '';
    } catch (e) {
      print("Error loading profile: $e");
      if (mounted) {
        // PERBAIKAN SNACKBAR: Menggunakan AwesomeSnackbar untuk konsistensi
        final snackBarContent = AwesomeSnackbarContent(
          title: "Error",
          message: "Gagal memuat data profil.",
          contentType: ContentType.failure,
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  //  UPDATE: Menyimpan data ke Firestore (TANPA DbHelper)
  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String userUid = widget.user.uid;

    setState(() {
      _isLoading = true;
    });

    try {
      final String newNimNidn = _nomorIndukController.text.trim();
      final String newNamaKampus = _selectedKampus!;

      // 1. Panggil service untuk update dokumen user di Firestore
      await _userManagementService.updateProfileDetails(
        uid: userUid,
        nimNidn: newNimNidn,
        namaKampus: newNamaKampus,
      );

      // 2. Buat Model Pengguna yang Baru dan Terupdate
      final UserFirebaseModel updatedUser = widget.user.copyWith(
        nimNidn: newNimNidn,
        namaKampus: newNamaKampus,
        // Perlu update updatedAt jika field tersebut penting
        updatedAt: DateTime.now().toIso8601String(),
      );

      // 3. Sukses: Sinyal ke parent DAN KEMBALIKAN DATA BARU
      if (mounted) {
        final snackBarContent = AwesomeSnackbarContent(
          title: "Sukses",
          message: "Berhasil merubah profil.",
          contentType: ContentType.success,
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: snackBarContent,
            ),
          );

        // Kirim sinyal ke parent untuk refresh data (penting!)
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      print("Error saving profile: $e");
      if (mounted) {
        final snackBarContent = AwesomeSnackbarContent(
          title: "Error",
          message:
              "Gagal menyimpan profil: ${e.toString().replaceAll('Exception: ', '')}",
          // Mengganti ContentType.warning menjadi ContentType.failure untuk error yang lebih serius
          contentType: ContentType.failure,
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: snackBarContent,
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna tema peran secara dinamis
    final Color rolePrimaryColor = _isDosen
        ? AppColor.kPrimaryColor
        : AppColor.kAccentColor;

    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Ubah Profil Akademik",
          style: TextStyle(
            color: rolePrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Ikon kembali menggunakan warna peran
        iconTheme: IconThemeData(color: rolePrimaryColor),
        backgroundColor: AppColor.kBackgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              // Loading indicator menggunakan warna peran
              child: CircularProgressIndicator(color: rolePrimaryColor),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Dropdown Kampus
                      DropdownButtonFormField<String>(
                        initialValue: _selectedKampus,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Nama Kampus / Universitas',
                          // Warna border saat fokus menggunakan warna peran
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: rolePrimaryColor,
                              width: 2.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: AppColor.kDividerColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: AppColor.kDividerColor,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColor.kWhiteColor,
                          labelStyle: TextStyle(color: AppColor.kTextColor),
                        ),
                        hint: const Text('Pilih Kampus'),
                        items: daftarKampus.map((String kampus) {
                          return DropdownMenuItem<String>(
                            value: kampus,
                            child: Text(
                              kampus,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedKampus = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap pilih nama kampus';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Nomor Induk (NIM/NIDN)
                      TextFormField(
                        controller: _nomorIndukController,
                        decoration: InputDecoration(
                          labelText: _nomorIndukLabel,
                          // Warna border saat fokus menggunakan warna peran
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: rolePrimaryColor,
                              width: 2.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: AppColor.kDividerColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: AppColor.kDividerColor,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColor.kWhiteColor,
                          labelStyle: TextStyle(color: AppColor.kTextColor),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '$_nomorIndukLabel tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Tombol Simpan
                      ElevatedButton(
                        onPressed: _saveProfileData,
                        style: ElevatedButton.styleFrom(
                          // Background tombol menggunakan warna peran
                          backgroundColor: rolePrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          // Foreground (teks) sudah benar menggunakan kWhiteColor
                          foregroundColor: AppColor.kWhiteColor,
                        ),
                        child: const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          // Warna teks sudah ditentukan oleh foregroundColor di styleFrom
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
