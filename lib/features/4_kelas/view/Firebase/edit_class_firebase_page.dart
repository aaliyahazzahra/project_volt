// HAPUS SQF IMPORT: import 'package:project_volt/data/SQF/models/kelas_model.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/service/kelas_firebase_service.dart';
import 'package:project_volt/widgets/buildtextfield.dart';

class EditClassFirebasePage extends StatefulWidget {
  // 🔥 UBAH TIPE MODEL: KelasModel -> KelasModelFirebase
  final KelasFirebaseModel kelas;
  const EditClassFirebasePage({super.key, required this.kelas});

  @override
  State<EditClassFirebasePage> createState() => _EditClassState();
}

class _EditClassState extends State<EditClassFirebasePage> {
  final _formKey = GlobalKey<FormState>();

  // 🔥 INISIASI SERVICE FIREBASE
  final KelasFirebaseService _kelasService = KelasFirebaseService();

  late TextEditingController _deskripsiController;
  late KelasFirebaseModel _currentKelasData; // 🔥 UBAH TIPE MODEL

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentKelasData = widget.kelas;
    _deskripsiController = TextEditingController(
      text: _currentKelasData.deskripsi,
    );
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    super.dispose();
  }

  void _submitUpdate() async {
    final navigator = Navigator.of(context);
    if (_isUpdating) return;

    if (_formKey.currentState!.validate()) {
      setState(() => _isUpdating = true);

      // 🔥 1. Buat model yang diperbarui
      final updatedModel = _currentKelasData.copyWith(
        deskripsi: _deskripsiController.text.trim(),
      );

      // Pastikan ID kelas ada sebelum update
      if (updatedModel.kelasId == null) {
        _showMessage("Error: Kelas ID tidak ditemukan.", isError: true);
        setState(() => _isUpdating = false);
        return;
      }

      try {
        // 🔥 2. Panggil Service Firebase: Update Kelas
        await _kelasService.updateKelas(updatedModel);

        if (!mounted) return;

        // Tampilkan snackbar sukses
        _showMessage("Deskripsi berhasil diperbarui!", isError: false);

        // Perbarui data lokal state agar konsisten (meskipun akan di-refresh oleh halaman parent)
        _currentKelasData = updatedModel;

        // 3. Navigasi kembali dan beri sinyal refresh (pop(true))
        navigator.pop(true);
      } catch (e) {
        if (!mounted) return;
        _showMessage(
          "Gagal memperbarui kelas: ${e.toString().replaceAll('Exception: ', '')}",
          isError: true,
        );
        print("Update Class Error: $e");
      } finally {
        if (mounted) setState(() => _isUpdating = false);
      }
    }
  }

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

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Hapus Kelas Ini?',
            style: TextStyle(color: Colors.red[700]),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('PERINGATAN:'),
                const SizedBox(height: 8),
                Text(
                  'Menghapus kelas "${_currentKelasData.namaKelas}" akan '
                  'menghapus SEMUA data tugas, materi, dan daftar anggota di dalamnya '
                  'secara permanen.', // Di Firestore, ini harus dilakukan secara manual!
                ),
                const SizedBox(height: 12),
                const Text('Tindakan ini tidak dapat dibatalkan.'),
              ],
            ),
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

                final String? kelasId = _currentKelasData.kelasId;
                if (kelasId == null) return;

                try {
                  // 🔥 Panggil Service Firebase: Delete Kelas
                  await _kelasService.deleteKelas(kelasId);

                  if (!mounted) return;

                  _showMessage("Kelas berhasil dihapus.", isError: false);

                  // Keluar dari dialog dan keluar dari halaman edit (dengan sinyal refresh)
                  dialogNavigator.pop();
                  mainNavigator.pop(true);
                } catch (e) {
                  if (!mounted) return;
                  _showMessage(
                    "Gagal menghapus kelas: ${e.toString().replaceAll('Exception: ', '')}",
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
          "Edit Kelas",
          style: TextStyle(
            color: AppColor.kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.kBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              BuildTextField(
                labelText: "Nama Kelas",
                // Menggunakan TextEditingController baru atau nilai tetap
                controller: TextEditingController(
                  text: _currentKelasData.namaKelas,
                ),
                readOnly: true, // Tidak boleh diubah
              ),
              const SizedBox(height: 16),
              BuildTextField(
                labelText: "Kode Kelas",
                controller: TextEditingController(
                  text: _currentKelasData.kodeKelas,
                ),
                readOnly: true, // Tidak boleh diubah
              ),
              const SizedBox(height: 16),
              BuildTextField(
                labelText: "Deskripsi",
                controller: _deskripsiController,
                maxLines: 5,
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
                        'Update Deskripsi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 40),
              Center(
                child: TextButton.icon(
                  icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                  label: Text(
                    'Hapus Kelas Ini',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  onPressed: _showDeleteConfirmationDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
