/// Model Exam — khớp với examView của API (T40).
/// Chưa có field thống kê (lượt làm, điểm TB/cao nhất/thấp nhất, độ khó)
/// vì API chưa trả — chờ Uy bổ sung rồi thêm sau, không bịa số liệu.
class Exam {
  Exam({
    required this.id,
    required this.topicId,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.durationMinutes,
    required this.maxAttempts,
    required this.allowHelpers,
    required this.showAnswerMode,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    final settings = json['settings'] as Map<String, dynamic>? ?? {};
    return Exam(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      questionCount: json['questionCount'] as int? ?? 0,
      durationMinutes: settings['durationMinutes'] as int? ?? 0,
      maxAttempts: settings['maxAttempts'] as int? ?? 1,
      allowHelpers: settings['allowHelpers'] as bool? ?? false,
      showAnswerMode: settings['showAnswerMode'] as String? ?? 'NEVER',
    );
  }

  final String id;
  final String topicId;
  final String title;
  final String description;
  final int questionCount;
  final int durationMinutes;
  final int maxAttempts;
  final bool allowHelpers;
  final String showAnswerMode;
}
