class Topic {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String visibility;
  final String createdAt;
  final int memberCount;
  final int examCount;
  final int questionCount;
  final String? myRole;
  final bool ownerExpired;

  const Topic({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.visibility,
    required this.createdAt,
    required this.memberCount,
    required this.examCount,
    required this.questionCount,
    this.myRole,
    this.ownerExpired = false,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      name: json['name'] as String? ?? 'Chủ đề',
      description: json['description'] as String? ?? '',
      visibility: json['visibility'] as String? ?? 'PUBLIC',
      createdAt: json['createdAt'] as String? ?? '',
      memberCount: (json['memberCount'] as num? ?? 0).toInt(),
      examCount: (json['examCount'] as num? ?? 0).toInt(),
      questionCount: (json['questionCount'] as num? ?? 0).toInt(),
      myRole: json['myRole'] as String?,
      ownerExpired: json['ownerExpired'] as bool? ?? false,
    );
  }

  bool get isPublic => visibility == 'PUBLIC';

  bool get isOwner => myRole == 'OWNER';

  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}

class TopicExam {
  final String id;
  final String topicId;
  final String title;
  final String description;
  final int questionCount;
  final int durationMinutes;
  final String? openAt;
  final String? closeAt;
  final int maxAttempts;
  final bool hasPin;
  final bool shuffleQuestions;
  final bool allowHelpers;
  final String showAnswerMode;

  const TopicExam({
    required this.id,
    required this.topicId,
    required this.title,
    required this.description,
    required this.questionCount,
    this.durationMinutes = 0,
    this.openAt,
    this.closeAt,
    this.maxAttempts = 0,
    this.hasPin = false,
    this.shuffleQuestions = true,
    this.allowHelpers = true,
    this.showAnswerMode = 'AFTER_CLOSE',
  });

  factory TopicExam.fromJson(Map<String, dynamic> json) {
    final settings = json['settings'] as Map<String, dynamic>? ?? {};
    return TopicExam(
      id: json['id'] as String? ?? '',
      topicId: json['topicId'] as String? ?? '',
      title: json['title'] as String? ?? 'Bộ đề',
      description: json['description'] as String? ?? '',
      questionCount: (json['questionCount'] as num? ?? 0).toInt(),
      durationMinutes: ((settings['durationMinutes'] as num?) ??
              (json['durationMinutes'] as num?) ??
              0)
          .toInt(),
      openAt: settings['openAt'] as String?,
      closeAt: settings['closeAt'] as String?,
      maxAttempts: (settings['maxAttempts'] as num? ?? 0).toInt(),
      hasPin: settings['pin'] != null,
      shuffleQuestions: settings['shuffleQuestions'] as bool? ?? true,
      allowHelpers: settings['allowHelpers'] as bool? ?? true,
      showAnswerMode:
          settings['showAnswerMode'] as String? ?? 'AFTER_CLOSE',
    );
  }

  String get status {
    final now = DateTime.now();
    if (openAt != null && now.isBefore(DateTime.parse(openAt!))) {
      return 'upcoming';
    }
    if (closeAt != null && now.isAfter(DateTime.parse(closeAt!))) {
      return 'closed';
    }
    return 'open';
  }

  String get statusText {
    switch (status) {
      case 'upcoming':
        return 'Sắp mở';
      case 'closed':
        return 'Đã đóng';
      default:
        return 'Đang mở';
    }
  }
}
