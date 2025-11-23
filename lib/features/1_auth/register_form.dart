import 'package:flutter/material.dart';
import 'package:project_volt/data/auth_data_source.dart';
import 'package:project_volt/data/models/user_model.dart';
import 'package:project_volt/widgets/buildtextfield.dart';
import 'package:project_volt/widgets/primary_auth_button.dart';
import 'package:project_volt/widgets/rolebutton.dart';
import 'package:project_volt/core/constants/app_color.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final AuthDataSource _authDataSource = AuthDataSource();

  UserRole _selectedRole = UserRole.mahasiswa;
  bool _isLoading = false;

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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. Set State Loading
    setState(() {
      _isLoading = true;
    });

    // 2. Buat Model
    UserModel newUser = UserModel(
      namaLengkap: namaLengkapController.text,
      email: emailController.text,
      password: passwordController.text,
      role: _selectedRole.toString(),
    );

    // 3. Panggil Data Layer via AuthDataSource
    bool isSuccess = await _authDataSource.registerUser(newUser);

    // Stop Loading sebelum tampilkan UI Feedback
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // 4. Logika Respons (UI Feedback)
    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi Berhasil! Silakan Login.'),
          backgroundColor: AppColor.kSuccessColor,
        ),
      );
      // Clear field setelah sukses
      namaLengkapController.clear();
      emailController.clear();
      passwordController.clear();
      // *Opsional: Navigasi ke tab Login jika menggunakan TabController di Authenticator
      // TabController.of(context).animateTo(0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email ini sudah terdaftar.'),
          backgroundColor: AppColor.kErrorColor,
        ),
      );
    }
  }

  // Logika UI: Dialog Konfirmasi
  Future<void> _showDosenConfirmationDialog() async {
    bool isChecked = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          activeColor: AppColor.kPrimaryColor,
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
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  onPressed: isChecked
                      ? () {
                          // Update State RegisterForm
                          setState(() {
                            _selectedRole = UserRole.dosen;
                          });
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Yakin'),
                ),
              ],
            );
          },
        );
      },
    );
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

                  if (errors.isNotEmpty) {
                    return 'Password harus mengandung setidaknya:\n- ${errors.join('\n- ')}';
                  }

                  return null;
                },
              ),

              SizedBox(height: 20),

              Text(
                "Mendaftar Sebagai:",
                style: TextStyle(color: AppColor.kTextColor, fontSize: 12),
              ),
              SizedBox(height: 10),
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

              // Tombol Daftar
              PrimaryAuthButton(
                text: 'Daftar Sekarang',
                isLoading: _isLoading,
                backgroundColor: _selectedRole == UserRole.mahasiswa
                    ? AppColor.kAccentColor
                    : AppColor.kPrimaryColor,
                onPressed: _handleRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
