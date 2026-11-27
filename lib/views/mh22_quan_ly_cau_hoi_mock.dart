// MOCK: du lieu gia cho MH-22 Quan ly cau hoi, theo du lieu cua task.
// Chua noi API — de giai doan chuc nang: app goi API, API moi qua Firebase.

/// Do kho cua mot cau hoi.
enum MockDifficulty { all, easy, medium, hard }

/// Mot cau hoi hien trong danh sach MH-22.
class MockQuestion {
  const MockQuestion({
    required this.number,
    required this.preview,
    required this.difficulty,
  });

  /// So thu tu hien thi, vi du "Câu 1".
  final int number;

  /// Noi dung xem truoc, vi du "Đạo hàm của x² là...".
  final String preview;

  /// Do kho: de / trung binh / kho.
  final MockDifficulty difficulty;

  /// Nhan do kho hien tren huy hieu, theo task.
  String get difficultyLabel {
    switch (difficulty) {
      case MockDifficulty.easy:
        return 'Dễ';
      case MockDifficulty.medium:
        return 'Trung bình';
      case MockDifficulty.hard:
        return 'Khó';
      case MockDifficulty.all:
        return 'Tất cả';
    }
  }
}

/// Tieu de chu de hien o header, theo task.
const String mockTopicTitle = 'Toán cao cấp';

/// 3 cau hoi theo task (frame MH-22).
const List<MockQuestion> mockQuestions = [
  MockQuestion(
    number: 1,
    preview: 'Đạo hàm của x² là...',
    difficulty: MockDifficulty.easy,
  ),
  MockQuestion(
    number: 2,
    preview: 'Đạo hàm của sin(x)...',
    difficulty: MockDifficulty.medium,
  ),
  MockQuestion(
    number: 3,
    preview: 'Tích phân của 1/x...',
    difficulty: MockDifficulty.hard,
  ),
];

/// Truong hop bien de kiem tra giao dien (khong hien mac dinh):
/// noi dung xem truoc rat dai, va noi dung trong.
const MockQuestion mockQuestionLongPreview = MockQuestion(
  number: 4,
  preview:
      'Tính đạo hàm cấp hai của hàm số f(x) = x³ − 3x² + 2x − 1 tại điểm x = 2 và giải thích từng bước...',
  difficulty: MockDifficulty.hard,
);

const MockQuestion mockQuestionEmptyPreview = MockQuestion(
  number: 5,
  preview: '',
  difficulty: MockDifficulty.easy,
);
