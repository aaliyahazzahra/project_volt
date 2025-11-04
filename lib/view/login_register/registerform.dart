import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_color.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/widgets/buildtextfield.dart';
import 'package:project_volt/widgets/rolebutton.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  UserRole _selectedRole = UserRole.mahasiswa;
  final TextEditingController namaLengkapController = TextEditingController();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    namaLengkapController.dispose();

    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BuildTextField(
                labelText: "Nama Lengkap",
                controller: namaLengkapController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),
              BuildTextField(
                labelText: "Email",
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  final bool emailValid = RegExp(
                    r'^.+@.+\.ac\.id$',
                  ).hasMatch(value);
                  if (!emailValid) {
                    return 'Email harus menggunakan domain .ac.id';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              BuildTextField(
                labelText: "Password",
                controller: passwordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }

                  List<String> errors = [];

                  if (value.length < 7) {
                    errors.add('minimal 7 karakter');
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    errors.add('1 huruf kapital');
                  }
                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                    errors.add('1 huruf kecil');
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    errors.add('1 angka');
                  }

                  // Jika ada error, gabungkan pesannya
                  if (errors.isNotEmpty) {
                    return 'Password harus mengandung setidaknya:\n- ${errors.join('\n- ')}';
                  }

                  return null; // Tidak ada error
                },
              ),
              SizedBox(height: 20),
              Text(
                "Mendaftar Sebagai:",
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
              SizedBox(height: 10),

              // Bagian Toogle
              Row(
                children: [
                  // Tombol Mahasiswa
                  Expanded(
                    child: RoleButton(
                      text: 'Mahasiswa',
                      icon: Icons.school,
                      role: UserRole.mahasiswa,
                      isSelected: _selectedRole == UserRole.mahasiswa,
                      onPressed: () {
                        setState(() {
                          _selectedRole = UserRole.mahasiswa;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  // Tombol Dosen
                  Expanded(
                    child: RoleButton(
                      text: 'Dosen',
                      icon: Icons.person,
                      role: UserRole.dosen,
                      isSelected: _selectedRole == UserRole.dosen,
                      onPressed: () {
                        if (_selectedRole != UserRole.dosen) {
                          _showDosenConfirmationDialog();
                        }
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final TabController? controller = DefaultTabController.of(
                    context,
                  );
                  final ScaffoldMessengerState scaffoldMessenger =
                      ScaffoldMessenger.of(context);
                  if (_formKey.currentState!.validate()) {
                    UserModel newUser = UserModel(
                      namaLengkap: namaLengkapController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      role: _selectedRole.toString(),
                    );
                    bool isSuccess = await DbHelper.registerUser(newUser);
                    if (!mounted) return;
                    if (isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Registrasi Berhasil! Silakan Login.'),
                        ),
                      );
                      TabController? controller = DefaultTabController.of(
                        context,
                      );
                      if (controller != null) {
                        controller.animateTo(0); // Pindah ke tab Login
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Email ini sudah terdaftar.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    print("Mendaftar sebagai: $_selectedRole");
                    print("Email: ${emailController.text}");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedRole == UserRole.mahasiswa
                      ? AppColor.colorMahasiswa
                      : AppColor.colorDosen,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text('Daftar Sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDosenConfirmationDialog() async {
    bool isChecked = false; // State lokal untuk checkbox di dalam dialog

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User harus menekan tombol
      builder: (BuildContext context) {
        // Gunakan StatefulBuilder agar dialog bisa update state checkbox-nya sendiri
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Konfirmasi Pilihan'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'Apakah Anda yakin ingin mendaftar sebagai Dosen? Pilihan ini hanya untuk Dosen/Staf Pengajar.',
                    ),
                    SizedBox(height: 20),
                    // Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              isChecked = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Saya mengerti dan saya adalah seorang Dosen.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                  },
                ),
                TextButton(
                  // Tombol 'Yakin' akan nonaktif jika checkbox belum dicentang
                  onPressed: isChecked
                      ? () {
                          // Jika yakin dan sudah centang:
                          setState(() {
                            _selectedRole = UserRole.dosen; // GANTI STATE UTAMA
                          });
                          Navigator.of(context).pop(); // Tutup dialog
                        }
                      : null, // <-- Ini membuat tombol nonaktif
                  child: const Text('Yakin'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
