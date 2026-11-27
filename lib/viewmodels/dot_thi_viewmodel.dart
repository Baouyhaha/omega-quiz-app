// DotThiViewModel — dữ liệu đợt thi khung giờ MH-17 + kết quả MH-18 (T28).
// Gọi API contests: danh sách đợt (GET /contests), vào thi
// (POST /contests/:id/enter), kết quả xếp hạng (GET /contests/:id/results).
// Tên chủ đề lấy từ topics/mine + topics/public vì API contests chỉ trả
// topicId, không trả tên chủ đề.
import 'package:flutter/foundation.dart';

import '../services/api_client.dart';

class DotThiViewModel extends ChangeNotifier {
  DotThiViewModel({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  bool dangTai = true;
  String? loi;

  // 3 nhóm theo trạng thái server tính sẵn (field status trong contestView):
  // OPEN = đang mở, UPCOMING = sắp mở, CLOSED = đã kết thúc.
  List<Map<String, dynamic>> dangMo = [];
  List<Map<String, dynamic>> sapMo = [];
  List<Map<String, dynamic>> daKetThuc = [];

  // topicId -> tên chủ đề (để hiện trên thẻ đợt thi ở MH-17).
  Map<String, String> tenChuDe = {};

  // Kết quả xếp hạng của 1 đợt đã đóng (MH-18) + uid của mình để tô sáng
  // dòng của mình trong bảng xếp hạng.
  bool dangTaiKetQua = false;
  String? loiKetQua;
  List<Map<String, dynamic>> ketQua = [];
  String? uidCuaToi;

  /// Tải danh sách đợt thi + tên chủ đề. Gọi khi mở MH-17 và khi kéo
  /// xuống để tải lại (RefreshIndicator).
  Future<void> taiDanhSachDotThi() async {
    dangTai = true;
    loi = null;
    notifyListeners();
    try {
      // Đợt thi + chủ đề của tôi + chủ đề công khai: gọi song song.
      final results = await Future.wait([
        _api.get('contests'),
        _api.get('topics/mine'),
        _api.get('topics/public', query: {'limit': '50'}),
      ]);
      final tatCa = (results[0] as List).cast<Map<String, dynamic>>();
      dangMo = tatCa.where((c) => c['status'] == 'OPEN').toList();
      sapMo = tatCa.where((c) => c['status'] == 'UPCOMING').toList();
      daKetThuc = tatCa.where((c) => c['status'] == 'CLOSED').toList();

      tenChuDe = {};
      for (final t in (results[1] as List).cast<Map<String, dynamic>>()) {
        tenChuDe[t['id'] as String] = t['name'] as String? ?? '';
      }
      final pageCongKhai = results[2] as Map<String, dynamic>;
      for (final t
          in (pageCongKhai['items'] as List).cast<Map<String, dynamic>>()) {
        tenChuDe[t['id'] as String] = t['name'] as String? ?? '';
      }
    } on ApiException catch (e) {
      loi = e.message;
    } catch (_) {
      loi = 'Không tải được danh sách đợt thi. '
          'Kiểm tra API local đã chạy chưa.';
    }
    dangTai = false;
    notifyListeners();
  }

  /// Vào thi 1 đợt: API tạo lượt làm bài + trả {attemptId, questions}.
  /// Ném ApiException khi đợt chưa mở (CONTEST_NOT_OPEN) hoặc tài khoản
  /// đã vào rồi (ALREADY_ENTERED — mỗi tài khoản chỉ 1 lượt).
  Future<Map<String, dynamic>> vaoThi(String contestId) async {
    final data = await _api.post('contests/$contestId/enter');
    return data as Map<String, dynamic>;
  }

  /// Tải kết quả xếp hạng của 1 đợt đã đóng (MH-18). Kèm uid của mình
  /// (GET /me) để màn hình tô sáng dòng của mình.
  Future<void> taiKetQua(String contestId) async {
    dangTaiKetQua = true;
    loiKetQua = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.get('contests/$contestId/results'),
        _api.get('me'),
      ]);
      ketQua = (results[0] as List).cast<Map<String, dynamic>>();
      uidCuaToi = (results[1] as Map<String, dynamic>)['uid'] as String?;
    } on ApiException catch (e) {
      loiKetQua = e.message;
    } catch (_) {
      loiKetQua = 'Không tải được kết quả đợt thi. '
          'Kiểm tra API local đã chạy chưa.';
    }
    dangTaiKetQua = false;
    notifyListeners();
  }
}
