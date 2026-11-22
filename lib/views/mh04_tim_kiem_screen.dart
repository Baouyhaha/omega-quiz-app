/// MH-04 — Tìm kiếm.
/// Luồng: L2 (Trang chủ — tìm chủ đề/bộ đề để làm bài).
/// Vào từ: MH-02 Trang chủ (ô tìm / nút tìm — điểm vào trên Figma MH-02
///   chưa có, để nhóm chốt).
/// Đi tiếp tới: MH-06 Chi tiết chủ đề, MH-08 Chi tiết bộ đề,
///   shell đúng tab khi bấm thanh dưới.
/// Thanh dưới tự gắn — sáng tab Trang chủ (màn con của luồng Trang chủ).
/// Dữ liệu giả: khối // MOCK: đầu file này.
/// Chức năng thật: để giai đoạn chức năng.
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/thanh_dieu_huong_duoi_widget.dart';

// MOCK: dữ liệu giả cho MH-04 — thay bằng API search ở giai đoạn chức năng.
const _mockBoLoc = ['Tất cả', 'Chủ đề', 'Bộ đề'];
const _mockResults = [
  {'type': 'Chủ đề', 'name': 'Toán cao cấp', 'topic': ''},
  {'type': 'Bộ đề', 'name': 'Giữa kỳ — Đạo hàm', 'topic': 'Toán cao cấp'},
  {'type': 'Chủ đề', 'name': 'Tiếng Anh', 'topic': ''},
];

class Mh04TimKiemScreen extends StatelessWidget {
  const Mh04TimKiemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      bottomNavigationBar: ThanhDieuHuongDuoi(
        selectedIndex: 0, // Trang chủ — màn con của luồng Trang chủ.
        onDestinationSelected: (i) =>
            ThanhDieuHuongDuoi.veShell(context, i),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: kTextPrimary),
              decoration: InputDecoration(
                hintText: 'Tìm chủ đề, bộ đề...',
                hintStyle: const TextStyle(color: kTextSecondary),
                prefixIcon: const Icon(Icons.search, color: kTextSecondary),
                // Viền kBorder #E9E6F7 theo Figma. (Figma không vẽ icon
                // tìm kiếm; màu icon tạm lấy theo màu placeholder.)
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: kBorder, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: kBorder, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: kBorder, width: 1.5),
                ),
              ),
            ),
          ),
          // Bộ lọc kết quả — hiện chọn "Tất cả"; lọc thật ở giai đoạn chức năng.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (var i = 0; i < _mockBoLoc.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    // Màu chip đặt trực tiếp theo Figma, KHÔNG dùng chipTheme
                    // chung (selectedColor tint của theme là sai cho màn này):
                    // chip đang chọn nền tím đặc + chữ trắng, chip chưa chọn
                    // nền kPrimaryTint #EFECFE + chữ tím.
                    child: ChoiceChip(
                      label: Text(_mockBoLoc[i]),
                      labelStyle: TextStyle(
                          color: i == 0 ? Colors.white : kPrimary),
                      selected: i == 0,
                      selectedColor: kPrimary,
                      backgroundColor: kPrimaryTint,
                      showCheckmark: false,
                      side: BorderSide.none,
                      onSelected: (_) {},
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _mockResults.length,
              itemBuilder: (context, i) {
                final r = _mockResults[i];
                final laBoDe = r['type'] == 'Bộ đề';
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side:
                        BorderSide(color: kBorder),
                  ),
                  child: ListTile(
                    title: Text(r['name']!,
                        style: const TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w700)),
                    subtitle: Text(laBoDe ? 'Bộ đề · ${r['topic']}' : 'Chủ đề',
                        style: const TextStyle(color: kTextSecondary)),
                    // Figma không vẽ icon chevron trên thẻ kết quả; màu
                    // icon tạm lấy theo màu chữ phụ.
                    trailing: const Icon(Icons.chevron_right,
                        color: kTextSecondary),
                    onTap: () => Navigator.pushNamed(
                        context, laBoDe ? '/mh08' : '/mh06'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
