import 'package:flutter/material.dart';

/// Seed color for the Volt Material 3 color scheme (matches the mockups).
const Color kVoltSeed = Color(0xFF6750A4);

ThemeData buildLightTheme() {
  return _buildTheme(Brightness.light, background: const Color(0xFFFAFAFB));
}

ThemeData buildDarkTheme() {
  return _buildTheme(Brightness.dark);
}

ThemeData _buildTheme(Brightness brightness, {Color? background}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: kVoltSeed,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: background ?? scheme.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
