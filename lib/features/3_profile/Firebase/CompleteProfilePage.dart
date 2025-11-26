// File: project_volt/features/3_profile/complete_profile_page.dart

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_data.dart' as AppData;
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
//  Import Service Manajemen Pengguna
import 'package:project_volt/data/firebase/service/user_management_firebase_service.dart';
import 'package:project_volt/widgets/buildtextfield.dart';

class CompleteProfilePage extends StatefulWidget {
  final UserFirebaseModel user;
  const CompleteProfilePage({super.key, required this.user});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();

  //  INISIASI SERVICE FIREBASE
  final UserManagementFirebaseService _userManagementService =
      UserManagementFirebaseService();

  final List<String> daftarKampus = AppData.daftarKampus;

  String? _selectedKampus;
  late TextEditingController _nomorIndukController;

  bool _isLoading = false;
  late bool _isDosen;
  String _nomorIndukLabel = "NIM";

  @override
  void initState() {
    super.initState();
    _nomorIndukController = TextEditingController();

    // ASUMSI: role disimpan sebagai string 'dosen'
    _isDosen = widget.user.role == 'dosen';
    _nomorIndukLabel = _isDosen ? "NIDN/NIDK" : "NIM";

    // Pre-fill data jika sudah ada (meskipun halaman ini harusnya muncul hanya jika data kosong)
    _nomorIndukController.text = widget.user.nimNidn ?? '';
    _selectedKampus = widget.user.namaKampus;
  }

  @override
  void dispose() {
    _nomorIndukController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, ContentType type) {
    final snackBarContent = AwesomeSnackbarContent(
      title: type == ContentType.success ? "Sukses" : "Peringatan",
      message: message,
      contentType: type,
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
        nimNidn: _nomorIndukController.text.trim(),
        namaKampus: _selectedKampus!,
      );

      // 2. Sukses: Sinyal ke parent untuk refresh sesi
      if (mounted) {
        _showSnackbar("Berhasil melengkapi profil!", ContentType.success);
        // Kirim sinyal ke AuthWrapper/halaman sebelumnya agar sesi di-refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error saving profile: $e");
      if (mounted) {
        _showSnackbar(
          "Gagal menyimpan profil: ${e.toString().replaceAll('Exception: ', '')}",
          ContentType.failure,
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
        title: const Text(
          "Lengkapi Profil Akademik",
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppColor.kPrimaryColor),
        backgroundColor: AppColor.kBackgroundColor,
        elevation: 0,
        // Menonaktifkan tombol back karena profil wajib diisi
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Harap lengkapi data kampus dan nomor induk Anda untuk mengaktifkan fitur kelas.",
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                          child: Text(kampus, overflow: TextOverflow.ellipsis),
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
                      onPressed: _isLoading ? null : _saveProfileData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              'Simpan dan Lanjutkan',
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
        ),
      ),
    );
  }
}
