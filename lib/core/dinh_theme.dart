import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// File theme RIENG cua Dinh — lib/core/dinh_theme.dart
// Theo huong dan co lap code giao dien cua Uy:
//   - KHONG sua file chung lib/core/app_theme.dart.
//   - Moi thu Dinh can them thi dat trong file rieng nay.
//   - Khi nao hop nhat, Uy se gop file nay vao app_theme.dart chung
//     mot lan sau cung. Truoc luc do khong ai dung vao file chung.
// Chi giu mau/style ma cac man cua Dinh that su dung
// (MH-20, MH-22 xong; them dan khi lam MH-23, 24, 27, 30, 31, 32, 33).
// So do theo task MH-20, xem bang day du trong mh20_figma_tokens.md.
// So do MH-22 xem trong mh22_figma_tokens.md.
// Bo goc 16px la so dung tam — Figma khong hien thi bo goc trong
// Properties nen chua xac minh duoc.
// ---------------------------------------------------------------------------

// Mau chinh lay theo task
const Color kPrimary = Color(0xFF6C4CF1);
const Color kBackground = Color(0xFFF6F4FF);

// Mau chu va vien
const Color kOnPrimary = Colors.white;
const Color kSurface = Colors.white;
const Color kTextPrimary = Color(0xFF1D1B2E);
const Color kTextSecondary = Color(0xFF6E6A8A);
const Color kInputBorder = Color(0xFFE9E6F7);
const Color kRadioBorder = Color(0xFFC9C4DE);
const Color kNavUnselected = Color(0xFF9A94B8);
const Color kWarningBackground = Color(0xFFFFF3E0);
const Color kWarningOrange = Color(0xFFFF9F1C);

// Bo goc
const double kRadiusCard = 24;
const double kRadiusButton = 16;
const double kRadiusItem = 16;

// Khoang cach (theo task)
const double kSpacing3 = 3; // nhan -> o nhap
const double kSpacing12 = 12;
const double kSpacing13 = 13; // o nhap -> nhan tiep theo
const double kSpacing16 = 16;
const double kSpacing20 = 20; // le noi dung 2 ben
const double kSpacing23 = 23; // radio 2 -> hop canh bao

// Chieu cao (theo task)
const double kFieldHeight = 52;
const double kButtonHeight = 52;
const double kCoverHeight = 96;
const double kWarningHeight = 52;

// Vien o nhap: 1.5px #E9E6F7
const OutlineInputBorder kFieldBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(color: kInputBorder, width: 1.5),
);
const OutlineInputBorder kFieldFocusedBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(color: kPrimary, width: 1.5),
);
// Chu trong o cach mep trai 14px, cach mep tren 17px (theo task).
const EdgeInsets kFieldPadding = EdgeInsets.fromLTRB(14, 17, 14, 17);

// Kieu chu: Nunito, line-height 100%
const TextStyle kPageTitleStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kBackStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 34,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kHeadingStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kLabelStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: kTextSecondary,
  height: 1.0,
);
const TextStyle kFieldTextStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kButtonTextStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 17,
  fontWeight: FontWeight.w700,
  color: kOnPrimary,
  height: 1.0,
);
const TextStyle kWarningTextStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kNavLabelStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  height: 1.0,
);

// ---------------------------------------------------------------------------
// Them cho MH-22 Quan ly cau hoi, theo task MH-22.
// ---------------------------------------------------------------------------

// Mau tab chua chon va vong tron AI
const Color kTabUnselectedBackground = Color(0xFFEFECFE);

// Mau do kho
const Color kEasy = Color(0xFF2FBF71);
const Color kEasyBackground = Color(0xFFE4F8EC);
const Color kMedium = Color(0xFFFF9F1C);
const Color kMediumBackground = Color(0xFFFFF3E0);
const Color kHard = Color(0xFFFF5A5F);
const Color kHardBackground = Color(0xFFFFE9E9);

// Mau huy hieu "Sap co" o the AI
const Color kComingSoonBackground = Color(0xFFE5E7EB);

// Chieu cao (theo task MH-22)
const double kTabHeight = 28;
const double kQuestionCardHeight = 72;
const double kAiCardHeight = 88;

// Kieu chu MH-22: Nunito, line-height 100%
const TextStyle kDifficultyLabelStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  height: 1.0,
);
const TextStyle kQuestionTitleStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kQuestionPreviewStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: kTextSecondary,
  height: 1.0,
);

// ---------------------------------------------------------------------------
// Them cho MH-23 Soan/Sua cau hoi, theo task MH-23.
// ---------------------------------------------------------------------------

// Mau huy hieu chu cai A/B/C/D
const Color kOptionA = Color(0xFFEF476F);
const Color kOptionB = Color(0xFF118AB2);
const Color kOptionC = Color(0xFFFFC93C);
const Color kOptionD = Color(0xFF06D6A0);

// Kieu chu MH-23: Nunito, line-height 100%
const TextStyle kAnswerValueStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 18,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kAnswerBadgeStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: kOnPrimary,
  height: 1.0,
);

// Kieu chu nut Xoa cau hoi (chi hien o che do Sua): Nunito 13px 700,
// mau do kHard tren nen hong nhat kHardBackground — cung cap mau do
// voi muc do Kho va chu bao loi o MH-22/MH-24.
const TextStyle kDeleteButtonTextStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: kHard,
  height: 1.0,
);

// ---------------------------------------------------------------------------
// Them cho MH-24 Import Excel, theo task MH-24.
// ---------------------------------------------------------------------------

// Mau nen thanh tien trinh doc file
const Color kProgressTrackBackground = Color(0xFFE4E0F5);

// Chieu cao (theo task MH-24)
const double kProgressBarHeight = 8;
const double kPreviewRowHeight = 56;
const double kFileCardHeight = 104;
const double kErrorBoxHeight = 64;

// Kieu chu MH-24: Nunito, line-height 100%
const TextStyle kChooseFileTextStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: kPrimary,
  height: 1.0,
);
const TextStyle kErrorTextStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: kHard,
  height: 1.0,
);

// ---------------------------------------------------------------------------
// Them cho MH-33 Admin: Thong ke, theo task MH-33.
// ---------------------------------------------------------------------------

// Kich thuoc bieu do va the gian lan (theo task MH-33)
const double kChartCardHeight = 180;
const double kChartBarWidth = 36;
const double kCheatCardHeight = 76;

// Kieu chu MH-33: Nunito, line-height 100%
const TextStyle kChartValueStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kCheatViolationStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: kHard,
  height: 1.0,
);
const TextStyle kViewButtonTextStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: kPrimary,
  height: 1.0,
);

// ---------------------------------------------------------------------------
// Them cho MH-32 Admin: Goi va han muc, theo task MH-32.
// ---------------------------------------------------------------------------

// Kich thuoc o nhap han muc (theo task MH-32)
const double kLimitInputWidth = 104;
const double kLimitInputHeight = 32;

// Kieu chu MH-32: Nunito, line-height 100%
const TextStyle kLimitValueStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);

// ---------------------------------------------------------------------------
// Them cho MH-31 Admin: Chi tiet tai khoan, theo task MH-31.
// ---------------------------------------------------------------------------

// Chieu cao (theo task MH-31)
const double kAccountDetailCardHeight = 152;
const double kHistoryCardHeight = 88;

// Kieu chu MH-31: Nunito, line-height 100%
const TextStyle kDetailAvatarLetterStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 26,
  fontWeight: FontWeight.w700,
  color: kOnPrimary,
  height: 1.0,
);
const TextStyle kDetailNameStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kDetailEmailStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: kTextSecondary,
  height: 1.0,
);
const TextStyle kDetailInfoStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kDetailStatusStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: kEasy,
  height: 1.0,
);
const TextStyle kPlanNameStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 18,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kHistoryDateStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);

// ---------------------------------------------------------------------------
// Them cho MH-30 Admin: Tai khoan, theo task MH-30.
// ---------------------------------------------------------------------------

// Mau nen header MH-30.
const Color kAdminHeaderBackground = Color(0xFF4A32B8);

// Chieu cao (theo task MH-30)
const double kAdminHeaderHeight = 104;
const double kSearchHeight = 48;
const double kAccountCardHeight = 84;
const double kActionButtonHeight = 30;

// Kieu chu MH-30: Nunito, line-height 100%
const TextStyle kAdminHeaderTitleStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: kOnPrimary,
  height: 1.0,
);
const TextStyle kAdminHeaderBadgeStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: Color(0xFFD9CFFF),
  height: 1.0,
);
const TextStyle kAccountAvatarLetterStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: kOnPrimary,
  height: 1.0,
);
const TextStyle kAccountNameStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 17,
  fontWeight: FontWeight.w700,
  color: kTextPrimary,
  height: 1.0,
);
const TextStyle kActionButtonTextStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  height: 1.0,
);

// ---------------------------------------------------------------------------
// Them cho MH-27 Thong ke chu de, theo task MH-27.
// ---------------------------------------------------------------------------

// Chieu cao (theo task MH-27)
const double kStatCardHeight = 96;
const double kExamCardHeight = 76;
const double kMemberRowHeight = 64;

// Kieu chu MH-27: Nunito, line-height 100%
const TextStyle kStatValueStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 24,
  fontWeight: FontWeight.w700,
  height: 1.0,
);
const TextStyle kAvatarLetterStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 19,
  fontWeight: FontWeight.w700,
  color: kOnPrimary,
  height: 1.0,
);

/// Theme rieng de chay thu phan cua Dinh trong file preview.
/// Giu giong buildAppTheme() cua file chung, chi khac la lay mau
/// tu file rieng nay.
ThemeData buildDinhTheme() {
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
