// Hàm định dạng ngày giờ + thời lượng dùng chung (T23).
// Không thuộc theme nên để file riêng trong lib/core.

/// Đổi chuỗi ISO (ví dụ closeAt) sang giờ Việt Nam dạng
/// "20:00 ngày 24/11/2026". Chuỗi lỗi thì trả nguyên chuỗi.
String dinhDangNgayGio(String iso) {
  try {
    final d = DateTime.parse(iso).toLocal();
    final gio = d.hour.toString().padLeft(2, '0');
    final phut = d.minute.toString().padLeft(2, '0');
    return '$gio:$phut ngày ${d.day}/${d.month}/${d.year}';
  } catch (_) {
    return iso;
  }
}

/// Đổi số giây sang dạng "m:ss" (ví dụ 750 giây -> "12:30").
String dinhDangThoiGian(int giay) {
  final phut = giay ~/ 60;
  final giayLe = (giay % 60).toString().padLeft(2, '0');
  return '$phut:$giayLe';
}
