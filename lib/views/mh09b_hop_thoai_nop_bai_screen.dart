/// MH-09b — Hộp thoại nộp bài.
/// Luồng: L2 (Làm bài thường); L6/L7 khi thi đấu.
/// Vào từ: MH-09 Làm bài (bấm Nộp bài).
/// Đi tiếp tới: MH-10 Kết quả (bấm Nộp bài) / quay lại MH-09 (bấm Hủy).
/// Không có thanh dưới (hộp thoại hiện trên MH-09, theo Figma).
/// Số câu chưa trả lời truyền từ MH-09 (số thật từ ViewModel, T23).
/// Chức năng thật: T23 nối nút Nộp bài với API (submit rồi sang MH-10
/// kèm kết quả); số câu chưa trả lời đã là số thật.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../services/api_client.dart';
import '../viewmodels/exam_attempt_viewmodel.dart';

class Mh09bHopThoaiNopBai extends StatelessWidget {
  const Mh09bHopThoaiNopBai({super.key, required this.unanswered});

  final int unanswered;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Dùng Dialog thay AlertDialog: actions của AlertDialog tự xếp dọc
    // khi nút rộng (theme nút cao 52dp, rộng tối đa) — Figma xếp 2 nút
    // cạnh nhau, tiêu đề + nội dung căn giữa.
    return Dialog(
      backgroundColor: kSurface,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nộp bài?',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Bạn còn $unanswered câu chưa trả lời',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextSecondary)),
            const SizedBox(height: 24),
            Row(
              children: [
                // Nút Hủy: nút viền (trắng + viền/chữ tím) — Figma.
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    // T23: gọi API nộp bài rồi mới sang MH-10, kèm kết
                    // quả + examId (kết quả nộp không có examId, MH-10
                    // cần để tải settings). Lỗi thì ở lại MH-09 + hiện
                    // SnackBar, không sang MH-10 với kết quả rỗng.
                    onPressed: () async {
                      final vm = context.read<ExamAttemptViewModel>();
                      try {
                        final ketQua = await vm.submit();
                        if (!context.mounted) return;
                        Navigator.pop(context); // đóng dialog
                        Navigator.pushNamed(
                          context,
                          '/mh10',
                          arguments: {
                            ...ketQua,
                            'examId': vm.examId,
                          },
                        );
                      } on ApiException catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message)));
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Không nộp được bài. Kiểm tra API local đã chạy chưa.')));
                      }
                    },
                    child: const Text('Nộp bài'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
