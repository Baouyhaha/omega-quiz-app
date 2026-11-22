import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-16 — Đối kháng 1-1
// Luồng: L6 (Đối kháng 1-1)
// Vào từ: tab "Thi đấu" của khung điều hướng
// Đi tới: MH-09 (màn thi đấu dùng chung khung MH-09 + panel đối thủ)
// Bố cục: dựng theo mockup Figma MH-16-doi-khang-1-1 — mockup vẽ
//         nối tiếp các trạng thái trên cùng một màn: chọn chủ đề,
//         mã phòng, chờ đối thủ, trạng thái người chơi
// Dữ liệu giả: chủ đề Toán cao cấp, mã phòng X7K2P9 ở dưới đây
// Chức năng thật nối ở: T27 (phòng realtime, rút câu ngẫu nhiên
//             từ kho chủ đề ở máy chủ)
// ============================================================
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
                        SizedBox(height: 4),
                        Text('Toán cao cấp', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(72, 40)),
                    onPressed: () {},
                    child: const Text('Đổi'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          NutChinh(text: 'Tạo phòng', onPressed: () {}),
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
                        SizedBox(height: 4),
                        Text(
                          'X7K2P9',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kPrimary, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(110, 40)),
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
                      Icon(Icons.hourglass_empty_rounded, color: kPrimary, size: 26),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Đang chờ đối thủ...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          SizedBox(height: 2),
                          Text('Chia sẻ mã phòng cho bạn bè', style: TextStyle(fontSize: 13, color: kTextSub)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  NutChinh(text: 'Mời bạn bè', onPressed: () {}),
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
                        radius: 22,
                        backgroundColor: kPrimary,
                        child: Text('U', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Uy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            SizedBox(height: 2),
                            Text('Hổ · 1250 điểm', style: TextStyle(fontSize: 13, color: kTextSub)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kSuccess.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Đã sẵn sàng',
                          style: TextStyle(fontSize: 12.5, color: kSuccess, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Đối thủ đã làm 5/20 câu', style: TextStyle(fontSize: 13, color: kTextSub)),
                  const SizedBox(height: 6),
                  const LinearProgressIndicator(
                    value: 0.25,
                    color: kSuccess,
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Màn thi đấu dùng chung khung MH-09 + panel đối thủ',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: kTextSub),
          ),
        ],
      ),
    );
  }
}
