import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-16 — Đối kháng 1-1
// Luồng: L6 (Đối kháng 1-1)
// Vào từ: màn đợt thi MH-17 (tab Thi đấu), bấm vào mục đối kháng
//         — KHÔNG phải màn gốc của tab Thi đấu
// Đi tới: MH-09 (màn thi đấu dùng chung khung làm bài + panel đối thủ)
// Bố cục: dựng theo mockup Figma MH-16-doi-khang-1-1 (thẻ chủ đề đã
//         chọn, nút Tạo phòng, thẻ mã phòng, thẻ chờ đối thủ,
//         thẻ người chơi có tiến trình đối thủ)
// Dữ liệu giả: khối _mockPhong ngay dưới đây
// Chức năng thật nối ở: T27 (phòng realtime, rút câu ngẫu nhiên
//             từ kho chủ đề ở máy chủ)
// ============================================================

// MOCK: phong doi khang mau
const _mockPhong = {
  'chuDe': 'Toán cao cấp',
  'maPhong': 'X7K2P9',
  'tenNguoiChoi': 'Uy',
  'hang': 'Ngựa',
  'diemRank': 1240,
  'cauDoiThuDaLam': 5,
  'tongCau': 20,
};

class Mh16DoiKhangScreen extends StatelessWidget {
  const Mh16DoiKhangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đối kháng 1-1')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chủ đề đã chọn', style: TextStyle(fontSize: 13, color: kTextSub)),
                        SizedBox(height: 2),
                        Text('Toán cao cấp', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(64, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: () {},
                    child: const Text('Đổi'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          NutChinh(
            text: 'Tạo phòng',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bản giao diện: phòng đã tạo, mã X7K2P9.')),
              );
            },
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mã phòng', style: TextStyle(fontSize: 13, color: kTextSub)),
                        SizedBox(height: 2),
                        Text(
                          'X7K2P9',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kPrimary, letterSpacing: 2),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(64, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: () {},
                    child: const Text('Chia sẻ mã'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: CircularProgressIndicator(color: kPrimary, strokeWidth: 3),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Đang chờ đối thủ…', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            SizedBox(height: 2),
                            Text('Chia sẻ mã phòng cho bạn bè', style: TextStyle(color: kTextSub)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  NutChinh(
                    text: 'Mời bạn bè',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: kPrimary,
                        child: Text('U', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Uy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            Text('Ngựa · 1240 điểm', style: TextStyle(color: kTextSub)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kSuccess.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Đã sẵn sàng', style: TextStyle(color: kSuccess, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Đối thủ đã làm ${_mockPhong['cauDoiThuDaLam']}/${_mockPhong['tongCau']} câu',
                    style: const TextStyle(color: kTextSub),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_mockPhong['cauDoiThuDaLam'] as int) / (_mockPhong['tongCau'] as int),
                    color: kSuccess,
                    backgroundColor: const Color(0xFFE7E3F5),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Màn thi đấu dùng chung khung MH-09 + panel đối thủ',
            style: TextStyle(color: kTextSub, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
