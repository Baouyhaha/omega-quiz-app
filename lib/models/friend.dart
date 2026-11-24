class Friend {
  final String uid;
  final String name;
  final String email;
  final int rankScore;
  final bool isOnline;

  const Friend({
    required this.uid,
    required this.name,
    required this.email,
    required this.rankScore,
    this.isOnline = false,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? 'Người dùng',
      email: json['email'] as String? ?? '',
      rankScore: (json['rankScore'] as num? ?? 0).toInt(),
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  String get animalRank => animalRankFor(rankScore);

  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}

class FriendRequest {
  final String id;
  final Friend from;

  const FriendRequest({required this.id, required this.from});

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    final fromJson = json['from'] as Map<String, dynamic>? ?? {};
    return FriendRequest(
      id: json['id'] as String? ?? '',
      from: Friend(
        uid: fromJson['uid'] as String? ?? '',
        name: fromJson['name'] as String? ?? 'Người dùng',
        email: fromJson['email'] as String? ?? '',
        rankScore: (fromJson['rankScore'] as num? ?? 0).toInt(),
      ),
    );
  }
}

String animalRankFor(int score) {
  if (score >= 2000) return 'Cá Voi Xanh';
  if (score >= 1800) return 'Voi';
  if (score >= 1650) return 'Sư Tử';
  if (score >= 1500) return 'Hổ';
  if (score >= 1350) return 'Gấu';
  if (score >= 1200) return 'Ngựa';
  if (score >= 1100) return 'Heo';
  if (score >= 1000) return 'Chó';
  if (score >= 900) return 'Mèo';
  return 'Chuột';
}

int pointsToNextRank(int score) {
  const thresholds = [900, 1000, 1100, 1200, 1350, 1500, 1650, 1800, 2000];
  for (final t in thresholds) {
    if (score < t) return t - score;
  }
  return 0;
}
