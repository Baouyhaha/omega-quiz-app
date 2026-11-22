import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../routes.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-29 — Gói của tôi
// Luồng: L8 (Gói thuê và vòng đời hết hạn)
// Vào từ: MH-03 (nút Xem gói) / sau khi đăng ký ở MH-28
// Đi tới: MH-28 (nút Gia hạn ngay)
// Bố cục: dựng theo mockup Figma MH-29-goi-cua-toi — thẻ gói hiện
//         tại, banner cảnh báo hết hạn, thẻ quyền lợi thuê bao
// Dữ liệu giả: khối _mockGoiCuaToi ngay dưới đây
// Chức năng thật nối ở: UC02 (trạng thái gói), vòng đời hết hạn:
//             cảnh báo 7 ngày, hết hạn thì chủ đề riêng tư bị xóa,
//             chủ đề công khai chuyển sang chỉ-đọc
// ============================================================

// MOCK: trang thai goi hien tai
const _mockGoiCuaToi = {
  'tenGoi': 'Gói dùng thử',
  'ngayHetHan': '28/11/2026',
  'conLaiNgay': 7,
};
const _mockQuyenLoi = [
  'Bỏ mọi hạn mức',
  'Tạo không giới hạn chủ đề',
  'Thêm thành viên không giới hạn',
];

class Mh29GoiCuaToiScreen extends StatelessWidget {
  const Mh29GoiCuaToiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gói của tôi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _mockGoiCuaToi['tenGoi'] as String,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Đang dùng',
                          style: TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hết hạn: ${_mockGoiCuaToi['ngayHetHan']}',
                    style: const TextStyle(color: kTextSub),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Còn ${_mockGoiCuaToi['conLaiNgay']} ngày',
                    style: const TextStyle(color: kSuccess, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kWarning.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: kWarning,
                  child: Icon(Icons.priority_high_rounded, size: 16, color: Colors.white),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Còn ≤7 ngày — gia hạn ngay để\n',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        TextSpan(text: 'không mất dữ liệu chủ đề private'),
                      ],
                    ),
                    style: TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Quyền lợi gói thuê bao', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (final ql in _mockQuyenLoi)
                    ListTile(
                      leading: const CircleAvatar(
                        radius: 13,
                        backgroundColor: kSuccess,
                        child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      ),
                      title: Text(ql),
                      dense: true,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          NutChinh(
            text: 'Gia hạn ngay',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.mh28),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hết hạn: 7 ngày cảnh báo, sau đó chủ đề\nprivate bị xóa, public chuyển chỉ-đọc.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kTextSub, height: 1.45),
          ),
        ],
      ),
    );
  }
}
