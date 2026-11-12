import 'package:flutter/material.dart';

// mau chinh lay theo figma
const Color kPrimary = Color(0xFF6C4CF1);
const Color kBackground = Color(0xFFF6F4FF);

// 4 mau dap an A B C D
const List<Color> kOptionColors = [
  Color(0xFFEF476F),
  Color(0xFF118AB2),
  Color(0xFFFFC93C),
  Color(0xFF06D6A0),
];

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
    scaffoldBackgroundColor: kBackground,
    fontFamily: 'Nunito',
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}
