import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart'; // Sesuaikan path ke DbHelper Anda
import 'package:project_volt/model/user_model.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _kampusController;
  late TextEditingController _nomorIndukController;

  bool _isLoading = true;
  late bool _isDosen;

  // Label untuk form
  String _nomorIndukLabel = "NIM";

  @override
  void initState() {
    super.initState();
    _kampusController = TextEditingController();
    _nomorIndukController = TextEditingController();

    _isDosen = widget.user.role == UserRole.dosen.toString();
    _nomorIndukLabel = _isDosen ? "NIDN/NIDK" : "NIM";

    _loadProfileData();
  }

  @override
  void dispose() {
    _kampusController.dispose();
    _nomorIndukController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic>? profileData;
    try {
      if (_isDosen) {
        profileData = await DbHelper.getDosenProfile(widget.user.id!);
      } else {
        profileData = await DbHelper.getMahasiswaProfile(widget.user.id!);
      }

      if (profileData != null) {
        _kampusController.text = profileData['nama_kampus'] ?? '';
        if (_isDosen) {
          _nomorIndukController.text = profileData['nidn_nidk'] ?? '';
        } else {
          _nomorIndukController.text = profileData['nim'] ?? '';
        }
      }
    } catch (e) {
      print("Error loading profile: $e");
      // Tampilkan snackbar jika gagal load
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data profil.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) {
      return; // Jangan simpan jika form tidak valid
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> data = {
        'user_id': widget.user.id!,
        'nama_kampus': _kampusController.text.trim(),
      };

      if (_isDosen) {
        data['nidn_nidk'] = _nomorIndukController.text.trim();
        await DbHelper.saveDosenProfile(data);
      } else {
        data['nim'] = _nomorIndukController.text.trim();
        await DbHelper.saveMahasiswaProfile(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profil berhasil diperbarui!')));
        Navigator.pop(context); // Kembali ke halaman profil
      }
    } catch (e) {
      print("Error saving profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan profil: $e')));
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
                      // Form Nama Kampus
                      TextFormField(
                        controller: _kampusController,
                        decoration: InputDecoration(
                          labelText: 'Nama Kampus / Universitas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: AppColor.kWhiteColor,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama kampus tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Form NIM / NIDN
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
                      SizedBox(height: 32),

                      // Tombol Simpan
                      ElevatedButton(
                        onPressed: _saveProfileData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.kPrimaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
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
