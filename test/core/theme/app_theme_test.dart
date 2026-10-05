import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_volt/core/theme/app_theme.dart';

void main() {
  test('light theme uses the Volt seed color', () {
    final theme = buildLightTheme();
    expect(theme.brightness, Brightness.light);
    expect(
      theme.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: kVoltSeed).primary,
    );
  });

  test('dark theme is built from the same seed', () {
    final theme = buildDarkTheme();
    expect(theme.brightness, Brightness.dark);
    expect(
      theme.colorScheme.primary,
      ColorScheme.fromSeed(
        seedColor: kVoltSeed,
        brightness: Brightness.dark,
      ).primary,
    );
  });
}
