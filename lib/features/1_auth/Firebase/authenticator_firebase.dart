import 'package:flutter/material.dart';
import 'package:flutter_animated_gradients/flutter_animated_gradients.dart';
// WAJIB import AppColor
import 'package:project_volt/core/constants/app_color.dart';
import 'package:project_volt/core/constants/app_image.dart';
import 'package:project_volt/features/1_auth/Firebase/login_form_firebase.dart';
import 'package:project_volt/features/1_auth/Firebase/register_form_firebase.dart';

class AuthenticatorFirebase extends StatelessWidget {
  const AuthenticatorFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SizedBox(
          height: double.infinity,
          child: AnimatedGradientBackground(
            // Mengganti hardcode warna gradasi
            colors: const [
              AppColor.kGradationBlueDark,
              AppColor.kGradationBlueLight,
              AppColor.kGradationOrangeLight,
              AppColor.kGradationOrangeDark,
              AppColor.kGradationOrangeLight,
              AppColor.kGradationBlueLight,
              AppColor.kGradationBlueDark,
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
                        // Mengganti Colors.white
                        color: AppColor.kWhiteColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            // Mengganti Colors.black
                            color: AppColor.kBlackColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          // Mengganti Colors.blueAccent dengan kAccentColor (Biru)
                          color: AppColor.kAccentColor,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        // Mengganti Colors.white
                        labelColor: AppColor.kWhiteColor,
                        // Mengganti Colors.grey
                        unselectedLabelColor: AppColor.kTextSecondaryColor,
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
                        children: const [
                          // Halaman 1: Form Login
                          LoginFormFirebase(),

                          // Halaman 2: Form Registrasi
                          RegisterFormFirebase(),
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
