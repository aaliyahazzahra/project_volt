import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/materi_firebase_model.dart';
import 'package:project_volt/data/firebase/service/materi_firebase_service.dart';

class CreateMateriFirebasePage extends StatefulWidget {
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

  void _showSnackbar(String message, ContentType type) {
    if (!mounted) return;

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

  Future<void> _saveMateri() async {
    // 1. VALIDASI JUDUL
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. VALIDASI KONTEN MINIMAL (Logika baru)
    final bool hasDescription = _deskripsiController.text.trim().isNotEmpty;
    final bool hasLink = _linkController.text.trim().isNotEmpty;
    final bool hasFile = _pickedFile != null;

    if (!hasDescription && !hasLink && !hasFile) {
      _showSnackbar(
        "Harap sertakan Deskripsi atau Link Materi.",
        ContentType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    String? fileUrl;

    try {
      // 3. UPLOAD FILE ke Firebase Storage
      if (_pickedFile != null) {
        fileUrl = await _materiService.uploadFile(_pickedFile!, widget.kelasId);
      }

      // 4. Buat Model Firebase
      final materi = MateriFirebaseModel(
        kelasId: widget.kelasId,
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim().isEmpty
            ? null
            : _deskripsiController.text.trim(),
        linkMateri: _linkController.text.trim().isEmpty
            ? null
            : _linkController.text.trim(),
        filePathMateri: fileUrl,
        tglPosting: DateTime.now().toIso8601String(),
      );

      // 5. Simpan metadata ke Firestore
      await _materiService.createMateri(materi);

      if (mounted) {
        _showSnackbar("Materi berhasil diposting!", ContentType.success);
        Navigator.of(context).pop(true);
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
