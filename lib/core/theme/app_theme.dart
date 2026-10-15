import 'package:flutter/material.dart';

const brandPrimary = Color(0xFF237AB0);

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: brandPrimary).copyWith(
    primary: brandPrimary,
    onPrimary: Colors.white,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
  );
}
