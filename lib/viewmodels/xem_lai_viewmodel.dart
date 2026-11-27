// XemLaiViewModel — tải đáp án xem lại cho MH-11 (T23).
// Gọi GET attempts/{id}/review. Endpoint này chỉ trả đáp án khi được
// phép; khi bị khóa server trả lỗi 403 FORBIDDEN.
import 'package:flutter/foundation.dart';

import '../services/api_client.dart';

class XemLaiViewModel extends ChangeNotifier {
  XemLaiViewModel(this._api);

  final ApiClient _api;

  List<dynamic> cauHoi = [];
  bool dangTai = false;
  bool biKhoa = false;
  String? thoiDiemDuocXem; // closeAt, dạng chuỗi ISO, null nếu không có
  String? loi;

  Future<void> taiXemLai({
    required String attemptId,
    required String examId,
  }) async {
    dangTai = true;
    loi = null;
    notifyListeners();
    try {
      // Lấy settings trước để biết closeAt (dùng khi bị khóa).
      final exam = await _api.get('exams/$examId') as Map<String, dynamic>;
      final settings = exam['settings'] as Map<String, dynamic>;
      thoiDiemDuocXem = settings['closeAt'] as String?;

      final data =
          await _api.get('attempts/$attemptId/review') as Map<String, dynamic>;
      cauHoi = data['questions'] as List;
    } on ApiException catch (e) {
      if (e.errorCode == 'FORBIDDEN') {
        // Bị khóa xem lại — KHÔNG phải lỗi mạng, hiện thông điệp riêng.
        biKhoa = true;
      } else {
        loi = e.message;
      }
    } finally {
      dangTai = false;
      notifyListeners();
    }
  }
}
