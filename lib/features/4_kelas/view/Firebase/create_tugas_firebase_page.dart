import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
// 🔥 TAMBAH: Import service Tugas Firebase dan model Tugas
import 'package:project_volt/data/firebase/service/tugas_firebase_service.dart';
import 'package:project_volt/widgets/buildtextfield.dart';

class CreateTugasFirebasePage extends StatefulWidget {
  // 🔥 UBAH TIPE DATA: kelasId dari int menjadi String (UID Kelas)
  final String kelasId;
  const CreateTugasFirebasePage({super.key, required this.kelasId});

  @override
  State<CreateTugasFirebasePage> createState() => _CreateTugasPageState();
}

class _CreateTugasPageState extends State<CreateTugasFirebasePage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();

  DateTime? _selectedDateTime;
  bool _isSaving = false; // State untuk loading button

  // 🔥 INISIASI SERVICE FIREBASE
  final TugasFirebaseService _tugasService = TugasFirebaseService();

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context) async {
    // ... (Logika Date and Time Picker tetap sama)
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      // locale: const Locale('id', 'ID'),
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_isSaving) return;

      setState(() {
        _isSaving = true;
      });

      // Simpan sebagai ISO string
      final String? tglTenggat = _selectedDateTime?.toIso8601String();

      // 🔥 1. Buat TugasModelFirebase (menggunakan kelasId String)
      final newTugas = TugasFirebaseModel(
        kelasId: widget.kelasId, // Sudah String
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        tglTenggat: tglTenggat,
      );

      try {
        // 🔥 2. Panggil Service Firebase
        await _tugasService.createTugas(newTugas);

        if (!mounted) return;

        final snackBarContent = AwesomeSnackbarContent(
          title: "Sukses",
          message: "Tugas berhasil dibuat!",
          contentType: ContentType.success,
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

        // 3. Navigasi kembali setelah sukses
        Navigator.pop(context, true); // Pop dengan sinyal refresh
      } catch (e) {
        if (!mounted) return;

        final snackBarContent = AwesomeSnackbarContent(
          title: "Error",
          message:
              "Gagal membuat tugas. ${e.toString().replaceAll('Exception: ', '')}",
          contentType: ContentType.warning,
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
        print("Create Tugas Error: $e");
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
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
          "Buat Tugas Baru",
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
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
                BuildTextField(
                  labelText: "Deskripsi (Opsional)",
                  controller: _deskripsiController,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),

                // Input Tanggal Tenggat
                Text(
                  "Tanggal Tenggat (Opsional)",
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _isSaving ? null : () => _pickDateTime(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDateTime == null
                              ? 'Pilih Tanggal dan Waktu'
                              : DateFormat.yMd().add_Hm().format(
                                  _selectedDateTime!,
                                ),

                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedDateTime == null
                                ? Colors.grey[600]
                                : Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColor.kPrimaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : _submitForm, // Matikan tombol saat saving
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
                          'Simpan Tugas',
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
