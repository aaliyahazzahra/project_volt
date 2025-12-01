import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/utils/Firebase/preference_handler_firebase.dart';
import 'package:project_volt/data/firebase/models/user_firebase_model.dart';
import 'package:project_volt/data/firebase/service/firebase.dart';
import 'package:project_volt/features/2_dashboard/Firebase/bottom_nav_dosen_firebase.dart';
import 'package:project_volt/features/2_dashboard/Firebase/bottom_nav_mhs_firebase.dart';
import 'package:project_volt/widgets/buildtextfield.dart';
import 'package:project_volt/widgets/primary_auth_button.dart';

class LoginFormFirebase extends StatefulWidget {
  const LoginFormFirebase({super.key});

  @override
  State<LoginFormFirebase> createState() => _LoginFormFirebaseState();
}

class _LoginFormFirebaseState extends State<LoginFormFirebase> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    UserFirebaseModel? user;

    try {
      // 1. Panggil Service Firebase
      user = await FirebaseService.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      // 2. Tampilkan pesan error jika login gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // 3. Jika user berhasil didapatkan: Lanjutkan proses navigasi
    if (user != null) {
      await PreferenceHandlerFirebase.saveUser(user);

      String userRole = user.role ?? 'unknown';

      Widget nextScreen;
      if (userRole == 'mahasiswa') {
        nextScreen = BottomNavMhsFirebase(user: user);
      } else if (userRole == 'dosen') {
        nextScreen = BottomNavDosenFirebase(user: user);
      } else {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    }
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
              labelColor: AppColor.kTextColor,
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
              labelColor: AppColor.kTextColor,
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
                return null;
              },
            ),

            SizedBox(height: 8),

            SizedBox(height: 30),

            PrimaryAuthButton(
              text: 'Masuk Sekarang',
              isLoading: _isLoading,
              onPressed: _handleLogin,
            ),
          ],
        ),
      ),
    );
  }
}
