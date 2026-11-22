import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../routes.dart';
import '../widgets/banner_canh_bao_widget.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-29 — Gói của tôi
// Luồng: L8 (Gói thuê và vòng đời hết hạn)
// Vào từ: MH-03 (nút Xem gói) / sau khi đăng ký ở MH-28
// Đi tới: MH-28 (nút Gia hạn ngay)
// Bố cục: dựng theo mockup Figma MH-29-goi-cua-toi (thẻ gói đang
//         dùng, banner cảnh báo còn ≤ 7 ngày, danh sách quyền lợi
//         gói thuê bao, nút Gia hạn ngay, ghi chú vòng đời hết hạn)
// Dữ liệu giả: _mockGoiCuaToi ngay dưới đây
// Chức năng thật nối ở: UC02 (trạng thái gói), vòng đời hết hạn:
//             cảnh báo 7 ngày, hết hạn thì chủ đề riêng tư bị xóa,
//             chủ đề công khai chuyển sang chỉ-đọc
// ============================================================

// MOCK: trang thai goi theo mockup Figma
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Đang dùng', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hết hạn: ${_mockGoiCuaToi['ngayHetHan']}',
                    style: const TextStyle(color: kTextSub),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Còn ${_mockGoiCuaToi['conLaiNgay']} ngày',
                    style: const TextStyle(color: kSuccess, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const BannerCanhBao(
            text: 'Còn ≤ 7 ngày — gia hạn ngay để không mất dữ liệu chủ đề private',
          ),
          const SizedBox(height: 16),
          const Text('Quyền lợi gói thuê bao', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (final ql in _mockQuyenLoi)
                    ListTile(
                      leading: const Icon(Icons.check_circle_rounded, color: kSuccess),
                      title: Text(ql, style: const TextStyle(fontWeight: FontWeight.w600)),
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
          const SizedBox(height: 14),
          const Text(
            'Hết hạn: 7 ngày cảnh báo, sau đó chủ đề private bị xóa, public chuyển chỉ-đọc.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextSub, fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }
}
