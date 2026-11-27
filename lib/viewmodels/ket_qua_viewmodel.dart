// KetQuaViewModel — giữ kết quả vừa nộp xong cho MH-10 (T23).
// 2 đường vào: vừa nộp xong (kết quả có sẵn từ MH-09b) hoặc mở từ
// lịch sử MH-12 (chỉ có attemptId, tải lại từ attempts/mine).
import 'package:flutter/foundation.dart';

import '../services/api_client.dart';

class KetQuaViewModel extends ChangeNotifier {
  KetQuaViewModel(this._api);

  final ApiClient _api;

  Map<String, dynamic>? ketQua; // data của POST submit (đã gộp examId)
  Map<String, dynamic>? exam; // data của GET exams/{id} (lấy settings)
  bool dangTai = false;
  String? loi;

  /// Đường vào 1: vừa nộp xong, kết quả có sẵn từ MH-09b.
  void nhanKetQuaVuaNop(Map<String, dynamic> data) {
    ketQua = data;
    notifyListeners();
  }

  /// Đường vào 2: mở từ lịch sử (MH-12) — chỉ có attemptId.
  /// GET attempts/mine trả danh sách bài đã làm, tìm đúng attemptId.
  /// Lưu ý: phần tử trong list dùng field `id` (không phải `attemptId`).
  Future<void> taiTuLichSu(String attemptId) async {
    dangTai = true;
    loi = null;
    notifyListeners();
    try {
      final list = await _api.get('attempts/mine') as List;
      final timThay = list.where((a) => a['id'] == attemptId);
      ketQua =
          timThay.isEmpty ? null : timThay.first as Map<String, dynamic>;
      if (ketQua == null) loi = 'Không tìm thấy bài làm này.';
    } on ApiException catch (e) {
      loi = e.message;
    } finally {
      dangTai = false;
      notifyListeners();
    }
  }

  /// Lấy settings của đề để quyết định ẩn/hiện (publishScore,
  /// showAnswerMode, closeAt). Gọi sau khi đã có ketQua.
  Future<void> taiCaiDatDe(String examId) async {
    try {
      exam = await _api.get('exams/$examId') as Map<String, dynamic>;
    } on ApiException catch (e) {
      loi = e.message;
    }
    notifyListeners();
  }

  // Tiện ích cho giao diện:
  String? get attemptId =>
      ketQua?['attemptId'] as String? ?? ketQua?['id'] as String?;
  String? get examId => ketQua?['examId'] as String?;
  bool get biTuNop => ketQua?['status'] == 'FORCE_SUBMITTED';

  /// Điểm bị ẩn: submit trả score null (publishScore=false), hoặc đường
  /// vào từ lịch sử mà đề đang tắt publishScore (API trả điểm gốc trong
  /// attempts/mine nên app phải tự kiểm tra settings để ẩn).
  bool get diemBiAn {
    if (biTuNop) return false;
    if (ketQua?['score'] == null) return true;
    final settings = exam?['settings'] as Map<String, dynamic>?;
    return settings != null && settings['publishScore'] == false;
  }

  double? get diem => (ketQua?['score'] as num?)?.toDouble();
  double? get thuongTocDo => (ketQua?['speedBonus'] as num?)?.toDouble();
  int? get thoiGianGiay => ketQua?['durationSeconds'] as int?;
  int get soCauDung => ketQua?['correctCount'] as int? ?? 0;
  int get tongSoCau => ketQua?['totalQuestions'] as int? ?? 0;
  int get soCauSai => tongSoCau - soCauDung;

  /// Tổng điểm của đề: API chưa trả tổng điểm, tạm tính mỗi câu 10 điểm
  /// (câu hỏi mẫu đều 10 điểm) — đã hỏi Uy bổ sung totalPoints vào API.
  double get tongDiem => tongSoCau * 10.0;

  /// Có được xem lại đáp án không (theo showAnswerMode + closeAt).
  /// Chưa tải xong settings thì mặc định cho xem (endpoint review là
  /// chốt chặn thật — bị khóa thì server trả 403, MH-11 hiện thông điệp).
  bool get duocXemLai {
    final settings = exam?['settings'] as Map<String, dynamic>?;
    if (settings == null) return true;
    final mode = settings['showAnswerMode'] as String?;
    if (mode == 'NEVER') return false;
    if (mode == 'AFTER_CLOSE') {
      final closeAt = settings['closeAt'] as String?;
      if (closeAt != null &&
          DateTime.now().isBefore(DateTime.parse(closeAt))) {
        return false;
      }
    }
    return true;
  }

  /// Thời điểm được xem lại (closeAt), null nếu không có.
  String? get thoiDiemDuocXem {
    final settings = exam?['settings'] as Map<String, dynamic>?;
    return settings?['closeAt'] as String?;
  }
}
