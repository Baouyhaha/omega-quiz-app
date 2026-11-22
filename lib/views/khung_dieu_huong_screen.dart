import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'mh03_ho_so_screen.dart';
import 'mh16_doi_khang_screen.dart';
import 'man_hinh_dang_phat_trien.dart';

// ============================================================
// Khung điều hướng chính — thanh dưới 5 mục
// Luồng: khung chứa của L2 (Trang chủ), L4 (Chủ đề), L6 (Thi đấu),
//        L7/L2 (Xếp hạng), L1 (Hồ sơ)
// Tab nào có màn hình thật thì gắn vào đây; tab chưa có màn hình
// thì hiện tạm ManHinhDangPhatTrien, xong màn nào thay màn đó.
// Chức năng thật nối ở: T40 (trang chủ), T17 (chủ đề), T29 (xếp hạng)
// ============================================================
class KhungDieuHuongScreen extends StatefulWidget {
  const KhungDieuHuongScreen({super.key});

  @override
  State<KhungDieuHuongScreen> createState() => _KhungDieuHuongScreenState();
}

class _KhungDieuHuongScreenState extends State<KhungDieuHuongScreen> {
  int _tab = 0;

  static const List<Widget> _tabs = [
    ManHinhDangPhatTrien(maMH: 'MH-02', ten: 'Trang chủ'),
    ManHinhDangPhatTrien(maMH: 'MH-05', ten: 'Chủ đề công khai'),
    Mh16DoiKhangScreen(),
    ManHinhDangPhatTrien(maMH: 'MH-14', ten: 'Bảng xếp hạng'),
    Mh03HoSoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        indicatorColor: kPrimary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.topic_rounded), label: 'Chủ đề'),
          NavigationDestination(icon: Icon(Icons.sports_esports_rounded), label: 'Thi đấu'),
          NavigationDestination(icon: Icon(Icons.leaderboard_rounded), label: 'Xếp hạng'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
