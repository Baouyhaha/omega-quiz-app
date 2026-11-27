// AuthService — đăng nhập bằng Google qua Firebase Auth (T14).
// Luồng L1: chọn tài khoản Google -> Firebase xác thực -> lấy ID token
// -> POST /auth/login (API verify token, lần đầu tự tạo hồ sơ + dùng thử
// 7 ngày) -> lưu phiên vào Session. Mọi màn hình sau đó gọi API bằng
// token thật qua ApiClient, không còn dùng token dev.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_client.dart';
import 'session.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Đăng nhập Google. Trả hồ sơ người dùng do API trả về.
  /// Ném ApiException hoặc Exception với message để MH-01 hiện cho người dùng.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Đã hủy đăng nhập');
    }
    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null) {
      throw Exception('Không lấy được token đăng nhập, thử lại sau');
    }
    final profile = await ApiClient(token: idToken).post('auth/login', {
      'name': userCredential.user?.displayName,
      'email': userCredential.user?.email,
      'photoUrl': userCredential.user?.photoURL,
    }) as Map<String, dynamic>;
    await Session.save(token: idToken, profile: profile);
    return profile;
  }

  /// Đăng xuất khỏi Google + Firebase và xóa phiên đã lưu.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await Session.clear();
  }
}
