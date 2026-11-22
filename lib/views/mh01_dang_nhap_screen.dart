import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../routes.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-01 — Đăng nhập
// Luồng: L1 (Đăng nhập và khởi tạo tài khoản)
// Vào từ: mở ứng dụng lần đầu / bấm Đăng xuất ở MH-03
// Đi tới: Khung điều hướng (sau khi bấm "Đăng nhập bằng Google")
// Dữ liệu giả: không có, chỉ chữ và nút tĩnh
// Chức năng thật nối ở: T14 (đăng nhập Google qua Firebase Auth)
// ============================================================
class Mh01DangNhapScreen extends StatelessWidget {
  const Mh01DangNhapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.quiz_rounded, size: 52, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'Omega Quiz',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kTextMain),
              ),
              const SizedBox(height: 8),
              const Text(
                'Học qua trắc nghiệm, thi đấu cùng bạn bè\nvà leo hạng mỗi ngày.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: kTextSub, height: 1.45),
              ),
              const Spacer(flex: 3),
              NutChinh(
                text: 'Đăng nhập bằng Google',
                icon: Icons.login_rounded,
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.khung),
              ),
              const SizedBox(height: 14),
              const Text(
                'Đăng nhập lần đầu sẽ tự kích hoạt gói dùng thử 7 ngày.',
                style: TextStyle(fontSize: 13, color: kTextSub),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
