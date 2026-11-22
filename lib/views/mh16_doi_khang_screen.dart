import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/nut_chinh_widget.dart';
import '../widgets/trang_thai_tai_widget.dart';

// ============================================================
// MH-16 — Đối kháng 1-1
// Luồng: L6 (Đối kháng 1-1)
// Vào từ: tab "Thi đấu" của khung điều hướng / nút Thi đấu ở MH-02
// Đi tới: MH-09 (màn làm bài dùng chung khi trận bắt đầu)
// Dữ liệu giả: _mockChuDe ngay dưới đây; trạng thái phòng đổi bằng
//             setState để xem trước giao diện, chưa nối Firestore
// Chức năng thật nối ở: T27 (phòng realtime, rút câu ngẫu nhiên
//             từ kho chủ đề ở máy chủ)
// ============================================================

// MOCK: danh sach chu de de chon thi dau
const _mockChuDe = ['Toán cao cấp', 'Tiếng Anh'];
const _mockSoCau = [5, 10, 15, 20];

class Mh16DoiKhangScreen extends StatefulWidget {
  const Mh16DoiKhangScreen({super.key});

  @override
  State<Mh16DoiKhangScreen> createState() => _Mh16DoiKhangScreenState();
}

class _Mh16DoiKhangScreenState extends State<Mh16DoiKhangScreen> {
  String _chuDe = _mockChuDe.first;
  int _soCau = 10;
  // 0: dang chon, 1: dang cho doi thu, 2: doi thu da vao, cho san sang
  int _trangThaiPhong = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đối kháng 1-1')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Câu hỏi được rút ngẫu nhiên từ kho câu hỏi của chủ đề. '
            'Hai người làm cùng một danh sách câu, thắng +15 điểm rank.',
            style: TextStyle(color: kTextSub, height: 1.45),
          ),
          const SizedBox(height: 16),
          if (_trangThaiPhong == 0) ...[
            const Text('Chọn chủ đề', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final cd in _mockChuDe)
                  ChoiceChip(
                    label: Text(cd),
                    selected: _chuDe == cd,
                    onSelected: (_) => setState(() => _chuDe = cd),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Số câu hỏi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final n in _mockSoCau)
                  ChoiceChip(
                    label: Text('$n câu'),
                    selected: _soCau == n,
                    onSelected: (_) => setState(() => _soCau = n),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            NutChinh(
              text: 'Tạo phòng',
              icon: Icons.add_circle_rounded,
              onPressed: () => setState(() => _trangThaiPhong = 1),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Vào phòng bằng mã', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'Nhập mã phòng, ví dụ X7K2'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => setState(() => _trangThaiPhong = 2),
              child: const Text('Vào phòng'),
            ),
          ] else if (_trangThaiPhong == 1) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Mã phòng của bạn', style: TextStyle(color: kTextSub)),
                    const SizedBox(height: 6),
                    const Text(
                      'X7K2',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 4, color: kPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text('Chủ đề: $_chuDe · $_soCau câu', style: const TextStyle(color: kTextSub)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const TrangThaiTai(text: 'Đang chờ đối thủ vào phòng…'),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => setState(() => _trangThaiPhong = 0),
              child: const Text('Hủy phòng'),
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Đối thủ đã vào phòng', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 8),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: kPrimary,
                        child: Icon(Icons.person_rounded, color: Colors.white),
                      ),
                      title: Text('Đặng Ngọc Đỉnh'),
                      subtitle: Text('Hạng Hổ · 1520 điểm rank'),
                    ),
                    const SizedBox(height: 8),
                    NutChinh(
                      text: 'Sẵn sàng',
                      icon: Icons.check_circle_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bản giao diện: khi cả hai sẵn sàng sẽ chuyển sang màn làm bài MH-09.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
