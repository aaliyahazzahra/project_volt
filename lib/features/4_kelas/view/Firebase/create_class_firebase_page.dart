import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/firebase/models/kelas_firebase_model.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/kelas_firebase_service.dart';
import 'package:project_volt/widgets/buildtextfield.dart';

class CreateClassFirebasePage extends StatefulWidget {
  final UserFirebaseModel user;
  const CreateClassFirebasePage({super.key, required this.user});

  @override
  State<CreateClassFirebasePage> createState() =>
      _CreateClassFirebasePageState();
}

class _CreateClassFirebasePageState extends State<CreateClassFirebasePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  //  INISIASI SERVICE FIREBASE
  final KelasFirebaseService _kelasService = KelasFirebaseService();
  bool _isSaving = false;

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

  String _generateKodeKelas() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_isSaving) return;

      setState(() {
        _isSaving = true;
      });

      final String newKode = _generateKodeKelas();

      final String dosenUid = widget.user.uid;

      final newKelas = KelasFirebaseModel(
        namaKelas: _namaController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        kodeKelas: newKode,
        dosenUid: dosenUid,
      );

      try {
        final createdKelas = await _kelasService.createKelas(newKelas);

        if (mounted) {
          Navigator.pop(context, createdKelas);
        }
      } catch (e) {
        _showMessage('Error saat membuat kelas: Coba lagi.', isError: true);
        print("Create Class Error: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
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
                const SizedBox(height: 10),
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
                const SizedBox(height: 16),
                BuildTextField(
                  maxLines: 5,
                  labelText: "Deskripsi (Opsional)",
                  controller: _deskripsiController,
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 30),
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
                          'Simpan Kelas',
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
