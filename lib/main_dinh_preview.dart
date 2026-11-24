import 'package:flutter/material.dart';

import 'core/dinh_theme.dart';
import 'views/mh20_tao_sua_chu_de_screen.dart';
import 'views/mh22_quan_ly_cau_hoi_screen.dart';
import 'views/mh23_soan_sua_cau_hoi_screen.dart';
import 'views/mh24_import_excel_screen.dart';
import 'views/mh27_thong_ke_chu_de_screen.dart';
import 'views/mh30_admin_tai_khoan_screen.dart';
import 'views/mh31_admin_chi_tiet_tai_khoan_screen.dart';
import 'views/mh32_admin_goi_va_han_muc_screen.dart';
import 'views/mh33_admin_thong_ke_screen.dart';

// ---------------------------------------------------------------------------
// Diem chay thu RIENG cua Dinh — lib/main_dinh_preview.dart
// Theo huong dan co lap code giao dien cua Uy:
//   - KHONG sua lib/main.dart chung.
//   - Chay thu phan cua Dinh bang lenh rieng:
//       flutter run -t lib/main_dinh_preview.dart
//     Chay flutter run thuong van ra ban main goc cua nhom.
//   - Route rieng cua Dinh khai bao ngay trong file nay.
//   - Khi hop nhat, Uy se gop route vao main.dart va xoa file preview.
// ---------------------------------------------------------------------------

void main() {
  runApp(const DinhPreviewApp());
}

class DinhPreviewApp extends StatelessWidget {
  const DinhPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildDinhTheme(),
      // Chay thu thang MH-22 de test T18 (noi API that): danh sach
      // cau hoi cua chu de Tieng Anh (topic_anh) lay tu API cua Uy.
      // Muon chay thu tu MH-30 thi doi home thanh
      // Mh30AdminTaiKhoanScreen() (bam the Danh sang MH-31).
      home: Mh22QuanLyCauHoiScreen(),
      routes: {
        '/mh20': (context) => const Mh20TaoSuaChuDeScreen(),
        // Che do sua, dung chung form MH-20.
        '/mh20-edit': (context) =>
            const Mh20TaoSuaChuDeScreen(isEdit: true),
        '/mh22': (context) => Mh22QuanLyCauHoiScreen(),
        '/mh23': (context) => Mh23SoanSuaCauHoiScreen(),
        // Che do sua, dung chung form MH-23.
        '/mh23-edit': (context) =>
            const Mh23SoanSuaCauHoiScreen(isEdit: true),
        '/mh24': (context) => Mh24ImportExcelScreen(),
        '/mh27': (context) => Mh27ThongKeChuDeScreen(),
        '/mh30': (context) => Mh30AdminTaiKhoanScreen(),
        '/mh31': (context) => Mh31AdminChiTietTaiKhoanScreen(),
        '/mh32': (context) => Mh32AdminGoiVaHanMucScreen(),
        '/mh33': (context) => Mh33AdminThongKeScreen(),
      },
    );
  }
}
