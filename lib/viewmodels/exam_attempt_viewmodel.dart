// ExamAttemptViewModel — "bộ não" của 1 lượt làm bài (tạo ở T22,
// dùng chung cho cả T22 và T23). Giữ attemptId, đề, đáp án đã chọn,
// thời gian từng câu, số lần vi phạm và trạng thái lượt làm.
import 'package:flutter/foundation.dart';

import '../services/api_client.dart';

/// Trạng thái của 1 lượt làm bài.
enum AttemptStatus { inProgress, submitted, forceSubmitted }

class ExamAttemptViewModel extends ChangeNotifier {
  ExamAttemptViewModel(this._api);

  final ApiClient _api;

  String? attemptId;
  String? examId;

  /// Thời gian làm bài (phút) do server trả khi tạo lượt làm (T21).
  int? durationMinutes;

  /// Mốc bắt đầu lượt làm — đồng hồ đếm ngược tính theo giờ thực
  /// (DateTime.now() - mốc), nên xoay màn hình hay thoát app rồi quay
  /// lại cũng không làm đồng hồ chạy sai.
  DateTime? thoiDiemBatDau;

  List<Map<String, dynamic>> questions = [];
  Map<String, int> selectedAnswers = {}; // questionId -> đáp án đã chọn (0-3)
  Map<String, int> timePerQuestion = {}; // questionId -> số giây đã làm
  int violations = 0;
  AttemptStatus status = AttemptStatus.inProgress;

  /// Câu đang làm + mốc vào câu — đo thời gian từng câu bằng mốc giờ
  /// (vào câu lúc nào, rời câu lúc nào) thay vì đếm từng giây bằng
  /// đồng hồ: câu nào làm dưới 1 giây (bấm nhanh) vẫn được ghi nhận
  /// (0 giây), thay vì bị bỏ sót làm server không tính được thưởng
  /// tốc độ (server chỉ tính theo từng câu khi MỌI câu đều có thời
  /// gian — xem submit()).
  String? _cauDangLam;
  DateTime? _thoiDiemVaoCau;

  static const int maxViolations = 5;

  bool get isForceSubmitted => status == AttemptStatus.forceSubmitted;

  /// Số giây còn lại của lượt làm (tính theo giờ thực). Trả về 0 khi
  /// chưa bắt đầu lượt làm hoặc đã hết giờ.
  int get soGiayConLai {
    final phut = durationMinutes;
    final batDau = thoiDiemBatDau;
    if (phut == null || batDau == null) return 0;
    final conLai = phut * 60 - DateTime.now().difference(batDau).inSeconds;
    return conLai < 0 ? 0 : conLai;
  }

  /// Bắt đầu lượt làm: gọi POST exams/{id}/attempts, lưu attemptId + đề
  /// + thời gian làm bài + mốc bắt đầu. Xóa đáp án + giờ từng câu của
  /// lượt làm trước (ViewModel sống suốt phiên app, không xóa thì đáp
  /// án đề cũ sẽ dính sang đề mới).
  Future<void> startAttempt(String examId) async {
    final data = await _api.post('exams/$examId/attempts', {});
    attemptId = data['attemptId'] as String;
    this.examId = examId;
    durationMinutes = data['durationMinutes'] as int?;
    thoiDiemBatDau = DateTime.now();
    questions = List<Map<String, dynamic>>.from(data['questions'] as List);
    selectedAnswers.clear();
    timePerQuestion.clear();
    _cauDangLam = null;
    _thoiDiemVaoCau = null;
    violations = 0;
    status = AttemptStatus.inProgress;
    // Bắt đầu tính giờ câu đầu tiên ngay khi đề tải xong.
    if (questions.isNotEmpty) {
      _cauDangLam = questions.first['id'] as String;
      _thoiDiemVaoCau = DateTime.now();
    }
    notifyListeners();
  }

  /// Nhận lượt làm ĐÃ TẠO SẴN từ đợt thi khung giờ (T28): MH-17 gọi
  /// API vào thi (POST /contests/:id/enter) trước, API tạo lượt làm +
  /// trả attemptId + đề; MH-09 chỉ nhận lại để làm bài — KHÔNG gọi
  /// POST exams/{id}/attempts như đề thường.
  ///
  /// [soGiayConLaiToiDa]: số giây còn lại tới giờ đóng đợt thi — đồng
  /// hồ đếm ngược theo số này (hết giờ tự nộp như đề thường, T21).
  /// examId để null vì lượt đợt thi không gắn với 1 bộ đề cố định
  /// (nguồn đề có thể là rút ngẫu nhiên từ kho chủ đề).
  void nhanLuotDotThi({
    required String attemptIdMoi,
    required List<Map<String, dynamic>> deThi,
    required int soGiayConLaiToiDa,
  }) {
    attemptId = attemptIdMoi;
    examId = null;
    // Đồng hồ tính theo phút (soGiayConLai): làm tròn xuống, tối thiểu
    // 1 phút — tự nộp sớm hơn giờ đóng vài chục giây là phía an toàn.
    final phut = soGiayConLaiToiDa ~/ 60;
    durationMinutes = phut < 1 ? 1 : phut;
    thoiDiemBatDau = DateTime.now();
    questions = deThi;
    selectedAnswers.clear();
    timePerQuestion.clear();
    _cauDangLam = null;
    _thoiDiemVaoCau = null;
    violations = 0;
    status = AttemptStatus.inProgress;
    // Bắt đầu tính giờ câu đầu tiên ngay khi nhận đề.
    if (questions.isNotEmpty) {
      _cauDangLam = questions.first['id'] as String;
      _thoiDiemVaoCau = DateTime.now();
    }
    notifyListeners();
  }

  /// Gọi khi người làm chuyển sang câu [questionId] (MH-09 gọi ở nút
  /// Câu trước/Câu sau): chốt thời gian câu cũ rồi bắt đầu tính giờ
  /// câu mới. Không gọi notifyListeners vì không có giao diện nào
  /// hiển thị số này.
  void chuyenSangCau(String questionId) {
    _chotThoiGianCauDangLam();
    _cauDangLam = questionId;
    _thoiDiemVaoCau = DateTime.now();
  }

  /// Chốt thời gian câu đang làm: cộng số giây đã ở câu đó vào
  /// timePerQuestion. Gọi khi chuyển câu và khi nộp bài (để câu cuối
  /// cũng được tính). Câu làm dưới 1 giây ghi 0 giây — đó là số đo
  /// thật (trả lời rất nhanh), khác với không đo. Mở lại 1 câu đã làm
  /// thì thời gian cộng dồn (tổng giờ đã ở câu đó qua các lần mở).
  void _chotThoiGianCauDangLam() {
    final id = _cauDangLam;
    final vao = _thoiDiemVaoCau;
    if (id == null || vao == null) return;
    final giay = DateTime.now().difference(vao).inSeconds;
    timePerQuestion[id] = (timePerQuestion[id] ?? 0) + giay;
    _cauDangLam = null;
    _thoiDiemVaoCau = null;
  }

  /// Học viên chọn đáp án (T22 chưa dùng nhiều, để sẵn cho task làm bài).
  void selectAnswer(String questionId, int optionIndex) {
    selectedAnswers[questionId] = optionIndex;
    notifyListeners();
  }

  /// Báo 1 lần vi phạm lên server.
  /// Trả về true nếu server báo đã đủ 5 lần (bị nộp cưỡng bức).
  Future<bool> reportViolation() async {
    if (attemptId == null) return false;
    if (status != AttemptStatus.inProgress) return false;

    final data =
        await _api.post('attempts/$attemptId/violations', {});
    violations = data['violations'] as int;
    final forceSubmitted = data['forceSubmitted'] as bool;

    if (forceSubmitted) {
      status = AttemptStatus.forceSubmitted;
    }
    notifyListeners();
    return forceSubmitted;
  }

  /// Nộp bài thường — T23 gọi từ MH-09b, T21 gọi khi hết giờ tự nộp.
  /// Khi bị nộp cưỡng bức thì KHÔNG gọi hàm này (server đã đóng lượt làm).
  ///
  /// Gửi kèm 2 thứ để server tính thưởng tốc độ đúng:
  /// - timeSpentSeconds cho MỌI câu đã trả lời. Server chỉ tính thưởng
  ///   theo từng câu khi MỌI câu đều có thời gian; thiếu 1 câu là nó
  ///   rơi về cách tính theo tổng thời gian. Câu nào đã đo thì gửi số
  ///   đo thật; câu nào chưa đo (chưa từng mở) thì gửi đủ thời gian
  ///   quy định của câu đó — tức "dùng hết giờ", thưởng 0 cho câu đó.
  /// - durationSeconds (tổng số giây đã làm): để cách tính theo tổng
  ///   thời gian vẫn ra thưởng thật thay vì 0, và server lưu số này
  ///   vào lịch sử làm bài.
  ///
  /// Trả về kết quả server kèm durationSeconds để MH-10 hiện thời gian
  /// làm bài thật (server không trả trường này trong kết quả nộp bài).
  Future<Map<String, dynamic>> submit() async {
    _chotThoiGianCauDangLam();
    final thoiGianLamGiay = thoiDiemBatDau == null
        ? 0
        : DateTime.now().difference(thoiDiemBatDau!).inSeconds;
    // Thời gian quy định của từng câu (server trả kèm trong đề).
    final gioiHanCau = <String, int>{
      for (final q in questions)
        (q['id'] as String): (q['timeSeconds'] as int? ?? 30),
    };
    final answers = selectedAnswers.entries.map((e) {
      return <String, dynamic>{
        'questionId': e.key,
        'selectedOption': e.value,
        // Câu chưa đo thời gian thì tính như đã dùng hết giờ của câu đó.
        'timeSpentSeconds': timePerQuestion[e.key] ?? gioiHanCau[e.key] ?? 30,
      };
    }).toList();
    final data = await _api.post('attempts/$attemptId/submit', {
      'answers': answers,
      'durationSeconds': thoiGianLamGiay,
    });
    status = AttemptStatus.submitted;
    notifyListeners();
    return {...data, 'durationSeconds': thoiGianLamGiay};
  }
}
