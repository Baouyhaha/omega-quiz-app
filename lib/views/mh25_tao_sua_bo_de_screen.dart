import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../routes.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-25 — Tạo/Sửa bộ đề (chủ sở hữu chủ đề)
// Luồng: L4 (chủ sở hữu tạo nội dung)
// Vào từ: MH-07 (danh sách bộ đề, nút Tạo bộ đề) / MH-08 (Sửa)
// Đi tới: MH-26 (cài đặt bộ đề) sau khi tạo xong phần nội dung
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
  // 0: ghep thu cong, 1: trich ngau nhien
  int _cachTao = 0;
  final Set<int> _cauDaChon = {0, 1};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo bộ đề')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(labelText: 'Tên bộ đề', hintText: 'Ví dụ: Bộ đề ôn tập chương 1'),
          ),
          const SizedBox(height: 12),
          const TextField(
            maxLines: 2,
            decoration: InputDecoration(labelText: 'Mô tả (không bắt buộc)'),
          ),
          const SizedBox(height: 16),
          const Text('Cách tạo bộ đề', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _TheCachTao(0, Icons.checklist_rounded, 'Ghép thủ công', 'Tự chọn từng câu')),
              const SizedBox(width: 10),
              Expanded(child: _TheCachTao(1, Icons.shuffle_rounded, 'Trích ngẫu nhiên', 'Chọn theo mức độ')),
            ],
          ),
          const SizedBox(height: 16),
          if (_cachTao == 0) ...[
            Text(
              'Chọn câu hỏi (đã chọn ${_cauDaChon.length}/${_mockCauHoi.length})',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
          ] else ...[
            const Text('Số câu theo mức độ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(child: _OSoLuong(nhan: 'Dễ', giaTri: '8')),
                SizedBox(width: 10),
                Expanded(child: _OSoLuong(nhan: 'Trung bình', giaTri: '7')),
                SizedBox(width: 10),
                Expanded(child: _OSoLuong(nhan: 'Khó', giaTri: '5')),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Tổng: 20 câu', style: TextStyle(color: kTextSub)),
          ],
          const SizedBox(height: 24),
          NutChinh(
            text: 'Tiếp tục: Cài đặt bộ đề',
            icon: Icons.settings_rounded,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.mh26),
          ),
        ],
      ),
    );
  }

  Widget _TheCachTao(int giaTri, IconData icon, String tieuDe, String moTa) {
    final dangChon = _cachTao == giaTri;
    return InkWell(
      onTap: () => setState(() => _cachTao = giaTri),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dangChon ? kPrimary : Colors.transparent, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: dangChon ? kPrimary : kTextSub),
            const SizedBox(height: 8),
            Text(tieuDe, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(moTa, style: const TextStyle(fontSize: 12, color: kTextSub)),
          ],
        ),
      ),
    );
  }
}

class _OSoLuong extends StatelessWidget {
  final String nhan;
  final String giaTri;

  const _OSoLuong({required this.nhan, required this.giaTri});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: giaTri,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(labelText: nhan),
    );
  }
}
