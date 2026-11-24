import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ============================================================================
// API client RIENG cua Dinh — lib/core/dinh_api.dart
// T18 buoc 2: noi MH-22/MH-23 vao Web API cua Uy (thu muc api/ tren main).
// T19 buoc 3: noi MH-24 vao #20 import / #21 confirm.
// T15 buoc 1-3: noi MH-30/MH-31 vao endpoint admin cua Uy (UC25-UC27):
//   GET /admin/users, GET /admin/users/:id, GET /admin/plans,
//   POST /admin/users/:id/lock|unlock|subscription.
// MH-32/MH-33: GET /admin/plans + PUT /admin/plans/:id (UC26),
//   GET /admin/stats (UC28) — xem fetchAdminPlans, updateAdminPlan,
//   fetchAdminStats.
//   - Endpoint admin chi cho role ADMIN goi (auth.js requireAdmin) nen
//     dung token TAM rieng kDinhAdminToken = 'dev:admin' (token dev:dinh
//     goi se bi 403). Khi noi Firebase Auth that thi thay bang ID token
//     cua tai khoan Admin that.
//   - Du lieu admin hien la seed trong bo nho cua API (5 tai khoan:
//     admin, uy, dinh, danh, thinh), restart server la reset; tong that
//     la 5, khong phai 128 nhu mock.
//   - Danh sach GET /admin/users KHONG tra goi dang dung — goi lay tu
//     chi tiet tung tai khoan (subscription.planId) + GET /admin/plans
//     de doi ma goi thanh ten goi.
//   - Base URL: tu chon theo nen tang (kIsWeb) — chay tren Chrome thi goi
//     localhost, chay tren may ao Android thi goi qua 10.0.2.2. File chung
//     lib/core/constants.dart dang de localhost nen KHONG dung no o day.
//   - Xac thuc TAM: header "Bearer dev:dinh" (API cua Uy chua noi Firebase
//     Auth that). Khi noi Firebase that thi thay bang Firebase ID token
//     lay tu FirebaseAuth — chi doi _headers, cac ham goi API giu nguyen.
//   - Field dap an dung cua API la "correctOption" (khong phai correctIndex).
//   - Envelope tra ve: { success, message, data }; loi nem ApiException
//     mang message tieng Viet cua server.
//   - Rieng #20 import: file co loi thi server tra 422 IMPORT_HAS_ERRORS
//     (success false) nhung data van dung duoc (previewToken de xac nhan
//     luu cac cau hop le), nen importQuestions KHONG nem ApiException cho
//     truong hop do.
// ============================================================================

/// Base URL cua API — tu chon theo noi app dang chay:
///   - Chay tren Chrome (web): app chay ngay tren may that nen goi thang
///     localhost.
///   - Chay tren may ao Android: localhost trong may ao la chinh no, khong
///     toi duoc API tren may that, nen goi qua 10.0.2.2.
/// File chung lib/core/constants.dart dang de localhost nen KHONG dung no
/// o day — client rieng nay tu chon theo nen tang.
const String kDinhApiBaseUrl = kIsWeb
    ? 'http://localhost:3000/api/'
    : 'http://10.0.2.2:3000/api/';

/// Token dev tam thoi cua Dinh — xem ghi chu o dau file.
const String kDinhDevToken = 'dev:dinh';

/// Token dev TAM cua tai khoan Admin — chi dung cho cac endpoint admin.
/// Xem ghi chu o dau file: dev:dinh (role USER) goi endpoint admin bi 403.
const String kDinhAdminToken = 'dev:admin';

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

/// Mot loi import theo dong tra ve tu #20.
/// Vi du: { line: 5, errors: ['đáp án đúng phải là A/B/C/D'] }.
class ImportError {
  const ImportError({required this.line, required this.messages});

  factory ImportError.fromJson(Map<String, dynamic> json) {
    return ImportError(
      line: json['line'] as int? ?? 0,
      messages: (json['errors'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  final int line;
  final List<String> messages;

  /// 'Dòng 5: đáp án đúng phải là A/B/C/D'.
  String get display => 'Dòng $line: ${messages.join('; ')}';
}

/// Ket qua goi #20: xem truoc + loi theo dong + previewToken.
// preview chi gom cac cau hop le (toi da 5 cau dau tien).
class ImportResult {
  const ImportResult({
    required this.previewToken,
    required this.validCount,
    required this.errorCount,
    required this.errors,
    required this.preview,
  });

  factory ImportResult.fromJson(Map<String, dynamic> json) {
    return ImportResult(
      previewToken: json['previewToken'] as String? ?? '',
      validCount: json['validCount'] as int? ?? 0,
      errorCount: json['errorCount'] as int? ?? 0,
      errors: (json['errors'] as List<dynamic>? ?? [])
          .map((e) => ImportError.fromJson(e as Map<String, dynamic>))
          .toList(),
      preview: (json['preview'] as List<dynamic>? ?? [])
          .map((e) => ApiQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String previewToken;
  final int validCount;
  final int errorCount;
  final List<ImportError> errors;
  final List<ApiQuestion> preview;

  /// Tong so dong trong file = hop le + loi.
  int get totalCount => validCount + errorCount;
}

/// Mot tai khoan tra ve tu GET /admin/users (api/src/routes/admin.js):
/// uid, name, email, role ('ADMIN'/'USER'), rankScore, animalRank, locked.
/// Danh sach KHONG tra goi dang dung — goi lay tu chi tiet tung tai khoan
/// (GET /admin/users/:id -> subscription.planId).
class ApiAdminUser {
  const ApiAdminUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.rankScore,
    required this.animalRank,
    required this.locked,
  });

  factory ApiAdminUser.fromJson(Map<String, dynamic> json) {
    return ApiAdminUser(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      rankScore: json['rankScore'] as int? ?? 0,
      animalRank: json['animalRank'] as String? ?? '',
      locked: json['locked'] as bool? ?? false,
    );
  }

  final String uid;
  final String name;
  final String email;
  final String role;
  final int rankScore;
  final String animalRank;
  final bool locked;

  ApiAdminUser copyWith({bool? locked}) {
    return ApiAdminUser(
      uid: uid,
      name: name,
      email: email,
      role: role,
      rankScore: rankScore,
      animalRank: animalRank,
      locked: locked ?? this.locked,
    );
  }

  /// Chu cai dau ten, hien trong avatar tron.
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();

  /// Tai khoan ADMIN khong co nut khoa/mokhoa.
  bool get isAdmin => role == 'ADMIN';

  /// 'Đang hoạt động' / 'Bị khóa' hien tren the.
  String get statusText => locked ? 'Bị khóa' : 'Đang hoạt động';
}

/// Han muc cua mot goi (plans.limits): gia tri null = khong gioi han.
// Neu ca doi tuong limits la null thi goi khong gioi han gi ca.
class ApiPlanLimits {
  const ApiPlanLimits({
    this.maxTopics,
    this.maxExamsPerTopic,
    this.maxMembersPerTopic,
    this.maxQuestionsPerExam,
  });

  factory ApiPlanLimits.fromJson(Map<String, dynamic> json) {
    return ApiPlanLimits(
      maxTopics: json['maxTopics'] as int?,
      maxExamsPerTopic: json['maxExamsPerTopic'] as int?,
      maxMembersPerTopic: json['maxMembersPerTopic'] as int?,
      maxQuestionsPerExam: json['maxQuestionsPerExam'] as int?,
    );
  }

  /// Body gui len PUT.
  Map<String, dynamic> toJson() {
    return {
      'maxTopics': maxTopics,
      'maxExamsPerTopic': maxExamsPerTopic,
      'maxMembersPerTopic': maxMembersPerTopic,
      'maxQuestionsPerExam': maxQuestionsPerExam,
    };
  }

  final int? maxTopics;
  final int? maxExamsPerTopic;
  final int? maxMembersPerTopic;
  final int? maxQuestionsPerExam;
}

/// Goi thue tra ve tu GET /admin/plans: id, name, days, price, limits.
class ApiAdminPlan {
  const ApiAdminPlan({
    required this.id,
    required this.name,
    this.days,
    required this.price,
    this.limits,
  });

  factory ApiAdminPlan.fromJson(Map<String, dynamic> json) {
    final limits = json['limits'] as Map<String, dynamic>?;
    return ApiAdminPlan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      days: json['days'] as int?,
      price: json['price'] as int? ?? 0,
      limits: limits == null ? null : ApiPlanLimits.fromJson(limits),
    );
  }

  final String id;
  final String name;
  final int? days;
  final int price;
  final ApiPlanLimits? limits;
}

/// So tong tra ve tu GET /admin/stats.
class ApiAdminStats {
  const ApiAdminStats({
    required this.totalUsers,
    required this.totalTopics,
    required this.totalQuestions,
    required this.totalExams,
    required this.totalAttempts,
    required this.totalBattles,
    required this.totalContests,
  });

  factory ApiAdminStats.fromJson(Map<String, dynamic> json) {
    return ApiAdminStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalTopics: json['totalTopics'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      totalExams: json['totalExams'] as int? ?? 0,
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      totalBattles: json['totalBattles'] as int? ?? 0,
      totalContests: json['totalContests'] as int? ?? 0,
    );
  }

  final int totalUsers;
  final int totalTopics;
  final int totalQuestions;
  final int totalExams;
  final int totalAttempts;
  final int totalBattles;
  final int totalContests;
}

/// Goi dang dung cua mot tai khoan (nam trong chi tiet):
/// userId, planId, startedAt, expiresAt (ISO, co the null), status.
class ApiAdminSubscription {
  const ApiAdminSubscription({
    required this.userId,
    required this.planId,
    required this.startedAt,
    this.expiresAt,
    required this.status,
  });

  factory ApiAdminSubscription.fromJson(Map<String, dynamic> json) {
    return ApiAdminSubscription(
      userId: json['userId'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      startedAt: json['startedAt'] as String? ?? '',
      expiresAt: json['expiresAt'] as String?,
      status: json['status'] as String? ?? '',
    );
  }

  final String userId;
  final String planId;
  final String startedAt;
  final String? expiresAt;
  final String status;
}

/// Chi tiet mot tai khoan tra ve tu GET /admin/users/:id:
/// toan bo field cua user + subscription (co the null).
class ApiAdminUserDetail {
  const ApiAdminUserDetail({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.rankScore,
    required this.locked,
    this.photoUrl,
    required this.createdAt,
    this.subscription,
  });

  factory ApiAdminUserDetail.fromJson(Map<String, dynamic> json) {
    final sub = json['subscription'] as Map<String, dynamic>?;
    return ApiAdminUserDetail(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
      rankScore: json['rankScore'] as int? ?? 0,
      locked: json['locked'] as bool? ?? false,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      subscription:
          sub == null ? null : ApiAdminSubscription.fromJson(sub),
    );
  }

  final String uid;
  final String name;
  final String email;
  final String role;
  final int rankScore;
  final bool locked;
  final String? photoUrl;
  final String createdAt;
  final ApiAdminSubscription? subscription;

  ApiAdminUserDetail copyWith({bool? locked}) {
    return ApiAdminUserDetail(
      uid: uid,
      name: name,
      email: email,
      role: role,
      rankScore: rankScore,
      locked: locked ?? this.locked,
      photoUrl: photoUrl,
      createdAt: createdAt,
      subscription: subscription,
    );
  }

  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
  bool get isAdmin => role == 'ADMIN';
  String get statusText => locked ? 'Bị khóa' : 'Đang hoạt động';
}

/// Cac ham goi endpoint cau hoi #16–#19 (contract v2 muc 2.3)
// va import #20/#21 (contract v2 muc 2.3, UC10).
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

  /// #20 POST /topics/:id/questions/import — upload file .xlsx,
  /// tra xem truoc + loi theo dong + previewToken.
  /// File co loi thi server tra 422 nhung data van dung duoc nen ham nay
  /// tra ve ImportResult binh thuong, khong nem ApiException.
  static Future<ImportResult> importQuestions(
    String topicId,
    List<int> bytes,
    String fileName,
  ) async {
    final uri = Uri.parse(
      '${kDinhApiBaseUrl}topics/$topicId/questions/import',
    );
    final req = http.MultipartRequest('POST', uri);
    req.headers['Authorization'] = 'Bearer $kDinhDevToken';
    req.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data == null) {
      throw ApiException(
        body['message'] as String? ?? 'Lỗi không rõ từ server',
      );
    }
    return ImportResult.fromJson(data as Map<String, dynamic>);
  }

  /// #21 POST /topics/:id/questions/import/confirm — luu cac cau hop le
  /// cua lan import truoc, tra ve so cau da luu.
  static Future<int> confirmImport(
    String topicId,
    String previewToken,
  ) async {
    final res = await http.post(
      Uri.parse(
        '${kDinhApiBaseUrl}topics/$topicId/questions/import/confirm',
      ),
      headers: _headers,
      body: jsonEncode({'previewToken': previewToken}),
    );
    final data = _decode(res) as Map<String, dynamic>;
    return data['saved'] as int? ?? 0;
  }

  // --- Endpoint admin (UC25-UC27, T15) — dung token Admin ---

  /// Header cho cac endpoint admin: dung token cua tai khoan Admin.
  static Map<String, String> get _adminHeaders {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $kDinhAdminToken',
    };
  }

  /// GET /admin/users — danh sach tai khoan (UC25, T15 buoc 1).
  static Future<List<ApiAdminUser>> fetchAdminUsers() async {
    final res = await http.get(
      Uri.parse('${kDinhApiBaseUrl}admin/users'),
      headers: _adminHeaders,
    );
    final data = _decode(res) as List<dynamic>;
    return data
        .map((e) => ApiAdminUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /admin/users/:id — chi tiet 1 tai khoan + goi dang dung
  /// (UC25, T15 buoc 2).
  static Future<ApiAdminUserDetail> fetchAdminUserDetail(String uid) async {
    final res = await http.get(
      Uri.parse('${kDinhApiBaseUrl}admin/users/$uid'),
      headers: _adminHeaders,
    );
    return ApiAdminUserDetail.fromJson(
      _decode(res) as Map<String, dynamic>,
    );
  }

  /// GET /admin/plans — danh sach goi (UC26, MH-32).
  static Future<List<ApiAdminPlan>> fetchAdminPlans() async {
    final res = await http.get(
      Uri.parse('${kDinhApiBaseUrl}admin/plans'),
      headers: _adminHeaders,
    );
    final data = _decode(res) as List<dynamic>;
    return data
        .map((e) => ApiAdminPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /admin/users/:id/lock — khoa tai khoan (UC27, T15 buoc 3).
  static Future<void> lockAdminUser(String uid) async {
    final res = await http.post(
      Uri.parse('${kDinhApiBaseUrl}admin/users/$uid/lock'),
      headers: _adminHeaders,
    );
    _decode(res);
  }

  /// POST /admin/users/:id/unlock — mo khoa tai khoan (UC27, T15 buoc 3).
  static Future<void> unlockAdminUser(String uid) async {
    final res = await http.post(
      Uri.parse('${kDinhApiBaseUrl}admin/users/$uid/unlock'),
      headers: _adminHeaders,
    );
    _decode(res);
  }

  /// POST /admin/users/:id/subscription — gan goi cho tai khoan (UC27,
  /// nut "Gán gói" tren MH-31). Gia han goi = gan lai chinh goi dang dung.
  static Future<void> assignAdminPlan(String uid, String planId) async {
    final res = await http.post(
      Uri.parse('${kDinhApiBaseUrl}admin/users/$uid/subscription'),
      headers: _adminHeaders,
      body: jsonEncode({'planId': planId}),
    );
    _decode(res);
  }

  /// GET /admin/stats — so tong he thong (UC28, MH-33).
  static Future<ApiAdminStats> fetchAdminStats() async {
    final res = await http.get(
      Uri.parse('${kDinhApiBaseUrl}admin/stats'),
      headers: _adminHeaders,
    );
    return ApiAdminStats.fromJson(
      _decode(res) as Map<String, dynamic>,
    );
  }

  /// PUT /admin/plans/:id — cap nhat goi (UC26, MH-32).
  static Future<ApiAdminPlan> updateAdminPlan(
    String id,
    Map<String, dynamic> body,
  ) async {
    final res = await http.put(
      Uri.parse('${kDinhApiBaseUrl}admin/plans/$id'),
      headers: _adminHeaders,
      body: jsonEncode(body),
    );
    return ApiAdminPlan.fromJson(
      _decode(res) as Map<String, dynamic>,
    );
  }
}
