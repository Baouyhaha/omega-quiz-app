import 'package:flutter/material.dart';

import 'app_theme.dart';

// Theme rieng cho cac man hinh phan cua Uy (MH-01, 03, 16, 21, 25, 26, 28, 29).
// File nay chi phan Uy dung, khong sua app_theme.dart dung chung cua nhom:
// them mau trang thai/chu va dinh dang nut, o nhap, app bar ma cac man
// cua Uy can. Chi ap dung qua main_uy_preview.dart (diem chay thu rieng),
// nen khong anh huong giao dien phan cac ban khac lam.
const Color kSuccess = Color(0xFF2FBF71);
const Color kError = Color(0xFFFF5A5F);
const Color kWarning = Color(0xFFFFB020);
const Color kTextMain = Color(0xFF2B2B3A);
const Color kTextSub = Color(0xFF6E6E80);

ThemeData buildUyTheme() {
  return buildAppTheme().copyWith(
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
