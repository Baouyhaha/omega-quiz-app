// Session — nơi giữ token đăng nhập hiện tại cho toàn app (T14).
// Sau khi đăng nhập Google, Firebase ID token được lưu ở đây và
// ApiClient tự lấy ra gửi kèm mọi request. Chưa đăng nhập thì
// token = null và ApiClient dùng token dev như trước.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static String? _token;
  static Map<String, dynamic>? _profile;

  static String? get token => _token;
  static Map<String, dynamic>? get profile => _profile;
  static bool get daDangNhap => _token != null;

  /// Nạp lại phiên đăng nhập đã lưu (gọi lúc mở app trong main()).
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('session_token');
    final raw = prefs.getString('session_profile');
    if (raw != null) {
      _profile = jsonDecode(raw) as Map<String, dynamic>;
    }
  }

  /// Lưu phiên sau khi API /auth/login trả hồ sơ về.
  static Future<void> save({
    required String token,
    required Map<String, dynamic> profile,
  }) async {
    _token = token;
    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', token);
    await prefs.setString('session_profile', jsonEncode(profile));
  }

  /// Vào chế độ kiểm thử bằng token dev (chỉ trong phiên chạy này,
  /// không lưu xuống máy để không lẫn với phiên đăng nhập thật).
  static void useDevToken(String uid) {
    _token = 'dev:$uid';
    _profile = null;
  }

  /// Xóa phiên (đăng xuất).
  static Future<void> clear() async {
    _token = null;
    _profile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');
    await prefs.remove('session_profile');
  }
}
