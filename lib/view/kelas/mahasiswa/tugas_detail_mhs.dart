import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/submisi_model.dart';
import 'package:project_volt/model/tugas_model.dart';
import 'package:project_volt/model/user_model.dart';

// --- [PERUBAHAN 1: GANTI JADI STATEFUL] ---
class TugasDetailMhs extends StatefulWidget {
  final TugasModel tugas;
  final UserModel user; // <-- [PERUBAHAN 2: Tambah UserModel]

  const TugasDetailMhs({super.key, required this.tugas, required this.user});

  @override
  State<TugasDetailMhs> createState() => _TugasDetailMhsState();
}

class _TugasDetailMhsState extends State<TugasDetailMhs> {
  // --- [PERUBAHAN 3: Tambah State Variables] ---
  late String _tenggatFormatted;
  late Color _tenggatColor;

  bool _isLoadingSubmisi = true; // Loading untuk cek submisi
  bool _isSubmitting = false; // Loading saat menekan tombol "Kumpul"
  SubmisiModel? _submisiSaya;

  final _linkController = TextEditingController();
  File? _pickedFile;
  // ------------------------------------------

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

  // --- [PERUBAHAN 4: Perbarui Logika Deadline & Warna] ---
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
  // ----------------------------------------------------

  // --- [FUNGSI BARU: Load status submisi] ---
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
          // Isi form jika sudah pernah submit
          if (submisi != null) {
            _linkController.text = submisi.linkSubmisi ?? '';
            // Kita tidak bisa me-load ulang File object,
            // tapi kita akan tampilkan namanya di UI
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

  // --- [FUNGSI BARU: Pilih File] ---
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        // Izinkan file simulasi Anda (misal .volt_sim) dan PDF
        allowedExtensions: ['pdf', 'zip', 'volt_sim'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = File(result.files.single.path!);
          // Hapus link jika user memilih file, agar tidak keduanya
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

  // --- [FUNGSI BARU: Kumpul Tugas] ---
  Future<void> _submitTugas() async {
    // Validasi: harus ada link ATAU file
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
      // 1. Salin file jika ada
      if (_pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = p.basename(_pickedFile!.path);
        final uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}_$fileName';
        final newPath = p.join(appDir.path, uniqueFileName);

        await _pickedFile!.copy(newPath);
        filePathToSave = newPath;
      }

      // 2. Buat Model Submisi
      final submisi = SubmisiModel(
        // 'id' akan di-handle 'replace' jika sudah ada
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

      // 3. Simpan ke DB (Create atau Update)
      await DbHelper.createOrUpdateSubmisi(submisi);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tugas berhasil dikumpulkan!'),
            backgroundColor: Colors.green,
          ),
        );
        // Kirim sinyal 'true' ke halaman list agar refresh
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

  // --- [FUNGSI BARU: Batal Kumpul] ---
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
      setState(() => _isSubmitting = true); // Tampilkan loading
      try {
        await DbHelper.deleteSubmisiByTugasAndMahasiswa(
          widget.tugas.id!,
          widget.user.id!,
        );
        // Hapus file lokal jika ada
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
          // Kirim sinyal 'true' agar list refresh
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
                  color: _tenggatColor, // <-- Gunakan warna dari state
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  _tenggatFormatted, // <-- Gunakan teks dari state
                  style: TextStyle(
                    fontSize: 14,
                    color: _tenggatColor, // <-- Gunakan warna dari state
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

            // --- [PERUBAHAN 5: GANTI DENGAN WIDGET DINAMIS] ---
            _isLoadingSubmisi
                ? Center(child: CircularProgressIndicator())
                : _buildSubmissionSection(),
            // -----------------------------------------------
          ],
        ),
      ),
    );
  }

  // --- [PERUBAHAN 6: BANGUN ULANG SUBMISSION SECTION] ---
  Widget _buildSubmissionSection() {
    // Jika sedang submit/batal submit, tampilkan loading
    if (_isSubmitting) {
      return Center(child: CircularProgressIndicator());
    }

    // ---------- JIKA SUDAH MENGUMPULKAN ----------
    if (_submisiSaya != null) {
      final submisi = _submisiSaya!;
      final bool adaFile =
          submisi.filePathSubmisi != null &&
          submisi.filePathSubmisi!.isNotEmpty;
      final bool adaLink =
          submisi.linkSubmisi != null && submisi.linkSubmisi!.isNotEmpty;
      final bool dinilai = submisi.nilai != null && submisi.nilai! > 0;

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
              // Tampilkan Nilai jika sudah ada
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
          // Tampilkan file/link yang disubmit
          if (adaFile)
            _buildSubmittedItem(
              icon: Icons.attach_file,
              text: p.basename(submisi.filePathSubmisi!), // Tampilkan nama file
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
          // Tombol Aksi
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _deleteSubmisi,
                  child: Text("Batal Kumpul"),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Tampilkan form lagi
                    setState(() => _submisiSaya = null);
                  },
                  child: Text("Kumpul Ulang"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimaryColor,
                    foregroundColor: AppColor.kWhiteColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // ---------- JIKA BELUM MENGUMPULKAN (FORM) ----------
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kumpulkan Tugas",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        // Form Link
        TextFormField(
          controller: _linkController,
          decoration: InputDecoration(
            labelText: 'Link Submisi (Opsional)',
            hintText: 'Contoh: https://drive.google.com/...',
            prefixIcon: Icon(Icons.link),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // Hapus file jika user mulai mengetik link
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
        // Tombol Pilih File
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
        // Tombol Submit
        ElevatedButton(
          onPressed: _submitTugas,
          child: Text('Kumpulkan'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            backgroundColor: AppColor.kPrimaryColor,
            foregroundColor: AppColor.kWhiteColor,
          ),
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
