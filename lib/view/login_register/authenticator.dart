import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_image.dart';
import 'package:project_volt/view/login_register/login_form.dart';
import 'package:project_volt/view/login_register/registerform.dart';

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
              // Bagian Header
              SizedBox(height: 16),
              Image.asset(AppImages.volt, height: 100),

              SizedBox(height: 40),

              // Bagian TabBar
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
    );
  }
}
