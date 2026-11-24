// TimKiemViewModel — dữ liệu màn tìm kiếm MH-04 (T40, B2).
// API search: GET search?q= trả về {topics: [...], exams: [{id, topicId, title}]}.
// Lọc theo chủ đề làm ở phía app (API search không nhận topicId).
// Lọc theo độ khó CHƯA làm được — exam chưa có độ khó trong API.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/topic.dart';
import '../services/api_client.dart';

class TimKiemViewModel extends ChangeNotifier {
  TimKiemViewModel({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  bool dangTim = false;
  String? loi;
  String tuKhoa = '';
  String boLocLoai = 'Tất cả'; // 'Tất cả' | 'Chủ đề' | 'Bộ đề'
  String? chuDeDangChon; // id chủ đề, null = tất cả chủ đề
  List<Topic> ketQuaChuDe = [];
  List<Map<String, dynamic>> ketQuaBoDe = [];
  List<Topic> danhSachChuDe = []; // để vẽ bộ lọc chủ đề

  Timer? _henGio;

  /// Tải danh sách chủ đề 1 lần để vẽ bộ lọc (gọi khi mở màn MH-04).
  Future<void> taiDanhSachChuDe() async {
    try {
      final data =
          await _api.get('topics/public', query: {'limit': '50'})
              as Map<String, dynamic>;
      danhSachChuDe = (data['items'] as List)
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } on ApiException catch (e) {
      loi = e.message;
      notifyListeners();
    }
  }

  /// Gõ xong chờ 400ms mới gọi API (debounce) để không spam request.
  void nhapTuKhoa(String value) {
    tuKhoa = value;
    _henGio?.cancel();
    if (value.trim().isEmpty) {
      ketQuaChuDe = [];
      ketQuaBoDe = [];
      notifyListeners();
      return;
    }
    _henGio = Timer(const Duration(milliseconds: 400), timKiem);
  }

  Future<void> timKiem() async {
    if (tuKhoa.trim().isEmpty) return;
    dangTim = true;
    loi = null;
    notifyListeners();
    try {
      final data = await _api.get('search', query: {'q': tuKhoa.trim()})
          as Map<String, dynamic>;
      ketQuaChuDe = (data['topics'] as List? ?? [])
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList();
      ketQuaBoDe = (data['exams'] as List? ?? []).cast<Map<String, dynamic>>();
      // Lọc theo chủ đề (lọc ở app, vì API search không nhận topicId).
      if (chuDeDangChon != null) {
        ketQuaBoDe = ketQuaBoDe
            .where((e) => e['topicId'] == chuDeDangChon)
            .toList();
        ketQuaChuDe =
            ketQuaChuDe.where((t) => t.id == chuDeDangChon).toList();
      }
    } on ApiException catch (e) {
      loi = e.message;
    } catch (_) {
      loi = 'Không tìm kiếm được. Kiểm tra API local đã chạy chưa.';
    }
    dangTim = false;
    notifyListeners();
  }

  void chonBoLocLoai(String loai) {
    boLocLoai = loai;
    notifyListeners();
  }

  /// Chọn chủ đề để lọc (null = tất cả), rồi tìm lại với từ khoá hiện tại.
  void chonChuDe(String? topicId) {
    chuDeDangChon = topicId;
    if (tuKhoa.trim().isNotEmpty) timKiem();
    notifyListeners();
  }

  @override
  void dispose() {
    _henGio?.cancel();
    super.dispose();
  }
}
