import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../services/api_client.dart';
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
// Nút "Xóa bộ đề" ở cuối danh sách (chốt bổ sung 28/11/2026):
//   gọi DELETE exams/{id}, chỉ chủ sở hữu; hộp xác nhận ghi rõ
//   lượt làm và yêu thích gắn với bộ đề cũng bị xóa.
// Dữ liệu giả: giá trị mẫu hiển thị trong từng hàng dưới đây
// Chức năng thật nối ở: T20 (lưu settings dạng map trong exams)
// ============================================================
class Mh26CaiDatBoDeScreen extends StatefulWidget {
  const Mh26CaiDatBoDeScreen({super.key, this.examId, this.tenBoDe});

  /// Mã bộ đề thật (khi vào từ MH-08 của chủ sở hữu). Để trống khi
  /// chạy bản giao diện xem thử — nút xóa khi đó chỉ hiện hộp xác nhận.
  final String? examId;

  /// Tên bộ đề, hiện trong hộp xác nhận xóa.
  final String? tenBoDe;

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
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _xacNhanXoaBoDe,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Xóa bộ đề'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kError,
                    side: const BorderSide(color: kError),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
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

  /// Hộp xác nhận xóa bộ đề. Có examId thì gọi API xóa thật rồi
  /// quay lại màn trước; chưa gắn bộ đề (bản giao diện) thì chỉ báo.
  Future<void> _xacNhanXoaBoDe() async {
    final ten = widget.tenBoDe ?? 'Bộ đề giữa kỳ';
    final dongY = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bộ đề?'),
        content: Text(
          'Xóa bộ đề "$ten"? Các lượt làm và mục yêu thích gắn với '
          'bộ đề này cũng bị xóa. Không hoàn tác được.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: kError),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (dongY != true || !mounted) return;
    if (widget.examId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bản giao diện: chưa gắn bộ đề thật để xóa.'),
        ),
      );
      return;
    }
    try {
      await ApiClient().delete('exams/${widget.examId}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa bộ đề.')),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
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
