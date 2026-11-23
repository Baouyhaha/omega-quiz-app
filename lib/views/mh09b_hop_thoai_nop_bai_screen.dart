/// MH-09b — Hộp thoại nộp bài.
/// Luồng: L2 (Làm bài thường); L6/L7 khi thi đấu.
/// Vào từ: MH-09 Làm bài (bấm Nộp bài).
/// Đi tiếp tới: MH-10 Kết quả (bấm Nộp bài) / quay lại MH-09 (bấm Hủy).
/// Không có thanh dưới (hộp thoại hiện trên MH-09, theo Figma).
/// Dữ liệu giả: số câu chưa trả lời truyền từ MH-09 (mock: 3 câu).
/// Chức năng thật: nối ở task T21 (để giai đoạn chức năng).
import 'package:flutter/material.dart';

import '../core/app_theme.dart';

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
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/mh10');
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
