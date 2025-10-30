import 'package:flutter/material.dart';
import 'package:project_volt/constant/app_image.dart';
import 'package:project_volt/login_register/login.dart';

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
              Image.asset(AppImages.logo, height: 180),
              Text(
                "----",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
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
                    RegisterForm(),

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

  // Widget terpisah untuk Form Login
  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          TextField(decoration: InputDecoration(labelText: 'Email')),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
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
            onPressed: () {
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => NavLucu()),
              // );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text('Masuk Sekarang'),
          ),
        ],
      ),
    );
  }
}
