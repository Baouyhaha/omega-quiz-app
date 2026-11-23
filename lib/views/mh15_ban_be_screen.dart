/// MH-15 — Bạn bè.
/// Luồng: L6 (Thi đấu — mời bạn đấu 1-1).
/// Vào từ: MH-16 Đối kháng (Mời bạn bè); điểm vào từ Hồ sơ để nhóm chốt.
/// Đi tiếp tới: MH-16 Đối kháng 1-1 (Đấu 1-1 với bạn đang online),
///   shell đúng tab khi bấm thanh dưới.
/// Thanh dưới tự gắn — sáng tab Thi đấu (bạn bè để mời Đấu 1-1).
/// Dữ liệu giả: khối // MOCK: đầu file này.
/// Chức năng thật: để giai đoạn chức năng.
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/thanh_dieu_huong_duoi_widget.dart';

// MOCK: dữ liệu giả cho MH-15 — thay bằng API friends ở giai đoạn chức năng.
// Chỉ bạn đang online mới có nút "Đấu 1-1" (như Figma).
const _mockRequests = [
  {'name': 'Uy', 'rank': 'Hổ · 1250 điểm'},
];
const _mockFriends = [
  {'name': 'Uy', 'status': 'Đang online', 'online': true},
  {'name': 'Thịnh', 'status': 'Ngoại tuyến', 'online': false},
  {'name': 'Đỉnh', 'status': 'Đang online', 'online': true},
];

// Màu avatar bạn bè theo Figma (không nằm trong dữ liệu MOCK): Uy tím
// chính, Thịnh xanh dương (B), Đỉnh hồng đỏ (A).
// Dùng final thay const: Dart không cho lấy phần tử bằng [] trong biểu
// thức const, kể cả khi danh sách gốc là const.
final _friendAvatarColors = {
  'Uy': kPrimary,
  'Thịnh': kOptionColors[1],
  'Đỉnh': kOptionColors[0],
};

// Viền thẻ/ô nhập theo Figma — kBorder #E9E6F7.
BorderSide get _vienThe =>
    BorderSide(color: kBorder);

class Mh15BanBeScreen extends StatelessWidget {
  const Mh15BanBeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Bạn bè')),
      bottomNavigationBar: ThanhDieuHuongDuoi(
        selectedIndex: 2, // Thi đấu — bạn bè để mời Đấu 1-1.
        onDestinationSelected: (i) =>
            ThanhDieuHuongDuoi.veShell(context, i),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm bạn theo tên/email',
              hintStyle: const TextStyle(color: kTextSecondary),
              prefixIcon: const Icon(Icons.search, color: kTextSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: _vienThe,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Lời mời kết bạn',
              style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
          ..._mockRequests.map((r) {
            final name = r['name']!;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: _vienThe,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: kPrimary,
                        child: Text(name[0],
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(name,
                          style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700)),
                      subtitle: Text(r['rank']!,
                          style: const TextStyle(color: kTextSecondary)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Chấp nhận'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Từ chối'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text('Bạn bè',
              style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
          ..._mockFriends.map((f) {
            final name = f['name'] as String;
            final online = f['online'] as bool;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: _vienThe,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _friendAvatarColors[name] ?? kPrimary,
                  child: Text(name[0],
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(name,
                    style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.w700)),
                subtitle: Text(
                  f['status'] as String,
                  style: TextStyle(
                      color: online ? kSuccess : kTextSecondary),
                ),
                trailing: online
                    ? ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/mh16'),
                        child: const Text('Đấu 1-1'),
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}
