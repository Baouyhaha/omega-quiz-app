// MOCK: du lieu gia cho MH-24 Import Excel, theo du lieu cua task.
// Chua noi API — de giai doan chuc nang: app goi API, API moi qua Firebase.

/// Ten file Excel da chon, theo task.
const String mockImportFileName = 'cau_hoi_toan.xlsx';

/// Tien trinh doc file: 0.65 = 65% theo task.
const double mockImportProgress = 0.65;

/// So cau hop le / tong so cau, theo task.
const int mockValidQuestionCount = 18;
const int mockTotalQuestionCount = 20;

/// Mot dong trong bang xem truoc.
class MockPreviewRow {
  const MockPreviewRow({
    required this.label,
    required this.preview,
    required this.valid,
  });

  /// Nhan dong, vi du "Dòng 1".
  final String label;

  /// Noi dung xem truoc, vi du "Đạo hàm của x²...".
  final String preview;

  /// true = hop le (tick xanh), false = loi (X do).
  final bool valid;
}

/// 3 dong xem truoc theo task: 2 dong hop le, 1 dong loi.
const List<MockPreviewRow> mockPreviewRows = [
  MockPreviewRow(
    label: 'Dòng 1',
    preview: 'Đạo hàm của x²...',
    valid: true,
  ),
  MockPreviewRow(
    label: 'Dòng 2',
    preview: 'Đạo hàm của sin(x)...',
    valid: true,
  ),
  MockPreviewRow(
    label: 'Dòng 3',
    preview: 'Tích phân của 1/x...',
    valid: false,
  ),
];

/// Cac loi theo dong, theo task.
const List<String> mockImportErrors = [
  'Dòng 5: thiếu đáp án đúng',
  'Dòng 12: sai định dạng mức độ',
];
