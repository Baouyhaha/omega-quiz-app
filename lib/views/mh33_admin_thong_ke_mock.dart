// MOCK: du lieu gia cho MH-33 Admin: Thong ke, theo du lieu
// cua task. Chua noi API — de giai doan chuc nang: app goi API,
// API moi qua Firebase.

import 'package:flutter/material.dart';

/// Mot the thong ke tong o hang tren.
class MockSystemStat {
  const MockSystemStat({
    required this.value,
    required this.label,
    required this.color,
  });

  /// Gia tri, vi du "128".
  final String value;

  /// Nhan, vi du "Tổng tài khoản".
  final String label;

  /// Mau gia tri theo task.
  final Color color;
}

/// 3 the thong ke tong theo task.
const List<MockSystemStat> mockSystemStats = [
  MockSystemStat(
    value: '128',
    label: 'Tổng tài khoản',
    color: Color(0xFF6C4CF1),
  ),
  MockSystemStat(
    value: '45',
    label: 'Tổng chủ đề',
    color: Color(0xFF6C4CF1),
  ),
  MockSystemStat(
    value: '1.240',
    label: 'Tổng lượt làm',
    color: Color(0xFF6C4CF1),
  ),
];

/// Mot cot trong bieu do luot lam theo ngay.
class MockChartBar {
  const MockChartBar({
    required this.day,
    required this.value,
    required this.height,
  });

  /// Nhan ngay, vi du "T2".
  final String day;

  /// Gia tri hien tren cot, vi du 18.
  final int value;

  /// Chieu cao cot theo so do task (px). Chieu cao trong task
  /// khong ti le tuyen tinh voi gia tri nen giu nguyen so do.
  final double height;
}

/// 5 cot bieu do theo task.
const List<MockChartBar> mockChartBars = [
  MockChartBar(day: 'T2', value: 18, height: 36),
  MockChartBar(day: 'T3', value: 24, height: 56),
  MockChartBar(day: 'T4', value: 32, height: 76),
  MockChartBar(day: 'T5', value: 41, height: 96),
  MockChartBar(day: 'T6', value: 52, height: 116),
];

/// Mot tai khoan gian lan theo task.
class MockCheatAccount {
  const MockCheatAccount({
    required this.name,
    required this.avatarLetter,
    required this.avatarColor,
    required this.violationText,
  });

  /// Ten tai khoan, vi du "An".
  final String name;

  /// Chu cai trong avatar, vi du "A".
  final String avatarLetter;

  /// Mau avatar theo task.
  final Color avatarColor;

  /// Dong vi pham, vi du "12 lần vi phạm".
  final String violationText;
}

/// 1 tai khoan gian lan theo task.
const MockCheatAccount mockCheatAccount = MockCheatAccount(
  name: 'An',
  avatarLetter: 'A',
  avatarColor: Color(0xFFFF5A5F),
  violationText: '12 lần vi phạm',
);
