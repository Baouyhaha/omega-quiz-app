// MOCK: du lieu gia cho MH-32 Admin: Goi va han muc, theo du lieu
// cua task. Chua noi API — de giai doan chuc nang: app goi API,
// API moi qua Firebase.

/// Mot han muc trong mot goi: nhan o trai, gia tri trong o nhap.
class MockPlanLimit {
  const MockPlanLimit({required this.label, required this.value});

  /// Nhan, vi du "Giá (đ)".
  final String label;

  /// Gia tri hien trong o nhap, vi du "49000".
  final String value;
}

/// Mot goi: ten goi va cac han muc.
class MockPlan {
  const MockPlan({required this.name, required this.limits});

  /// Ten goi, vi du "Gói 30 ngày".
  final String name;

  /// Cac han muc cua goi.
  final List<MockPlanLimit> limits;
}

/// 2 goi theo task.
const List<MockPlan> mockPlans = [
  MockPlan(
    name: 'Gói 30 ngày',
    limits: [
      MockPlanLimit(label: 'Giá (đ)', value: '49000'),
      MockPlanLimit(label: 'Thời hạn', value: '30 ngày'),
      MockPlanLimit(label: 'Chủ đề tối đa', value: '999'),
      MockPlanLimit(label: 'Thành viên/chủ đề', value: '999'),
      MockPlanLimit(label: 'Câu hỏi/chủ đề', value: '999'),
    ],
  ),
  MockPlan(
    name: 'Gói miễn phí',
    limits: [
      MockPlanLimit(label: 'Chủ đề tối đa', value: '1'),
      MockPlanLimit(label: 'Bộ đề/chủ đề', value: '2'),
      MockPlanLimit(label: 'Thành viên/chủ đề', value: '10'),
    ],
  ),
];

/// Ghi chu duoi nut luu theo task.
const String mockPlanNote =
    'Thay đổi chỉ áp dụng cho lượt đăng ký mới.';
