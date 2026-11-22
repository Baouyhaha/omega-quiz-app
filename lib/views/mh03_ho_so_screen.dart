import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../routes.dart';
import '../widgets/banner_canh_bao_widget.dart';

// ============================================================
// MH-03 — Hồ sơ cá nhân
// Luồng: L1 (tài khoản), L8 (gói thuê)
// Vào từ: tab "Hồ sơ" của khung điều hướng
// Đi tới: MH-12 (lịch sử), MH-13 (ôn tập), MH-19 (yêu thích),
//         MH-29 (gói của tôi), MH-01 (đăng xuất)
// Dữ liệu giả: khối _mockHoSo ngay dưới đây
// Chức năng thật nối ở: T14 (hồ sơ), T29 (điểm xếp hạng), UC02 (gói)
// ============================================================

// MOCK: ho so mau, sau nay lay tu API GET /me
const _mockHoSo = {
  'ten': 'Nguyễn Trọng Bảo Uy',
  'email': '0306241504@caothang.edu.vn',
  'rankScore': 1240,
  'hangConVat': 'Ngựa',
  'diemTrungBinh': 8.2,
  'soBaiDaLam': 17,
  'goiHienTai': 'Dùng thử',
  'goiConLaiNgay': 5,
};

class Mh03HoSoScreen extends StatelessWidget {
  const Mh03HoSoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: kPrimary,
                    child: Icon(Icons.person_rounded, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mockHoSo['ten'] as String,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _mockHoSo['email'] as String,
                          style: const TextStyle(fontSize: 13, color: kTextSub),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ChiSo('Hạng', '${_mockHoSo['hangConVat']}'),
                  _ChiSo('Điểm rank', '${_mockHoSo['rankScore']}'),
                  _ChiSo('Điểm TB', '${_mockHoSo['diemTrungBinh']}'),
                  _ChiSo('Bài đã làm', '${_mockHoSo['soBaiDaLam']}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          BannerCanhBao(
            text: 'Gói dùng thử còn ${_mockHoSo['goiConLaiNgay']} ngày. '
                'Gia hạn để không bị giới hạn chủ đề và thành viên.',
            actionText: 'Xem gói',
            onAction: () => Navigator.pushNamed(context, AppRoutes.mh29),
          ),
          const SizedBox(height: 12),
          _MucMenu(
            icon: Icons.history_rounded,
            text: 'Lịch sử làm bài',
            onTap: () => Navigator.pushNamed(context, AppRoutes.mh12),
          ),
          _MucMenu(
            icon: Icons.replay_rounded,
            text: 'Ôn tập câu sai',
            onTap: () => Navigator.pushNamed(context, AppRoutes.mh13),
          ),
          _MucMenu(
            icon: Icons.favorite_rounded,
            text: 'Bộ đề yêu thích',
            onTap: () => Navigator.pushNamed(context, AppRoutes.mh19),
          ),
          _MucMenu(
            icon: Icons.workspace_premium_rounded,
            text: 'Gói của tôi',
            onTap: () => Navigator.pushNamed(context, AppRoutes.mh29),
          ),
          _MucMenu(
            icon: Icons.logout_rounded,
            text: 'Đăng xuất',
            mauChu: kError,
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.mh01,
              (_) => false,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChiSo extends StatelessWidget {
  final String nhan;
  final String giaTri;

  const _ChiSo(this.nhan, this.giaTri);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(giaTri, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kPrimary)),
        const SizedBox(height: 2),
        Text(nhan, style: const TextStyle(fontSize: 12, color: kTextSub)),
      ],
    );
  }
}

class _MucMenu extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color mauChu;

  const _MucMenu({
    required this.icon,
    required this.text,
    required this.onTap,
    this.mauChu = kTextMain,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: mauChu),
        title: Text(text, style: TextStyle(color: mauChu, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: kTextSub),
        onTap: onTap,
      ),
    );
  }
}
