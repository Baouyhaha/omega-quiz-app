import 'package:flutter/material.dart';

// mau chinh lay theo figma
const Color kPrimary = Color(0xFF6C4CF1);
const Color kBackground = Color(0xFFF6F4FF);
const Color kSuccess = Color(0xFF2FBF71);
const Color kError = Color(0xFFFF5A5F);
const Color kWarning = Color(0xFFFFB020);
const Color kTextMain = Color(0xFF2B2B3A);
const Color kTextSub = Color(0xFF6E6E80);

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
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: kPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      foregroundColor: kTextMain,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: kTextMain,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        fontFamily: 'Nunito',
      ),
    ),
  );
}
