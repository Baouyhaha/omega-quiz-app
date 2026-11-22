import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Thanh điều hướng dưới dùng chung — 5 mục: Trang chủ / Chủ đề / Thi đấu /
/// Xếp hạng / Hồ sơ. Icon theo thiết kế nhóm đã thống nhất trên Figma
/// (22/11): nhà, lớp chồng, cúp, biểu đồ cột, người — dạng outline; icon
/// khi chọn vẫn là hình đó, chỉ đổi sang màu tím kPrimary.
/// Dùng ở: shell preview (tab đang chọn tô màu) + các màn con MH-04, MH-10,
/// MH-15, MH-18 (sáng tab cha: MH-04/MH-10 → Trang chủ, MH-15/MH-18 → Thi đấu).
/// Màu chỉ lấy từ hằng số trong app_theme.dart, không tự gõ mã màu.
/// Widget chung do Danh tạo đầu tiên — nhớ báo lên Discord theo quy tắc nhóm.
class ThanhDieuHuongDuoi extends StatelessWidget {
  const ThanhDieuHuongDuoi({
    super.key,
    this.selectedIndex,
    required this.onDestinationSelected,
  });

  /// Tab đang chọn (0–4). null = không tab nào được chọn (tất cả xám).
  final int? selectedIndex;

  /// Gọi khi bấm 1 mục, kèm chỉ số tab (0–4).
  final ValueChanged<int> onDestinationSelected;

  /// Về shell (khung điều hướng) ở đúng tab [tab], xóa hết màn hình cũ.
  /// Route '/' là shell trong file preview local; khi nối routes.dart thật
  /// thì đổi '/' thành route shell của nhóm (hiện Uy đặt là '/khung').
  static void veShell(BuildContext context, int tab) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
      arguments: tab,
    );
  }

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      label: 'Trang chủ',
    ),
    NavigationDestination(
      icon: Icon(Icons.layers_outlined),
      label: 'Chủ đề',
    ),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined),
      label: 'Thi đấu',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart),
      label: 'Xếp hạng',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outlined),
      label: 'Hồ sơ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final index = selectedIndex;
    if (index == null) {
      // Màn con: tắt hiệu ứng "đang chọn" (vòng chỉ báo + màu chọn) để
      // cả 5 mục đều xám như Figma — NavigationBar vẫn cần 1 selectedIndex
      // hợp lệ nên giữ số 0 nhưng tô lại toàn bộ bằng màu chưa chọn.
      const mauChuaChon = kNavInactive;
      return NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          iconTheme: WidgetStatePropertyAll(
            IconThemeData(color: mauChuaChon),
          ),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(color: mauChuaChon),
          ),
        ),
        child: NavigationBar(
          selectedIndex: 0,
          onDestinationSelected: onDestinationSelected,
          destinations: _destinations,
        ),
      );
    }
    // Shell: mục đang chọn tím kPrimary, mục chưa chọn xám kNavInactive
    // (#9A94B8 theo Figma) + vòng chỉ báo tím nhạt.
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: kPrimary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? kPrimary
                : kNavInactive,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? kPrimary
                : kNavInactive,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onDestinationSelected,
        destinations: _destinations,
      ),
    );
  }
}
