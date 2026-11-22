import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../routes.dart';

// ============================================================
// MH-28 — Danh sách gói thuê
// Luồng: L8 (Gói thuê và vòng đời hết hạn)
// Vào từ: MH-29 (nút Gia hạn ngay) / MH-03 (nút Xem gói)
// Đi tới: MH-29 sau khi đăng ký thành công (thanh toán mô phỏng)
// Bố cục: dựng theo mockup Figma MH-28-danh-sach-goi — thẻ gói
//         đang chọn có viền tím, nút đăng ký ở cuối đổi theo gói
//         đang chọn, bảng so sánh hạn mức ở dưới
// Dữ liệu giả: _mockGoi ngay dưới đây (giá lấy theo mockup Figma)
// Chức năng thật nối ở: UC02/UC03 (gói thuê, thanh toán mô phỏng)
// ============================================================

// MOCK: cac goi thue, gia theo mockup Figma cua Danh
const _mockGoi = [
  {'ten': 'Dùng thử 7 ngày', 'moTa': 'Miễn phí — bỏ mọi hạn mức trong 7 ngày', 'gia': '', 'nhan': 'Đang dùng'},
  {'ten': '30 ngày', 'moTa': 'Gói thuê bao 30 ngày', 'gia': '49.000đ', 'nhan': ''},
  {'ten': '90 ngày', 'moTa': 'Tiết kiệm 18.000đ so với gói 30 ngày', 'gia': '129.000đ', 'nhan': 'Phổ biến nhất'},
  {'ten': '365 ngày', 'moTa': 'Gói thuê bao 1 năm', 'gia': '449.000đ', 'nhan': ''},
];

class Mh28DanhSachGoiScreen extends StatefulWidget {
  const Mh28DanhSachGoiScreen({super.key});

  @override
  State<Mh28DanhSachGoiScreen> createState() => _Mh28DanhSachGoiScreenState();
}

class _Mh28DanhSachGoiScreenState extends State<Mh28DanhSachGoiScreen> {
  int _goiChon = 2; // mac dinh chon goi 90 ngay nhu mockup

  @override
  Widget build(BuildContext context) {
    final goi = _mockGoi[_goiChon];
    return Scaffold(
      appBar: AppBar(title: const Text('Gói thuê')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < _mockGoi.length; i++)
            _TheGoi(
              goi: _mockGoi[i],
              dangChon: _goiChon == i,
              onTap: () => setState(() => _goiChon = i),
            ),
          const SizedBox(height: 8),
          const Text('So sánh hạn mức', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 3, child: Text('Hạn mức', style: TextStyle(color: kTextSub, fontSize: 13))),
                      Expanded(flex: 2, child: Text('Miễn phí', style: TextStyle(color: kTextSub, fontSize: 13))),
                      Expanded(
                        flex: 3,
                        child: Text('Thuê bao', style: TextStyle(color: kPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  Divider(height: 20),
                  _DongSoSanh('Chủ đề', '1'),
                  _DongSoSanh('Bộ đề/chủ đề', '2'),
                  _DongSoSanh('Thành viên/chủ đề', '10'),
                  _DongSoSanh('Câu hỏi', 'Không giới hạn'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _goiChon == 0 ? null : () => _xacNhanMoPhong(context, goi['ten']!),
            child: Text(_goiChon == 0 ? 'Đang dùng gói dùng thử' : 'Đăng ký gói ${goi['ten']}'),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Thanh toán mô phỏng — không trừ tiền thật',
              style: TextStyle(fontSize: 13, color: kTextSub),
            ),
          ),
        ],
      ),
    );
  }

  void _xacNhanMoPhong(BuildContext context, String tenGoi) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thanh toán mô phỏng'),
        content: Text('Đăng ký gói $tenGoi thành công (mô phỏng).\nGói đã được kích hoạt cho tài khoản của bạn.'),
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

class _TheGoi extends StatelessWidget {
  final Map<String, String> goi;
  final bool dangChon;
  final VoidCallback onTap;

  const _TheGoi({required this.goi, required this.dangChon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nhan = goi['nhan']!;
    final laPhoBien = nhan == 'Phổ biến nhất';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: dangChon ? kPrimary : Colors.transparent, width: 1.6),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(goi['ten']!, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
                  ),
                  if (nhan.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: laPhoBien ? kWarning : kPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        nhan,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: laPhoBien ? Colors.white : kPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(goi['moTa']!, style: const TextStyle(fontSize: 13, color: kTextSub)),
                  ),
                  if (goi['gia']!.isNotEmpty)
                    Text(
                      goi['gia']!,
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, color: kPrimary),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DongSoSanh extends StatelessWidget {
  final String chiTieu;
  final String mienPhi;

  const _DongSoSanh(this.chiTieu, this.mienPhi);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(chiTieu)),
          Expanded(flex: 2, child: Text(mienPhi, style: const TextStyle(color: kTextSub))),
          const Expanded(
            flex: 3,
            child: Text('Không giới hạn', style: TextStyle(color: kSuccess, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
