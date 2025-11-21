import 'package:flutter/material.dart';
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
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
          child: Column(
            children: [
              SizedBox(height: 16),
              Image.asset(AppImages.volt, height: 100),

              SizedBox(height: 40),

              Container(
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
                child: TabBar(
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
              ),

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
    );
  }
}
