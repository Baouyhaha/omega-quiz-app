import 'package:flutter/material.dart';

import 'views/khung_dieu_huong_screen.dart';
import 'views/man_hinh_dang_phat_trien.dart';
import 'views/mh01_dang_nhap_screen.dart';
import 'views/mh03_ho_so_screen.dart';
import 'views/mh16_doi_khang_screen.dart';
import 'views/mh21_quan_ly_thanh_vien_screen.dart';
import 'views/mh25_tao_sua_bo_de_screen.dart';
import 'views/mh26_cai_dat_bo_de_screen.dart';
import 'views/mh28_danh_sach_goi_screen.dart';
import 'views/mh29_goi_cua_toi_screen.dart';

// Ten route theo ma man hinh MH-01..MH-33 (xem DANH_SACH_MAN_HINH_DOT4.md).
// Man hinh nao chua duoc dung thi tro tam vao ManHinhDangPhatTrien.
class AppRoutes {
  static const String khung = '/khung';
  static const String mh01 = '/mh01';
  static const String mh02 = '/mh02';
  static const String mh03 = '/mh03';
  static const String mh04 = '/mh04';
  static const String mh05 = '/mh05';
  static const String mh06 = '/mh06';
  static const String mh07 = '/mh07';
  static const String mh08 = '/mh08';
  static const String mh09 = '/mh09';
  static const String mh10 = '/mh10';
  static const String mh11 = '/mh11';
  static const String mh12 = '/mh12';
  static const String mh13 = '/mh13';
  static const String mh14 = '/mh14';
  static const String mh15 = '/mh15';
  static const String mh16 = '/mh16';
  static const String mh17 = '/mh17';
  static const String mh18 = '/mh18';
  static const String mh19 = '/mh19';
  static const String mh20 = '/mh20';
  static const String mh21 = '/mh21';
  static const String mh22 = '/mh22';
  static const String mh23 = '/mh23';
  static const String mh24 = '/mh24';
  static const String mh25 = '/mh25';
  static const String mh26 = '/mh26';
  static const String mh27 = '/mh27';
  static const String mh28 = '/mh28';
  static const String mh29 = '/mh29';
  static const String mh30 = '/mh30';
  static const String mh31 = '/mh31';
  static const String mh32 = '/mh32';
  static const String mh33 = '/mh33';
}

Widget _tam(String ma, String ten) => ManHinhDangPhatTrien(maMH: ma, ten: ten);

Map<String, WidgetBuilder> appRoutes() {
  return {
    AppRoutes.khung: (_) => const KhungDieuHuongScreen(),
    AppRoutes.mh01: (_) => const Mh01DangNhapScreen(),
    AppRoutes.mh02: (_) => _tam('MH-02', 'Trang chủ'),
    AppRoutes.mh03: (_) => const Mh03HoSoScreen(),
    AppRoutes.mh04: (_) => _tam('MH-04', 'Tìm kiếm'),
    AppRoutes.mh05: (_) => _tam('MH-05', 'Chủ đề công khai'),
    AppRoutes.mh06: (_) => _tam('MH-06', 'Chi tiết chủ đề'),
    AppRoutes.mh07: (_) => _tam('MH-07', 'Danh sách bộ đề'),
    AppRoutes.mh08: (_) => _tam('MH-08', 'Chi tiết bộ đề'),
    AppRoutes.mh09: (_) => _tam('MH-09', 'Làm bài'),
    AppRoutes.mh10: (_) => _tam('MH-10', 'Kết quả bài làm'),
    AppRoutes.mh11: (_) => _tam('MH-11', 'Xem lại bài đã làm'),
    AppRoutes.mh12: (_) => _tam('MH-12', 'Lịch sử làm bài'),
    AppRoutes.mh13: (_) => _tam('MH-13', 'Ôn tập câu sai'),
    AppRoutes.mh14: (_) => _tam('MH-14', 'Bảng xếp hạng'),
    AppRoutes.mh15: (_) => _tam('MH-15', 'Bạn bè'),
    AppRoutes.mh16: (_) => const Mh16DoiKhangScreen(),
    AppRoutes.mh17: (_) => _tam('MH-17', 'Đợt thi khung giờ'),
    AppRoutes.mh18: (_) => _tam('MH-18', 'Kết quả đợt thi'),
    AppRoutes.mh19: (_) => _tam('MH-19', 'Yêu thích'),
    AppRoutes.mh20: (_) => _tam('MH-20', 'Tạo/Sửa chủ đề'),
    AppRoutes.mh21: (_) => const Mh21QuanLyThanhVienScreen(),
    AppRoutes.mh22: (_) => _tam('MH-22', 'Quản lý câu hỏi'),
    AppRoutes.mh23: (_) => _tam('MH-23', 'Soạn/Sửa câu hỏi'),
    AppRoutes.mh24: (_) => _tam('MH-24', 'Import Excel'),
    AppRoutes.mh25: (_) => const Mh25TaoSuaBoDeScreen(),
    AppRoutes.mh26: (_) => const Mh26CaiDatBoDeScreen(),
    AppRoutes.mh27: (_) => _tam('MH-27', 'Thống kê chủ đề'),
    AppRoutes.mh28: (_) => const Mh28DanhSachGoiScreen(),
    AppRoutes.mh29: (_) => const Mh29GoiCuaToiScreen(),
    AppRoutes.mh30: (_) => _tam('MH-30', 'Admin: Tài khoản'),
    AppRoutes.mh31: (_) => _tam('MH-31', 'Admin: Chi tiết tài khoản'),
    AppRoutes.mh32: (_) => _tam('MH-32', 'Admin: Gói và hạn mức'),
    AppRoutes.mh33: (_) => _tam('MH-33', 'Admin: Thống kê'),
  };
}
