import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/friend.dart';

class FriendService {
  final String token;

  FriendService(this.token);

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

  Future<({List<Friend> friends, List<FriendRequest> pending})>
      getFriends() async {
    final data = _data(
      await http.get(Uri.parse('${baseUrl}friends'), headers: _headers),
    );
    return (
      friends: (data['friends'] as List)
          .map((e) => Friend.fromJson(e as Map<String, dynamic>))
          .toList(),
      pending: (data['pendingRequests'] as List)
          .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> sendRequest(String email) async {
    _data(
      await http.post(
        Uri.parse('${baseUrl}friends/requests'),
        headers: _headers,
        body: jsonEncode({'email': email.trim()}),
      ),
    );
  }

  Future<void> acceptRequest(String requestId) async {
    _data(
      await http.post(
        Uri.parse('${baseUrl}friends/requests/$requestId/accept'),
        headers: _headers,
      ),
    );
  }

  Future<void> rejectRequest(String requestId) async {
    _data(
      await http.delete(
        Uri.parse('${baseUrl}friends/requests/$requestId'),
        headers: _headers,
      ),
    );
  }

  Future<void> cancelRequest(String requestId) async {
    _data(
      await http.delete(
        Uri.parse('${baseUrl}friends/requests/$requestId'),
        headers: _headers,
      ),
    );
  }

  Future<void> unfriend(String userId) async {
    _data(
      await http.delete(
        Uri.parse('${baseUrl}friends/$userId'),
        headers: _headers,
      ),
    );
  }
}
