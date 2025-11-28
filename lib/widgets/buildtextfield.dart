import 'package:flutter/material.dart';
import 'package:project_volt/core/constants/app_color.dart';

class BuildTextField extends StatefulWidget {
  const BuildTextField({
    super.key,

    this.labelText,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.readOnly = false,
    this.maxLines,
    // --- TAMBAHKAN PROPERTI BARU ---
    this.labelColor,
    // --- TAMBAHKAN PROPERTI BARU ---
  });

  final String? labelText;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool readOnly;
  final int? maxLines;
  // --- DEKLARASI PROPERTI BARU ---
  final Color? labelColor;
  // --- DEKLARASI PROPERTI BARU ---

  @override
  State<BuildTextField> createState() => _BuildTextFieldState();
}

class _BuildTextFieldState extends State<BuildTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna label.
    // Default-nya: AppColor.kTextColor (diasumsikan abu-abu gelap/hitam)
    // Jika widget.labelColor di-set, gunakan warna itu.
    final Color effectiveLabelColor = widget.labelColor ?? AppColor.kTextColor;

    final Color focusedBorderColor = AppColor.kPrimaryColor;
    final Color enabledBorderColor = AppColor.kTextSecondaryColor.withOpacity(
      0.5,
    );

    return TextFormField(
      validator: widget.validator,
      controller: widget.controller,
      obscureText: _obscureText,
      readOnly: widget.readOnly,
      maxLines: widget.isPassword ? 1 : (widget.maxLines ?? 1),
      decoration: InputDecoration(
        labelText: widget.labelText,

        // --- GUNAKAN effectiveLabelColor ---
        labelStyle: TextStyle(color: effectiveLabelColor),

        // --- GUNAKAN effectiveLabelColor ---
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
        ),

        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: enabledBorderColor, width: 1.0),
        ),

        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.kErrorColor, width: 1.0),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.kErrorColor, width: 2.0),
        ),

        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  // Menggunakan warna yang sama dengan label agar konsisten
                  color: effectiveLabelColor.withOpacity(0.7),
                ),
              )
            : null,
      ),
    );
  }
}
