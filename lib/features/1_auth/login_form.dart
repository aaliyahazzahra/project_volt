import 'package:flutter/material.dart';
import 'package:project_volt/widgets/buildtextfield.dart';
import 'package:project_volt/widgets/primary_auth_button.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/data/auth_data_source.dart';
import 'package:project_volt/core/utils/preference_handler.dart';
import 'package:project_volt/data/models/user_model.dart';
import 'package:project_volt/features/2_dashboard/bottom_nav_dosen.dart';
import 'package:project_volt/features/2_dashboard/bottom_nav_mhs.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final AuthDataSource _authDataSource = AuthDataSource();

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

    UserModel? user = await _authDataSource.loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email atau Password salah.'),
          backgroundColor: AppColor.kErrorColor,
        ),
      );
    } else {
      await PreferenceHandler.saveUser(user);
      String userRole = user.role;

      Widget nextScreen;
      if (userRole == UserRole.mahasiswa.toString()) {
        nextScreen = BottomNavMhs(user: user);
      } else if (userRole == UserRole.dosen.toString()) {
        nextScreen = BottomNavDosen(user: user);
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
                return null;
              },
            ),

            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Lupa Password?',
                style: TextStyle(color: AppColor.kAccentColor),
              ),
            ),
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
