/// MH-09 — Làm bài.
/// Luồng: L2 (Làm bài thường); L6/L7 khi thi đấu (đối kháng / đợt thi).
/// Vào từ: MH-08 Chi tiết bộ đề (Bắt đầu) / MH-16 Đối kháng (Sẵn sàng) /
///   MH-17 Đợt thi (Vào thi).
/// Đi tiếp tới: MH-09b Hộp thoại nộp bài (bấm Nộp bài) → MH-10 Kết quả.
/// Không có thanh dưới (theo Figma).
/// Dữ liệu giả: khối // MOCK: đầu file này.
/// Chức năng thật: nối ở task T16 + T17 (để giai đoạn chức năng).
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'mh09b_hop_thoai_nop_bai_screen.dart';

// MOCK: dữ liệu giả cho MH-09 — thay bằng API phát đề ở giai đoạn chức năng.
// Đáp án B đang được chọn (như Figma); đã rời bài 1/5 lần.
const _mockQuestion = {
  'index': 7,
  'total': 20,
  'timeLeft': '12:34',
  'content': 'Đạo hàm của f(x) = x² tại x = 2 bằng bao nhiêu?',
  'options': ['2', '4', '8', '0'],
};
const _mockSelected = 1;
const _mockUnanswered = 3;
const _mockViolations = 1;
const _mockMaxViolations = 5;

class Mh09LamBaiScreen extends StatelessWidget {
  const Mh09LamBaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final options = _mockQuestion['options'] as List<String>;
    final index = _mockQuestion['index'] as int;
    final total = _mockQuestion['total'] as int;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Câu $index/$total'),
        actions: [
          // Đồng hồ đếm ngược — chạy thật ở task T16.
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined,
                    size: 20, color: kTextPrimary),
                const SizedBox(width: 4),
                Text(_mockQuestion['timeLeft'] as String,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: kTextPrimary)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh tiến trình làm bài — nền kProgressTrack #E4E0F5,
            // phần đã làm tím đặc kPrimary.
            LinearProgressIndicator(
              value: index / total,
              color: kPrimary,
              backgroundColor: kProgressTrack,
            ),
            const SizedBox(height: 16),
            Card(
              // Viền thẻ kBorder #E9E6F7.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: kBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_mockQuestion['content'] as String,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: kTextPrimary)),
                    const SizedBox(height: 4),
                    const Text('Chọn 1 đáp án đúng',
                        style: TextStyle(color: kTextSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 4 ô đáp án — màu huy hiệu chữ lấy từ hằng số kOptionColors.
            ...List.generate(options.length, (i) {
              return _AnswerOption(
                letter: 'ABCD'[i],
                text: options[i],
                color: kOptionColors[i],
                selected: i == _mockSelected,
              );
            }),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    // Nút Tip: nền trắng + viền/chữ tím (Figma).
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Tip'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Trợ giúp'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Panel trợ giúp — Figma vẽ sẵn dạng mở; khi làm thật thì panel
            // này mở ra từ nút Trợ giúp (giai đoạn chức năng).
            const _TroGiupPanel(),
            const SizedBox(height: 12),
            // Cảnh báo rời bài — Figma chỉ vẽ dòng chữ đỏ, không nền,
            // không icon (task T17).
            Text(
              'Đã rời bài $_mockViolations/$_mockMaxViolations lần — '
              'đủ $_mockMaxViolations lần bài sẽ tự nộp',
              style: const TextStyle(
                  color: kError, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                // Lớp mờ sau dialog #000000 opacity 0.55 (Figma).
                barrierColor: Colors.black.withValues(alpha: 0.55),
                builder: (_) =>
                    const Mh09bHopThoaiNopBai(unanswered: _mockUnanswered),
              ),
              child: const Text('Nộp bài'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1 ô đáp án: huy hiệu chữ màu (A–D) + nội dung; viền màu của đáp án
/// đó (chưa chọn 2px, đang chọn 3px); đáp án đang chọn tô nền tint
/// theo màu của đáp án đó (Figma: B chọn → nền #E3F2FD).
class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.letter,
    required this.text,
    required this.color,
    required this.selected,
  });

  final String letter;
  final String text;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: selected ? color.withValues(alpha: 0.12) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color, width: selected ? 3 : 2),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(letter,
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(text, style: const TextStyle(color: kTextPrimary)),
        // Chọn đáp án thật ở task T16 — hiện chỉ để xem bố cục.
        onTap: () {},
      ),
    );
  }
}

/// Panel trợ giúp: 50:50, thêm giờ, đổi câu, khiên an toàn.
/// "Hỏi Cộng Đồng" đã lọc khỏi phạm vi — vẽ DISABLED kèm nhãn "Sắp có".
class _TroGiupPanel extends StatelessWidget {
  const _TroGiupPanel();

  @override
  Widget build(BuildContext context) {
    // Chip trợ giúp: nền kPrimaryTint #EFECFE + chữ tím.
    return Card(
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
            Text('Trợ giúp',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: kTextPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  backgroundColor: kPrimaryTint,
                  label: const Text('50:50',
                      style: TextStyle(color: kPrimary)),
                  onPressed: () {},
                ),
                ActionChip(
                  backgroundColor: kPrimaryTint,
                  label: const Text('Thêm giờ +15s',
                      style: TextStyle(color: kPrimary)),
                  onPressed: () {},
                ),
                ActionChip(
                  backgroundColor: kPrimaryTint,
                  label: const Text('Đổi câu',
                      style: TextStyle(color: kPrimary)),
                  onPressed: () {},
                ),
                ActionChip(
                  backgroundColor: kPrimaryTint,
                  label: const Text('Khiên an toàn',
                      style: TextStyle(color: kPrimary)),
                  onPressed: () {},
                ),
                // Đã lọc khỏi phạm vi — onPressed null = disabled.
                // Figma: nền xám #E5E7EB + chữ #6E6A8A.
                ActionChip(
                  backgroundColor:
                      kDisabledBg,
                  disabledColor:
                      kDisabledBg,
                  label: const Text('Hỏi Cộng Đồng · Sắp có',
                      style: TextStyle(color: kTextSecondary)),
                  onPressed: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
