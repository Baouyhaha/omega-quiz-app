// Bảng rank con vật — ngưỡng GIỐNG HỆT server (api/src/util.js).
// Server đã trả sẵn animalRank trong /leaderboard và /me; file này dùng để
// tính "còn X điểm lên rank sau", lấy màu con vật và phát hiện lên rank.
import 'package:flutter/material.dart';

String animalRank(int score) {
  if (score < 900) return 'Chuột';
  if (score < 1000) return 'Mèo';
  if (score < 1100) return 'Chó';
  if (score < 1200) return 'Heo';
  if (score < 1350) return 'Ngựa';
  if (score < 1500) return 'Gấu';
  if (score < 1650) return 'Hổ';
  if (score < 1800) return 'Sư Tử';
  if (score < 2000) return 'Voi';
  return 'Cá Voi Xanh';
}

const Map<String, Color> _mauRank = {
  'Chuột': Color(0xFF9E9E9E),
  'Mèo': Color(0xFF7CB342),
  'Chó': Color(0xFF42A5F5),
  'Heo': Color(0xFFEC407A),
  'Ngựa': Color(0xFFFB8C00),
  'Gấu': Color(0xFF8D6E63),
  'Hổ': Color(0xFFF4511E),
  'Sư Tử': Color(0xFFF9A825),
  'Voi': Color(0xFF7E57C2),
  'Cá Voi Xanh': Color(0xFF1565C0),
};

/// Màu của con vật. Màu chỉ đặt ở đây, không hardcode mã màu trong màn hình.
Color animalColor(String animal) => _mauRank[animal] ?? const Color(0xFF9E9E9E);

/// Ngưỡng điểm của rank kế tiếp. Trả về null khi đã ở rank cao nhất.
int? _mocRankSau(int score) {
  if (score < 900) return 900;
  if (score < 1000) return 1000;
  if (score < 1100) return 1100;
  if (score < 1200) return 1200;
  if (score < 1350) return 1350;
  if (score < 1500) return 1500;
  if (score < 1650) return 1650;
  if (score < 1800) return 1800;
  if (score < 2000) return 2000;
  return null; // Cá Voi Xanh: không còn rank sau.
}

/// Số điểm còn thiếu để lên rank sau. Trả về null khi đã ở rank cao nhất.
int? pointsToNextRank(int score) {
  final moc = _mocRankSau(score);
  if (moc == null) return null;
  return moc - score;
}

/// Tên rank kế tiếp. Trả về null khi đã ở rank cao nhất.
String? tenRankSau(int score) {
  final moc = _mocRankSau(score);
  if (moc == null) return null;
  return animalRank(moc);
}

/// Tỉ lệ tiến độ trong rank hiện tại (0.0–1.0) để vẽ thanh tiến độ.
double tienTrinhLenRank(int score) {
  final mocSau = _mocRankSau(score);
  if (mocSau == null) return 1.0;
  final mocHienTai = _mocDauRank(animalRank(score));
  return (score - mocHienTai) / (mocSau - mocHienTai);
}

int _mocDauRank(String animal) {
  switch (animal) {
    case 'Chuột':
      return 0;
    case 'Mèo':
      return 900;
    case 'Chó':
      return 1000;
    case 'Heo':
      return 1100;
    case 'Ngựa':
      return 1200;
    case 'Gấu':
      return 1350;
    case 'Hổ':
      return 1500;
    case 'Sư Tử':
      return 1650;
    case 'Voi':
      return 1800;
    default:
      return 2000; // Cá Voi Xanh
  }
}
