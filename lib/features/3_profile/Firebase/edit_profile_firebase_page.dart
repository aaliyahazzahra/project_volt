import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_data.dart' as AppData;
// HAPUS SQF IMPORT: import 'package:project_volt/data/SQF/database/db_helper.dart';
// HAPUS SQF IMPORT: import 'package:project_volt/data/SQF/models/user_model.dart';

//  TAMBAH: Import Service Manajemen Pengguna
import 'package:project_volt/data/firebase/service/user_management_firebase_service.dart';

import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

class EditProfileFirebasePage extends StatefulWidget {
  final UserFirebaseModel user;
  const EditProfileFirebasePage({super.key, required this.user});

  @override
  State<EditProfileFirebasePage> createState() =>
      _EditProfileFirebasePageState();
}

class _EditProfileFirebasePageState extends State<EditProfileFirebasePage> {
  final _formKey = GlobalKey<FormState>();

  //  INISIASI SERVICE FIREBASE
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

  //  UPDATE: Menggunakan data dari model sesi (BUKAN query DB terpisah)
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data profil.')),
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

  //  UPDATE: Menyimpan data ke Firestore (TANPA DbHelper)
  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String? userUid = widget.user.uid;
    if (userUid == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Panggil service untuk update dokumen user di Firestore
      await _userManagementService.updateProfileDetails(
        uid: userUid,
        nimNidn: _nomorIndukController.text
            .trim(), // nim untuk mhs, nidn untuk dosen
        namaKampus: _selectedKampus!,
      );

      // 2. Sukses: Sinyal ke homepage/AuthWrapper untuk refresh sesi
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
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error saving profile: $e");
      if (mounted) {
        final snackBarContent = AwesomeSnackbarContent(
          title: "Error",
          message:
              "Gagal menyimpan profil: ${e.toString().replaceAll('Exception: ', '')}",
          contentType: ContentType.warning,
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
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Ubah Profil Akademik",
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppColor.kPrimaryColor),
        backgroundColor: AppColor.kBackgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColor.kPrimaryColor),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: AppColor.kWhiteColor,
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: AppColor.kWhiteColor,
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
                          backgroundColor: AppColor.kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.kWhiteColor,
                          ),
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
