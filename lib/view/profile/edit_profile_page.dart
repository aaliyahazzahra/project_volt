import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart'; // Sesuaikan path
import 'package:project_volt/model/user_model.dart';

final List<String> daftarKampus = [
  'Universitas Indonesia (UI)',
  'Institut Teknologi Bandung (ITB)',
  'Universitas Gadjah Mada (UGM)',
  'Universitas Airlangga (UNAIR)',
  'Institut Pertanian Bogor (IPB)',
  'Universitas Padjadjaran (UNPAD)',
  'Universitas Diponegoro (UNDIP)',
  'Universitas Brawijaya (UB)',
  'Institut Teknologi Sepuluh Nopember (ITS)',
  'Universitas Negeri Jakarta (UNJ)',
  'Universitas Sebelas Maret (UNS)',
  'Universitas Hasanuddin (UNHAS)',
];

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedKampus;

  late TextEditingController _nomorIndukController;

  bool _isLoading = true;
  late bool _isDosen;
  String _nomorIndukLabel = "NIM";

  @override
  void initState() {
    super.initState();
    _nomorIndukController = TextEditingController();
    _selectedKampus = null; // Awalnya kosong

    _isDosen = widget.user.role == UserRole.dosen.toString();
    _nomorIndukLabel = _isDosen ? "NIDN/NIDK" : "NIM";

    _loadProfileData();
  }

  @override
  void dispose() {
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
        final String? loadedNamaKampus = profileData['nama_kampus'];

        if (loadedNamaKampus != null &&
            daftarKampus.contains(loadedNamaKampus)) {
          _selectedKampus = loadedNamaKampus;
        } else {
          _selectedKampus = null;
        }

        if (_isDosen) {
          _nomorIndukController.text = profileData['nidn_nidk'] ?? '';
        } else {
          _nomorIndukController.text = profileData['nim'] ?? '';
        }
      }
    } catch (e) {
      print("Error loading profile: $e");
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
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> data = {
        'user_id': widget.user.id!,
        'nama_kampus': _selectedKampus,
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
        Navigator.pop(context);
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
                        hint: Text('Pilih Kampus'),
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

                      SizedBox(height: 16),

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
