import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_volt/common_widgets/buildtextfield.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/database/db_helper.dart';
import 'package:project_volt/data/models/tugas_model.dart';

class CreateTugasPage extends StatefulWidget {
  final int kelasId;
  const CreateTugasPage({super.key, required this.kelasId});

  @override
  State<CreateTugasPage> createState() => _CreateTugasPageState();
}

class _CreateTugasPageState extends State<CreateTugasPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();

  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context) async {
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
      // Simpan sebagai ISO string
      final String? tglTenggat = _selectedDateTime?.toIso8601String();

      final newTugas = TugasModel(
        kelasId: widget.kelasId,
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
        tglTenggat: tglTenggat,
      );

      try {
        await DbHelper.createTugas(newTugas);
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
        if (mounted) {
          Navigator.pop(context); // Kembali ke halaman detail kelas
        }
      } catch (e) {
        final snackBarContent = AwesomeSnackbarContent(
          title: "Error",
          message: "Gagal membuat tugas.",
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

                // Input Tanggal Tenggat
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
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Simpan Tugas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
