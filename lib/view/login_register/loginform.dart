import 'package:bottom_bar_matu/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:project_volt/database/db_helper.dart';
import 'package:project_volt/model/user_model.dart';
import 'package:project_volt/view/dashboard/homepage_dosen.dart';
import 'package:project_volt/view/dashboard/homepage_mhs.dart';
import 'package:project_volt/widgets/buildtextfield.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 20),

            BuildTextField(
              labelText: 'Email',
              controller: _emailController,
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
              labelText: 'Password',
              controller: _passwordController,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }

                final bool passValid = RegExp(
                  r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).{7,}$',
                ).hasMatch(value);

                if (!passValid) {
                  return 'Password tidak sesuai ketentuan.';
                }

                return null; // Lolos validasi
              },
            ),

            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Lupa Password?',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  UserModel? user = await DbHelper.loginUser(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );

                  if (!mounted) return;

                  if (user == null) {
                    // Jika user tidak ditemukan
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Email atau Password salah.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    // Jika user ditemukan, cek role-nya
                    String userRole = user.role;

                    if (userRole == UserRole.mahasiswa.toString()) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomepageMhs()),
                      );
                      print("NAVIGASI KE DASHBOARD MAHASISWA");
                    } else if (userRole == UserRole.dosen.toString()) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomepageDosen(user: user),
                        ),
                      );
                      print("NAVIGASI KE DASHBOARD DOSEN");
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorBlueLightAS,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: Text('Masuk Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
