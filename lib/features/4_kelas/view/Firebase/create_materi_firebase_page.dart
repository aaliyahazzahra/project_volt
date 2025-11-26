// File: project_volt/features/4_kelas/view/create_materi_page.dart

import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:project_volt/core/constants/app_color.dart';

//  Import Service dan Model Firebase
import 'package:project_volt/data/firebase/service/materi_firebase_service.dart';
import 'package:project_volt/data/firebase/models/materi_firebase_model.dart';

class CreateMateriFirebasePage extends StatefulWidget {
  // ID Kelas sekarang bertipe String (UID Kelas)
  final String kelasId;
  const CreateMateriFirebasePage({super.key, required this.kelasId});

  @override
  State<CreateMateriFirebasePage> createState() =>
      _CreateMateriFirebasePageState();
}

class _CreateMateriFirebasePageState extends State<CreateMateriFirebasePage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _linkController = TextEditingController();

  //  INISIASI SERVICE FIREBASE
  final MateriFirebaseService _materiService = MateriFirebaseService();

  File? _pickedFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // Helper untuk menampilkan Awesome Snackbar
  void _showSnackbar(String message, ContentType type) {
    final snackBarContent = AwesomeSnackbarContent(
      title: type == ContentType.success ? "Sukses" : "Peringatan",
      message: message,
      contentType: type,
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

  // untuk memilih file (logika FilePicker)
  Future<void> _pickFile() async {
    if (_isLoading) return; // Jangan izinkan saat sedang loading

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          _pickedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showSnackbar("Gagal memilih file.", ContentType.warning);
    }
  }

  // untuk menyimpan materi ke Firebase Storage dan Firestore
  Future<void> _saveMateri() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_linkController.text.trim().isEmpty && _pickedFile == null) {
      _showSnackbar(
        "Harap sertakan Link Materi atau Upload File.",
        ContentType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    String? fileUrl;

    try {
      // 1. UPLOAD FILE ke Firebase Storage
      if (_pickedFile != null) {
        fileUrl = await _materiService.uploadFile(_pickedFile!, widget.kelasId);
      }

      // 2. Buat Model Firebase
      final materi = MateriFirebaseModel(
        kelasId: widget.kelasId,
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        linkMateri: _linkController.text.trim().isEmpty
            ? null
            : _linkController.text.trim(),
        // filePathMateri adalah URL hasil upload
        filePathMateri: fileUrl,
        tglPosting: DateTime.now().toIso8601String(),
      );

      // 3. Simpan metadata ke Firestore
      await _materiService.createMateri(materi);

      if (mounted) {
        _showSnackbar("Materi berhasil diposting!", ContentType.success);
        Navigator.of(context).pop(true); // Kirim 'true' untuk refresh
      }
    } catch (e) {
      print("Error saving materi/uploading file: $e");
      if (mounted) {
        _showSnackbar(
          "Gagal menyimpan materi. Pastikan koneksi dan file valid: ${e.toString().replaceAll('Exception: ', '')}",
          ContentType.warning,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: const Text("Posting Materi Baru"),
        backgroundColor: AppColor.kBackgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _judulController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Materi',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Judul tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deskripsiController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi (Opsional)',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Lampiran:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      labelText: 'Link Materi (Opsional)',
                      hintText: 'Contoh: https://youtube.com/...',
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // tombol pilih file
                  OutlinedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      _pickedFile == null
                          ? 'Upload File (PDF/Simulasi)'
                          : p.basename(_pickedFile!.path),
                    ),
                    onPressed: _pickFile,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _pickedFile != null
                          ? Colors.green
                          : AppColor.kTextColor,
                      side: BorderSide(
                        color: _pickedFile != null ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveMateri,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kPrimaryColor,
                      foregroundColor: AppColor.kWhiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        : const Text('Posting Materi'),
                  ),
                ],
              ),
            ),
    );
  }
}
