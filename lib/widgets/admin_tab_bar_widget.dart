import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';
import '../views/mh30_admin_tai_khoan_screen.dart';
import '../views/mh32_admin_goi_va_han_muc_screen.dart';
import '../views/mh33_admin_thong_ke_screen.dart';

// ============================================================================
// Widget dùng chung: thanh tab phụ Admin — lib/widgets/admin_tab_bar_widget.dart
// Theo luồng Admin đã chốt (xem luong-admin-da-chot.md):
//   - Dùng chung cho 3 màn MH-30 / MH-32 / MH-33, gồm 3 tab:
//     Tài khoản | Gói và hạn mức | Thống kê.
//   - Thanh tab này phải ĐỨNG YÊN khi chuyển tab — chỉ phần nội
//     dung bên trên mới trượt ngang. Vì vậy thanh tab không nằm
//     trong từng màn nữa mà nằm ở màn host Admin (AdminHostScreen,
//     lib/views/admin_host_screen.dart): host giữ thanh tab cố định
//     ở dưới, phần nội dung là PageView 3 trang (MH-30/32/33).
//     Bấm tab thì host trượt PageView (300ms, easeInOut), thanh
//     tab không nhúc nhích.
//   - Khi màn chạy độc lập, không qua host, bấm tab vẫn đổi màn
//     bằng pushReplacement + trượt ngang 300ms như trước — nút quay
//     lại ở header các màn sau đó vẫn về đúng Hồ sơ (MH-03), màn
//     vào khu vực Admin.
//   - Không phải thanh menu dưới 5 mục dùng chung của app — Admin
//     không dùng menu 5 mục đó; thanh này chỉ hiện trong khu vực Admin.
//   - Nút quay lại về Hồ sơ nằm ở từng màn (MH-30/32/33), không nằm
//     trong widget này.
// Khung giống thanh menu dưới 5 mục đã chốt (xem
// menu-duoi-5-muc-chia-se-nhom.md): nền kSurface, viền trên 1px
// kInputBorder, cao 76px, mục đang chọn tím kPrimary, mục chưa chọn
// kNavUnselected, icon Material bản outlined.
//
// Chuyển màn: TRƯỢT NGANG, không dùng hiệu ứng mờ dần (fade) mặc
// định — fade trên Chrome/Windows nhìn như chớp, thiếu chuyên nghiệp.
// Hướng trượt theo thứ tự tab: sang tab bên phải thì màn mới trượt
// vào từ phải, sang tab bên trái thì trượt vào từ trái (kiểu trượt
// của tab chuẩn). Qua host thì PageView tự trượt theo hướng; chạy
// độc lập thì widget này tự làm hiệu ứng trượt (PageRouteBuilder),
// vì vậy nó import luôn 3 màn để dựng route trượt; vòng import
// widget <-> màn hình là có chủ ý và Dart cho phép.
// ============================================================================

/// Thanh tab phụ Admin: 3 tab Tài khoản / Gói và hạn mức / Thống kê.
/// [currentIndex]: 0 = MH-30 Tài khoản, 1 = MH-32 Gói và hạn mức,
/// 2 = MH-33 Thống kê.
/// [onTabSelected]: khi có callback này, bấm tab sẽ gọi nó thay cho
/// việc tự đổi màn bằng pushReplacement — màn host Admin dùng cách
/// này để chỉ trượt phần nội dung (PageView), thanh tab đứng yên.
/// Khi không có callback (màn chạy độc lập, không qua host), giữ
/// hành vi cũ: pushReplacement + trượt ngang 300ms.
class AdminTabBar extends StatelessWidget {
  const AdminTabBar({
    super.key,
    required this.currentIndex,
    this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int>? onTabSelected;

  // Màn đích của 3 tab, theo thứ tự tab.
  static Widget _screenFor(int index) {
    switch (index) {
      case 1:
        return const Mh32AdminGoiVaHanMucScreen();
      case 2:
        return const Mh33AdminThongKeScreen();
      case 0:
      default:
        return const Mh30AdminTaiKhoanScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(
          top: BorderSide(color: kInputBorder, width: 1),
        ),
      ),
      child: SizedBox(
        height: 76,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: kSurface,
          elevation: 0,
          currentIndex: currentIndex,
          selectedItemColor: kPrimary,
          unselectedItemColor: kNavUnselected,
          selectedLabelStyle: kNavLabelStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: kPrimary,
          ),
          unselectedLabelStyle: kNavLabelStyle,
          onTap: (index) {
            // Đang ở tab nào rồi thì không làm gì.
            if (index == currentIndex) return;
            // Màn host Admin: để host trượt PageView, thanh tab đứng yên.
            if (onTabSelected != null) {
              onTabSelected!(index);
              return;
            }
            // Trượt ngang theo hướng tab: sang tab bên phải thì màn
            // mới trượt vào từ phải (Offset 1 -> 0), sang tab bên
            // trái thì trượt vào từ trái (Offset -1 -> 0).
            final slideFromRight = index > currentIndex;
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    _screenFor(index),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  final begin = slideFromRight
                      ? const Offset(1.0, 0.0)
                      : const Offset(-1.0, 0.0);
                  final tween = Tween(begin: begin, end: Offset.zero)
                      .chain(
                        CurveTween(curve: Curves.easeInOut),
                      );
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Tài khoản',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_outlined),
              label: 'Gói và hạn mức',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              label: 'Thống kê',
            ),
          ],
        ),
      ),
    );
  }
}
