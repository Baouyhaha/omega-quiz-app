// BangXepHangViewModel — gọi API BXH cho MH-14 (T29).
// Điểm xếp hạng do server quản lý, app chỉ hiển thị lại — KHÔNG tự
// cộng điểm ở app (sẽ lệch với server).
import 'package:flutter/foundation.dart';

import '../services/api_client.dart';

/// 2 phạm vi BXH làm được trong task này. Lọc tuần/tháng/chủ đề chờ API,
/// chưa có trong enum này.
enum PhamViBxh { toanHeThong, banBe }

class BangXepHangViewModel extends ChangeNotifier {
  BangXepHangViewModel(this._api);

  final ApiClient _api;

  List<Map<String, dynamic>> _tatCa = [];
  Set<String> _uidBanBe = {};
  PhamViBxh phamVi = PhamViBxh.toanHeThong;

  bool dangTai = false;
  String? loi;

  String? uidCuaToi;
  int? diemCuaToi;
  String? rankCuaToi;

  /// Con vật của lần load trước — dùng để phát hiện vừa lên rank.
  String? _rankLanTruoc;

  /// Tên rank mới khi vừa lên rank (khác null = màn hình hiện dialog
  /// chúc mừng). Màn hình gọi [xacNhanDaXemLenRank] sau khi hiện xong.
  String? lenRankMoi;

  /// Danh sách theo phạm vi đang chọn, đã xếp sẵn theo rankScore giảm dần
  /// (server trả về đã xếp sẵn, app không xếp lại).
  List<Map<String, dynamic>> get danhSach {
    if (phamVi == PhamViBxh.banBe) {
      return _tatCa.where((e) => _uidBanBe.contains(e['uid'])).toList();
    }
    return _tatCa;
  }

  /// Nạp lần đầu: gọi cả 3 endpoint cùng lúc.
  /// Lưu ý: đường dẫn KHÔNG có dấu / ở đầu (ApiClient nối baseUrl + path,
  /// baseUrl đã có / cuối — thêm / nữa sẽ thành // và API trả 404).
  Future<void> load() async {
    dangTai = true;
    loi = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.get('leaderboard'),
        _api.get('friends'),
        _api.get('me'),
      ]);
      _tatCa = (results[0] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final friendsJson = results[1] as Map<String, dynamic>;
      _uidBanBe = (friendsJson['friends'] as List)
          .map((e) => (e as Map)['uid'] as String)
          .toSet();
      final me = results[2] as Map<String, dynamic>;
      uidCuaToi = me['uid'] as String?;
      diemCuaToi = me['rankScore'] as int?;
      rankCuaToi = me['animalRank'] as String?;
      _kiemTraLenRank();
    } on ApiException catch (e) {
      loi = e.message;
    } catch (_) {
      loi = 'Không tải được bảng xếp hạng. Kiểm tra server đã chạy chưa.';
    }
    dangTai = false;
    notifyListeners();
  }

  /// Đổi phạm vi Toàn hệ thống / Bạn bè. Chỉ lọc lại danh sách đã tải,
  /// không gọi API lại.
  void doiPhamVi(PhamViBxh moi) {
    if (phamVi == moi) return;
    phamVi = moi;
    notifyListeners();
  }

  /// Tải lại sau mỗi hoạt động (nộp bài, đấu xong) để cập nhật điểm mới.
  Future<void> lamMoi() => load();

  void xacNhanDaXemLenRank() {
    lenRankMoi = null;
  }

  void _kiemTraLenRank() {
    final rankHienTai = rankCuaToi;
    if (rankHienTai == null) return;
    // Lần load đầu tiên chỉ ghi nhận, chưa kết luận lên rank.
    if (_rankLanTruoc == null) {
      _rankLanTruoc = rankHienTai;
      return;
    }
    if (rankHienTai != _rankLanTruoc) {
      lenRankMoi = rankHienTai;
    }
    _rankLanTruoc = rankHienTai;
  }
}
