// MOCK: du lieu gia cho MH-30 Admin: Tai khoan, theo du lieu cua task.
// Chua noi API — de giai doan chuc nang: app goi API, API moi qua Firebase.

import 'package:flutter/material.dart';

/// Trang thai tai khoan.
enum MockAccountStatus { active, locked }

/// Hanh dong hien o goc duoi phai cua the tai khoan.
enum MockAccountAction { lock, unlock, none }

/// Mot tai khoan trong danh sach admin.
class MockAdminAccount {
  const MockAdminAccount({
    required this.name,
    required this.initial,
    required this.avatarColor,
    required this.role,
    required this.plan,
    required this.status,
    required this.action,
  });

  /// Ten tai khoan, vi du "Danh".
  final String name;

  /// Chu cai trong avatar, vi du "D".
  final String initial;

  /// Mau nen avatar.
  final Color avatarColor;

  /// Vai tro: "user" hoac "admin".
  final String role;

  /// Goi dang dung: "Dùng thử", "Thuê bao", "Miễn phí".
  final String plan;

  /// Trang thai: dang hoat dong hoac bi khoa.
  final MockAccountStatus status;

  /// Nut hanh dong cua the: khoa, mo khoa, hoac khong co nut.
  final MockAccountAction action;
}

/// 3 tai khoan theo task.
const List<MockAdminAccount> mockAdminAccounts = [
  MockAdminAccount(
    name: 'Danh',
    initial: 'D',
    avatarColor: Color(0xFF6C4CF1),
    role: 'user',
    plan: 'Dùng thử',
    status: MockAccountStatus.active,
    action: MockAccountAction.lock,
  ),
  MockAdminAccount(
    name: 'Uy',
    initial: 'U',
    avatarColor: Color(0xFF118AB2),
    role: 'admin',
    plan: 'Thuê bao',
    status: MockAccountStatus.active,
    action: MockAccountAction.none,
  ),
  MockAdminAccount(
    name: 'Thịnh',
    initial: 'T',
    avatarColor: Color(0xFF06D6A0),
    role: 'user',
    plan: 'Miễn phí',
    status: MockAccountStatus.locked,
    action: MockAccountAction.unlock,
  ),
];

/// So tai khoan dang hien trong danh sach.
const int mockShownAccountCount = 3;

/// Tong so tai khoan.
const int mockTotalAccountCount = 128;
