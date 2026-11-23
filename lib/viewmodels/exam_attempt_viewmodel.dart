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
  List<Map<String, dynamic>> questions = [];
  Map<String, int> selectedAnswers = {}; // questionId -> đáp án đã chọn (0-3)
  Map<String, int> timePerQuestion = {}; // questionId -> số giây đã làm
  int violations = 0;
  AttemptStatus status = AttemptStatus.inProgress;

  static const int maxViolations = 5;

  bool get isForceSubmitted => status == AttemptStatus.forceSubmitted;

  /// Bắt đầu lượt làm: gọi POST exams/{id}/attempts, lưu attemptId + đề.
  Future<void> startAttempt(String examId) async {
    final data = await _api.post('exams/$examId/attempts', {});
    attemptId = data['attemptId'] as String;
    this.examId = examId;
    questions = List<Map<String, dynamic>>.from(data['questions'] as List);
    violations = 0;
    status = AttemptStatus.inProgress;
    notifyListeners();
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

  /// Nộp bài thường — thuộc task T23, T22 chỉ viết khung sẵn ở đây.
  /// Khi bị nộp cưỡng bức thì KHÔNG gọi hàm này (server đã đóng lượt làm).
  Future<Map<String, dynamic>> submit() async {
    final answers = selectedAnswers.entries
        .map((e) => {
              'questionId': e.key,
              'selectedOption': e.value,
              'timeSpentSeconds': timePerQuestion[e.key] ?? 0,
            })
        .toList();
    final data = await _api.post('attempts/$attemptId/submit', {
      'answers': answers,
    });
    status = AttemptStatus.submitted;
    notifyListeners();
    return data;
  }
}
