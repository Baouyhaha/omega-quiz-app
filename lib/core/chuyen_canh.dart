// T13: chuyển cảnh mờ dần 250ms (trong khoảng 220–300ms của thẻ T13).
// routes.dart dùng bảng Map nên không chỉnh được hiệu ứng — hàm này áp
// tại chỗ bấm điều hướng bằng Navigator.push. Đặt ở core/ thay vì
// routes.dart vì routes.dart là file của Uy (ghi chú trong file dặn
// màn khác không khai báo ở đó).
import 'package:flutter/material.dart';

/// Route chuyển cảnh mờ dần 250ms.
/// [arguments] để truyền dữ liệu kèm (ví dụ examId, kết quả nộp bài).
Route routeChuyenCanh(Widget manHinh, {Object? arguments}) {
  return PageRouteBuilder(
    settings: RouteSettings(arguments: arguments),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => manHinh,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
