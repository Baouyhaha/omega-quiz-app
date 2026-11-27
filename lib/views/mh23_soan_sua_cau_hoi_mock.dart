// MOCK: du lieu gia cho MH-23 Soan/Sua cau hoi, theo du lieu cua task.
// Chua noi API — de giai doan chuc nang: app goi API, API moi qua Firebase.

/// Mot cau hoi dang soan/sua o MH-23.
class MockQuestionDraft {
  const MockQuestionDraft({
    required this.content,
    required this.answers,
    required this.correctIndex,
    required this.difficulty,
    required this.timeSeconds,
    required this.points,
    required this.hint,
    required this.explanation,
  });

  /// Noi dung cau hoi, vi du "Đạo hàm của f(x) = x² tại x = 2?".
  final String content;

  /// 4 dap an A, B, C, D theo thu tu.
  final List<String> answers;

  /// Vi tri dap an dung trong [answers]: 0 = A, 1 = B, 2 = C, 3 = D.
  final int correctIndex;

  /// Muc do: "Dễ" / "Trung bình" / "Khó".
  final String difficulty;

  /// Thoi gian lam bai (giay).
  final int timeSeconds;

  /// Diem cua cau hoi.
  final int points;

  /// Goi y cho nguoi lam bai.
  final String hint;

  /// Giai thich dap an dung.
  final String explanation;
}

/// Cau hoi mau theo task (frame MH-23): dap an dung la B ("4").
const MockQuestionDraft mockQuestionDraft = MockQuestionDraft(
  content: 'Đạo hàm của f(x) = x² tại x = 2?',
  answers: ['2', '4', '8', '0'],
  correctIndex: 1,
  difficulty: 'Trung bình',
  timeSeconds: 30,
  points: 10,
  hint: "Nhớ công thức (x²)' = 2x",
  explanation: "f'(x) = 2x nên f'(2) = 4",
);

/// Ban trong de tao cau hoi moi (che do Soan, chua dien gi).
const MockQuestionDraft mockQuestionDraftEmpty = MockQuestionDraft(
  content: '',
  answers: ['', '', '', ''],
  correctIndex: 1,
  difficulty: 'Trung bình',
  timeSeconds: 30,
  points: 10,
  hint: '',
  explanation: '',
);
