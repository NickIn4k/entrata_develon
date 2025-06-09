import 'package:flutter/material.dart';

final ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    surface: Colors.white,
    background: Color(0xFFF6F6F6),
    primary: Color(0xFF1976D2),   // Blu
    secondary: Color(0xFF03DAC6), // Verde acqua
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black,
  ),
);

final ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF121212),
    background: Color(0xFF1E1E1E),
    primary: Color(0xFF90CAF9),   // Blu chiaro
    secondary: Color(0xFF03DAC6), // Verde acqua
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
  ),
);
