// MOCK: Dữ liệu giả cho màn hình MH-20 "Tạo/Sửa chủ đề".
// Chưa nối API. Sau này thay bằng dữ liệu thật của chủ đề đang sửa,
// giao diện trong mh20_tao_sua_chu_de_screen.dart không cần sửa.
// Giá trị mẫu theo dữ liệu của task để ảnh chụp khớp thiết kế.
// Để thử form trống (chế độ tạo, chưa nhập gì), dùng mockTopicEmpty.

/// Dữ liệu của một chủ đề, theo các trường trong form MH-20.
class MockTopic {
  const MockTopic({
    required this.name,
    required this.description,
    required this.mode,
  });

  /// Tên chủ đề, ví dụ "Toán cao cấp".
  final String name;

  /// Mô tả chủ đề, ví dụ "Ôn tập đạo hàm, tích phân".
  final String description;

  /// Chế độ: 'public' = Công khai, 'private' = Riêng tư.
  final String mode;
}

/// Chủ đề mẫu theo dữ liệu của task: tên "Toán cao cấp", chế độ Công khai.
const MockTopic mockTopic = MockTopic(
  name: 'Toán cao cấp',
  description: 'Ôn tập đạo hàm, tích phân',
  mode: 'public',
);

/// Form trống, dùng khi muốn thử chế độ tạo mới chưa nhập gì.
const MockTopic mockTopicEmpty = MockTopic(
  name: '',
  description: '',
  mode: 'public',
);
