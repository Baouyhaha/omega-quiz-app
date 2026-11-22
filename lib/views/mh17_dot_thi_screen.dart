/// MH-17 — Đợt thi khung giờ.
/// Luồng: L7 (Thi theo khung giờ).
/// Vào từ: thanh dưới mục Thi đấu.
/// Đi tiếp tới: MH-09 Làm bài (bấm Vào thi) /
///   MH-18 Kết quả đợt thi (đợt đã kết thúc — Xem kết quả).
/// Thanh dưới do shell (khung điều hướng) cấp — màn này không tự gắn nav.
/// Dữ liệu giả: khối // MOCK: đầu file này.
/// Chức năng thật: nối ở task T28 (để giai đoạn chức năng).
import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// MOCK: dữ liệu giả cho MH-17 — thay bằng API contests (task T28) ở giai đoạn chức năng.
// 3 nhóm: đang mở / sắp mở / đã kết thúc — không có lobby (mô hình cũ đã bỏ).
const _mockOpen = [
  {
    'name': 'Đợt Giữa kỳ — Đạo hàm',
    'topic': 'Toán cao cấp',
    'detail': '20 câu · 30 phút',
    'countdown': 'Còn 02:15:30 thì đóng',
  },
];
const _mockUpcoming = [
  {
    'name': 'Đợt Cuối kỳ — Tích phân',
    'topic': 'Toán cao cấp',
    'detail': '25 câu · 45 phút',
    'countdown': 'Mở sau 1 ngày 04:00',
  },
];
const _mockEnded = [
  {
    'name': 'Đợt Luyện tập tuần 1',
    'topic': 'Toán cao cấp',
    'detail': '20 câu',
    'countdown': '',
  },
];

class Mh17DotThiScreen extends StatelessWidget {
  const Mh17DotThiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Đợt thi khung giờ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Đang mở',
              style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
          ..._mockOpen.map((c) => _TheDotThi(
                dot: c,
                mauDemNguoc: kWarning,
                nutChinh: 'Vào thi',
                onNutChinh: () => Navigator.pushNamed(context, '/mh09'),
              )),
          const SizedBox(height: 16),
          Text('Sắp mở',
              style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
          // Đợt sắp mở chưa có nút (theo Figma).
          ..._mockUpcoming.map(
              (c) => _TheDotThi(dot: c, mauDemNguoc: kPrimary)),
          const SizedBox(height: 16),
          Text('Đã kết thúc',
              style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
          ..._mockEnded.map((c) => _TheDotThi(
                dot: c,
                nutChinh: 'Xem kết quả',
                laNutPhu: true,
                onNutChinh: () => Navigator.pushNamed(context, '/mh18'),
              )),
        ],
      ),
    );
  }
}

/// Thẻ 1 đợt thi: tên + chủ đề · số câu · thời gian + đếm ngược
/// + nút toàn chiều rộng (Vào thi / Xem kết quả — hoặc không có nút).
class _TheDotThi extends StatelessWidget {
  const _TheDotThi({
    required this.dot,
    this.mauDemNguoc,
    this.nutChinh,
    this.laNutPhu = false,
    this.onNutChinh,
  });

  final Map<String, String> dot;
  // Màu đếm ngược theo Figma: cam (đang mở) / tím (sắp mở).
  final Color? mauDemNguoc;
  final String? nutChinh;
  final bool laNutPhu;
  final VoidCallback? onNutChinh;

  @override
  Widget build(BuildContext context) {
    final countdown = dot['countdown']!;
    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      shape: _vienThe(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(dot['name']!,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: kTextPrimary)),
            Text('${dot['topic']} · ${dot['detail']}',
                style: const TextStyle(color: kTextSecondary)),
            if (countdown.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(countdown,
                  style: TextStyle(color: mauDemNguoc ?? kTextSecondary)),
            ],
            if (nutChinh != null) ...[
              const SizedBox(height: 12),
              if (laNutPhu)
                OutlinedButton(
                  onPressed: onNutChinh,
                  child: Text(nutChinh!),
                )
              else
                ElevatedButton(
                  onPressed: onNutChinh,
                  child: Text(nutChinh!),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Viền thẻ theo Figma — kBorder #E9E6F7.
ShapeBorder _vienThe() => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: kBorder),
    );
