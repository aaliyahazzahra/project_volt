import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.hintText,
    this.securePass = false,
    this.isVisibility = false,
    this.click,
  });
  final String? hintText;
  final bool securePass;
  final bool isVisibility;
  final void Function()? click;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: securePass,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 10.0,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        hintText: hintText,
        suffixIcon: click != null
            ? IconButton(
                onPressed: click,
                icon: Icon(
                  securePass ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xff6c7278),
                ),
              )
            : null,
      ),
    );
  }
}
