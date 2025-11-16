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
          width: double.infinity,
          height: double.infinity,
          child: AnimatedGradientBackground(
            colors: const [
              Color(0xffc4c9f2),
              Color.fromARGB(255, 158, 204, 231),
              Color.fromARGB(255, 240, 175, 90),
              Color(0xffffc22f),
              Color.fromARGB(255, 240, 175, 90),
              Color.fromARGB(255, 158, 204, 231),
              Color(0xffc4c9f2),
            ],
            duration: const Duration(seconds: 10),

            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
              child: Column(
                children: [
                  // Bagian Header
                  SizedBox(height: 16),
                  Image.asset(AppImages.volt, height: 100),

                  SizedBox(height: 40),

                  // Bagian TabBar
                  Container(
                    height: double.minPositive,
                    width: double.minPositive,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      border: Border.all(color: Colors.white.withOpacity(0.7)),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TabBar(
                            indicator: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,

                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              Tab(text: 'Login'),
                              Tab(text: 'Registrasi'),
                            ],
                          ),
                          // Bagian Form
                          SizedBox(
                            height: 500,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
