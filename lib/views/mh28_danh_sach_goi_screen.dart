import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../routes.dart';

// ============================================================
// MH-28 — Danh sách gói thuê
// Luồng: L8 (Gói thuê và vòng đời hết hạn)
// Vào từ: MH-29 (nút Nâng cấp/Gia hạn) / banner ở MH-02, MH-03
// Đi tới: MH-29 sau khi đăng ký thành công (thanh toán mô phỏng)
// Dữ liệu giả: _mockGoi ngay dưới đây — GIÁ CHƯA CHỐT, chỉ là số mẫu
// Chức năng thật nối ở: UC02/UC03 (gói thuê, thanh toán mô phỏng)
// ============================================================

// MOCK: gia goi la so mau, nhom chua chot gia chinh thuc
const _mockGoi = [
  {'ten': 'Dùng thử', 'thoiHan': '7 ngày', 'gia': '0 đ', 'nhan': 'Tự kích hoạt khi đăng ký'},
  {'ten': 'Gói 30 ngày', 'thoiHan': '30 ngày', 'gia': '29.000 đ', 'nhan': ''},
  {'ten': 'Gói 90 ngày', 'thoiHan': '90 ngày', 'gia': '79.000 đ', 'nhan': 'Phổ biến'},
  {'ten': 'Gói 1 năm', 'thoiHan': '365 ngày', 'gia': '249.000 đ', 'nhan': 'Tiết kiệm nhất'},
];

class Mh28DanhSachGoiScreen extends StatelessWidget {
  const Mh28DanhSachGoiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Các gói thuê')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tài khoản thuê bao được bỏ mọi giới hạn. '
            'Thanh toán trong đồ án là mô phỏng, không trừ tiền thật.',
            style: TextStyle(color: kTextSub, height: 1.45),
          ),
          const SizedBox(height: 14),
          for (final goi in _mockGoi) _TheGoi(goi: goi),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('So sánh hạn mức', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 10),
                  _DongSoSanh('Chủ đề tạo được', '1', 'Không giới hạn'),
                  _DongSoSanh('Bộ đề mỗi chủ đề', '2', 'Không giới hạn'),
                  _DongSoSanh('Thành viên mỗi chủ đề', '10', 'Không giới hạn'),
                  _DongSoSanh('Câu hỏi mỗi bộ đề', 'Không giới hạn', 'Không giới hạn'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TheGoi extends StatelessWidget {
  final Map<String, String> goi;

  const _TheGoi({required this.goi});

  @override
  Widget build(BuildContext context) {
    final nhan = goi['nhan']!;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(goi['ten']!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                if (nhan.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(nhan, style: const TextStyle(fontSize: 12, color: kPrimary, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Thời hạn: ${goi['thoiHan']}', style: const TextStyle(color: kTextSub)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(goi['gia']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kPrimary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
                  onPressed: () => _xacNhanMoPhong(context, goi['ten']!),
                  child: const Text('Đăng ký'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _xacNhanMoPhong(BuildContext context, String tenGoi) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thanh toán mô phỏng'),
        content: Text('Đăng ký $tenGoi thành công (mô phỏng).\nGói đã được kích hoạt cho tài khoản của bạn.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, AppRoutes.mh29);
            },
            child: const Text('Xem gói của tôi'),
          ),
        ],
      ),
    );
  }
}

class _DongSoSanh extends StatelessWidget {
  final String chiTieu;
  final String mienPhi;
  final String thueBao;

  const _DongSoSanh(this.chiTieu, this.mienPhi, this.thueBao);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(chiTieu)),
          Expanded(flex: 2, child: Text(mienPhi, style: const TextStyle(color: kTextSub))),
          Expanded(
            flex: 2,
            child: Text(thueBao, style: const TextStyle(fontWeight: FontWeight.w700, color: kPrimary)),
          ),
        ],
      ),
    );
  }
}
