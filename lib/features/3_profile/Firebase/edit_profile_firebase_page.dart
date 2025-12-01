import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_data.dart' as AppData;
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/user_management_firebase_service.dart'; // Import User Management Service

class EditProfileFirebasePage extends StatefulWidget {
  final UserFirebaseModel user;
  const EditProfileFirebasePage({super.key, required this.user});

  @override
  State<EditProfileFirebasePage> createState() =>
      _EditProfileFirebasePageState();
}

class _EditProfileFirebasePageState extends State<EditProfileFirebasePage> {
  final _formKey = GlobalKey<FormState>();

  final UserManagementFirebaseService _userManagementService =
      UserManagementFirebaseService();

  String? _selectedKampus;

  late TextEditingController _nomorIndukController;

  bool _isLoading = true;
  late bool _isDosen;
  String _nomorIndukLabel = "NIM";

  final List<String> daftarKampus = AppData.daftarKampus;

  @override
  void initState() {
    super.initState();
    _nomorIndukController = TextEditingController();

    // Determine role and label based on UserFirebaseModel
    _isDosen = widget.user.role == 'dosen';
    _nomorIndukLabel = _isDosen ? "NIDN/NIDK" : "NIM";

    _loadProfileData();
  }

  @override
  void dispose() {
    _nomorIndukController.dispose();
    super.dispose();
  }

  // Load profile data from the session model (UserFirebaseModel)
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Get data directly from UserFirebaseModel
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
        final snackBarContent = AwesomeSnackbarContent(
          title: "Error",
          message: "Failed to load profile data.",
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

      // 1. Call service to update user document in Firestore
      await _userManagementService.updateProfileDetails(
        uid: userUid,
        nimNidn: newNimNidn,
        namaKampus: newNamaKampus,
      );

      // 2. Create the new, updated User Model
      final UserFirebaseModel updatedUser = widget.user.copyWith(
        nimNidn: newNimNidn,
        namaKampus: newNamaKampus,
        updatedAt: DateTime.now().toIso8601String(),
      );

      // 3. Success: Signal to parent and RETURN NEW DATA
      if (mounted) {
        final snackBarContent = AwesomeSnackbarContent(
          title: "Success",
          message: "Successfully updated profile.",
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

        // Return the updated user model to the previous page
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      // Log error for debugging
      print("Error saving profile: $e");
      if (mounted) {
        final snackBarContent = AwesomeSnackbarContent(
          title: "Error",
          message:
              "Failed to save profile: ${e.toString().replaceAll('Exception: ', '')}",
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
    // Determine the role-based theme color dynamically
    final Color rolePrimaryColor = _isDosen
        ? AppColor.kPrimaryColor
        : AppColor.kAccentColor;

    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Ubah Profil Akademik",
          style: TextStyle(
            color: AppColor.kTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: rolePrimaryColor),
        backgroundColor: AppColor.kBackgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: rolePrimaryColor))
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: rolePrimaryColor,
                              width: 2.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
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
                          labelStyle: const TextStyle(
                            color: AppColor.kTextColor,
                          ),
                          errorStyle: const TextStyle(
                            color: AppColor.kErrorColor,
                          ),
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
                            return 'Please select a campus name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ID Number (NIM/NIDN)
                      TextFormField(
                        controller: _nomorIndukController,
                        decoration: InputDecoration(
                          labelText: _nomorIndukLabel,
                          // Focused border color uses role color
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: rolePrimaryColor,
                              width: 2.0,
                            ),
                          ),
                          // Error border color
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: AppColor.kErrorColor,
                              width: 1.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: AppColor.kErrorColor,
                              width: 2.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
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
                          labelStyle: const TextStyle(
                            color: AppColor.kTextColor,
                          ),
                          // Error text color
                          errorStyle: const TextStyle(
                            color: AppColor.kErrorColor,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '$_nomorIndukLabel cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : _saveProfileData, // Disable button when loading
                        style: ElevatedButton.styleFrom(
                          // Button background uses role color
                          backgroundColor: rolePrimaryColor,
                          // Disabled color uses kDisabledColor
                          disabledBackgroundColor: AppColor.kDisabledColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          // Text color uses kWhiteColor
                          foregroundColor: AppColor.kWhiteColor,
                        ),
                        child:
                            _isLoading // Show loading spinner
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColor.kWhiteColor,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
