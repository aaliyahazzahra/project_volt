import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/SQF/database/db_helper.dart';
import 'package:project_volt/data/SQF/models/submisi_model.dart';
import 'package:project_volt/data/SQF/models/tugas_model.dart';
import 'package:project_volt/data/SQF/models/user_model.dart';

class TugasDetailMhs extends StatefulWidget {
  final TugasModel tugas;
  final UserModel user;

  const TugasDetailMhs({super.key, required this.tugas, required this.user});

  @override
  State<TugasDetailMhs> createState() => _TugasDetailMhsState();
}

class _TugasDetailMhsState extends State<TugasDetailMhs> {
  late String _tenggatFormatted;
  late Color _tenggatColor;

  bool _isLoadingSubmisi = true;
  bool _isSubmitting = false;
  SubmisiModel? _submisiSaya;

  final _linkController = TextEditingController();
  File? _pickedFile;

  @override
  void initState() {
    super.initState();
    _formatTenggat();
    _loadSubmisi();
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _formatTenggat() {
    if (widget.tugas.tglTenggat == null) {
      _tenggatFormatted = "Tidak ada tenggat waktu.";
      _tenggatColor = Colors.grey[600] ?? Colors.grey;
      return;
    }
    try {
      final tgl = DateTime.parse(widget.tugas.tglTenggat!);
      _tenggatFormatted = "Tenggat: ${DateFormat.yMd().add_Hm().format(tgl)}";

      final now = DateTime.now();
      if (now.isAfter(tgl)) {
        _tenggatColor = Colors.red[700] ?? Colors.red;
      } else if (tgl.isBefore(now.add(const Duration(days: 3)))) {
        _tenggatColor = Colors.orange[800] ?? Colors.orange;
      } else {
        _tenggatColor = Colors.green[700] ?? Colors.green;
      }
    } catch (e) {
      _tenggatFormatted = "Format tanggal salah.";
      _tenggatColor = Colors.red;
    }
  }

  Future<void> _loadSubmisi() async {
    setState(() => _isLoadingSubmisi = true);
    try {
      final submisi = await DbHelper.getSubmisiByTugasAndMahasiswa(
        widget.tugas.id!,
        widget.user.id!,
      );

      if (mounted) {
        setState(() {
          _submisiSaya = submisi;
          if (submisi != null) {
            _linkController.text = submisi.linkSubmisi ?? '';
          }
        });
      }
    } catch (e) {
      print("Error loading submisi: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingSubmisi = false);
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'zip', 'volt_sim'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = File(result.files.single.path!);
          _linkController.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitTugas() async {
    if (_linkController.text.trim().isEmpty && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap sertakan Link atau Upload File.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    String? filePathToSave;

    try {
      if (_pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(_pickedFile!.path);
        final uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}_$fileName';
        final newPath = p.join(appDir.path, uniqueFileName);

        await _pickedFile!.copy(newPath);
        filePathToSave = newPath;
      }

      final submisi = SubmisiModel(
        id: _submisiSaya?.id,
        tugasId: widget.tugas.id!,
        mahasiswaId: widget.user.id!,
        linkSubmisi: _linkController.text.trim().isEmpty
            ? null
            : _linkController.text.trim(),
        filePathSubmisi: filePathToSave, // Path file di HP
        tglSubmit: DateTime.now().toIso8601String(),
        nilai:
            _submisiSaya?.nilai ??
            0, // Pertahankan nilai lama jika kumpul ulang
      );

      await DbHelper.createOrUpdateSubmisi(submisi);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tugas berhasil dikumpulkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengumpulkan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteSubmisi() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Batal Kumpul'),
        content: Text('Anda yakin ingin membatalkan pengumpulan tugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isSubmitting = true);
      try {
        await DbHelper.deleteSubmisiByTugasAndMahasiswa(
          widget.tugas.id!,
          widget.user.id!,
        );
        if (_submisiSaya?.filePathSubmisi != null) {
          final file = File(_submisiSaya!.filePathSubmisi!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Submisi dibatalkan.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membatalkan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Detail Tugas",
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tugas.judul,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColor.kTextColor,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: _tenggatColor,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  _tenggatFormatted,
                  style: TextStyle(
                    fontSize: 14,
                    color: _tenggatColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Divider(height: 32),
            Text(
              "Deskripsi Tugas:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              widget.tugas.deskripsi != null &&
                      widget.tugas.deskripsi!.isNotEmpty
                  ? widget.tugas.deskripsi!
                  : "(Tidak ada deskripsi)",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
            Divider(height: 32),

            _isLoadingSubmisi
                ? Center(child: CircularProgressIndicator())
                : _buildSubmissionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionSection() {
    if (_isSubmitting) {
      return Center(child: CircularProgressIndicator());
    }

    if (_submisiSaya != null) {
      final submisi = _submisiSaya!;
      final bool adaFile =
          submisi.filePathSubmisi != null &&
          submisi.filePathSubmisi!.isNotEmpty;
      final bool adaLink =
          submisi.linkSubmisi != null && submisi.linkSubmisi!.isNotEmpty;
      final bool dinilai = submisi.nilai != null && submisi.nilai! > 0;

      // jika ingin mengumpulkan ulang
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tugas Terkumpul",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (dinilai)
                Chip(
                  label: Text(
                    "Nilai: ${submisi.nilai}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.green[100],
                  avatar: Icon(Icons.check_circle, color: Colors.green[700]),
                ),
            ],
          ),
          SizedBox(height: 16),
          if (adaFile)
            _buildSubmittedItem(
              icon: Icons.attach_file,
              text: p.basename(submisi.filePathSubmisi!),
              onTap: () {
                /* TODO: Buka file lokal */
              },
            ),
          if (adaLink)
            _buildSubmittedItem(
              icon: Icons.link,
              text: submisi.linkSubmisi!,
              onTap: () {
                /* TODO: Buka link */
              },
            ),

          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _deleteSubmisi,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: Text("Batal Kumpul"),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _submisiSaya = null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimaryColor,
                    foregroundColor: AppColor.kWhiteColor,
                  ),
                  child: Text("Kumpul Ulang"),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Jika belum mengumpulkan
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kumpulkan Tugas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _linkController,
          decoration: InputDecoration(
            labelText: 'Link Submisi (Opsional)',
            hintText: 'Contoh: https://drive.google.com/...',
            prefixIcon: Icon(Icons.link),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && _pickedFile != null) {
              setState(() => _pickedFile = null);
            }
          },
        ),
        SizedBox(height: 16),
        Center(
          child: Text("ATAU", style: TextStyle(color: Colors.grey[600])),
        ),
        SizedBox(height: 16),
        OutlinedButton.icon(
          icon: Icon(Icons.attach_file),
          label: Text(
            _pickedFile == null
                ? 'Upload File (PDF/Simulasi)'
                : p.basename(_pickedFile!.path),
          ),
          onPressed: _pickFile,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            foregroundColor: _pickedFile != null
                ? Colors.green
                : AppColor.kTextColor,
            side: BorderSide(
              color: _pickedFile != null ? Colors.green : Colors.grey,
            ),
          ),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submitTugas,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            backgroundColor: AppColor.kPrimaryColor,
            foregroundColor: AppColor.kWhiteColor,
          ),
          child: Text('Kumpulkan'),
        ),
      ],
    );
  }

  // Helper widget untuk menampilkan item yang sudah disubmit
  Widget _buildSubmittedItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColor.kPrimaryColor),
        title: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.open_in_new, size: 20),
        onTap: onTap,
      ),
    );
  }
}
