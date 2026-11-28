// ApiClient — lớp gọi Web API dùng chung cho mọi task (tạo ở T40).
// Token gửi kèm: token truyền riêng (nếu có) -> token phiên đăng nhập
// thật trong Session (T14) -> token dev tạm khi chưa đăng nhập.
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import 'session.dart';

/// Lỗi trả về từ API: có message để hiện cho người dùng,
/// errorCode để code xử lý riêng (ví dụ LIMIT_EXCEEDED, PIN_INVALID...).
class ApiException implements Exception {
  ApiException(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, String? token})
      : _client = client ?? http.Client(),
        _token = token;

  final http.Client _client;

  /// Token truyền riêng cho lần gọi này (ví dụ ID token vừa lấy được
  /// ngay sau đăng nhập Google, trước khi lưu vào Session).
  final String? _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_token ?? Session.token ?? 'dev:danh'}',
      };

  /// GET, trả về phần `data` trong envelope {success, message, data}.
  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final res = await _client.get(uri, headers: _headers);
    return _unwrap(res);
  }

  /// POST, body là Map (tự jsonEncode). Trả về phần `data`.
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _client.post(uri,
        headers: _headers, body: body == null ? null : jsonEncode(body));
    return _unwrap(res);
  }

  /// PATCH, giống POST nhưng dùng cho cập nhật.
  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _client.patch(uri,
        headers: _headers, body: body == null ? null : jsonEncode(body));
    return _unwrap(res);
  }

  /// DELETE, trả về phần `data` trong envelope.
  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _client.delete(uri, headers: _headers);
    return _unwrap(res);
  }

  /// Bóc envelope: success=true thì trả data, success=false thì ném lỗi.
  dynamic _unwrap(http.Response res) {
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json['success'] == true) return json['data'];
    throw ApiException(
      json['message'] as String? ?? 'Có lỗi xảy ra',
      errorCode: json['errorCode'] as String?,
    );
  }
}
