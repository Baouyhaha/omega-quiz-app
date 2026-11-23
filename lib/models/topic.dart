/// Model Topic — khớp với topicView của API (T40).
class Topic {
  Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.visibility,
    required this.memberCount,
    required this.examCount,
    required this.questionCount,
    this.myRole,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        visibility: json['visibility'] as String,
        memberCount: json['memberCount'] as int? ?? 0,
        examCount: json['examCount'] as int? ?? 0,
        questionCount: json['questionCount'] as int? ?? 0,
        myRole: json['myRole'] as String?,
      );

  final String id;
  final String name;
  final String description;
  final String visibility; // 'PUBLIC' hoặc 'PRIVATE' (API trả chữ hoa)
  final int memberCount;
  final int examCount;
  final int questionCount;
  final String? myRole; // 'OWNER' hoặc 'MEMBER' (chỉ có ở topics/mine)
}
