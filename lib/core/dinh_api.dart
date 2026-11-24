import 'dart:convert';

import 'package:http/http.dart' as http;

// ============================================================================
// API client RIENG cua Dinh — lib/core/dinh_api.dart
// T18 buoc 2: noi MH-22/MH-23 vao Web API cua Uy (thu muc api/ tren main).
//   - Base URL: may ao Android goi ra may that qua 10.0.2.2 (localhost trong
//     may ao la chinh no, khong toi duoc API tren may that). File chung
//     lib/core/constants.dart dang de localhost nen KHONG dung no o day —
//     client rieng nay dung 10.0.2.2. Chay tren may that doi thanh localhost.
//   - Xac thuc TAM: header "Bearer dev:dinh" (API cua Uy chua noi Firebase
//     Auth that). Khi noi Firebase that thi thay bang Firebase ID token
//     lay tu FirebaseAuth — chi doi _headers, cac ham goi API giu nguyen.
//   - Field dap an dung cua API la "correctOption" (khong phai correctIndex).
//   - Envelope tra ve: { success, message, data }; loi nem ApiException
//     mang message tieng Viet cua server.
// ============================================================================

/// Base URL cua API khi chay tren may ao Android.
const String kDinhApiBaseUrl = 'http://10.0.2.2:3000/api/';

/// Token dev tam thoi cua Dinh — xem ghi chu o dau file.
const String kDinhDevToken = 'dev:dinh';

/// Loi tu API (message tieng Viet cua server).
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 'easy' -> 'Dễ', 'medium' -> 'Trung bình', 'hard' -> 'Khó'.
String difficultyToVi(String en) {
  switch (en) {
    case 'easy':
      return 'Dễ';
    case 'medium':
      return 'Trung bình';
    case 'hard':
      return 'Khó';
    default:
      return en;
  }
}

/// 'Dễ' -> 'easy', 'Trung bình' -> 'medium', 'Khó' -> 'hard'.
// API cung nhan tieng Viet truc tiep, nhung gui tieng Anh cho chac.
String difficultyToEn(String vi) {
  switch (vi) {
    case 'Dễ':
      return 'easy';
    case 'Trung bình':
      return 'medium';
    case 'Khó':
      return 'hard';
    default:
      return vi;
  }
}

/// Mot cau hoi tra ve / gui len API.
/// Field theo api/src/routes/questions.js: id, topicId, content, options,
/// correctOption (0-3), difficulty ('easy'/'medium'/'hard'), timeSeconds,
/// points, hint, explanation, source.
class ApiQuestion {
  const ApiQuestion({
    required this.id,
    required this.topicId,
    required this.content,
    required this.options,
    required this.correctOption,
    required this.difficulty,
    required this.timeSeconds,
    required this.points,
    this.hint,
    this.explanation,
  });

  factory ApiQuestion.fromJson(Map<String, dynamic> json) {
    return ApiQuestion(
      id: json['id'] as String? ?? '',
      topicId: json['topicId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((o) => o.toString())
          .toList(),
      correctOption: json['correctOption'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? 'medium',
      timeSeconds: json['timeSeconds'] as int? ?? 30,
      points: json['points'] as int? ?? 10,
      hint: json['hint'] as String?,
      explanation: json['explanation'] as String?,
    );
  }

  /// Body gui len POST/PATCH (#17/#18).
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'options': options,
      'correctOption': correctOption,
      'difficulty': difficulty,
      'timeSeconds': timeSeconds,
      'points': points,
      'hint': hint ?? '',
      'explanation': explanation ?? '',
    };
  }

  final String id;
  final String topicId;
  final String content;
  final List<String> options;
  final int correctOption;
  final String difficulty;
  final int timeSeconds;
  final int points;
  final String? hint;
  final String? explanation;

  /// Nhan do kho tieng Viet hien tren giao dien.
  String get difficultyVi => difficultyToVi(difficulty);
}

/// Cac ham goi endpoint cau hoi #16–#19 (contract v2 muc 2.3).
class DinhApi {
  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $kDinhDevToken',
    };
  }

  /// Boc envelope { success, message, data } cua API.
  /// success false -> nem ApiException(message cua server).
  static dynamic _decode(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        throw ApiException(
          body['message'] as String? ?? 'Lỗi không rõ từ server',
        );
      }
      return body['data'];
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Không gọi được API (${res.statusCode})');
    }
  }

  /// #16 GET /topics/:id/questions — danh sach cau hoi cua chu de.
  static Future<List<ApiQuestion>> fetchQuestions(String topicId) async {
    final res = await http.get(
      Uri.parse('${kDinhApiBaseUrl}topics/$topicId/questions'),
      headers: _headers,
    );
    final data = _decode(res) as List<dynamic>;
    return data
        .map((e) => ApiQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// #17 POST /topics/:id/questions — them cau hoi moi.
  static Future<ApiQuestion> createQuestion(
    String topicId,
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse('${kDinhApiBaseUrl}topics/$topicId/questions'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return ApiQuestion.fromJson(
      _decode(res) as Map<String, dynamic>,
    );
  }

  /// #18 PATCH /questions/:id — sua cau hoi (chi gui field muon doi).
  static Future<ApiQuestion> updateQuestion(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await http.patch(
      Uri.parse('${kDinhApiBaseUrl}questions/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return ApiQuestion.fromJson(
      _decode(res) as Map<String, dynamic>,
    );
  }

  /// #19 DELETE /questions/:id — xoa cau hoi.
  static Future<void> deleteQuestion(String id) async {
    final res = await http.delete(
      Uri.parse('${kDinhApiBaseUrl}questions/$id'),
      headers: _headers,
    );
    _decode(res);
  }
}
