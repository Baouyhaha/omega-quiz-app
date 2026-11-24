// File tạm CHỈ DÙNG LOCAL — KHÔNG commit. Xóa trước khi mở PR.
//
// Preview riêng phần của Danh: shell có thanh điều hướng dưới 5 tab
// (Trang chủ MH-02 / Chủ đề MH-05 / Thi đấu MH-17 / Xếp hạng MH-14 /
// Hồ sơ MH-03) + route cho các màn con + placeholder cho màn của bạn khác.
// Chạy: flutter run -t lib/main_danh_preview.dart
// Nút "Màn hình" (góc dưới phải, trên shell) mở menu liệt kê đủ 10 màn
// của Danh để Uy/nhóm bấm xem từng màn — phục vụ review.
// Đóng gói APK cho Uy: flutter build apk --debug --split-per-abi -t lib/main_danh_preview.dart
// File APK ở build/app/outputs/flutter-apk/ (gửi bản arm64-v8a cho
// điện thoại, x86_64 cho emulator).
// Sau khi Uy merge routes.dart + khung điều hướng thật thì xóa file này,
// chạy flutter run thường.
//
// T40/T22: Provider nối Ở ĐÂY để test (TrangChuViewModel +
// TimKiemViewModel + ExamAttemptViewModel). Việc nối vào main.dart thật
// chờ nhóm chốt — đừng tự nối vào main.dart rồi push.
// Route /mh08 hiện là màn chờ hiện dữ liệu chi tiết thật; khi Thịnh
// xong MH-08 thật thì đổi route sang màn của Thịnh.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/sound_service.dart';

import 'core/app_theme.dart';
import 'services/api_client.dart';
import 'models/exam.dart';
import 'viewmodels/exam_attempt_viewmodel.dart';
import 'viewmodels/tim_kiem_viewmodel.dart';
import 'viewmodels/trang_chu_viewmodel.dart';
import 'views/mh02_trang_chu_screen.dart';
import 'views/mh04_tim_kiem_screen.dart';
import 'views/mh09_lam_bai_screen.dart';
import 'views/mh09b_hop_thoai_nop_bai_screen.dart';
import 'views/mh10_ket_qua_screen.dart';
import 'views/mh11_xem_lai_screen.dart';
import 'views/mh14_bang_xep_hang_screen.dart';
import 'views/mh15_ban_be_screen.dart';
import 'views/mh17_dot_thi_screen.dart';
import 'views/mh18_ket_qua_dot_thi_screen.dart';
import 'widgets/thanh_dieu_huong_duoi_widget.dart';

void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TrangChuViewModel()..taiTrangChu(),
        ),
        ChangeNotifierProvider(
          create: (_) => TimKiemViewModel()..taiDanhSachChuDe(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExamAttemptViewModel(ApiClient()),
        ),
      ],
      child: MaterialApp(
        title: 'Danh preview (local)',
        theme: buildAppTheme(),
        initialRoute: '/',
        routes: {
          // Shell: khung + thanh điều hướng dưới. Nhận tab ban đầu (0–4)
          // qua route arguments khi màn con bấm tab thanh dưới.
          '/': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            return _PreviewShell(tabBanDau: args is int ? args : 0);
          },
          // Bí danh theo tên route shell của Uy ('/khung' trong routes.dart)
          // để code màn hình chạy được cả 2 cách đặt tên.
          '/khung': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            return _PreviewShell(tabBanDau: args is int ? args : 0);
          },
          // Màn tab — chạy lẻ để test bố cục (không có thanh nav khi chạy lẻ;
          // muốn xem kèm thanh nav thì dùng lối tắt '/tab02', '/tab14',
          // '/tab17' bên dưới, hoặc chạy shell '/' rồi bấm tab).
          '/mh02': (_) => const Mh02TrangChuScreen(),
          '/mh14': (_) => const Mh14BangXepHangScreen(),
          '/mh17': (_) => const Mh17DotThiScreen(),
          // Lối tắt để test màn tab KÈM thanh nav: đặt initialRoute thành
          // '/tab02', '/tab14' hoặc '/tab17' rồi bấm R (mở shell ở đúng tab).
          '/tab02': (_) => const _PreviewShell(tabBanDau: 0),
          '/tab17': (_) => const _PreviewShell(tabBanDau: 2),
          '/tab14': (_) => const _PreviewShell(tabBanDau: 3),
          // Menu xem thử: liệt kê đủ 10 màn của Danh để Uy review.
          '/menu': (_) => const _MenuManHinh(),
          // Màn con — mở từ màn khác hoặc chạy lẻ để test.
          '/mh04': (_) => const Mh04TimKiemScreen(),
          '/mh09': (_) => const Mh09LamBaiScreen(),
          '/mh10': (_) => const Mh10KetQuaScreen(),
          '/mh11': (_) => const Mh11XemLaiScreen(),
          '/mh15': (_) => const Mh15BanBeScreen(token: 'dev:danh'),
          '/mh18': (_) => const Mh18KetQuaDotThiScreen(),
          // MH-08: màn chờ hiện dữ liệu chi tiết thật (MH-08 thật của Thịnh
          // chưa xong). Khi Thịnh xong thì đổi route này sang màn thật.
          '/mh08': (context) {
            final exam =
                ModalRoute.of(context)?.settings.arguments as Exam?;
            return Scaffold(
              appBar:
                  AppBar(title: const Text('Chi tiết bộ đề (màn chờ)')),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: exam == null
                    ? const Text('Không có dữ liệu bộ đề.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exam.title,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(exam.description),
                          const SizedBox(height: 8),
                          Text('Số câu: ${exam.questionCount}'),
                          Text('Thời gian: ${exam.durationMinutes} phút'),
                          Text('Số lần làm tối đa: ${exam.maxAttempts}'),
                          const Text('Lượt làm: —'),
                          const Text(
                              'Điểm TB: — · Cao nhất: — · Thấp nhất: —'),
                          const Text('Độ khó: — (chờ API bổ sung)'),
                        ],
                      ),
              ),
            );
          },
          // Placeholder cho màn của bạn khác mà các màn của Danh dẫn tới —
          // để bấm vào không bị crash khi chưa có màn thật.
          '/mh03': (_) =>
              const _ManHinhCho(maMH: 'MH-03', ten: 'Hồ sơ (phần Uy)'),
          '/mh05': (_) => const _ManHinhCho(
              maMH: 'MH-05', ten: 'Chủ đề công khai (phần Thịnh)'),
          '/mh06': (_) => const _ManHinhCho(
              maMH: 'MH-06', ten: 'Chi tiết chủ đề (phần Thịnh)'),
          '/mh16': (_) =>
              const _ManHinhCho(maMH: 'MH-16', ten: 'Đối kháng 1-1 (phần Uy)'),
          '/mh28': (_) =>
              const _ManHinhCho(maMH: 'MH-28', ten: 'Danh sách gói (phần Uy)'),
          '/mh29': (_) =>
              const _ManHinhCho(maMH: 'MH-29', ten: 'Gói của tôi (phần Uy)'),
        },
        // Lưới an toàn: route nào chưa khai báo cũng hiện placeholder
        // thay vì màn hình đỏ.
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => _ManHinhCho(
            maMH: settings.name ?? '?',
            ten: 'Chưa có trong preview của Danh',
          ),
        ),
      ),
    );
  }
}

/// Shell preview: giữ 5 tab bằng IndexedStack (đổi tab không mất trạng thái
/// màn hình) + thanh điều hướng dưới dùng chung. Tab Thi đấu gắn MH-17
/// theo dây nối Figma (trophy → MH-17); khung của Uy hiện gắn MH-16 ở tab
/// này — nhóm cần chốt 1 trong 2 khi ghép (xem BAO_CAO_v2.md).
class _PreviewShell extends StatefulWidget {
  const _PreviewShell({this.tabBanDau = 0});

  final int tabBanDau;

  @override
  State<_PreviewShell> createState() => _PreviewShellState();
}

class _PreviewShellState extends State<_PreviewShell> {
  late int _tab;

  static const _tabs = [
    Mh02TrangChuScreen(),
    _ManHinhCho(maMH: 'MH-05', ten: 'Chủ đề công khai (phần Thịnh)'),
    Mh17DotThiScreen(),
    Mh14BangXepHangScreen(),
    _ManHinhCho(maMH: 'MH-03', ten: 'Hồ sơ (phần Uy)'),
  ];

  @override
  void initState() {
    super.initState();
    _tab = widget.tabBanDau.clamp(0, _tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _tabs),
      bottomNavigationBar: ThanhDieuHuongDuoi(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/menu'),
        icon: const Icon(Icons.list),
        label: const Text('Màn hình'),
      ),
    );
  }
}

/// Màn hình chờ tự viết cho preview (không copy file của Uy):
/// hiện khi bấm tới màn của bạn khác chưa có trong preview.
class _ManHinhCho extends StatelessWidget {
  const _ManHinhCho({required this.maMH, required this.ten});

  final String maMH;
  final String ten;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ten)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '$maMH — $ten\nChưa có trong preview của Danh.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

/// Menu xem thử (chỉ có trong preview, không commit): liệt kê đủ 10 màn
/// của Danh để Uy/nhóm bấm xem từng màn mà không cần đổi initialRoute.
/// MH-14/MH-17 mở qua lối tắt /tab để kèm thanh điều hướng; MH-09b là hộp
/// thoại nên bấm vào sẽ hiện dialog ngay trên menu.
class _MenuManHinh extends StatelessWidget {
  const _MenuManHinh();

  static const _manHinh = [
    ('MH-02', 'Trang chủ', '/mh02'),
    ('MH-04', 'Tìm kiếm', '/mh04'),
    ('MH-09', 'Làm bài', '/mh09'),
    ('MH-10', 'Kết quả bài làm', '/mh10'),
    ('MH-11', 'Xem lại bài', '/mh11'),
    ('MH-14', 'Bảng xếp hạng', '/tab14'),
    ('MH-15', 'Bạn bè', '/mh15'),
    ('MH-17', 'Đợt thi khung giờ', '/tab17'),
    ('MH-18', 'Kết quả đợt thi', '/mh18'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Màn hình của Danh')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Bản xem thử — bấm 1 màn để xem. MH-14/MH-17 mở kèm thanh điều hướng.',
            ),
          ),
          // T13 — NÚT TEST ÂM THANH TẠM, CHỈ ĐỂ QUAY VIDEO NGHIỆM THU.
          // XÓA TRƯỚC KHI NỘP PR. (Tiếng đúng/sai thật phát ở MH-13 của
          // Thịnh; ở đây chỉ để nghe thử file + quay video.)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('Test âm thanh (T13 — tạm, xóa trước khi nộp PR)',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Test tiếng đúng'),
            onTap: () => SoundService.instance.playCorrect(),
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Test tiếng sai'),
            onTap: () => SoundService.instance.playWrong(),
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Test tiếng hết giờ'),
            onTap: () => SoundService.instance.playTimeout(),
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Test tiếng lên rank'),
            onTap: () => SoundService.instance.playRankUp(),
          ),
          const Divider(),
          for (final (ma, ten, route) in _manHinh)
            ListTile(
              leading: CircleAvatar(child: Text(ma.substring(3))),
              title: Text('$ma — $ten'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, route),
            ),
          ListTile(
            leading: const CircleAvatar(child: Text('9b')),
            title: const Text('MH-09b — Hộp thoại nộp bài'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDialog(
              context: context,
              builder: (_) =>
                  const Mh09bHopThoaiNopBai(unanswered: 3),
            ),
          ),
          // T23: mở MH-11 với lượt làm vừa nộp xong (để test màn hình
          // khóa xem lại của đề NEVER — nút "Xem lại bài" trên MH-10 bị
          // mờ nên không vào được từ đó). Chỉ có trong preview.
          ListTile(
            leading: const CircleAvatar(child: Text('11*')),
            title: const Text('MH-11 xem lại (lượt vừa làm)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final vm = context.read<ExamAttemptViewModel>();
              if (vm.attemptId == null || vm.examId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Chưa có lượt làm nào. Làm xong 1 bộ đề rồi quay lại.')),
                );
                return;
              }
              Navigator.pushNamed(
                context,
                '/mh11',
                arguments: {
                  'attemptId': vm.attemptId,
                  'examId': vm.examId,
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
