import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/kelas_model.dart';
import 'package:project_volt/widgets/buildtextfield.dart';

class EditClass extends StatefulWidget {
  final KelasModel kelas;
  const EditClass({super.key, required this.kelas});

  @override
  State<EditClass> createState() => _EditClassState();
}

class _EditClassState extends State<EditClass> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _deskripsiController;
  late KelasModel _currentKelasData; // state lokal

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

  void _showMessage(
    ScaffoldMessengerState messenger,
    String message, {
    bool isError = false,
  }) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _submitUpdate() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_formKey.currentState!.validate()) {
      final updatedModel = _currentKelasData.copyWith(
        deskripsi: _deskripsiController.text,
      );

      try {
        await DbHelper.updateKelas(updatedModel); // <-- ASYNC GAP

        if (!mounted) return;
        _showMessage(messenger, 'Deskripsi berhasil diperbarui!');
        navigator.pop(updatedModel); // Kirim data baru
      } catch (e) {
        if (!mounted) return;
        _showMessage(
          messenger,
          'Error: Gagal memperbarui kelas.',
          isError: true,
        );
        print(e);
      }
    }
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
          content: ListBody(
            children: <Widget>[
              Text('PERINGATAN:'),
              SizedBox(height: 8),
              Text(
                'Menghapus kelas "${_currentKelasData.namaKelas}" akan '
                'menghapus SEMUA data tugas dan daftar anggota di dalamnya '
                'secara permanen.',
              ),
              SizedBox(height: 12),
              Text('Tindakan ini tidak dapat dibatalkan.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
              child: const Text('Ya, Hapus'),
              onPressed: () async {
                final dialogNavigator = Navigator.of(dialogContext);

                final mainNavigator = Navigator.of(context);
                final mainMessenger = ScaffoldMessenger.of(context);

                if (_currentKelasData.id == null) return;
                try {
                  // Panggil DbHelper untuk hapus
                  await DbHelper.deleteKelas(_currentKelasData.id!);

                  if (!mounted) return;
                  _showMessage(
                    mainMessenger,
                    'Kelas berhasil dihapus.',
                    isError: false,
                  );

                  dialogNavigator.pop(); // Tutup dialog
                  mainNavigator.pop(); // Kembali ke HomepageDosen
                } catch (e) {
                  if (!mounted) return;
                  _showMessage(
                    mainMessenger,
                    'Gagal menghapus kelas.',
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
        title: Text(
          "Edit Kelas",
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
                SizedBox(height: 10),
                BuildTextField(
                  labelText: "Nama Kelas",
                  controller: TextEditingController(
                    text: _currentKelasData.namaKelas,
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 16),
                BuildTextField(
                  labelText: "Kode Kelas",
                  controller: TextEditingController(
                    text: _currentKelasData.kodeKelas,
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 16),
                BuildTextField(
                  labelText: "Deskripsi",
                  controller: _deskripsiController,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Update Deskripsi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 40),
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
      ),
    );
  }
}
