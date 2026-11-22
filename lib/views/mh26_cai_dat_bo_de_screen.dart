import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-26 — Cài đặt bộ đề (chủ sở hữu chủ đề)
// Luồng: L4 (chủ sở hữu tạo nội dung)
// Vào từ: MH-25 (nút "Tạo bộ đề") / MH-08 (Cài đặt)
// Đi tới: quay lại MH-08 (chi tiết bộ đề) sau khi lưu
// Bố cục: dựng theo mockup Figma MH-26-cai-dat-bo-de (các hàng
//         cài đặt dạng thẻ trắng: nhãn trái, giá trị phải; 4 hàng
//         công tắc; hàng Mã PIN có chip 1234; nút Lưu cài đặt
//         dính đáy màn hình)
// Dữ liệu giả: giá trị mẫu hiển thị trong từng hàng dưới đây
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HangGiaTri(nhan: 'Khung giờ mở', giaTri: '21/11 08:00'),
                _HangGiaTri(nhan: 'Khung giờ đóng', giaTri: '21/11 18:00'),
                _HangGiaTri(nhan: 'Thời gian làm', giaTri: '30 phút'),
                _HangGiaTri(nhan: 'Số lần làm tối đa', giaTri: '3'),
                _HangCongTac(
                  nhan: 'Mã PIN',
                  giaTriPhu: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('1234', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w800)),
                  ),
                  bat: _batPin,
                  onChanged: (v) => setState(() => _batPin = v),
                ),
                _HangCongTac(
                  nhan: 'Xáo trộn câu hỏi',
                  bat: _xaoTronCau,
                  onChanged: (v) => setState(() => _xaoTronCau = v),
                ),
                _HangCongTac(
                  nhan: 'Xáo trộn đáp án',
                  bat: _xaoTronDapAn,
                  onChanged: (v) => setState(() => _xaoTronDapAn = v),
                ),
                _HangCongTac(
                  nhan: 'Cho phép trợ giúp',
                  bat: _choTroGiup,
                  onChanged: (v) => setState(() => _choTroGiup = v),
                ),
                _HangGiaTri(nhan: 'Hiện đáp án', giaTri: 'Sau khi nộp'),
                _HangGiaTri(nhan: 'Công bố điểm', giaTri: 'Ngay sau khi nộp'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: NutChinh(
              text: 'Lưu cài đặt',
              icon: Icons.save_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã lưu cài đặt (bản giao diện, chưa lưu thật).')),
                );
                Navigator.pop(context);
              },
            ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(nhan, style: const TextStyle(fontSize: 15.5))),
            Text(giaTri, style: const TextStyle(color: kTextSub, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _HangCongTac extends StatelessWidget {
  final String nhan;
  final Widget? giaTriPhu;
  final bool bat;
  final ValueChanged<bool> onChanged;

  const _HangCongTac({
    required this.nhan,
    this.giaTriPhu,
    required this.bat,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(nhan, style: const TextStyle(fontSize: 15.5))),
            if (giaTriPhu != null) ...[giaTriPhu!, const SizedBox(width: 10)],
            Switch(value: bat, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
