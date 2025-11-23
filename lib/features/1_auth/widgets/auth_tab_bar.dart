import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';

class AuthTabBar extends StatelessWidget {
  const AuthTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColor.kWhiteColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: AppColor.kBlackColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: AppColor.kAccentColor,
          borderRadius: BorderRadius.circular(25.0),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColor.kWhiteColor,
        unselectedLabelColor: AppColor.kTextSecondaryColor,
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Registrasi'),
        ],
      ),
    );
  }
}
