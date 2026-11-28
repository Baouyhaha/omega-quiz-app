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

  // --- Tro giup (T25) ---
  /// Giới hạn số lần dùng mỗi quyền trong 1 lượt làm — khớp luật
  /// phía server (api attempts.js HELPER_LIMITS, theo REQ-F31).
  static const Map<String, int> helperLimits = {
    'FIFTY_FIFTY': 1,
    'LIGHT_HINT': 2,
    'VIEW_EXPLANATION': 1,
    'CHANGE_QUESTION': 1,
    'EXTRA_TIME': 2,
    'SAFE_SHIELD': 1,
  };

  /// Số lần đã dùng từng quyền (để khóa chip khi hết lượt).
  Map<String, int> helperCounts = {};

  /// Đáp án bị ẩn bởi 50:50, theo từng câu (questionId -> tập chỉ số).
  Map<String, Set<int>> hiddenOptions = {};

  /// Gợi ý đã mở (Gợi Ý Nhẹ) theo từng câu.
  Map<String, String> hintsShown = {};

  /// Giải thích đã soi (Soi Giải Thích) theo từng câu.
  Map<String, String> explanationsShown = {};

  /// Tổng số giây được cộng thêm bởi quyền Thêm Giờ.
  int extraSeconds = 0;

  /// Khiên An Toàn đang bật (1 câu sai đầu tiên được tha khi chấm).
  bool shieldActive = false;

  /// Số lượt còn lại của 1 quyền trợ giúp.
  int helperConLai(String type) =>
      (helperLimits[type] ?? 0) - (helperCounts[type] ?? 0);

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
    final conLai =
        phut * 60 + extraSeconds - DateTime.now().difference(batDau).inSeconds;
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
    helperCounts = {};
    hiddenOptions = {};
    hintsShown = {};
    explanationsShown = {};
    extraSeconds = 0;
    shieldActive = false;
    // Bắt đầu tính giờ câu đầu tiên ngay khi đề tải xong.
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

  /// Dùng 1 quyền trợ giúp (T25): gọi POST attempts/{id}/helpers
  /// rồi áp hiệu ứng vào trạng thái lượt làm. Lỗi (hết lượt, bộ đề
  /// tắt trợ giúp...) ném ApiException để màn hình báo cho người làm.
  Future<void> useHelper(String type, String questionId) async {
    if (attemptId == null) return;
    if (status != AttemptStatus.inProgress) return;
    final data = await _api.post('attempts/$attemptId/helpers', {
      'type': type,
      'questionId': questionId,
    });
    helperCounts[type] = (helperCounts[type] ?? 0) + 1;
    switch (type) {
      case 'FIFTY_FIFTY':
        hiddenOptions[questionId] = Set<int>.from(
          (data['hiddenOptions'] as List).map((e) => (e as num).toInt()),
        );
        // Đáp án đang chọn mà bị ẩn (chỉ ẩn đáp án sai) thì bỏ chọn.
        final dangChon = selectedAnswers[questionId];
        if (dangChon != null && hiddenOptions[questionId]!.contains(dangChon)) {
          selectedAnswers.remove(questionId);
        }
        break;
      case 'LIGHT_HINT':
        hintsShown[questionId] = (data['hint'] as String?) ?? '';
        break;
      case 'VIEW_EXPLANATION':
        explanationsShown[questionId] =
            (data['explanation'] as String?) ?? '';
        break;
      case 'CHANGE_QUESTION':
        final moi = Map<String, dynamic>.from(data['newQuestion'] as Map);
        final idx = questions.indexWhere((q) => q['id'] == questionId);
        if (idx >= 0) {
          questions[idx] = moi;
          // Đáp án đã chọn cho câu cũ không còn nghĩa — bỏ; thời
          // gian đã đo chuyển sang câu mới để thưởng tốc độ vẫn
          // tính đủ từng câu khi nộp.
          selectedAnswers.remove(questionId);
          hiddenOptions.remove(questionId);
          hintsShown.remove(questionId);
          explanationsShown.remove(questionId);
          final tg = timePerQuestion.remove(questionId);
          if (tg != null) timePerQuestion[moi['id'] as String] = tg;
          if (_cauDangLam == questionId) {
            _cauDangLam = moi['id'] as String;
            _thoiDiemVaoCau = DateTime.now();
          }
        }
        break;
      case 'EXTRA_TIME':
        extraSeconds = (data['extraSeconds'] as num?)?.toInt() ?? extraSeconds;
        break;
      case 'SAFE_SHIELD':
        shieldActive = true;
        break;
    }
    notifyListeners();
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
