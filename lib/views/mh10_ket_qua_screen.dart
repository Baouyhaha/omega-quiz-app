/// MH-10 — Kết quả bài làm.
/// Luồng: L2 (Làm bài thường); L6/L7 khi thi đấu.
/// Vào từ: MH-09b Hộp thoại nộp bài (kèm kết quả nộp + examId) / MH-12
///   Lịch sử (kèm attemptId) / tự nộp khi đủ 5 vi phạm (kèm arguments
///   {'forceSubmitted': true} — T22).
/// Đi tiếp tới: MH-11 Xem lại bài, shell tab Trang chủ (Về trang chủ),
///   shell đúng tab khi bấm thanh dưới.
/// Thanh dưới tự gắn — sáng tab Trang chủ (xem xong kết quả thì về Trang chủ).
/// Chức năng thật: T23 nối API kết quả (KetQuaViewModel) — điểm đếm số
///   600ms, ẩn điểm khi publishScore=false, khóa nút Xem lại theo
///   showAnswerMode/closeAt; GIỮ trạng thái bị nộp cưỡng bức của T22.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/dinh_dang.dart';
import '../services/api_client.dart';
import '../viewmodels/ket_qua_viewmodel.dart';
import '../widgets/thanh_dieu_huong_duoi_widget.dart';

class Mh10KetQuaScreen extends StatelessWidget {
  const Mh10KetQuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trạng thái bị nộp cưỡng bức (T22): MH-09 truyền arguments
    // {'forceSubmitted': true} khi đủ 5 vi phạm. Server không chấm điểm
    // khi nộp cưỡng bức (điểm null) nên KHÔNG hiện bảng điểm.
    final args = ModalRoute.of(context)?.settings.arguments;
    final biNopCuongBuc = args is Map && args['forceSubmitted'] == true;
    if (biNopCuongBuc) {
      final textTheme = Theme.of(context).textTheme;
      return Scaffold(
        appBar: AppBar(title: const Text('Kết quả')),
        bottomNavigationBar: ThanhDieuHuongDuoi(
          selectedIndex: 0,
          onDestinationSelected: (i) =>
              ThanhDieuHuongDuoi.veShell(context, i),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _KetQuaBiNopCuongBuc(textTheme: textTheme),
        ),
      );
    }
    // Kết quả thường: bọc KetQuaViewModel riêng cho màn này.
    return ChangeNotifierProvider(
      create: (_) => KetQuaViewModel(ApiClient()),
      child: const _Mh10NoiDung(),
    );
  }
}

/// Nội dung MH-10 khi có kết quả nộp (đọc arguments rồi tải qua VM).
class _Mh10NoiDung extends StatefulWidget {
  const _Mh10NoiDung();

  @override
  State<_Mh10NoiDung> createState() => _Mh10NoiDungState();
}

class _Mh10NoiDungState extends State<_Mh10NoiDung> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _taiKetQua());
  }

  Future<void> _taiKetQua() async {
    final vm = context.read<KetQuaViewModel>();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (args['examId'] != null && args['correctCount'] != null) {
        // Vừa nộp xong (từ MH-09b): kết quả đầy đủ + examId đã gộp.
        vm.nhanKetQuaVuaNop(Map<String, dynamic>.from(args));
        await vm.taiCaiDatDe(args['examId'] as String);
      } else if (args['attemptId'] != null) {
        // Mở từ lịch sử (MH-12): chỉ có attemptId.
        await vm.taiTuLichSu(args['attemptId'] as String);
        final examId = vm.examId;
        if (examId != null) await vm.taiCaiDatDe(examId);
      }
    }
    // Không có arguments (mở từ menu preview): hiện trạng thái trống.
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KetQuaViewModel>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả')),
      bottomNavigationBar: ThanhDieuHuongDuoi(
        selectedIndex: 0, // Trang chủ — xem xong kết quả thì về Trang chủ.
        onDestinationSelected: (i) =>
            ThanhDieuHuongDuoi.veShell(context, i),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _noiDungTheoTrangThai(vm, textTheme),
      ),
    );
  }

  Widget _noiDungTheoTrangThai(KetQuaViewModel vm, TextTheme textTheme) {
    // Đang tải (đường vào từ lịch sử).
    if (vm.dangTai && vm.ketQua == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Lỗi tải.
    if (vm.loi != null && vm.ketQua == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.loi!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _taiKetQua,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    // Không có kết quả (mở từ menu preview, chưa nộp bài nào).
    if (vm.ketQua == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Chưa có kết quả. Làm xong 1 bộ đề rồi quay lại nhé.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kTextSecondary),
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () => ThanhDieuHuongDuoi.veShell(context, 0),
            style:
                OutlinedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Về trang chủ'),
          ),
        ],
      );
    }
    return _KetQuaThuong(vm: vm, textTheme: textTheme);
  }
}

/// Trạng thái bị nộp cưỡng bức (T22): chỉ hiện thông báo, không điểm,
/// không nút "Xem lại bài" (không có đáp án để xem lại).
class _KetQuaBiNopCuongBuc extends StatelessWidget {
  const _KetQuaBiNopCuongBuc({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: kBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 48, color: kWarning),
                const SizedBox(height: 16),
                Text('Bài làm đã tự nộp',
                    style: textTheme.titleLarge
                        ?.copyWith(color: kTextPrimary)),
                const SizedBox(height: 8),
                const Text(
                  'Bạn đã rời bài đủ 5 lần nên bài làm đã tự nộp. '
                  'Bài làm không được chấm điểm.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => ThanhDieuHuongDuoi.veShell(context, 0),
          // Nút viền: nền trắng + viền/chữ tím (Figma).
          style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
          child: const Text('Về trang chủ'),
        ),
      ],
    );
  }
}

/// Kết quả thường: điểm thật từ API (T23).
class _KetQuaThuong extends StatelessWidget {
  const _KetQuaThuong({required this.vm, required this.textTheme});

  final KetQuaViewModel vm;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final duocXemLai = vm.duocXemLai;
    final thoiDiem = vm.thoiDiemDuocXem;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            // Viền thẻ kBorder #E9E6F7.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: kBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _vungDiem(),
                  const SizedBox(height: 16),
                  // Lưới thống kê 2x2.
                  Row(
                    children: [
                      _OThongKe(
                        giaTri: '${vm.soCauDung}/${vm.tongSoCau}',
                        nhan: 'câu đúng',
                      ),
                      _OThongKe(
                        giaTri: '${vm.soCauSai}',
                        nhan: 'câu sai',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _OThongKe(
                        // Thời gian làm bài: API nộp không trả, chỉ có
                        // khi mở từ lịch sử (và app chưa gửi thời gian
                        // lên — thuộc task làm bài).
                        giaTri: vm.thoiGianGiay != null
                            ? dinhDangThoiGian(vm.thoiGianGiay!)
                            : '—',
                        nhan: 'thời gian',
                      ),
                      _OThongKe(
                        giaTri: vm.thuongTocDo != null
                            ? '+${vm.thuongTocDo!.toStringAsFixed(1)}'
                            : '—',
                        nhan: 'thưởng tốc độ',
                        // Điểm thưởng tốc độ xanh lá (Figma).
                        mauGiaTri: kSuccess,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            // Đề khóa xem lại thì nút mờ (onPressed null = disabled).
            onPressed: duocXemLai
                ? () => Navigator.pushNamed(
                      context,
                      '/mh11',
                      arguments: {
                        'attemptId': vm.attemptId,
                        'examId': vm.examId,
                      },
                    )
                : null,
            child: const Text('Xem lại bài'),
          ),
          if (!duocXemLai) ...[
            const SizedBox(height: 8),
            Text(
              thoiDiem != null
                  ? 'Xem lại mở sau ${dinhDangNgayGio(thoiDiem)}'
                  : 'Bộ đề không cho xem đáp án',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSecondary),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => ThanhDieuHuongDuoi.veShell(context, 0),
            // Nút viền: nền trắng + viền/chữ tím (Figma).
            style:
                OutlinedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  /// Vùng điểm lớn ở giữa: đếm số 600ms khi có điểm thật; bị tự nộp
  /// hoặc điểm bị ẩn thì chỉ hiện dòng thông báo chữ (không đếm số).
  Widget _vungDiem() {
    if (vm.biTuNop) {
      return Text('Bài bị tự nộp do rời bài đủ 5 lần',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(color: kError));
    }
    if (vm.diemBiAn) {
      return Text('Điểm chưa được công bố',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(color: kTextSecondary));
    }
    final diem = vm.diem ?? 0;
    final tong = vm.tongDiem.toStringAsFixed(0);
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: diem),
          duration: const Duration(milliseconds: 600),
          builder: (context, giaTri, child) {
            return Text(
              '${giaTri.toStringAsFixed(1)}/$tong',
              style: textTheme.displayMedium?.copyWith(color: kPrimary),
            );
          },
        ),
        const SizedBox(height: 8),
        Text('Bạn làm rất tốt!',
            style: textTheme.titleMedium
                ?.copyWith(color: kTextSecondary)),
      ],
    );
  }
}

/// 1 ô thống kê trong lưới 2x2: giá trị lớn + nhãn nhỏ.
/// Giá trị mặc định màu chữ chính; ô thưởng tốc độ truyền kSuccess.
class _OThongKe extends StatelessWidget {
  const _OThongKe({
    required this.giaTri,
    required this.nhan,
    this.mauGiaTri = kTextPrimary,
  });

  final String giaTri;
  final String nhan;
  final Color mauGiaTri;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(giaTri,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: mauGiaTri)),
          Text(nhan, style: const TextStyle(color: kTextSecondary)),
        ],
      ),
    );
  }
}
