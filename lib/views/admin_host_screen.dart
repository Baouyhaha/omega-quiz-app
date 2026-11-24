// ============================================================================
// Màn host khu vực Admin — lib/views/admin_host_screen.dart
// Mã MH: MH-30 / MH-32 / MH-33 (host chung) — theo task T15/T39.
// Thuộc luồng: L9 — Admin nền tảng (Flow boards, flow-L9-admin).
// Vào từ: Hồ sơ (MH-03) qua mục "Quản trị nền tảng" (chỉ hiện với
//   tài khoản Admin). MH-30 chính là "màn Quản trị", không có màn
//   trung gian (luồng đã chốt 24/11).
// Đi tới: MH-31 (chi tiết tài khoản, bấm thẻ trên MH-30); quay lại
//   Hồ sơ bằng nút "‹" ở header từng màn con.
// Dữ liệu: mỗi màn con tự tải dữ liệu thật từ API của Uy.
//   MH-30: GET /admin/users, /:id, /admin/plans, lock/unlock.
//   MH-32: GET /admin/plans, PUT /admin/plans/:id.
//   MH-33: GET /admin/stats.
//
// Vì sao có màn host này: thanh tab phụ Admin (AdminTabBar) phải
// ĐỨNG YÊN khi chuyển tab — chỉ phần nội dung bên trên mới trượt
// ngang. Trước đây thanh tab nằm trong từng màn (bottomNavigationBar
// của mỗi Scaffold) nên mỗi lần pushReplacement đổi màn là cả thanh
// tab cũng trượt theo, nhìn sai. Cách sửa: một Scaffold chung giữ
// thanh tab cố định ở dưới, phần nội dung là PageView 3 trang
// (MH-30/32/33); bấm tab thì PageView trượt ngang 300ms easeInOut,
// thanh tab không nhúc nhích. Vuốt ngang để đổi tab đã tắt
// (NeverScrollableScrollPhysics) để không chạm với thao tác kéo
// trong nội dung các màn con.
// ============================================================================

import 'package:flutter/material.dart';

import '../widgets/admin_tab_bar_widget.dart';
import 'mh30_admin_tai_khoan_screen.dart';
import 'mh32_admin_goi_va_han_muc_screen.dart';
import 'mh33_admin_thong_ke_screen.dart';

/// Màn host khu vực Admin: giữ thanh tab phụ cố định dưới đáy, phần
/// nội dung là 3 màn MH-30 / MH-32 / MH-33 trượt ngang khi đổi tab.
/// [initialIndex]: 0 = MH-30 Tài khoản, 1 = MH-32 Gói và hạn mức,
/// 2 = MH-33 Thống kê.
class AdminHostScreen extends StatefulWidget {
  const AdminHostScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AdminHostScreen> createState() => _AdminHostScreenState();
}

class _AdminHostScreenState extends State<AdminHostScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Bấm tab: chỉ trượt phần nội dung (PageView), thanh tab đứng yên.
  // PageView tự trượt đúng hướng theo thứ tự tab (sang phải/trái).
  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // Tắt vuốt ngang: chỉ đổi tab bằng cách bấm thanh tab.
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          Mh30AdminTaiKhoanScreen(),
          Mh32AdminGoiVaHanMucScreen(),
          Mh33AdminThongKeScreen(),
        ],
      ),
      // Thanh tab cố định ở đây — không nằm trong từng màn con nữa.
      bottomNavigationBar: AdminTabBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
