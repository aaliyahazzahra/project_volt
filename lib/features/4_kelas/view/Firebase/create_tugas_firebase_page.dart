// lib/features/4_kelas/view/Firebase/create_tugas_firebase_page.dart

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
//  Import Model dan Service Tugas Firebase
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
import 'package:project_volt/data/firebase/service/tugas_firebase_service.dart';
import 'package:project_volt/features/5_simulasi/create_simulasi_firebase_page.dart';
import 'package:project_volt/widgets/buildtextfield.dart';
// 🎯 Import Model User dan Halaman Simulasi
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';

class CreateTugasFirebasePage extends StatefulWidget {
  //  TAMBAHAN: Menerima User Model Dosen
  final String kelasId;
  final UserFirebaseModel user;

  const CreateTugasFirebasePage({
    super.key,
    required this.kelasId,
    required this.user, // Dosen User Model
  });

  @override
  State<CreateTugasFirebasePage> createState() =>
      _CreateTugasFirebasePageState();
}

class _CreateTugasFirebasePageState extends State<CreateTugasFirebasePage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();

  DateTime? _selectedDateTime;
  bool _isSaving = false;

  // 🎯 STATE BARU: ID Simulasi yang dilampirkan
  String? _simulasiId;

  //  INISIASI SERVICE FIREBASE
  final TugasFirebaseService _tugasService = TugasFirebaseService();

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // --- FUNGSI HELPER UI ---

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

  // --- FUNGSI TANGGAL WAKTU (tetap sama) ---

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateTime ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDateTime ?? DateTime.now(),
        ),
      );

      if (pickedTime != null) {
        final combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedDateTime = combinedDateTime;
        });
      }
    }
  }

  // 🎯 FUNGSI BARU: NAVIGASI KE EDITOR SIMULASI
  void _navigateToSimulationEditor() async {
    if (widget.user.uid == null) {
      _showSnackbar(
        "Error",
        "User ID Dosen tidak ditemukan.",
        ContentType.failure,
      );
      return;
    }

    // Meluncurkan SimulationPage (Editor Simulasi)
    // Asumsi: SimulationPage mengembalikan String ID Simulasi yang baru disimpan.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSimulasiFirebasePage(
          kelasId: widget.kelasId,
          user: widget.user,
        ),
      ),
    );

    if (result != null && result is String) {
      // Jika berhasil disimpan, ID Simulasi akan dikembalikan
      if (mounted) {
        setState(() {
          _simulasiId = result;
        });
        _showSnackbar(
          "Berhasil",
          "Simulasi berhasil dibuat dan dilampirkan!",
          ContentType.success,
        );
      }
    } else if (result == true && mounted) {
      // fallback jika SimulationPage hanya mengembalikan boolean 'true'
      // Untuk tujuan demo, kita akan mengasumsikan ID baru (tapi ini kurang disarankan)
      _showSnackbar(
        "Perhatian",
        "Simulasi berhasil disimpan, tetapi ID tidak diterima.",
        ContentType.warning,
      );
    }
  }

  // --- LOGIKA UTAMA: SUBMIT FORM / CREATE TUGAS FIREBASE ---

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackbar(
        "Peringatan",
        "Harap isi Judul Tugas.",
        ContentType.warning,
      );
      return;
    }

    if (_selectedDateTime == null) {
      _showSnackbar(
        "Peringatan",
        "Harap tentukan tanggal tenggat waktu.",
        ContentType.warning,
      );
      return;
    }

    // Cek jika tugas adalah simulasi, harus ada simulasi yang dilampirkan
    // Jika Anda ingin semua tugas harus memiliki simulasi, aktifkan cek ini:
    /*
    if (_simulasiId == null && isSimulasiType) {
         _showSnackbar("Peringatan", "Tugas simulasi harus melampirkan proyek simulasi.", ContentType.warning);
         return;
    }
    */

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final newTugas = TugasFirebaseModel(
        kelasId: widget.kelasId,
        dosenId: widget.user.uid!, //  Masukkan ID Dosen dari User Model
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        tglDibuat: DateTime.now(), // Tambahkan tgl dibuat
        tglTenggat: _selectedDateTime,
        simulasiId: _simulasiId, // 🎯 Lampirkan ID Simulasi jika ada
      );

      //  Panggil Service Firebase
      await _tugasService.createTugas(newTugas);

      if (!mounted) return;

      _showSnackbar(
        "Sukses",
        "Tugas berhasil dipublikasikan!",
        ContentType.success,
      );
      Navigator.pop(context, true); // Pop dengan sinyal refresh
    } catch (e) {
      if (!mounted) return;

      print("Create Tugas Error: $e");
      _showSnackbar(
        "Error",
        "Gagal membuat tugas. ${e.toString().replaceAll('Exception: ', '')}",
        ContentType.failure,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan user model memiliki UID
    if (widget.user.uid == null) {
      return const Scaffold(
        body: Center(child: Text("Error: Dosen ID tidak tersedia.")),
      );
    }

    final String tenggatFormatted = _selectedDateTime == null
        ? 'Pilih Tanggal dan Waktu'
        : DateFormat.yMd().add_Hm().format(_selectedDateTime!);

    final bool isSimulasiAttached = _simulasiId != null;

    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: const Text("Buat Tugas Baru"),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
        foregroundColor: AppColor.kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // --- Input Judul ---
                BuildTextField(
                  labelText: "Judul Tugas",
                  controller: _judulController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul Tugas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // --- Input Deskripsi ---
                BuildTextField(
                  labelText: "Deskripsi (Opsional)",
                  controller: _deskripsiController,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),

                // --- Pilihan Tanggal Tenggat ---
                Text(
                  "Tanggal Tenggat",
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      isSimulasiAttached
                          ? Icons.check_circle
                          : Icons.integration_instructions_outlined,
                      color: isSimulasiAttached
                          ? Colors.green
                          : AppColor.kPrimaryColor,
                    ),
                    title: Text(
                      isSimulasiAttached
                          ? "Simulasi Terlampir (Siap)"
                          : "Lampirkan Proyek Simulasi",
                    ),
                    subtitle: isSimulasiAttached
                        ? const Text(
                            "Tugas ini berupa proyek Simulasi Logika Digital.",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          )
                        : const Text(
                            "Tugas akan dianggap sebagai pengumpulan dokumen standar.",
                          ),
                    trailing: isSimulasiAttached
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColor.kErrorColor,
                            ),
                            onPressed: () => setState(() => _simulasiId = null),
                            tooltip: 'Hapus Lampiran Simulasi',
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _isSaving || isSimulasiAttached
                        ? null
                        : _navigateToSimulationEditor,
                  ),
                ),
                const SizedBox(height: 30),

                // 🎯 BAGIAN BARU: LAMPIRKAN SIMULASI
                Text(
                  "Lampiran Tugas",
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      isSimulasiAttached
                          ? Icons.check_circle
                          : Icons.integration_instructions_outlined,
                      color: isSimulasiAttached
                          ? Colors.green
                          : AppColor.kPrimaryColor,
                    ),
                    title: Text(
                      isSimulasiAttached
                          ? "Simulasi Terlampir (Siap)"
                          : "Lampirkan Proyek Simulasi",
                    ),
                    subtitle: isSimulasiAttached
                        ? const Text(
                            "Tugas ini berupa proyek Simulasi Logika Digital.",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          )
                        : const Text(
                            "Tugas akan dianggap sebagai pengumpulan dokumen standar.",
                          ),
                    trailing: isSimulasiAttached
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColor.kErrorColor,
                            ),
                            onPressed: () => setState(() => _simulasiId = null),
                            tooltip: 'Hapus Lampiran Simulasi',
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _isSaving || isSimulasiAttached
                        ? null
                        : _navigateToSimulationEditor, // Tidak bisa melampirkan 2 kali
                  ),
                ),
                const SizedBox(height: 30),

                // --- Tombol Simpan ---
                ElevatedButton(
                  onPressed: _isSaving ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimaryColor,
                    foregroundColor: AppColor.kWhiteColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Publikasikan Tugas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
