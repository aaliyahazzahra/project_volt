import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/widgets/buildtextfield.dart';

class BuatKelas extends StatefulWidget {
  // Menerima data Dosen yang sedang login
  final UserModel user;
  const BuatKelas({super.key, required this.user});

  @override
  State<BuatKelas> createState() => _BuatKelasState();
}

class _BuatKelasState extends State<BuatKelas> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _kodeController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _kodeController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nama_kelas': _namaController.text,
        'deskripsi': _deskripsiController.text,
        'kode_kelas': _kodeController.text,
        'dosen_id': widget.user.id,
      };

      try {
        await DbHelper.createKelas(data);

        _showMessage('Kelas berhasil dibuat!');
        if (mounted) {
          Navigator.pop(context); // Kembali ke homepage
        }
      } catch (e) {
        // Ini terjadi jika 'kode_kelas' sudah ada
        _showMessage(
          'Error: Kode Kelas mungkin sudah digunakan.',
          isError: true,
        );
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
          "Buat Kelas Baru",
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
                  controller: _namaController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Kelas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                BuildTextField(
                  labelText: "Deskripsi (Opsional)",
                  controller: _deskripsiController,
                ),
                SizedBox(height: 16),
                BuildTextField(
                  labelText: "Kode Kelas (Unik)",
                  controller: _kodeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode Kelas tidak boleh kosong';
                    }
                    if (value.contains(' ')) {
                      return 'Kode Kelas tidak boleh mengandung spasi';
                    }
                    return null;
                  },
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
                    'Simpan Kelas',
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
