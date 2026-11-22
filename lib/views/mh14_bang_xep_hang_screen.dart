/// MH-14 — Bảng xếp hạng.
/// Luồng: L7 (Xếp hạng).
/// Vào từ: thanh dưới mục Xếp hạng.
/// Đi tiếp tới: MH-03 Hồ sơ (bấm vào 1 người — để giai đoạn chức năng).
/// Thanh dưới do shell (khung điều hướng) cấp — màn này không tự gắn nav.
/// Dữ liệu giả: khối // MOCK: đầu file này.
/// Chức năng thật: nối ở task T23 (để giai đoạn chức năng).
import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// MOCK: dữ liệu giả cho MH-14 — thay bằng API leaderboard (task T23) ở giai đoạn chức năng.
// Hạng thú theo thang ELO chuẩn E2: Mèo 900–999, Chó 1000–1099,
// Heo 1100–1199, Hổ 1200–1349. Tab 2 là "Chủ đề" (BXH trong 1 chủ đề,
// UC22) — không có tab "Bạn bè".
const _mockTop3 = [
  {'rank': 2, 'name': 'Đỉnh', 'animal': 'Heo', 'elo': 1100, 'isMe': false},
  {'rank': 1, 'name': 'Uy', 'animal': 'Hổ', 'elo': 1250, 'isMe': false},
  {'rank': 3, 'name': 'Danh', 'animal': 'Chó', 'elo': 1000, 'isMe': true},
];
const _mockRank4To7 = [
  {'rank': 4, 'name': 'Thịnh', 'animal': 'Mèo', 'elo': 980},
  {'rank': 5, 'name': 'An', 'animal': 'Mèo', 'elo': 950},
  {'rank': 6, 'name': 'Bình', 'animal': 'Mèo', 'elo': 920},
  {'rank': 7, 'name': 'Chi', 'animal': 'Mèo', 'elo': 900},
];

// Màu avatar hạng 4–7 theo Figma: Thịnh xanh dương (B), An xanh lá (D),
// Bình tím đậm, Chi hồng đỏ (A).
// Dùng final thay const: Dart không cho lấy phần tử bằng [] trong biểu
// thức const, kể cả khi danh sách gốc là const.
final _rank4To7AvatarColors = [
  kOptionColors[1],
  kOptionColors[3],
  kPrimaryDark,
  kOptionColors[0],
];

// Viền thẻ theo Figma — kBorder #E9E6F7.
BorderSide get _vienThe =>
    BorderSide(color: kBorder);

class Mh14BangXepHangScreen extends StatefulWidget {
  const Mh14BangXepHangScreen({super.key});

  @override
  State<Mh14BangXepHangScreen> createState() =>
      _Mh14BangXepHangScreenState();
}

class _Mh14BangXepHangScreenState extends State<Mh14BangXepHangScreen> {
  // 0 = Toàn hệ thống, 1 = Chủ đề.
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bảng xếp hạng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                _ChipLoc(
                  label: 'Toàn hệ thống',
                  selected: _selectedFilter == 0,
                  onSelected: (_) => setState(() => _selectedFilter = 0),
                ),
                const SizedBox(width: 8),
                _ChipLoc(
                  label: 'Chủ đề',
                  selected: _selectedFilter == 1,
                  onSelected: (_) => setState(() => _selectedFilter = 1),
                ),
              ],
            ),
          ),
          // Tab Chủ đề hiện dùng chung dữ liệu giả; dữ liệu thật theo
          // từng chủ đề nối ở giai đoạn chức năng (task T23).
          const Expanded(child: _BangXepHang()),
        ],
      ),
    );
  }
}

/// Chip lọc "Toàn hệ thống / Chủ đề" theo Figma: chip đang chọn nền tím
/// đặc + chữ trắng, chip chưa chọn nền tím nhạt + chữ xám tím. Màu đặt
/// trực tiếp trên từng chip, không dùng chipTheme chung (selectedColor
/// tint trong theme là sai cho màn này).
class _ChipLoc extends StatelessWidget {
  const _ChipLoc({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      side: BorderSide.none,
      // Nền chip chưa chọn theo Figma #F0EEF9 — dùng kPrimaryTint
      // #EFECFE (lệch ≤5/kênh, mắt thường không phân biệt được).
      backgroundColor: kPrimaryTint,
      selectedColor: kPrimary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : kTextSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Nội dung 1 tab BXH: bục top 3 + danh sách hạng 4–7.
class _BangXepHang extends StatelessWidget {
  const _BangXepHang();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Top 3',
            style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: _vienThe,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final e in _mockTop3)
                  Expanded(child: _BucTop3(entry: e)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Hạng 4–7',
            style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
        const SizedBox(height: 8),
        for (var i = 0; i < _mockRank4To7.length; i++)
          _HangBxh(
            entry: _mockRank4To7[i],
            avatarColor: _rank4To7AvatarColors[i],
          ),
      ],
    );
  }
}

/// 1 cột trên bục top 3: hạng, avatar chữ cái, tên, hạng thú · điểm.
/// Hạng 1 ở giữa, avatar to hơn; cột của mình có nhãn "Bạn".
class _BucTop3 extends StatelessWidget {
  const _BucTop3({required this.entry});

  final Map<String, Object> entry;

  @override
  Widget build(BuildContext context) {
    final rank = entry['rank'] as int;
    final name = entry['name'] as String;
    final isMe = entry['isMe'] as bool;
    final isTop1 = rank == 1;
    // Màu avatar theo Figma: hạng 1 vàng cam (kWarning), hạng 2 xanh
    // dương (B), hạng 3 tím chính. Số hạng: hạng 1 vàng cam, hạng 2–3 tím.
    final avatarColor =
        isTop1 ? kWarning : rank == 2 ? kOptionColors[1] : kPrimary;
    final rankColor = isTop1 ? kWarning : kPrimary;
    final textTheme = Theme.of(context).textTheme;
    final column = Column(
      children: [
        if (isMe)
          const Chip(
            label: Text('Bạn',
                style: TextStyle(color: Colors.white)),
            backgroundColor: kPrimary,
            side: BorderSide.none,
          ),
        Text('$rank',
            style: textTheme.titleLarge?.copyWith(color: rankColor)),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: isTop1 ? 28 : 22,
          backgroundColor: avatarColor,
          child: Text(name[0],
              style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(name,
            style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
        Text('${entry['animal']} · ${entry['elo']}',
            style: const TextStyle(color: kTextSecondary)),
      ],
    );
    if (!isMe) return column;
    // Cột của mình có nền kPrimaryTint #EFECFE theo Figma.
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryTint,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: column,
    );
  }
}

/// 1 hàng hạng 4–7: số hạng, avatar chữ cái, tên + hạng thú, điểm.
class _HangBxh extends StatelessWidget {
  const _HangBxh({required this.entry, required this.avatarColor});

  final Map<String, Object> entry;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    final name = entry['name'] as String;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: _vienThe,
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${entry['rank']}',
                style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: avatarColor,
              child: Text(name[0],
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        title: Text(name, style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700)),
        subtitle: Text('Hạng ${entry['animal']}',
            style: const TextStyle(color: kTextSecondary)),
        trailing: Text('${entry['elo']} điểm',
            style: textTheme.titleMedium?.copyWith(color: kPrimary)),
      ),
    );
  }
}
