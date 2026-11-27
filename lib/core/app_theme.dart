import 'package:flutter/material.dart';

// Màu theo hệ thống thiết kế E2 (Figma) — mọi màn hình chỉ dùng các hằng số
// này, không tự gõ mã màu trong file màn hình (theo QUY_TAC_CODE_GIAO_DIEN).
const Color kPrimary = Color(0xFF6C4CF1);
const Color kPrimaryDark = Color(0xFF4A32B8);
const Color kSecondary = Color(0xFF00BFA6);
const Color kAccent = Color(0xFFFFC93C);
const Color kBackground = Color(0xFFF6F4FF);
const Color kSurface = Color(0xFFFFFFFF);
const Color kTextPrimary = Color(0xFF1D1B2E);
const Color kTextSecondary = Color(0xFF6E6A8A);
const Color kSuccess = Color(0xFF2FBF71);
const Color kError = Color(0xFFFF5A5F);
const Color kWarning = Color(0xFFFF9F1C);

// Màu tint + viền + trạng thái lấy trực tiếp từ Figma v3 (22/11/2026,
// trích từ SVG Danh gửi — không phải màu bịa thêm):
// kPrimaryTint nền pill "Của tôi", chip chưa chọn, cột "Bạn" (MH-14),
//   dòng user (MH-18), chip trợ giúp (MH-09);
// kSuccessTint nền thẻ lời mời + pill "Công khai" (MH-02);
// kWarningTint nền banner dùng thử (MH-02), thẻ Top-1 (MH-18);
// kBorder viền thẻ/ô nhập/dialog; kProgressTrack nền thanh tiến trình (MH-09);
// kDisabledBg nền chip disabled; kNavInactive icon/nhãn nav chưa chọn.
const Color kPrimaryTint = Color(0xFFEFECFE);
const Color kSuccessTint = Color(0xFFE4F8EC);
const Color kWarningTint = Color(0xFFFFF3E0);
const Color kBorder = Color(0xFFE9E6F7);
const Color kProgressTrack = Color(0xFFE4E0F5);
const Color kDisabledBg = Color(0xFFE5E7EB);
const Color kNavInactive = Color(0xFF9A94B8);

// 4 màu đáp án A B C D (cố định theo E2).
const List<Color> kOptionColors = [
  Color(0xFFEF476F),
  Color(0xFF118AB2),
  Color(0xFFFFC93C),
  Color(0xFF06D6A0),
];

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: kPrimary).copyWith(
      primary: kPrimary,
      secondary: kSecondary,
      error: kError,
    ),
    scaffoldBackgroundColor: kBackground,
    fontFamily: 'Nunito',
    // Chữ theo E2/Figma: tiêu đề in đậm, nội dung thường. Cỡ giữ nguyên
    // mặc định Material 3 để không vỡ bố cục — chỉ đổi độ đậm + màu.
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: kTextPrimary,
          fontFamily: 'Nunito'),
      titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: kTextPrimary,
          fontFamily: 'Nunito'),
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: kTextPrimary,
          fontFamily: 'Nunito'),
      titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: kTextPrimary,
          fontFamily: 'Nunito'),
      bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: kTextPrimary,
          fontFamily: 'Nunito'),
      bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: kTextPrimary,
          fontFamily: 'Nunito'),
      bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: kTextSecondary,
          fontFamily: 'Nunito'),
    ),
    cardTheme: const CardThemeData(
      color: kSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    // Nút chính: nền tím đặc + chữ trắng, cao 52dp, bo 14dp (E2).
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
    // Nút viền: chữ + viền tím, cao 52dp, bo 14dp (E2).
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
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kPrimary,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      foregroundColor: kTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: kTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        fontFamily: 'Nunito',
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      selectedColor: kPrimary.withValues(alpha: 0.15),
      checkmarkColor: kPrimary,
      labelStyle: const TextStyle(color: kTextPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: kPrimary.withValues(alpha: 0.15),
    ),
  );
}
