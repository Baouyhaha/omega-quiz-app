import 'package:flutter/material.dart';

import 'core/dinh_theme.dart';
import 'models/topic.dart';
import 'views/mh20_tao_sua_chu_de_screen.dart';
import 'views/mh22_quan_ly_cau_hoi_screen.dart';
import 'views/mh23_soan_sua_cau_hoi_screen.dart';
import 'views/mh24_import_excel_screen.dart';
import 'views/mh27_thong_ke_chu_de_screen.dart';
import 'views/admin_host_screen.dart';
import 'views/mh31_admin_chi_tiet_tai_khoan_screen.dart';

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
      // Muon chay thu khu vuc Admin thi doi home thanh
      // AdminHostScreen() (thanh tab dung yen, chi noi dung truot).
      home: AdminHostScreen(),
      routes: {
        // MH-20 ban noi API that (Thinh): can token; che do sua truyen
        // them topic mau de xem form.
        '/mh20': (context) =>
            const Mh20TaoSuaChuDeScreen(token: 'dev:dinh'),
        '/mh20-edit': (context) => const Mh20TaoSuaChuDeScreen(
              token: 'dev:dinh',
              topic: Topic(
                id: 'topic_toan',
                ownerId: 'dinh',
                name: 'Toán cao cấp',
                description: '',
                visibility: 'PUBLIC',
                createdAt: '',
                memberCount: 0,
                examCount: 0,
                questionCount: 0,
              ),
            ),
        '/mh22': (context) => Mh22QuanLyCauHoiScreen(),
        '/mh23': (context) => Mh23SoanSuaCauHoiScreen(),
        // Che do sua, dung chung form MH-23.
        '/mh23-edit': (context) =>
            const Mh23SoanSuaCauHoiScreen(isEdit: true),
        '/mh24': (context) => Mh24ImportExcelScreen(),
        '/mh27': (context) => Mh27ThongKeChuDeScreen(),
        // Khu vuc Admin chay qua màn host chung: thanh tab dung yen
        // duoi day, noi dung MH-30/32/33 truot ngang khi doi tab.
        '/mh30': (context) => const AdminHostScreen(initialIndex: 0),
        // MH-30 truyen ma tai khoan qua arguments; mo truc tiep
        // khong co arguments thi mac dinh xem tai khoan Danh.
        '/mh31': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return Mh31AdminChiTietTaiKhoanScreen(
            accountId: args is String ? args : 'danh',
          );
        },
        '/mh32': (context) => const AdminHostScreen(initialIndex: 1),
        '/mh33': (context) => const AdminHostScreen(initialIndex: 2),
      },
    );
  }
}
