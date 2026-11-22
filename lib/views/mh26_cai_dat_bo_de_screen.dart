import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-26 — Cài đặt bộ đề (chủ sở hữu chủ đề)
// Luồng: L4 (chủ sở hữu tạo nội dung)
// Vào từ: MH-25 (nút "Tạo bộ đề") / MH-08 (Cài đặt)
// Đi tới: quay lại MH-08 (chi tiết bộ đề) sau khi lưu
// Bố cục: dựng theo mockup Figma MH-26-cai-dat-bo-de — mỗi cài đặt
//         là một thẻ trắng riêng, nhãn bên trái, giá trị/công tắc
//         bên phải; hàng Mã PIN có nhãn số PIN cạnh công tắc
// Dữ liệu giả: giá trị mẫu điền sẵn trong các hàng dưới đây
// Chức năng thật nối ở: T20 (lưu settings dạng map trong exams)
// ============================================================
class Mh26CaiDatBoDeScreen extends StatefulWidget {
  const Mh26CaiDatBoDeScreen({super.key});

  @override
  State<Mh26CaiDatBoDeScreen> createState() => _Mh26CaiDatBoDeScreenState();
}

class _Mh26CaiDatBoDeScreenState extends State<Mh26CaiDatBoDeScreen> {
  bool _batPin = true;
  bool _xaoTronCau = true;
  bool _xaoTronDapAn = true;
  bool _choTroGiup = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt bộ đề')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _HangGiaTri(nhan: 'Khung giờ mở', giaTri: '21/11 08:00'),
          const _HangGiaTri(nhan: 'Khung giờ đóng', giaTri: '21/11 18:00'),
          const _HangGiaTri(nhan: 'Thời gian làm', giaTri: '30 phút'),
          const _HangGiaTri(nhan: 'Số lần làm tối đa', giaTri: '3'),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: const Text('Mã PIN', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_batPin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '1234',
                        style: TextStyle(color: kPrimary, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                      ),
                    ),
                  const SizedBox(width: 6),
                  Switch(
                    value: _batPin,
                    onChanged: (v) => setState(() => _batPin = v),
                  ),
                ],
              ),
            ),
          ),
          _HangCongTac(
            nhan: 'Xáo trộn câu hỏi',
            giaTri: _xaoTronCau,
            onChanged: (v) => setState(() => _xaoTronCau = v),
          ),
          _HangCongTac(
            nhan: 'Xáo trộn đáp án',
            giaTri: _xaoTronDapAn,
            onChanged: (v) => setState(() => _xaoTronDapAn = v),
          ),
          _HangCongTac(
            nhan: 'Cho phép trợ giúp',
            giaTri: _choTroGiup,
            onChanged: (v) => setState(() => _choTroGiup = v),
          ),
          const _HangGiaTri(nhan: 'Hiện đáp án', giaTri: 'Sau khi nộp'),
          const _HangGiaTri(nhan: 'Công bố điểm', giaTri: 'Ngay sau khi nộp'),
          const SizedBox(height: 14),
          NutChinh(
            text: 'Lưu cài đặt',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu cài đặt (bản giao diện, chưa lưu thật).')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _HangGiaTri extends StatelessWidget {
  final String nhan;
  final String giaTri;

  const _HangGiaTri({required this.nhan, required this.giaTri});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(nhan, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(giaTri, style: const TextStyle(fontSize: 14.5, color: kTextSub)),
      ),
    );
  }
}

class _HangCongTac extends StatelessWidget {
  final String nhan;
  final bool giaTri;
  final ValueChanged<bool> onChanged;

  const _HangCongTac({required this.nhan, required this.giaTri, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: SwitchListTile(
        title: Text(nhan, style: const TextStyle(fontWeight: FontWeight.w600)),
        value: giaTri,
        onChanged: onChanged,
      ),
    );
  }
}
