// MOCK: du lieu gia cho MH-31 Admin: Chi tiet tai khoan, theo du lieu
// cua task. Chua noi API — de giai doan chuc nang: app goi API,
// API moi qua Firebase.

/// Chi tiet mot tai khoan (man nay hien tai khoan Danh,
/// mo tu MH-30 bang cach bam vao the Danh).
class MockAccountDetail {
  const MockAccountDetail({
    required this.name,
    required this.initial,
    required this.email,
    required this.role,
    required this.status,
    required this.planName,
    required this.planExpiry,
    required this.planHistory,
  });

  /// Ten tai khoan, vi du "Danh".
  final String name;

  /// Chu cai trong avatar, vi du "D".
  final String initial;

  /// Email, vi du "danh@gmail.com".
  final String email;

  /// Vai tro: "user" hoac "admin".
  final String role;

  /// Trang thai dang hien: "Đang hoạt động" hoac "Bị khóa".
  final String status;

  /// Ten goi dang dung: "Dùng thử", "Thuê bao", "Miễn phí".
  final String planName;

  /// Han goi, vi du "Hết hạn 28/11/2026 — còn 7 ngày".
  final String planExpiry;

  /// Lich su goi.
  final List<MockPlanHistory> planHistory;
}

/// Mot dong trong lich su goi.
class MockPlanHistory {
  const MockPlanHistory({required this.date, required this.action});

  /// Ngay, vi du "21/11".
  final String date;

  /// Hanh dong, vi du "Kích hoạt dùng thử 7 ngày".
  final String action;
}

/// Tai khoan Danh theo task.
const MockAccountDetail mockAccountDetail = MockAccountDetail(
  name: 'Danh',
  initial: 'D',
  email: 'danh@gmail.com',
  role: 'user',
  status: 'Đang hoạt động',
  planName: 'Dùng thử',
  planExpiry: 'Hết hạn 28/11/2026 — còn 7 ngày',
  planHistory: [
    MockPlanHistory(
      date: '21/11',
      action: 'Kích hoạt dùng thử 7 ngày',
    ),
    MockPlanHistory(
      date: '21/11',
      action: 'Tạo tài khoản mới',
    ),
  ],
);
