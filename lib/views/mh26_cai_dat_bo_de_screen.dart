import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-26 — Cài đặt bộ đề (chủ sở hữu chủ đề)
// Luồng: L4 (chủ sở hữu tạo nội dung)
// Vào từ: MH-25 (nút "Tiếp tục: Cài đặt bộ đề") / MH-08 (Cài đặt)
// Đi tới: quay lại MH-08 (chi tiết bộ đề) sau khi lưu
// Dữ liệu giả: giá trị mặc định điền sẵn trong các ô dưới đây
// Chức năng thật nối ở: T20 (lưu settings dạng map trong exams)
// ============================================================
class Mh26CaiDatBoDeScreen extends StatefulWidget {
  const Mh26CaiDatBoDeScreen({super.key});

  @override
  State<Mh26CaiDatBoDeScreen> createState() => _Mh26CaiDatBoDeScreenState();
}

class _Mh26CaiDatBoDeScreenState extends State<Mh26CaiDatBoDeScreen> {
  bool _batPin = false;
  bool _xaoTronCau = true;
  bool _xaoTronDapAn = true;
  bool _choTroGiup = true;
  bool _hienDiem = true;
  String _hienDapAn = 'sau_khi_dong';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt bộ đề')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: '20',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Thời gian làm bài (phút)'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: '1',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Số lần làm tối đa'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: '23/11/2026 08:00',
                  decoration: InputDecoration(labelText: 'Giờ mở đề'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: '24/11/2026 21:00',
                  decoration: InputDecoration(labelText: 'Giờ đóng đề'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Bật mã PIN vào phòng'),
                  value: _batPin,
                  onChanged: (v) => setState(() => _batPin = v),
                ),
                if (_batPin)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: TextField(
                      decoration: InputDecoration(hintText: 'Mã PIN gồm 4–6 chữ số'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                SwitchListTile(
                  title: const Text('Xáo trộn thứ tự câu hỏi'),
                  value: _xaoTronCau,
                  onChanged: (v) => setState(() => _xaoTronCau = v),
                ),
                SwitchListTile(
                  title: const Text('Xáo trộn thứ tự đáp án'),
                  value: _xaoTronDapAn,
                  onChanged: (v) => setState(() => _xaoTronDapAn = v),
                ),
                SwitchListTile(
                  title: const Text('Cho phép dùng quyền trợ giúp'),
                  value: _choTroGiup,
                  onChanged: (v) => setState(() => _choTroGiup = v),
                ),
                SwitchListTile(
                  title: const Text('Hiện điểm ngay sau khi nộp'),
                  value: _hienDiem,
                  onChanged: (v) => setState(() => _hienDiem = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Hiện đáp án đúng và giải thích', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: DropdownButton<String>(
              value: _hienDapAn,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'ngay', child: Text('Ngay sau khi làm bài')),
                DropdownMenuItem(value: 'sau_khi_dong', child: Text('Sau khi đóng đề')),
                DropdownMenuItem(value: 'khong_bao_gio', child: Text('Không bao giờ')),
              ],
              onChanged: (v) => setState(() => _hienDapAn = v!),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chống gian lận: thoát khỏi ứng dụng 5 lần trong lúc làm bài sẽ bị tự động nộp bài.',
            style: TextStyle(color: kTextSub, height: 1.45),
          ),
          const SizedBox(height: 20),
          NutChinh(
            text: 'Lưu cài đặt',
            icon: Icons.save_rounded,
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
