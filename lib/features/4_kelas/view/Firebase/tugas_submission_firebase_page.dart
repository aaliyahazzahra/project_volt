// lib/features/4_kelas/view/Firebase/tugas_submission_firebase_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/submisi_firebase_model.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/submisi_firebase_service.dart';
import 'package:project_volt/features/5_simulasi/create_simulasi_firebase_page.dart';

class TugasSubmissionFirebasePage extends StatefulWidget {
  final TugasFirebaseModel tugas;
  final UserFirebaseModel user;

  const TugasSubmissionFirebasePage({
    super.key,
    required this.tugas,
    required this.user,
  });

  @override
  State<TugasSubmissionFirebasePage> createState() =>
      _TugasSubmissionFirebasePageState();
}

class _TugasSubmissionFirebasePageState
    extends State<TugasSubmissionFirebasePage> {
  //  FIREBASE SERVICE
  final SubmisiFirebaseService _submisiService = SubmisiFirebaseService();

  // State untuk status submisi
  bool _isSubmitting = false;
  bool _isSimulasiAttached = false;

  // State Submisi
  String? _submittedSimulasiId;
  String? _submittedFilePath;
  SubmisiFirebaseModel? _currentSubmisi;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isSimulasiAttached = widget.tugas.simulasiId != null;
    _loadCurrentSubmisi();
  }

  // --- FUNGSI MUAT STATUS SUBMISI (Implementasi) ---

  Future<void> _loadCurrentSubmisi() async {
    if (widget.tugas.tugasId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Panggil service untuk mendapatkan Submisi Mahasiswa berdasarkan tugasId dan userId.
    final submisi = await _submisiService.getSubmisiByTugasAndMahasiswa(
      widget.tugas.tugasId!,
      widget.user.uid,
    );

    if (mounted) {
      setState(() {
        _currentSubmisi = submisi;
        // Asumsi model sudah memiliki simulasiSubmisiId
        _submittedSimulasiId = submisi?.simulasiSubmisiId;
        _submittedFilePath = submisi?.filePathSubmisi;
        _isLoading = false;
      });
    }
  }

  // --- LOGIKA SUBMIT ---

  //   FUNGSI UNTUK TUGAS NON-SIMULASI (Placeholder File Picker)
  void _pickAndSubmitFile() async {
    // 💡 Implementasi File Picker (Menggunakan Path Dummy untuk saat ini)
    if (_isSubmitting) return;

    // TODO: Ganti dengan FilePicker.platform.pickFiles
    const String dummyFilePath = "path/to/submission/answer_file.pdf";

    if (dummyFilePath.isNotEmpty && mounted) {
      _submitSubmisi(filePath: dummyFilePath, status: 'DISUBMIT');
    }
  }

  //   FUNGSI UNTUK TUGAS SIMULASI (Kerjakan Proyek)
  void _navigateToSimulationWorkspace() async {
    if (_isSubmitting || widget.tugas.simulasiId == null) return;

    // Navigasi ke Editor Simulasi, dengan ID Simulasi Dosen sebagai template
    final String? resultSimulasiId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSimulasiFirebasePage(
          kelasId: widget.tugas.kelasId,
          user: widget.user,
          //  Meload simulasi Dosen sebagai template
          loadSimulasiId: widget.tugas.simulasiId!,
        ),
      ),
    );

    if (resultSimulasiId != null && mounted) {
      // Jika Mahasiswa berhasil menyimpan JAWABAN simulasi (SimulasiId baru)
      _submitSubmisi(simulasiId: resultSimulasiId, status: 'DISUBMIT');
    }
  }

  // --- LOGIKA INTI: MENGIRIM SUBMISI KE FIREBASE (Implementasi) ---

  Future<void> _submitSubmisi({
    String? filePath,
    String? simulasiId,
    required String status,
  }) async {
    if (_isSubmitting || widget.tugas.tugasId == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Cek apakah ada submisi sebelumnya untuk update
      final String? submisiIdToUpdate = _currentSubmisi?.submisiId;

      final submisiToSave = _currentSubmisi != null
          ? _currentSubmisi!.copyWith(
              // Update fields
              simulasiSubmisiId: simulasiId,
              filePathSubmisi: filePath,
              tglSubmit: DateTime.now(),
              status: status,
            )
          : SubmisiFirebaseModel(
              // Buat baru
              tugasId: widget.tugas.tugasId!,
              mahasiswaId: widget.user.uid,
              tglSubmit: DateTime.now(),
              filePathSubmisi: filePath,
              simulasiSubmisiId: simulasiId,
              status: status,
            );

      //  Panggil service untuk membuat atau mengupdate submisi
      await _submisiService.createOrUpdateSubmisi(submisiToSave);

      if (mounted) {
        // Tampilkan notifikasi sukses dan refresh status
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tugas berhasil disubmit! Status: $status')),
        );
        _loadCurrentSubmisi();
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Submisi Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal submit tugas: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --- WIDGET BUILDER ---

  Widget _buildSubmissionButton() {
    final String label =
        _currentSubmisi != null && _currentSubmisi!.status == 'DISUBMIT'
        ? 'Ulangi Submisi'
        : 'Kirim Jawaban';

    // Tugas Simulasi
    if (_isSimulasiAttached) {
      final simLabel = _submittedSimulasiId != null
          ? 'Ulangi Mengerjakan Simulasi'
          : 'Kerjakan Simulasi';
      return ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _navigateToSimulationWorkspace,
        icon: const Icon(Icons.check),
        label: Text(simLabel),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.kAccentColor,
          foregroundColor: AppColor.kWhiteColor,
          minimumSize: const Size(double.infinity, 50),
        ),
      );
    }

    // Tugas File Standar
    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : _pickAndSubmitFile,
      icon: const Icon(Icons.upload_file),
      label: Text(
        _submittedFilePath != null
            ? 'Ganti File Submisi'
            : 'Unggah File Jawaban',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.kAccentColor,
        foregroundColor: AppColor.kWhiteColor,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildTugasInfo() {
    final String tenggatFormatted = widget.tugas.tglTenggat != null
        ? DateFormat('EEEE, dd MMM yyyy HH:mm').format(widget.tugas.tglTenggat!)
        : 'Tidak ada tenggat waktu';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.tugas.judul,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColor.kPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tenggat: $tenggatFormatted",
          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
        const Divider(height: 20),
        Text(
          "Instruksi Tugas:",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          widget.tugas.deskripsi ?? "Tidak ada deskripsi/instruksi.",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tugas.judul),
        backgroundColor: AppColor.kAccentColor,
        foregroundColor: AppColor.kWhiteColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Tugas Info ---
                  _buildTugasInfo(),

                  // --- Status Submisi ---
                  const Text(
                    "Area Pengumpulan Tugas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  // Tampilkan status submisi saat ini (jika sudah pernah submit)
                  if (_currentSubmisi != null)
                    ListTile(
                      leading: Icon(
                        _currentSubmisi!.status == 'DISUBMIT'
                            ? Icons.done_all
                            : Icons.warning_amber,
                        color: _currentSubmisi!.status == 'DISUBMIT'
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text("Status Submisi: ${_currentSubmisi!.status}"),
                      subtitle: Text(
                        "Dikirim pada: ${DateFormat('dd MMM HH:mm').format(_currentSubmisi!.tglSubmit!)}",
                      ),
                      trailing: _currentSubmisi!.nilai != null
                          ? Chip(
                              label: Text("Nilai: ${_currentSubmisi!.nilai}"),
                            )
                          : null,
                      contentPadding: EdgeInsets.zero,
                    ),

                  _buildSubmissionButton(),

                  // Tampilkan detail file/simulasi yang sudah disubmit
                  if (_submittedFilePath != null)
                    ListTile(
                      title: const Text("File Terkirim"),
                      subtitle: Text(_submittedFilePath!.split('/').last),
                      leading: const Icon(Icons.attach_file),
                    ),
                  if (_submittedSimulasiId != null)
                    const ListTile(
                      title: Text("Proyek Simulasi Terkirim"),
                      subtitle: Text(
                        "Simulasi berhasil disimpan sebagai jawaban.",
                      ),
                      leading: Icon(Icons.check, color: Colors.green),
                    ),

                  if (_isSubmitting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
