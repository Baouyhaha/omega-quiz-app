import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../routes.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-25 — Tạo/Sửa bộ đề (chủ sở hữu chủ đề)
// Luồng: L4 (chủ sở hữu tạo nội dung)
// Vào từ: MH-07 (danh sách bộ đề, nút Tạo bộ đề) / MH-08 (Sửa)
// Đi tới: MH-26 (cài đặt bộ đề) sau khi bấm "Tạo bộ đề"
// Bố cục: dựng theo mockup Figma MH-25-tao-sua-bo-de (2 thẻ radio
//         chọn cách tạo; 3 ô số câu Dễ/Trung bình/Khó khi trích
//         ngẫu nhiên; ghép thủ công thì hiện danh sách câu hỏi)
// Dữ liệu giả: _mockCauHoi ngay dưới đây
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
  // 0: trich ngau nhien, 1: ghep thu cong (theo thu tu tren mockup)
  int _cachTao = 0;
  final Set<int> _cauDaChon = {0, 1};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo bộ đề')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tên bộ đề', style: TextStyle(fontSize: 13, color: kTextSub)),
          const SizedBox(height: 6),
          TextFormField(initialValue: 'Giữa kỳ — Đạo hàm'),
          const SizedBox(height: 18),
          const Text('Cách tạo bộ đề', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _TheCachTao(
            giaTri: 0,
            tieuDe: 'Trích ngẫu nhiên',
            moTa: 'Rút câu theo mức độ từ kho câu hỏi',
          ),
          const SizedBox(height: 10),
          _TheCachTao(
            giaTri: 1,
            tieuDe: 'Ghép thủ công',
            moTa: 'Tự chọn từng câu trong kho',
          ),
          const SizedBox(height: 16),
          if (_cachTao == 0) ...[
            Row(
              children: [
                Expanded(child: _OSoLuong(nhan: 'Dễ', giaTri: '8', mau: kSuccess)),
                const SizedBox(width: 10),
                Expanded(child: _OSoLuong(nhan: 'Trung bình', giaTri: '8', mau: kWarning)),
                const SizedBox(width: 10),
                Expanded(child: _OSoLuong(nhan: 'Khó', giaTri: '4', mau: kError)),
              ],
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('Tổng: 20 câu', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text('Câu hỏi được rút ngẫu nhiên từ kho', style: TextStyle(fontSize: 13, color: kTextSub)),
            ),
          ] else ...[
            Text(
              'Chọn câu hỏi (đã chọn ${_cauDaChon.length}/${_mockCauHoi.length})',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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
          const SizedBox(height: 24),
          NutChinh(
            text: 'Tạo bộ đề',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.mh26),
          ),
        ],
      ),
    );
  }

  Widget _TheCachTao({required int giaTri, required String tieuDe, required String moTa}) {
    final dangChon = _cachTao == giaTri;
    return InkWell(
      onTap: () => setState(() => _cachTao = giaTri),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dangChon ? kPrimary : Colors.transparent, width: 1.6),
        ),
        child: Row(
          children: [
            Icon(
              dangChon ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: dangChon ? kPrimary : kTextSub,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tieuDe, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(moTa, style: const TextStyle(fontSize: 13, color: kTextSub)),
              ],
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
  final Color mau;

  const _OSoLuong({required this.nhan, required this.giaTri, required this.mau});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(nhan, style: const TextStyle(fontSize: 13, color: kTextSub)),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: giaTri,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: mau),
            decoration: const InputDecoration(
              filled: false,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
