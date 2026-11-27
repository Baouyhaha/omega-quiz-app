import 'package:flutter/material.dart';

import 'views/khung_dieu_huong_screen.dart';
import 'views/mh01_dang_nhap_screen.dart';
import 'views/mh03_ho_so_screen.dart';
import 'views/mh05_chu_de_screen.dart';
import 'views/mh15_ban_be_screen.dart';
import 'views/mh16_doi_khang_screen.dart';
import 'views/mh21_quan_ly_thanh_vien_screen.dart';
import 'views/mh25_tao_sua_bo_de_screen.dart';
import 'views/mh26_cai_dat_bo_de_screen.dart';
import 'views/mh28_danh_sach_goi_screen.dart';
import 'views/mh29_goi_cua_toi_screen.dart';

// Route CHI cho cac man hinh phan cua Uy (MH-01, 03, 16, 21, 25, 26, 28, 29),
// dung boi main_uy_preview.dart de chay thu rieng phan Uy.
// Man hinh cua cac ban khac khong khai bao o day — moi nguoi tu them
// route cua minh khi noi vao main chinh, tranh dung cham file chung.
class AppRoutes {
  static const String khung = '/khung';
  static const String mh01 = '/mh01';
  static const String mh03 = '/mh03';
  static const String mh05 = '/mh05';
  static const String mh15 = '/mh15';
  static const String mh16 = '/mh16';
  static const String mh21 = '/mh21';
  static const String mh25 = '/mh25';
  static const String mh26 = '/mh26';
  static const String mh28 = '/mh28';
  static const String mh29 = '/mh29';
}

Map<String, WidgetBuilder> appRoutes() {
  return {
    AppRoutes.khung: (_) => const KhungDieuHuongScreen(),
    AppRoutes.mh01: (_) => const Mh01DangNhapScreen(),
    AppRoutes.mh03: (_) => const Mh03HoSoScreen(),
    AppRoutes.mh05: (_) => const Mh05ChuDeScreen(token: 'dev:thinh'),
    AppRoutes.mh15: (_) => const Mh15BanBeScreen(token: 'dev:thinh'),
    AppRoutes.mh16: (_) => const Mh16DoiKhangScreen(),
    AppRoutes.mh21: (_) => const Mh21QuanLyThanhVienScreen(),
    AppRoutes.mh25: (_) => const Mh25TaoSuaBoDeScreen(),
    AppRoutes.mh26: (_) => const Mh26CaiDatBoDeScreen(),
    AppRoutes.mh28: (_) => const Mh28DanhSachGoiScreen(),
    AppRoutes.mh29: (_) => const Mh29GoiCuaToiScreen(),
  };
}
