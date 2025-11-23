import 'dart:math';
import 'package:flutter/material.dart';
import 'package:project_volt/widgets/buildtextfield.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/database/db_helper.dart';
import 'package:project_volt/data/models/kelas_model.dart';
import 'package:project_volt/data/models/user_model.dart';

class CreateClass extends StatefulWidget {
  final UserModel user;
  const CreateClass({super.key, required this.user});

  @override
  State<CreateClass> createState() => _CreateClassState();
}

class _CreateClassState extends State<CreateClass> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
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

  // Fungsi untuk generate kode unik
  String _generateKodeKelas() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String newKode = _generateKodeKelas();

      final newKelas = KelasModel(
        namaKelas: _namaController.text,
        deskripsi: _deskripsiController.text,
        kodeKelas: newKode,
        dosenId: widget.user.id!,
      );

      try {
        final int newId = await DbHelper.createKelas(newKelas);

        //Buat objek utuh untuk dikirim kembali
        final createdKelas = newKelas.copyWith(id: newId);

        if (mounted) {
          Navigator.pop(context, createdKelas);
        }
      } catch (e) {
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
                  maxLines: 5,
                  labelText: "Deskripsi (Opsional)",
                  controller: _deskripsiController,
                ),
                SizedBox(height: 16),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimaryColor,
                    foregroundColor: AppColor.kWhiteColor,
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
