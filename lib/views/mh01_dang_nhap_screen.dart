import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../routes.dart';

// ============================================================
// MH-01 — Đăng nhập
// Luồng: L1 (Đăng nhập và khởi tạo tài khoản)
// Vào từ: mở ứng dụng lần đầu / bấm Đăng xuất ở MH-03
// Đi tới: Khung điều hướng (sau khi bấm "Đăng nhập bằng Google")
// Bố cục: dựng theo mockup Figma MH-01-dang-nhap (nền tím toàn màn,
//         vòng tròn trắng chứa ký hiệu Ω, nút Google trắng)
// Dữ liệu giả: không có, chỉ chữ và nút tĩnh
// Chức năng thật nối ở: T14 (đăng nhập Google qua Firebase Auth)
// ============================================================
class Mh01DangNhapScreen extends StatelessWidget {
  const Mh01DangNhapScreen({super.key});

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
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, AppRoutes.khung),
                      child: const Row(
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
                  const Spacer(flex: 2),
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
