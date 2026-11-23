/// MH-18 — Kết quả đợt thi.
/// Luồng: L7 (Thi theo khung giờ).
/// Vào từ: MH-17 Đợt thi khung giờ (đợt đã kết thúc — Xem kết quả).
/// Đi tiếp tới: MH-17 (nút back), shell tab Trang chủ (Về trang chủ),
///   shell đúng tab khi bấm thanh dưới.
/// Thanh dưới tự gắn — sáng tab Thi đấu (kết quả đợt thi, theo Figma).
/// Dữ liệu giả: khối // MOCK: đầu file này.
/// Chức năng thật: nối ở task T28 (để giai đoạn chức năng).
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/thanh_dieu_huong_duoi_widget.dart';

// MOCK: dữ liệu giả cho MH-18 — thay bằng API contest results (task T28) ở giai đoạn chức năng.
// Xếp hạng theo số câu đúng, bằng nhau thì thời gian ngắn hơn xếp trên
// (Danh và Đỉnh cùng 17/20 — Danh 11:02 hạng 2, Đỉnh 11:40 hạng 3).
// Điểm rank: top 1 +20, hạng 2–3 +10, còn lại +2.
const _mockTop1 = {
  'name': 'Uy',
  'rank': 'Hổ · 1250',
  'correct': 18,
  'time': '10:24',
  'points': 20,
};
const _mockResults = [
  {'rank': 2, 'name': 'Danh', 'correct': 17, 'time': '11:02', 'points': 10},
  {'rank': 3, 'name': 'Đỉnh', 'correct': 17, 'time': '11:40', 'points': 10},
  {'rank': 4, 'name': 'Thịnh', 'correct': 15, 'time': '12:05', 'points': 2},
];

class Mh18KetQuaDotThiScreen extends StatelessWidget {
  const Mh18KetQuaDotThiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả đợt thi')),
      bottomNavigationBar: ThanhDieuHuongDuoi(
        selectedIndex: 2, // Thi đấu — kết quả đợt thi, theo Figma.
        onDestinationSelected: (i) =>
            ThanhDieuHuongDuoi.veShell(context, i),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thẻ Top 1 nổi bật — nền kWarningTint #FFF3E0 (vàng nhạt).
          Card(
            color: kWarningTint,
            shape: _vienThe(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top 1',
                      style: textTheme.titleMedium
                          ?.copyWith(color: kWarning)),
                  const SizedBox(height: 4),
                  Text(
                    '${_mockTop1['name']} — ${_mockTop1['rank']}',
                    style: textTheme.titleMedium
                        ?.copyWith(color: kTextPrimary),
                  ),
                  Text(
                    '${_mockTop1['correct']}/20 câu đúng · ${_mockTop1['time']}',
                    style: const TextStyle(color: kTextPrimary),
                  ),
                  Text('+${_mockTop1['points']} điểm xếp hạng',
                      style: const TextStyle(color: kSuccess)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Bảng xếp hạng đợt',
              style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
          const SizedBox(height: 8),
          ..._mockResults.map((r) {
            final name = r['name'] as String;
            final hang = r['rank'] as int;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              // Dòng của user (hạng 2 — Danh): nền kPrimaryTint #EFECFE.
              color: hang == 2 ? kPrimaryTint : null,
              shape: _vienThe(),
              child: ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$hang.',
                        style: textTheme.titleMedium
                            ?.copyWith(color: kPrimary)),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: _mauAvatar(hang),
                      child: Text(name[0],
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                title: Text(name,
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.w700)),
                subtitle: Text(
                    '${r['correct']}/20 câu đúng · ${r['time']}',
                    style: const TextStyle(color: kTextSecondary)),
                trailing: Text('+${r['points']}',
                    style: textTheme.titleMedium
                        ?.copyWith(color: kSuccess)),
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text(
            'Xếp hạng theo số câu đúng, bằng nhau thì thời gian ngắn hơn xếp trên.',
            style: TextStyle(color: kTextSecondary),
          ),
          const SizedBox(height: 16),
          // Figma: nút tím đặc (không phải nút viền).
          ElevatedButton(
            onPressed: () => ThanhDieuHuongDuoi.veShell(context, 0),
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }
}

/// Viền thẻ theo Figma — kBorder #E9E6F7.
ShapeBorder _vienThe() => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: kBorder),
    );

/// Màu avatar theo hạng (Figma): hạng 2 tím, hạng 3 hồng (màu đáp án A),
/// hạng 4 xanh dương (màu đáp án B).
Color _mauAvatar(int hang) {
  switch (hang) {
    case 3:
      return kOptionColors[0];
    case 4:
      return kOptionColors[1];
    default:
      return kPrimary;
  }
}
