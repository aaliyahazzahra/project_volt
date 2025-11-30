// lib/features/4_kelas/view/Firebase/submisi_detail_dosen_firebase.dart

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/simulasi_firebase_model.dart';
import 'package:project_volt/data/firebase/service/simulasi_firebase_service.dart';
import 'package:project_volt/data/firebase/service/submisi_firebase_service.dart';
import 'package:project_volt/data/firebase/service/tugas_firebase_service.dart';
import 'package:project_volt/features/5_simulasi/create_simulasi_firebase_page.dart';
// --- IMPORT BARU UNTUK MEMBUKA URL (Penyelesaian TODO) ---
import 'package:url_launcher/url_launcher.dart';
// --------------------------------------------------------

class SubmisiDetailPage extends StatefulWidget {
  final SubmisiDetailFirebase detail;

  const SubmisiDetailPage({super.key, required this.detail});

  @override
  State<SubmisiDetailPage> createState() => _SubmisiDetailPageState();
}

class _SubmisiDetailPageState extends State<SubmisiDetailPage> {
  final TextEditingController _nilaiController = TextEditingController();
  final SubmisiFirebaseService _submisiService = SubmisiFirebaseService();
  final SimulasiFirebaseService _simulasiService =
      SimulasiFirebaseService(); // Service Simulasi
  final TugasFirebaseService _tugasService = TugasFirebaseService();

  bool _isSaving = false;

  // State untuk menyimpan data Simulasi Jawaban Mahasiswa
  SimulasiFirebaseModel? _simulasiJawaban;

  @override
  void initState() {
    super.initState();
    // Isi nilai yang sudah ada (jika sudah pernah dinilai)
    if (widget.detail.submisi.nilai != null) {
      _nilaiController.text = widget.detail.submisi.nilai.toString();
    }

    // Muat data simulasi jawaban jika ada
    if (widget.detail.submisi.simulasiSubmisiId != null) {
      _loadSimulasiJawaban(widget.detail.submisi.simulasiSubmisiId!);
    }
  }

  @override
  void dispose() {
    _nilaiController.dispose();
    super.dispose();
  }

  // --- LOGIC LOADING SIMULASI JAWABAN ---

  Future<void> _loadSimulasiJawaban(String simulasiId) async {
    try {
      final data = await _simulasiService.getSimulasiById(simulasiId);
      if (mounted && data != null) {
        setState(() {
          _simulasiJawaban = data;
        });
      }
    } catch (e) {
      _showSnackbar(
        "Error",
        "Gagal memuat proyek simulasi jawaban: ${e.toString()}",
        ContentType.failure,
      );
    }
  }

  // --- LOGIC NAVIGATION / VIEW SIMULASI ---

  void _viewSimulasiJawaban() async {
    if (_simulasiJawaban == null) return;

    //    LANGKAH 1: Dapatkan data Tugas untuk mendapatkan kelasId
    final tugas = await _tugasService.getTugasById(
      widget.detail.submisi.tugasId,
    );

    if (tugas == null || tugas.kelasId.isEmpty) {
      // Handle jika Tugas atau ID Kelas tidak ditemukan
      _showSnackbar(
        "Error",
        "Gagal memuat konteks kelas.",
        ContentType.failure,
      );
      return;
    }

    // Dosen membuka Editor Simulasi dalam mode Read-Only
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSimulasiFirebasePage(
          //    KOREKSI: Ambil kelasId dari Tugas yang dimuat
          kelasId: tugas.kelasId,
          user: widget.detail.mahasiswa,
          loadSimulasiId: _simulasiJawaban!.simulasiId,
          isReadOnly: true,
        ),
      ),
    );
  }

  // --- LOGIC PENILAIAN & SNACKBAR ---

  void _showSnackbar(String title, String message, ContentType type) {
    final snackBarContent = AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: type,
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

  Future<void> _submitNilai() async {
    final int? nilai = int.tryParse(_nilaiController.text);

    if (nilai == null || nilai < 0 || nilai > 100) {
      _showSnackbar(
        "Peringatan",
        "Nilai harus angka antara 0 hingga 100.",
        ContentType.warning,
      );
      return;
    }
    if (widget.detail.submisi.submisiId == null) {
      _showSnackbar(
        "Error",
        "ID Submisi tidak ditemukan.",
        ContentType.failure,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      //   Panggil service untuk mengupdate nilai
      await _submisiService.updateNilai(
        submisiId: widget.detail.submisi.submisiId!,
        nilai: nilai,
      );

      if (mounted) {
        _showSnackbar(
          "Sukses",
          "Nilai berhasil disimpan!",
          ContentType.success,
        );
        // Kembali ke daftar submisi dan refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar(
          "Gagal",
          "Gagal menyimpan nilai: ${e.toString()}",
          ContentType.failure,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- LOGIC MEMBUKA URL (Penyelesaian TODO) ---

  Future<void> _openFileUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);

    try {
      // Menggunakan LaunchMode.externalApplication agar file diunduh/dibuka di browser
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showSnackbar(
          "Gagal",
          "Tidak dapat membuka link: $url",
          ContentType.failure,
        );
      }
    } catch (e) {
      _showSnackbar(
        "Gagal",
        "Terjadi kesalahan saat mencoba membuka link.",
        ContentType.failure,
      );
    }
  }

  // --- WIDGET BUILDER ---

  Widget _buildSubmisiContent() {
    final submisi = widget.detail.submisi;

    // Tampilan Konten Submisi Simulasi
    if (submisi.simulasiSubmisiId != null) {
      return Card(
        color: AppColor.kLightAccentColor,
        child: ListTile(
          leading: const Icon(
            Icons.developer_board,
            color: AppColor.kPrimaryColor,
          ),
          title: const Text("Proyek Simulasi (Jawaban)"),
          subtitle: Text(
            _simulasiJawaban == null
                ? "Memuat data simulasi..."
                : _simulasiJawaban!.judul,
          ),
          trailing: _simulasiJawaban != null
              ? const Icon(Icons.arrow_forward_ios)
              : null,
          onTap: _simulasiJawaban != null ? _viewSimulasiJawaban : null,
        ),
      );
    }

    // Tampilan Konten Submisi File Standar (Membuka URL Supabase)
    if (submisi.filePathSubmisi != null || submisi.linkSubmisi != null) {
      final String path = submisi.filePathSubmisi ?? submisi.linkSubmisi!;
      return Card(
        child: ListTile(
          leading: const Icon(Icons.attach_file, color: AppColor.kPrimaryColor),
          title: const Text("Lampiran File Jawaban"),
          subtitle: Text(path.split('/').last),
          trailing: const Icon(Icons.visibility),
          onTap: () {
            // Penyelesaian TODO: Panggil fungsi _openFileUrl
            _openFileUrl(path);
          },
        ),
      );
    }

    return const Center(
      child: Text("Mahasiswa belum mengirimkan lampiran jawaban."),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submisi = widget.detail.submisi;
    final mahasiswa = widget.detail.mahasiswa;

    final String tglSubmitFormatted = submisi.tglSubmit != null
        ? DateFormat('EEEE, dd MMM yyyy HH:mm').format(submisi.tglSubmit!)
        : 'Belum disubmit';

    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: Text("Nilai Tugas: ${mahasiswa.namaLengkap}"),
        backgroundColor: AppColor.kPrimaryColor,
        foregroundColor: AppColor.kWhiteColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Info Mahasiswa & Status ---
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColor.kIconBgColor,
                child: Text(
                  mahasiswa.namaLengkap[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                mahasiswa.namaLengkap,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(mahasiswa.nimNidn ?? mahasiswa.email),
              trailing: Chip(
                label: Text(
                  submisi.status,
                  style: TextStyle(
                    color: submisi.status == 'DINILAI'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                backgroundColor: submisi.status == 'DINILAI'
                    ? Colors.green[100]
                    : Colors.orange[100],
              ),
            ),
            const Divider(),

            // --- Tanggal Submit ---
            Text(
              "Terkirim: $tglSubmitFormatted",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // --- Konten Submisi ---
            const Text(
              "Konten Jawaban",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSubmisiContent(),
            const SizedBox(height: 30),

            // --- Form Penilaian ---
            const Text(
              "Berikan Nilai (0-100)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nilaiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Nilai",
                suffixText: "/ 100",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // --- Tombol Simpan Nilai ---
            ElevatedButton(
              onPressed: _isSaving ? null : _submitNilai,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.kPrimaryColor,
                foregroundColor: AppColor.kWhiteColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: AppColor.kWhiteColor)
                  : Text(submisi.nilai != null ? 'UBAH NILAI' : 'SIMPAN NILAI'),
            ),
          ],
        ),
      ),
    );
  }
}
