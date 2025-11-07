import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/materi_model.dart';

class CreateMateriPage extends StatefulWidget {
  final int kelasId;
  const CreateMateriPage({super.key, required this.kelasId});

  @override
  State<CreateMateriPage> createState() => _CreateMateriPageState();
}

class _CreateMateriPageState extends State<CreateMateriPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _linkController = TextEditingController();

  File? _pickedFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  // untuk memilih file
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        // type: FileType.custom,
        // allowedExtensions: ['pdf', 'volt_sim', 'zip'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = File(result.files.single.path!);
        });
      } else {}
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // untuk menyimpan materi
  Future<void> _saveMateri() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_linkController.text.trim().isEmpty && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap sertakan Link Materi atau Upload File.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? filePathToSave;

    try {
      if (_pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(_pickedFile!.path);
        final uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}_$fileName';
        final newPath = p.join(appDir.path, uniqueFileName);

        await _pickedFile!.copy(newPath);
        filePathToSave = newPath; // simpan di DB
      }

      final materi = MateriModel(
        kelasId: widget.kelasId,
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        linkMateri: _linkController.text.trim().isEmpty
            ? null
            : _linkController.text.trim(),
        filePathMateri: filePathToSave,
        tglPosting: DateTime.now().toIso8601String(),
      );

      // Simpan ke DB
      await DbHelper.createMateri(materi);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Materi berhasil diposting!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Kirim 'true' untuk refresh
      }
    } catch (e) {
      print("Error saving materi: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan materi: $e'),
            backgroundColor: Colors.red,
          ),
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
        title: Text("Posting Materi Baru"),
        backgroundColor: AppColor.kBackgroundColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _judulController,
                    decoration: InputDecoration(labelText: 'Judul Materi'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Judul tidak boleh kosong'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _deskripsiController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi (Opsional)',
                    ),
                    maxLines: 4,
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Lampiran:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      labelText: 'Link Materi (Opsional)',
                      hintText: 'Contoh: https://youtube.com/...',
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  SizedBox(height: 16),

                  // tombol pilih file
                  OutlinedButton.icon(
                    icon: Icon(Icons.attach_file),
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

                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveMateri,
                    child: Text('Posting Materi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kPrimaryColor,
                      foregroundColor: AppColor.kWhiteColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
