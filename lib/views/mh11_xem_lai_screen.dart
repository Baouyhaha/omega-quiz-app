/// MH-11 — Xem lại bài đã làm.
/// Luồng: L2 (Làm bài thường).
/// Vào từ: MH-10 Kết quả (Xem lại) / MH-12 Lịch sử — kèm arguments
///   {'attemptId': ..., 'examId': ...}.
/// Đi tiếp tới: quay lại MH-10 / MH-12.
/// Không có thanh dưới (theo Figma).
/// Chức năng thật: T23 nối API xem lại (XemLaiViewModel) — hiện đáp án
///   đúng + giải thích khi đề cho xem; khi đề khóa thì chỉ hiện thông
///   điệp khóa (server trả 403, không gửi đáp án về nên app không giữ
///   đáp án ở đâu cả — chống xem lén).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/dinh_dang.dart';
import '../services/api_client.dart';
import '../viewmodels/xem_lai_viewmodel.dart';

class Mh11XemLaiScreen extends StatelessWidget {
  const Mh11XemLaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => XemLaiViewModel(ApiClient()),
      child: const _Mh11NoiDung(),
    );
  }
}

class _Mh11NoiDung extends StatefulWidget {
  const _Mh11NoiDung();

  @override
  State<_Mh11NoiDung> createState() => _Mh11NoiDungState();
}

class _Mh11NoiDungState extends State<_Mh11NoiDung> {
  String? _attemptId;
  String? _examId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map &&
          args['attemptId'] != null &&
          args['examId'] != null) {
        _attemptId = args['attemptId'] as String;
        _examId = args['examId'] as String;
        _taiXemLai();
      }
    });
  }

  void _taiXemLai() {
    if (_attemptId == null || _examId == null) return;
    context.read<XemLaiViewModel>().taiXemLai(
          attemptId: _attemptId!,
          examId: _examId!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<XemLaiViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Xem lại bài')),
      body: _noiDungTheoTrangThai(vm),
    );
  }

  Widget _noiDungTheoTrangThai(XemLaiViewModel vm) {
    // Chưa có bài để xem (mở từ menu preview, không có arguments).
    if (_attemptId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Chưa có bài để xem lại. Nộp xong 1 bộ đề rồi quay lại nhé.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextSecondary),
          ),
        ),
      );
    }
    // Đang tải.
    if (vm.dangTai) {
      return const Center(child: CircularProgressIndicator());
    }
    // Lỗi tải (không phải bị khóa).
    if (vm.loi != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(vm.loi!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _taiXemLai,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    // Bị khóa xem lại — chỉ hiện thông điệp, không có đáp án nào.
    if (vm.biKhoa) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: kWarning),
              const SizedBox(height: 16),
              const Text(
                'Bộ đề không cho xem đáp án vào lúc này',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              if (vm.thoiDiemDuocXem != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Bạn xem lại được sau '
                  '${dinhDangNgayGio(vm.thoiDiemDuocXem!)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kTextSecondary),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }
    // Mở: danh sách câu hỏi kèm đáp án đúng + giải thích.
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.cauHoi.length + 1,
      itemBuilder: (context, i) {
        // Dòng cuối: ghi chú đáp án hiện theo cài đặt của bộ đề.
        if (i == vm.cauHoi.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Đáp án hiện theo cài đặt của bộ đề',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: kTextSecondary),
            ),
          );
        }
        final r = vm.cauHoi[i] as Map<String, dynamic>;
        final daChon = r['selectedOption'] as int?;
        final dapAnDung = r['correctOption'] as int;
        final isCorrect = daChon == dapAnDung;
        final giaiThich = r['explanation'] as String? ?? '';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          // Viền thẻ kBorder #E9E6F7.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: kBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? kSuccess : kError,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Câu ${i + 1}: ${r['content']}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: kTextPrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  daChon == null
                      ? 'Bạn chưa trả lời câu này — '
                          'đáp án đúng: ${_chu(dapAnDung)}'
                      : isCorrect
                          ? 'Bạn chọn ${_chu(daChon)} — Đúng'
                          : 'Bạn chọn ${_chu(daChon)} — Sai, '
                              'đáp án đúng: ${_chu(dapAnDung)}',
                  style: TextStyle(
                    color: isCorrect ? kSuccess : kError,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!isCorrect && giaiThich.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Giải thích: $giaiThich',
                      style: const TextStyle(color: kTextSecondary)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Đổi số đáp án 0–3 sang chữ A–D.
String _chu(int index) => String.fromCharCode(65 + index);
