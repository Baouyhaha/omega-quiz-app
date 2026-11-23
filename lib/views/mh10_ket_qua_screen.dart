/// MH-10 — Kết quả bài làm.
/// Luồng: L2 (Làm bài thường); L6/L7 khi thi đấu.
/// Vào từ: MH-09b Hộp thoại nộp bài (xác nhận) / tự nộp khi hết giờ
///   hoặc đủ 5 vi phạm chống gian lận (kèm arguments
///   {'forceSubmitted': true} — T22).
/// Đi tiếp tới: MH-11 Xem lại bài, shell tab Trang chủ (Về trang chủ),
///   shell đúng tab khi bấm thanh dưới.
/// Thanh dưới tự gắn — sáng tab Trang chủ (xem xong kết quả thì về Trang chủ).
/// Dữ liệu giả: khối // MOCK: đầu file này.
/// Chức năng thật: nối ở task T23 (để giai đoạn chức năng) — khi T23 viết
///   lại màn này thì GIỮ trạng thái bị nộp cưỡng bức bên dưới.
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/thanh_dieu_huong_duoi_widget.dart';

// MOCK: dữ liệu giả cho MH-10 — thay bằng API kết quả bài làm ở giai đoạn chức năng.
const _mockResult = {
  'score': '8.5',
  'total': '10',
  'correct': 17,
  'totalQuestions': 20,
  'wrong': 3,
  'time': '12:30',
  'speedBonus': '1.2',
};

class Mh10KetQuaScreen extends StatelessWidget {
  const Mh10KetQuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trạng thái bị nộp cưỡng bức (T22): MH-09 truyền arguments
    // {'forceSubmitted': true} khi đủ 5 vi phạm. Server không chấm điểm
    // khi nộp cưỡng bức (điểm null) nên KHÔNG hiện bảng điểm.
    final args = ModalRoute.of(context)?.settings.arguments;
    final biNopCuongBuc = args is Map && args['forceSubmitted'] == true;
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
        child: biNopCuongBuc
            ? _KetQuaBiNopCuongBuc(textTheme: textTheme)
            : _KetQuaThuong(textTheme: textTheme),
      ),
    );
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

/// Kết quả thường (bản UI mock — T23 nối API thật).
class _KetQuaThuong extends StatelessWidget {
  const _KetQuaThuong({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                Text('${_mockResult['score']}/${_mockResult['total']}',
                    style: textTheme.displayMedium
                        ?.copyWith(color: kPrimary)),
                const SizedBox(height: 8),
                Text('Bạn làm rất tốt!',
                    style: textTheme.titleMedium
                        ?.copyWith(color: kTextSecondary)),
                const SizedBox(height: 16),
                // Lưới thống kê 2x2.
                Row(
                  children: [
                    _OThongKe(
                      giaTri:
                          '${_mockResult['correct']}/${_mockResult['totalQuestions']}',
                      nhan: 'câu đúng',
                    ),
                    _OThongKe(
                      giaTri: '${_mockResult['wrong']}',
                      nhan: 'câu sai',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _OThongKe(
                      giaTri: _mockResult['time'] as String,
                      nhan: 'thời gian',
                    ),
                    _OThongKe(
                      giaTri: '+${_mockResult['speedBonus']}',
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
          onPressed: () => Navigator.pushNamed(context, '/mh11'),
          child: const Text('Xem lại bài'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => ThanhDieuHuongDuoi.veShell(context, 0),
          // Nút viền: nền trắng + viền/chữ tím (Figma).
          style:
              OutlinedButton.styleFrom(backgroundColor: Colors.white),
          child: const Text('Về trang chủ'),
        ),
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
