import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/widgets/buildtextfield.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/database/db_helper.dart';
import 'package:project_volt/data/models/tugas_model.dart';

class EditTugasPage extends StatefulWidget {
  final TugasModel tugas;

  const EditTugasPage({super.key, required this.tugas});

  @override
  State<EditTugasPage> createState() => _EditTugasPageState();
}

class _EditTugasPageState extends State<EditTugasPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late TugasModel _currentTugasData;

  DateTime? _selectedDateTime;

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
        _selectedDateTime = null; // Abaikan jika format salah
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
      firstDate: DateTime.now().subtract(Duration(days: 30)),
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

  void _submitUpdate() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_formKey.currentState!.validate()) {
      final String? tglTenggat = _selectedDateTime?.toIso8601String();

      // Buat model baru dengan data yang diupdate
      final updatedTugas = _currentTugasData.copyWith(
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
        tglTenggat: tglTenggat,
      );

      try {
        await DbHelper.updateTugas(updatedTugas);
        final snackBarContent = AwesomeSnackbarContent(
          title: "Sukses",
          message: "Tugas berhasil diperbarui",
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
        if (mounted) {
          // Kirim data baru kembali ke halaman daftar tugas
          Navigator.pop(context, true);
        }
      } catch (e) {
        final snackBarContent = AwesomeSnackbarContent(
          title: "Error",
          message: "Gagal memperbarui tugas.",
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

        print(e);
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Hapus Tugas Ini?'),
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
                // Ambil context SEBELUM await
                final dialogNavigator = Navigator.of(dialogContext);
                final mainNavigator = Navigator.of(context);
                final mainMessenger = ScaffoldMessenger.of(context);

                if (_currentTugasData.id == null) return;
                try {
                  await DbHelper.deleteTugas(_currentTugasData.id!);

                  if (!mounted) return;
                  final snackBarContent = AwesomeSnackbarContent(
                    title: "Sukses",
                    message: "Tugas berhasil dihapus",
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
                  dialogNavigator.pop();
                  mainNavigator.pop(true);
                } catch (e) {
                  if (!mounted) return;
                  final snackBarContent = AwesomeSnackbarContent(
                    title: "Peringatan",
                    message: "Gagal menghapus tugas.",
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
                SizedBox(height: 10),
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
                SizedBox(height: 16),
                BuildTextField(
                  labelText: "Deskripsi (Opsional)",
                  controller: _deskripsiController,
                  maxLines: 5,
                ),
                SizedBox(height: 16),
                Text(
                  "Tanggal Tenggat (Opsional)",
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () => _pickDateTime(context),
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
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimaryColor,
                    foregroundColor: AppColor.kWhiteColor,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Update Tugas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                OutlinedButton.icon(
                  icon: Icon(Icons.delete_outline),
                  label: Text("Hapus Tugas Ini"),
                  onPressed: _showDeleteConfirmationDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[700]!),
                    minimumSize: Size(double.infinity, 50),
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
