import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/service/submisi_firebase_service.dart';
import 'package:project_volt/data/firebase/models/submisi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

class TugasDetailMhsFirebase extends StatefulWidget {
  final TugasFirebaseModel tugas;
  final UserFirebaseModel user;

  const TugasDetailMhsFirebase({
    super.key,
    required this.tugas,
    required this.user,
  });

  @override
  State<TugasDetailMhsFirebase> createState() => _TugasDetailMhsFirebaseState();
}

class _TugasDetailMhsFirebaseState extends State<TugasDetailMhsFirebase> {
  //  INISIASI SERVICE FIREBASE
  final SubmisiFirebaseService _submisiService = SubmisiFirebaseService();

  late String _tenggatFormatted;
  late Color _tenggatColor;

  bool _isLoadingSubmisi = true;
  bool _isSubmitting = false;
  SubmisiFirebaseModel? _submisiSaya;

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

  // --- Logika Formatting Tenggat Waktu (Tidak Berubah) ---
  void _formatTenggat() {
    // ... (kode tetap sama)
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

  //  UPDATE LOGIKA LOAD SUBMISI (Menggunakan FirebaseService)
  Future<void> _loadSubmisi() async {
    setState(() => _isLoadingSubmisi = true);

    final String? tugasId = widget.tugas.tugasId;
    final String? userUid = widget.user.uid;

    if (tugasId == null || userUid == null) {
      if (mounted) setState(() => _isLoadingSubmisi = false);
      return;
    }

    try {
      //  Panggil service Firebase dengan ID string
      final submisi = await _submisiService.getSubmisiByTugasAndMahasiswa(
        tugasId,
        userUid,
      );

      if (mounted) {
        setState(() {
          _submisiSaya = submisi;
          if (submisi != null) {
            _linkController.text = submisi.linkSubmisi ?? '';
            // NOTE: Karena file sekarang di cloud, kita tidak memuat file lokal.
            // _pickedFile akan tetap null saat memuat submisi lama.
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

  // --- Logika File Picker (Hampir tidak berubah) ---
  Future<void> _pickFile() async {
    // ... (kode tetap sama)
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

  //  UPDATE LOGIKA SUBMIT (Menggunakan FirebaseService + Cloud Storage)
  Future<void> _submitTugas() async {
    if (_linkController.text.trim().isEmpty && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap sertakan Link atau Upload File.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final String? tugasId = widget.tugas.tugasId;
    final String? userUid = widget.user.uid;
    if (tugasId == null || userUid == null) return;

    setState(() => _isSubmitting = true);

    //  GANTI: filePathToSave sekarang adalah URL Cloud Storage
    String? fileUrl;

    try {
      // 1. Jika ada file, UPLOAD ke Firebase Storage
      if (_pickedFile != null) {
        // ASUMSI: uploadSubmisiFile ada di SubmisiFirebaseService
        fileUrl = await _submisiService.uploadSubmisiFile(
          _pickedFile!,
          tugasId,
          userUid,
        );
      } else if (_submisiSaya != null &&
          _submisiSaya!.filePathSubmisi != null) {
        // Jika submisi ulang, tapi tidak upload file baru, pertahankan URL lama
        fileUrl = _submisiSaya!.filePathSubmisi;
      }

      // 2. Buat Model Submisi Firebase
      final submisi = SubmisiFirebaseModel(
        // ID Dokumen Submisi akan otomatis digenerate/ditimpa berdasarkan tugasId_mahasiswaId
        tugasId: tugasId,
        mahasiswaId: userUid,
        linkSubmisi: _linkController.text.trim().isEmpty
            ? null
            : _linkController.text.trim(),
        //  Simpan URL CLOUD STORAGE
        filePathSubmisi: fileUrl,
        tglSubmit: DateTime.now().toIso8601String(),
        nilai: _submisiSaya?.nilai ?? 0,
      );

      // 3. Simpan/Update Metadata di Firestore
      await _submisiService.createOrUpdateSubmisi(
        submisi,
      ); // Menggunakan unique ID gabungan

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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

  //  UPDATE LOGIKA DELETE SUBMISI (Menggunakan FirebaseService + Cloud Storage)
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
      final String? tugasId = widget.tugas.tugasId;
      final String? userUid = widget.user.uid;
      if (tugasId == null || userUid == null) return;

      setState(() => _isSubmitting = true);

      try {
        // 1. Hapus File dari Cloud Storage (jika ada)
        if (_submisiSaya?.filePathSubmisi != null) {
          // ASUMSI: deleteSubmisiFile ada di SubmisiFirebaseService
          await _submisiService.deleteSubmisiFile(
            _submisiSaya!.filePathSubmisi!,
          );
        }

        // 2. Hapus Metadata dari Firestore
        await _submisiService.deleteSubmisiByTugasAndMahasiswa(
          tugasId,
          userUid,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
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
    // ... (Tampilan Widget Build tetap sama)
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: _tenggatColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
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
            const Divider(height: 32),
            const Text(
              "Deskripsi Tugas:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
            const Divider(height: 32),

            _isLoadingSubmisi
                ? const Center(child: CircularProgressIndicator())
                : _buildSubmissionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionSection() {
    if (_isSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_submisiSaya != null) {
      final submisi = _submisiSaya!;
      // NOTE: File path is now a URL
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
              const Text(
                "Tugas Terkumpul",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (dinilai)
                Chip(
                  label: Text(
                    "Nilai: ${submisi.nilai}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.green[100],
                  avatar: Icon(Icons.check_circle, color: Colors.green[700]),
                ),
            ],
          ),
          const SizedBox(height: 16),
          //  Display item SUBMITTED
          if (adaFile)
            _buildSubmittedItem(
              icon: Icons.attach_file,
              // Karena ini URL, kita hanya menampilkan nama file yang diekstrak (atau URL penuh)
              text: submisi.filePathSubmisi!,
              onTap: () {
                /* TODO: Buka URL Cloud Storage */
                // launchUrl(Uri.parse(submisi.filePathSubmisi!));
              },
            ),
          if (adaLink)
            _buildSubmittedItem(
              icon: Icons.link,
              text: submisi.linkSubmisi!,
              onTap: () {
                /* TODO: Buka link */
                // launchUrl(Uri.parse(submisi.linkSubmisi!));
              },
            ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : _deleteSubmisi,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text("Batal Kumpul"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          // Reset state untuk formulir
                          _linkController.text = submisi.linkSubmisi ?? '';
                          _pickedFile = null;
                          setState(() => _submisiSaya = null);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimaryColor,
                    foregroundColor: AppColor.kWhiteColor,
                  ),
                  child: const Text("Kumpul Ulang"),
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
        const Text(
          "Kumpulkan Tugas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _linkController,
          decoration: const InputDecoration(
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
        const SizedBox(height: 16),
        Center(
          child: Text("ATAU", style: TextStyle(color: Colors.grey[600])),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.attach_file),
          label: Text(
            _pickedFile == null
                ? 'Upload File (PDF/Simulasi)'
                : p.basename(_pickedFile!.path),
          ),
          onPressed: _isSubmitting ? null : _pickFile,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            foregroundColor: _pickedFile != null
                ? Colors.green
                : AppColor.kTextColor,
            side: BorderSide(
              color: _pickedFile != null ? Colors.green : Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitTugas,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppColor.kPrimaryColor,
            foregroundColor: AppColor.kWhiteColor,
          ),
          child: const Text('Kumpulkan'),
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
        trailing: const Icon(Icons.open_in_new, size: 20),
        onTap: onTap,
      ),
    );
  }
}
