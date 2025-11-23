import 'package:flutter/material.dart';
import 'package:flutter_animated_gradients/flutter_animated_gradients.dart';
import 'package:project_volt/core/constants/app_image.dart';
import 'package:project_volt/features/1_auth/login_form.dart';
import 'package:project_volt/features/1_auth/register_form.dart';
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/features/1_auth/widgets/auth_tab_bar.dart';

class Authenticator extends StatelessWidget {
  const Authenticator({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: AnimatedGradientBackground(
          colors: const [
            AppColor.kGradationBlueDark,
            AppColor.kGradationBlueLight,
            AppColor.kGradationOrangeLight,
            AppColor.kGradationOrangeDark,
          ],
          duration: const Duration(seconds: 10),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Image.asset(AppImages.volt, height: 100),

                  const SizedBox(height: 40),

                  const AuthTabBar(),

                  const SizedBox(height: 20),

                  IntrinsicHeight(
                    child: TabBarView(
                      children: [
                        // Halaman 1: Form Login
                        LoginForm(),

                        // Halaman 2: Form Registrasi
                        RegisterForm(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
