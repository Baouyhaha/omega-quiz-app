import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../routes.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-25 — Tạo/Sửa bộ đề (chủ sở hữu chủ đề)
// Luồng: L4 (chủ sở hữu tạo nội dung)
// Vào từ: MH-07 (danh sách bộ đề, nút Tạo bộ đề) / MH-08 (Sửa)
// Đi tới: MH-26 (cài đặt bộ đề) sau khi tạo xong phần nội dung
// Bố cục: dựng theo mockup Figma MH-25-tao-sua-bo-de (ô tên bộ đề,
//         2 thẻ chọn cách tạo dạng radio, 3 ô số lượng theo mức độ
//         Dễ 8 / Trung bình 8 / Khó 4, tổng 20 câu, nút Tạo bộ đề
//         dính đáy màn hình)
// Dữ liệu giả: _mockCauHoi ngay dưới đây (chỉ hiện khi chọn
//             Ghép thủ công)
// Chức năng thật nối ở: T20 (tạo bộ đề: ghép thủ công hoặc
//             trích ngẫu nhiên theo mức độ)
// ============================================================

// MOCK: vai cau hoi cua chu de Toan cao cap de ghep thu cong
const _mockCauHoi = [
  {'noiDung': 'Đạo hàm của hàm số f(x) = x² là gì?', 'mucDo': 'Dễ'},
  {'noiDung': 'Giới hạn lim (x→0) sin(x)/x bằng bao nhiêu?', 'mucDo': 'Trung bình'},
  {'noiDung': 'Tích phân ∫(0→1) x·e^x dx bằng bao nhiêu?', 'mucDo': 'Khó'},
  {'noiDung': 'Định thức của ma trận [[1,2],[3,4]] bằng bao nhiêu?', 'mucDo': 'Dễ'},
  {'noiDung': 'Nghiệm của phương trình vi phân y\' = 2y là gì?', 'mucDo': 'Khó'},
];

class Mh25TaoSuaBoDeScreen extends StatefulWidget {
  const Mh25TaoSuaBoDeScreen({super.key});

  @override
  State<Mh25TaoSuaBoDeScreen> createState() => _Mh25TaoSuaBoDeScreenState();
}

class _Mh25TaoSuaBoDeScreenState extends State<Mh25TaoSuaBoDeScreen> {
  // 0: trich ngau nhien, 1: ghep thu cong
  int _cachTao = 0;
  final Set<int> _cauDaChon = {0, 1};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo bộ đề')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Tên bộ đề', style: TextStyle(color: kTextSub)),
                const SizedBox(height: 6),
                const TextField(
                  decoration: InputDecoration(hintText: 'Ví dụ: Giữa kỳ — Đạo hàm'),
                ),
                const SizedBox(height: 18),
                const Text('Cách tạo bộ đề', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                _TheCachTao(
                  dangChon: _cachTao == 0,
                  tieuDe: 'Trích ngẫu nhiên',
                  moTa: 'Rút câu theo mức độ từ kho câu hỏi',
                  onTap: () => setState(() => _cachTao = 0),
                ),
                const SizedBox(height: 10),
                _TheCachTao(
                  dangChon: _cachTao == 1,
                  tieuDe: 'Ghép thủ công',
                  moTa: 'Tự chọn từng câu trong kho',
                  onTap: () => setState(() => _cachTao = 1),
                ),
                const SizedBox(height: 16),
                if (_cachTao == 0) ...[
                  const Row(
                    children: [
                      Expanded(child: _OSoLuong(nhan: 'Dễ', giaTri: '8', mauSo: kSuccess)),
                      SizedBox(width: 10),
                      Expanded(child: _OSoLuong(nhan: 'Trung bình', giaTri: '8', mauSo: Color(0xFFEF8A2A))),
                      SizedBox(width: 10),
                      Expanded(child: _OSoLuong(nhan: 'Khó', giaTri: '4', mauSo: kError)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text('Tổng: 20 câu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Câu hỏi được rút ngẫu nhiên từ kho',
                      style: TextStyle(color: kTextSub),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Chọn câu hỏi (đã chọn ${_cauDaChon.length}/${_mockCauHoi.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < _mockCauHoi.length; i++)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        value: _cauDaChon.contains(i),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _cauDaChon.add(i);
                          } else {
                            _cauDaChon.remove(i);
                          }
                        }),
                        title: Text(_mockCauHoi[i]['noiDung']!),
                        subtitle: Text('Mức độ: ${_mockCauHoi[i]['mucDo']}'),
                      ),
                    ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: NutChinh(
              text: 'Tạo bộ đề',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.mh26),
            ),
          ),
        ],
      ),
    );
  }
}

class _TheCachTao extends StatelessWidget {
  final bool dangChon;
  final String tieuDe;
  final String moTa;
  final VoidCallback onTap;

  const _TheCachTao({
    required this.dangChon,
    required this.tieuDe,
    required this.moTa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dangChon ? kPrimary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: dangChon ? kPrimary : kTextSub, width: 2),
              ),
              alignment: Alignment.center,
              child: dangChon
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tieuDe, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                  Text(moTa, style: const TextStyle(fontSize: 13, color: kTextSub)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OSoLuong extends StatelessWidget {
  final String nhan;
  final String giaTri;
  final Color mauSo;

  const _OSoLuong({required this.nhan, required this.giaTri, required this.mauSo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(nhan, style: const TextStyle(fontSize: 13, color: kTextSub)),
          const SizedBox(height: 4),
          Text(giaTri, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: mauSo)),
        ],
      ),
    );
  }
}
