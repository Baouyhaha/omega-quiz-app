import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/topic.dart';

class TopicService {
  final String token;

  TopicService(this.token);

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  dynamic _data(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 200 &&
        res.statusCode < 300 &&
        body['success'] == true) {
      return body['data'];
    }
    throw Exception(body['message'] ?? 'Lỗi ${res.statusCode}');
  }

  Future<List<Topic>> getMine() async {
    final data = _data(
      await http.get(Uri.parse('${baseUrl}topics/mine'), headers: _headers),
    );
    return (data as List)
        .map((e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Topic>> getPublic({String query = ''}) async {
    final uri = query.isEmpty
        ? Uri.parse('${baseUrl}topics/public')
        : Uri.parse(
            '${baseUrl}topics/public?q=${Uri.encodeQueryComponent(query)}',
          );
    final data = _data(await http.get(uri, headers: _headers));
    return (data['items'] as List)
        .map((e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Topic> createTopic({
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    final data = _data(
      await http.post(
        Uri.parse('${baseUrl}topics'),
        headers: _headers,
        body: jsonEncode({
          'name': name.trim(),
          'description': description.trim(),
          'visibility': isPublic ? 'PUBLIC' : 'PRIVATE',
        }),
      ),
    );
    return Topic.fromJson(data as Map<String, dynamic>);
  }

  Future<Topic> updateTopic({
    required String id,
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    final data = _data(
      await http.patch(
        Uri.parse('${baseUrl}topics/$id'),
        headers: _headers,
        body: jsonEncode({
          'name': name.trim(),
          'description': description.trim(),
          'visibility': isPublic ? 'PUBLIC' : 'PRIVATE',
        }),
      ),
    );
    return Topic.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteTopic(String id) async {
    _data(
      await http.delete(
        Uri.parse('${baseUrl}topics/$id'),
        headers: _headers,
      ),
    );
  }

  Future<List<TopicExam>> getExams(String topicId) async {
    final data = _data(
      await http.get(
        Uri.parse('${baseUrl}topics/$topicId/exams'),
        headers: _headers,
      ),
    );
    return (data as List)
        .map((e) => TopicExam.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> getDoneAttempts() async {
    final data = _data(
      await http.get(Uri.parse('${baseUrl}attempts/mine'), headers: _headers),
    );
    final counts = <String, int>{};
    for (final e in data as List) {
      final examId = (e as Map<String, dynamic>)['examId'] as String?;
      if (examId != null) {
        counts[examId] = (counts[examId] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<int> getDifficultyCount(String topicId) async {
    final data = _data(
      await http.get(
        Uri.parse('${baseUrl}topics/$topicId/questions'),
        headers: _headers,
      ),
    );
    final levels = <String>{};
    for (final e in data as List) {
      final d = (e as Map<String, dynamic>)['difficulty'] as String?;
      if (d != null && d.isNotEmpty) levels.add(d);
    }
    return levels.length;
  }

  Future<String> startAttempt(String examId, {String? pin}) async {
    final data = _data(
      await http.post(
        Uri.parse('${baseUrl}exams/$examId/attempts'),
        headers: _headers,
        body: jsonEncode(pin == null ? {} : {'pin': pin}),
      ),
    );
    return (data as Map<String, dynamic>)['attemptId'] as String;
  }

  Future<TopicExam> createExamRandom({
    required String topicId,
    required String title,
  }) async {
    final data = _data(
      await http.post(
        Uri.parse('${baseUrl}topics/$topicId/exams'),
        headers: _headers,
        body: jsonEncode({
          'title': title.trim(),
          'mode': 'RANDOM',
          'counts': {'easy': 2, 'medium': 2, 'hard': 1},
        }),
      ),
    );
    return TopicExam.fromJson(data as Map<String, dynamic>);
  }
}
