import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/banner_canh_bao_widget.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-21 — Quản lý thành viên (chủ sở hữu chủ đề)
// Luồng: L4 (chủ sở hữu mời thành viên), L5 (trạng thái lời mời)
// Vào từ: MH-06 (chi tiết chủ đề, nút Quản lý thành viên)
// Đi tới: quay lại MH-06
// Dữ liệu giả: _mockThanhVien + _mockLoiMoiCho ngay dưới đây
// Chức năng thật nối ở: UC05–UC07 (mời qua email, hạn mức
//             10 thành viên/chủ đề ở gói miễn phí)
// ============================================================

// MOCK: thanh vien va loi moi cho cua chu de Toan cao cap
const _mockThanhVien = [
  {'ten': 'Ngô Thành Danh', 'email': 'danhngo@example.com', 'ngay': '15/11/2026'},
  {'ten': 'Đỗ Quốc Thịnh', 'email': 'thinhdo@example.com', 'ngay': '15/11/2026'},
  {'ten': 'Trần Văn An', 'email': 'antran@example.com', 'ngay': '17/11/2026'},
];
const _mockLoiMoiCho = ['lehoa@example.com', 'phamtu@example.com'];

class Mh21QuanLyThanhVienScreen extends StatelessWidget {
  const Mh21QuanLyThanhVienScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý thành viên')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Chủ đề: Toán cao cấp',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const Text('Thành viên: 3/10 (gói miễn phí)', style: TextStyle(color: kTextSub)),
          const SizedBox(height: 6),
          const LinearProgressIndicator(value: 0.3, color: kPrimary, minHeight: 8),
          const SizedBox(height: 16),
          const BannerCanhBao(
            text: 'Người được mời sẽ thấy thông báo ở trang chủ và bấm "Tham gia" mới trở thành thành viên.',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mời thành viên qua email', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 10),
                  const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Nhập nhiều email, mỗi email một dòng\nhoặc cách nhau bằng dấu phẩy',
                    ),
                  ),
                  const SizedBox(height: 12),
                  NutChinh(
                    text: 'Gửi lời mời',
                    icon: Icons.mail_rounded,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bản giao diện: chưa gửi lời mời thật.')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Thành viên hiện tại', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          for (final tv in _mockThanhVien)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: kPrimary,
                  child: Icon(Icons.person_rounded, color: Colors.white),
                ),
                title: Text(tv['ten']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${tv['email']} · Tham gia ${tv['ngay']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: kError),
                  onPressed: () {},
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text('Lời mời đang chờ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          for (final email in _mockLoiMoiCho)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.schedule_rounded, color: kWarning),
                title: Text(email),
                subtitle: const Text('Đang chờ người nhận bấm Tham gia'),
                trailing: TextButton(onPressed: () {}, child: const Text('Hủy mời')),
              ),
            ),
        ],
      ),
    );
  }
}
