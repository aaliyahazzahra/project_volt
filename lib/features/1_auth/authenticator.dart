import 'package:flutter/material.dart';
import 'package:flutter_animated_gradients/flutter_animated_gradients.dart';
import 'package:project_volt/core/constants/app_image.dart';
import 'package:project_volt/features/1_auth/login_form.dart';
import 'package:project_volt/features/1_auth/register_form.dart';

class Authenticator extends StatelessWidget {
  const Authenticator({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SizedBox(
          height: double.infinity,
          child: AnimatedGradientBackground(
            colors: const [
              Color(0xFF64B5F6),
              Color(0xFFB3E5FC),
              Color(0xFFFFE0B2),
              Color(0xFFFFCC80),
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

                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(text: 'Login'),
                          Tab(text: 'Registrasi'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 500,
                      child: TabBarView(
                        children: [
                          // Halaman 1: Form Login
                          const LoginForm(),

                          // Halaman 2: Form Registrasi
                          const RegisterForm(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
