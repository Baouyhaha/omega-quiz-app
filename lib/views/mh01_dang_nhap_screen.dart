import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../routes.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/session.dart';

// ============================================================
// MH-01 — Đăng nhập
// Luồng: L1 (Đăng nhập và khởi tạo tài khoản)
// Vào từ: mở ứng dụng lần đầu / bấm Đăng xuất ở MH-03
// Đi tới: Khung điều hướng (sau khi bấm "Đăng nhập bằng Google")
// Bố cục: dựng theo mockup Figma MH-01-dang-nhap (nền tím toàn màn,
//         vòng tròn trắng chứa ký hiệu Ω, nút Google trắng)
// Dữ liệu giả: không có, chỉ chữ và nút tĩnh
// Chức năng thật: ĐÃ nối ở T14 — AuthService đăng nhập Google qua
//         Firebase Auth, gọi POST /auth/login rồi vào khung điều hướng;
//         nút phụ vào bằng token dev phục vụ kiểm thử khi máy chưa
//         cấu hình Firebase (xem docs/T14_HUONG_DAN_CAU_HINH_FIREBASE.md)
// ============================================================
class Mh01DangNhapScreen extends StatefulWidget {
  const Mh01DangNhapScreen({super.key});

  @override
  State<Mh01DangNhapScreen> createState() => _Mh01DangNhapScreenState();
}

class _Mh01DangNhapScreenState extends State<Mh01DangNhapScreen> {
  bool _dangXuLy = false;
  String? _loi;

  Future<void> _dangNhapGoogle() async {
    setState(() {
      _dangXuLy = true;
      _loi = null;
    });
    try {
      await AuthService().signInWithGoogle();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.khung);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dangXuLy = false;
        _loi = _thongDiepLoi(e);
      });
    }
  }

  String _thongDiepLoi(Object e) {
    if (e is ApiException) return e.message;
    final s = e.toString();
    if (s.contains('Đã hủy')) return 'Đã hủy đăng nhập';
    if (e is TimeoutException) {
      return 'Máy chủ không phản hồi sau 15 giây. Kiểm tra API đã chạy '
          'trên máy (kèm khóa Firebase) rồi thử lại';
    }
    if (s.contains('network') || s.contains('SocketException')) {
      return 'Lỗi mạng, kiểm tra kết nối rồi thử lại';
    }
    return 'Đăng nhập thất bại. Nếu máy chưa cấu hình Firebase, '
        'dùng tài khoản dev bên dưới để kiểm thử';
  }

  void _vaoBangDev() {
    Session.useDevToken('uy');
    Navigator.pushReplacementNamed(context, AppRoutes.khung);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: Stack(
        children: [
          // vong tron trang mo trang tri o goc phai tren va trai duoi
          Positioned(
            top: -70,
            right: -60,
            child: _VongTronMo(duongKinh: 190),
          ),
          Positioned(
            bottom: -90,
            left: -70,
            child: _VongTronMo(duongKinh: 230),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Container(
                    width: 112,
                    height: 112,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Ω',
                      style: TextStyle(fontSize: 58, fontWeight: FontWeight.w900, color: kPrimary),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'OMEGA QUIZ',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Học — Thi — Đấu hạng cùng nhau',
                    style: TextStyle(fontSize: 14.5, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const Spacer(flex: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kTextMain,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      onPressed: _dangXuLy ? null : _dangNhapGoogle,
                      child: _dangXuLy
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: kPrimary),
                            )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'G',
                            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF4285F4)),
                          ),
                          SizedBox(width: 12),
                          Text('Đăng nhập bằng Google'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Đăng nhập bằng tài khoản Google —\nmọi tài khoản đều dùng được',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Lần đầu đăng nhập: tự tạo hồ sơ + dùng thử 7 ngày',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  if (_loi != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _loi!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFFFD7D9)),
                    ),
                  ],
                  const Spacer(flex: 2),
                  TextButton(
                    onPressed: _dangXuLy ? null : _vaoBangDev,
                    child: Text(
                      'Vào bằng tài khoản dev (kiểm thử)',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.75)),
                    ),
                  ),
                  Text(
                    'Phiên bản 1.0',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VongTronMo extends StatelessWidget {
  final double duongKinh;

  const _VongTronMo({required this.duongKinh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: duongKinh,
      height: duongKinh,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
    );
  }
}
