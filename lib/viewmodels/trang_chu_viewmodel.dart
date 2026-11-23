// TrangChuViewModel — dữ liệu trang chủ MH-02 (T40).
// Gọi 3 API khi mở trang chủ: topics/mine, topics/public, invitations/mine.
// Bộ đề mới: lấy bộ đề của từng chủ đề công khai rồi gộp lại, lấy tối đa 5.
import 'package:flutter/foundation.dart';

import '../models/exam.dart';
import '../models/topic.dart';
import '../services/api_client.dart';

class TrangChuViewModel extends ChangeNotifier {
  TrangChuViewModel({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  bool dangTai = true;
  String? loi;
  List<Topic> chuDeCuaToi = [];
  List<Topic> chuDeCongKhai = [];
  List<Exam> boDeMoi = [];
  List<Map<String, dynamic>> loiMoiCho = [];

  Future<void> taiTrangChu() async {
    dangTai = true;
    loi = null;
    notifyListeners();
    try {
      // Chủ đề của tôi + chủ đề công khai + lời mời: gọi song song.
      final results = await Future.wait([
        _api.get('topics/mine'),
        _api.get('topics/public', query: {'limit': '20'}),
        _api.get('invitations/mine'),
      ]);
      chuDeCuaToi = (results[0] as List)
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList();
      final pageCongKhai = results[1] as Map<String, dynamic>;
      chuDeCongKhai = (pageCongKhai['items'] as List)
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList();
      loiMoiCho = (results[2] as List).cast<Map<String, dynamic>>();

      // Bộ đề mới: lấy bộ đề của từng chủ đề công khai rồi gộp lại.
      final tatCaBoDe = <Exam>[];
      for (final topic in chuDeCongKhai) {
        final examsJson = await _api.get('topics/${topic.id}/exams') as List;
        tatCaBoDe.addAll(examsJson
            .map((e) => Exam.fromJson(e as Map<String, dynamic>)));
      }
      // API chưa trả createdAt để sắp xếp tin cậy thì cứ giữ thứ tự trả về,
      // lấy tối đa 5 bộ đề.
      boDeMoi = tatCaBoDe.take(5).toList();
    } on ApiException catch (e) {
      loi = e.message;
    } catch (_) {
      loi = 'Không tải được trang chủ. Kiểm tra API local đã chạy chưa.';
    }
    dangTai = false;
    notifyListeners();
  }

  /// Chấp nhận lời mời: gọi POST invitations/{id}/accept rồi tải lại trang chủ
  /// (lời mời biến mất khỏi danh sách chờ, chủ đề xuất hiện ở "Chủ đề của tôi").
  Future<void> chapNhanLoiMoi(String invitationId) async {
    await _api.post('invitations/$invitationId/accept');
    await taiTrangChu();
  }

  /// Lấy chi tiết 1 bộ đề để mở MH-08.
  Future<Exam> layChiTietBoDe(String examId) async {
    final data = await _api.get('exams/$examId') as Map<String, dynamic>;
    return Exam.fromJson(data);
  }
}
