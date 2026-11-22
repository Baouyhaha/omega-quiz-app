import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../routes.dart';

// ============================================================
// MH-28 — Danh sách gói thuê
// Luồng: L8 (Gói thuê và vòng đời hết hạn)
// Vào từ: MH-29 (nút Gia hạn/Nâng cấp) / banner ở MH-02, MH-03
// Đi tới: MH-29 sau khi đăng ký thành công (thanh toán mô phỏng)
// Bố cục: dựng theo mockup Figma MH-28-danh-sach-goi (4 thẻ gói,
//         thẻ 90 ngày có nhãn "Phổ biến nhất", bảng so sánh hạn mức,
//         nút đăng ký theo gói đã chọn dính đáy, ghi chú mô phỏng)
// Giá gói: theo đúng mockup Figma (30 ngày 49.000đ, 90 ngày
//         129.000đ, 365 ngày 449.000đ) — giá chính thức do nhóm chốt
// Chức năng thật nối ở: UC02/UC03 (gói thuê, thanh toán mô phỏng)
// ============================================================

// MOCK: gia goi theo mockup Figma
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
  int _goiDaChon = 2; // mac dinh chon goi 90 ngay theo mockup

  @override
  Widget build(BuildContext context) {
    final goi = _mockGoi[_goiDaChon];
    return Scaffold(
      appBar: AppBar(title: const Text('Gói thuê')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              children: [
                for (var i = 0; i < _mockGoi.length; i++) _TheGoi(
                  goi: _mockGoi[i],
                  dangDung: i == 0,
                  onTap: () => setState(() => _goiDaChon = i),
                ),
                const SizedBox(height: 6),
                const Text('So sánh hạn mức', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(flex: 3, child: Text('Hạn mức', style: TextStyle(color: kTextSub))),
                            const Expanded(flex: 2, child: Text('Miễn phí', style: TextStyle(color: kTextSub))),
                            Expanded(
                              flex: 2,
                              child: Text('Thuê bao', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _DongSoSanh('Chủ đề', '1', 'Không giới hạn'),
                        _DongSoSanh('Bộ đề/chủ đề', '2', 'Không giới hạn'),
                        _DongSoSanh('Thành viên/chủ đề', '10', 'Không giới hạn'),
                        _DongSoSanh('Câu hỏi', 'Không giới hạn', 'Không giới hạn'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goiDaChon == 0
                        ? null
                        : () => _xacNhanMoPhong(context, goi['ten']!),
                    child: Text(_goiDaChon == 0 ? 'Đang dùng gói này' : 'Đăng ký gói ${goi['ten']}'),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Thanh toán mô phỏng — không trừ tiền thật',
                  style: TextStyle(color: kTextSub, fontSize: 13),
                ),
                const SizedBox(height: 10),
              ],
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
  final bool dangDung;
  final VoidCallback onTap;

  const _TheGoi({required this.goi, required this.dangDung, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nhan = goi['nhan']!;
    final card = Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: dangDung ? kPrimary : Colors.transparent, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goi['ten']!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(goi['moTa']!, style: const TextStyle(color: kTextSub, fontSize: 13.5)),
                  ],
                ),
              ),
              if (dangDung)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Đang dùng', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
                )
              else
                Text(
                  goi['gia']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kPrimary),
                ),
            ],
          ),
        ),
      ),
    );
    if (nhan == 'Phổ biến nhất') {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            card,
            Positioned(
              top: -10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kTextMain,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Phổ biến nhất', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );
    }
    return card;
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
            child: Text(thueBao, style: const TextStyle(fontWeight: FontWeight.w700, color: kSuccess)),
          ),
        ],
      ),
    );
  }
}
