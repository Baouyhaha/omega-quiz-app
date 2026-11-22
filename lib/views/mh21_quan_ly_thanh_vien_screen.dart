import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-21 — Quản lý thành viên (chủ sở hữu chủ đề)
// Luồng: L4 (chủ sở hữu mời thành viên), L5 (trạng thái lời mời)
// Vào từ: MH-06 (chi tiết chủ đề, nút Quản lý thành viên)
// Đi tới: quay lại MH-06
// Bố cục: dựng theo mockup Figma MH-21-quan-ly-thanh-vien
// Dữ liệu giả: _mockThanhVien + _mockLoiMoiCho ngay dưới đây
// Chức năng thật nối ở: UC05–UC07 (mời qua email, hạn mức
//             10 thành viên/chủ đề ở gói miễn phí)
// ============================================================

// MOCK: thanh vien va loi moi cho cua chu de Toan cao cap
const _mockThanhVien = [
  {'ten': 'Uy', 'chuCai': 'U', 'ngay': '19/11', 'mau': kPrimary},
  {'ten': 'Thịnh', 'chuCai': 'T', 'ngay': '20/11', 'mau': Color(0xFF118AB2)},
];
const _mockLoiMoiCho = ['dinh@example.com'];

class Mh21QuanLyThanhVienScreen extends StatelessWidget {
  const Mh21QuanLyThanhVienScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thành viên — Toán cao cấp')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Mời thành viên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const TextField(
            maxLines: 2,
            decoration: InputDecoration(hintText: 'Nhập email, mỗi email một dòng'),
          ),
          const SizedBox(height: 12),
          NutChinh(
            text: 'Gửi lời mời',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bản giao diện: chưa gửi lời mời thật.')),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Miễn phí: tối đa 10 thành viên/chủ đề',
            style: TextStyle(fontSize: 13, color: kTextSub),
          ),
          const SizedBox(height: 18),
          Text(
            'Đã tham gia (${_mockThanhVien.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (final tv in _mockThanhVien)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tv['mau'] as Color,
                  child: Text(
                    tv['chuCai'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
                title: Text(tv['ten'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('Tham gia ${tv['ngay']}'),
                trailing: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kError,
                    side: const BorderSide(color: kError),
                    minimumSize: const Size(64, 36),
                  ),
                  onPressed: () {},
                  child: const Text('Xóa'),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            'Lời mời đang chờ (${_mockLoiMoiCho.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (final email in _mockLoiMoiCho)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(email, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kWarning.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Đang chờ',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFFB97E0B), fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
