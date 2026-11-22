import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../routes.dart';
import '../widgets/banner_canh_bao_widget.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-29 — Gói của tôi
// Luồng: L8 (Gói thuê và vòng đời hết hạn)
// Vào từ: MH-03 (mục Gói của tôi) / sau khi đăng ký ở MH-28
// Đi tới: MH-28 (nâng cấp/gia hạn)
// Dữ liệu giả: _mockGoiCuaToi ngay dưới đây
// Chức năng thật nối ở: UC02 (trạng thái gói), vòng đời hết hạn:
//             cảnh báo 7 ngày, hết hạn thì chủ đề riêng tư bị xóa,
//             chủ đề công khai chuyển sang chỉ-đọc
// ============================================================

// MOCK: trang thai goi va han muc da dung
const _mockGoiCuaToi = {
  'tenGoi': 'Dùng thử',
  'ngayHetHan': '27/11/2026',
  'conLaiNgay': 5,
};
const _mockHanMuc = [
  {'nhan': 'Chủ đề', 'daDung': 1, 'toiDa': 1},
  {'nhan': 'Bộ đề (chủ đề Toán cao cấp)', 'daDung': 2, 'toiDa': 2},
  {'nhan': 'Thành viên (chủ đề Toán cao cấp)', 'daDung': 3, 'toiDa': 10},
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
                      const Icon(Icons.workspace_premium_rounded, color: kPrimary, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        _mockGoiCuaToi['tenGoi'] as String,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hết hạn ngày ${_mockGoiCuaToi['ngayHetHan']} · Còn ${_mockGoiCuaToi['conLaiNgay']} ngày',
                    style: const TextStyle(color: kTextSub),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          BannerCanhBao(
            text: 'Gói sắp hết hạn. Khi hết hạn, chủ đề riêng tư sẽ bị xóa dữ liệu, '
                'chủ đề công khai chuyển sang chế độ chỉ-đọc.',
            actionText: 'Gia hạn',
            onAction: () => Navigator.pushNamed(context, AppRoutes.mh28),
          ),
          const SizedBox(height: 16),
          const Text('Hạn mức đã dùng', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          for (final hm in _mockHanMuc)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(hm['nhan'] as String, style: const TextStyle(fontWeight: FontWeight.w600))),
                        Text('${hm['daDung']}/${hm['toiDa']}', style: const TextStyle(color: kTextSub)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (hm['daDung'] as int) / (hm['toiDa'] as int),
                      color: (hm['daDung'] as int) >= (hm['toiDa'] as int) ? kError : kPrimary,
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          NutChinh(
            text: 'Nâng cấp / Gia hạn gói',
            icon: Icons.upgrade_rounded,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.mh28),
          ),
          const SizedBox(height: 16),
          const Text('Lịch sử gói', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.history_rounded, color: kTextSub),
              title: Text('Kích hoạt gói Dùng thử'),
              subtitle: Text('20/11/2026 · Tự kích hoạt khi đăng nhập lần đầu'),
            ),
          ),
        ],
      ),
    );
  }
}
