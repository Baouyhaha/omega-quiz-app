// MOCK: du lieu gia cho MH-27 Thong ke chu de, theo du lieu cua task.
// Chua noi API — de giai doan chuc nang: app goi API, API moi qua Firebase.

import 'package:flutter/material.dart';

/// Ten chu de hien o tieu de, theo task.
const String mockTopicTitle = 'Toán cao cấp';

/// Mot the thong ke tong (gia tri + nhan).
class MockStatCard {
  const MockStatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  /// Gia tri hien thi, vi du "128", "7.2", "68%".
  final String value;

  /// Nhan duoi gia tri, vi du "Tổng lượt làm".
  final String label;

  /// Mau cua gia tri.
  final Color color;
}

/// 3 the thong ke theo task.
const List<MockStatCard> mockStatCards = [
  MockStatCard(
    value: '128',
    label: 'Tổng lượt làm',
    color: Color(0xFF6C4CF1),
  ),
  MockStatCard(
    value: '7.2',
    label: 'Điểm trung bình',
    color: Color(0xFF118AB2),
  ),
  MockStatCard(
    value: '68%',
    label: 'Tỉ lệ đúng',
    color: Color(0xFF2FBF71),
  ),
];

/// Ti le dung cua mot bo de.
class MockExamStat {
  const MockExamStat({required this.name, required this.percent});

  /// Ten bo de, vi du "Giữa kỳ — Đạo hàm".
  final String name;

  /// Ti le dung: 0.72 = 72% theo task.
  final double percent;
}

/// 2 bo de theo task.
const List<MockExamStat> mockExamStats = [
  MockExamStat(name: 'Giữa kỳ — Đạo hàm', percent: 0.72),
  MockExamStat(name: 'Cuối kỳ — Tích phân', percent: 0.61),
];

/// Mot thanh vien tich cuc.
class MockActiveMember {
  const MockActiveMember({
    required this.name,
    required this.initial,
    required this.avatarColor,
    required this.rank,
    required this.points,
    required this.attempts,
  });

  /// Ten thanh vien, vi du "Uy".
  final String name;

  /// Chu cai trong avatar, vi du "U".
  final String initial;

  /// Mau nen avatar.
  final Color avatarColor;

  /// Hang, vi du "Hạng Hổ".
  final String rank;

  /// Diem, vi du 1250.
  final int points;

  /// So luot lam, vi du 24.
  final int attempts;
}

/// 2 thanh vien tich cuc theo task.
const List<MockActiveMember> mockActiveMembers = [
  MockActiveMember(
    name: 'Uy',
    initial: 'U',
    avatarColor: Color(0xFF6C4CF1),
    rank: 'Hạng Hổ',
    points: 1250,
    attempts: 24,
  ),
  MockActiveMember(
    name: 'Danh',
    initial: 'D',
    avatarColor: Color(0xFF2FBF71),
    rank: 'Hạng Chó',
    points: 1000,
    attempts: 18,
  ),
];
