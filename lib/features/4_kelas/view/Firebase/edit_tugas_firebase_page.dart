import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/tugas_firebase_model.dart';
//  TAMBAH: Import service Tugas Firebase dan model Tugas
import 'package:project_volt/data/firebase/service/tugas_firebase_service.dart';
import 'package:project_volt/widgets/buildtextfield.dart';

class EditTugasFirebasePage extends StatefulWidget {
  //  UBAH TIPE MODEL: TugasModel -> TugasFirebaseModel
  final TugasFirebaseModel tugas;

  const EditTugasFirebasePage({super.key, required this.tugas});

  @override
  State<EditTugasFirebasePage> createState() => _EditTugasFirebasePageState();
}

class _EditTugasFirebasePageState extends State<EditTugasFirebasePage> {
  final _formKey = GlobalKey<FormState>();

  //  INISIASI SERVICE FIREBASE
  final TugasFirebaseService _tugasService = TugasFirebaseService();

  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late TugasFirebaseModel _currentTugasData;

  DateTime? _selectedDateTime;
  bool _isUpdating = false; // State untuk tombol loading

  @override
  void initState() {
    super.initState();
    _currentTugasData = widget.tugas;
    _judulController = TextEditingController(text: _currentTugasData.judul);
    _deskripsiController = TextEditingController(
      text: _currentTugasData.deskripsi,
    );

    // Isi tanggal tenggat jika ada
    if (_currentTugasData.tglTenggat != null) {
      try {
        _selectedDateTime = DateTime.parse(_currentTugasData.tglTenggat!);
      } catch (e) {
        _selectedDateTime = null;
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext dialogContext) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
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

  // Helper untuk menampilkan Awesome Snackbar
  void _showMessage(String message, {bool isError = false}) {
    final snackBarContent = AwesomeSnackbarContent(
      title: isError ? "Error" : "Sukses",
      message: message,
      contentType: isError ? ContentType.failure : ContentType.success,
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

  void _submitUpdate() async {
    final navigator = Navigator.of(context);
    if (_isUpdating) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isUpdating = true);

      final String? tglTenggat = _selectedDateTime?.toIso8601String();

      // Buat model baru dengan data yang diupdate
      final updatedTugas = _currentTugasData.copyWith(
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        tglTenggat: tglTenggat,
      );

      // Cek ID Tugas
      if (updatedTugas.tugasId == null) {
        _showMessage("Error: Tugas ID tidak ditemukan.", isError: true);
        setState(() => _isUpdating = false);
        return;
      }

      try {
        //  Panggil Service Firebase: Update Tugas
        await _tugasService.updateTugas(updatedTugas);

        if (!mounted) return;

        _showMessage("Tugas berhasil diperbarui", isError: false);

        // Kirim sinyal refresh kembali ke halaman daftar tugas
        navigator.pop(true);
      } catch (e) {
        if (!mounted) return;
        _showMessage(
          "Gagal memperbarui tugas: ${e.toString().replaceAll('Exception: ', '')}",
          isError: true,
        );
        print("Update Tugas Error: $e");
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Tugas Ini?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus tugas "${_currentTugasData.judul}"?\n\nTindakan ini tidak dapat dibatalkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
              child: const Text('Ya, Hapus'),
              onPressed: () async {
                final dialogNavigator = Navigator.of(dialogContext);
                final mainNavigator = Navigator.of(context);

                final String? tugasId = _currentTugasData.tugasId;
                if (tugasId == null) return;

                try {
                  //  Panggil Service Firebase: Delete Tugas
                  // CATATAN: Ini hanya menghapus tugas, SUBMISI terkait harus dihapus secara manual di service!
                  await _tugasService.deleteTugas(tugasId);

                  if (!mounted) return;

                  _showMessage("Tugas berhasil dihapus", isError: false);

                  dialogNavigator.pop();
                  mainNavigator.pop(true); // Sinyal refresh
                } catch (e) {
                  if (!mounted) return;
                  _showMessage(
                    "Gagal menghapus tugas: ${e.toString().replaceAll('Exception: ', '')}",
                    isError: true,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Edit Tugas",
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
                Text(
                  "Tanggal Tenggat (Opsional)",
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _isUpdating ? null : () => _pickDateTime(context),
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
                  onPressed: _isUpdating ? null : _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimaryColor,
                    foregroundColor: AppColor.kWhiteColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Update Tugas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Hapus Tugas Ini"),
                  onPressed: _isUpdating ? null : _showDeleteConfirmationDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[700]!),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
