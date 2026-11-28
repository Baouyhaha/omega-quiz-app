import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../routes.dart';
import '../services/session.dart';
import '../utils/rank_helper.dart';

// ============================================================
// MH-03 — Hồ sơ cá nhân
// Luồng: L1 (tài khoản), L8 (gói thuê)
// Vào từ: tab "Hồ sơ" của khung điều hướng
// Đi tới: MH-29 (nút Xem gói), MH-30 (mục Quản trị nền tảng —
//         chỉ hiện khi tài khoản là Admin, luồng L9 đã chốt 24/11),
//         MH-01 (đăng xuất)
// Bố cục: dựng theo mockup Figma MH-03-ho-so (avatar tròn giữa màn,
//         thẻ hạng có thanh tiến trình, 3 chỉ số, hàng trạng thái gói,
//         mục Cài đặt có hàng ASMR để mờ kèm nhãn "Sắp có")
// Dữ liệu giả: khối _mockHoSo ngay dưới đây
// Chức năng thật nối ở: T14 (hồ sơ), T29 (điểm xếp hạng), UC02 (gói)
// ============================================================

// MOCK: ho so mau, sau nay lay tu API GET /me
const _mockHoSo = {
  'ten': 'Nguyễn Trọng Bảo Uy',
  'email': '0306241504@caothang.edu.vn',
  'hangConVat': 'Ngựa',
  'rankScore': 1240,
  'conLaiLenHang': 110,
  'hangTiepTheo': 'Gấu',
  'tienTrinhHang': 0.27,
  'diemTrungBinh': 8.2,
  'luotLam': 17,
  'tranThang': 6,
  'goiHienTai': 'Dùng thử — còn 7 ngày',
};

class Mh03HoSoScreen extends StatefulWidget {
  const Mh03HoSoScreen({super.key});

  @override
  State<Mh03HoSoScreen> createState() => _Mh03HoSoScreenState();
}

class _Mh03HoSoScreenState extends State<Mh03HoSoScreen> {
  bool _thongBao = true;
  bool _amThanh = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: kPrimary,
              child: Text(
                'U',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _mockHoSo['ten'] as String,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              _mockHoSo['email'] as String,
              style: const TextStyle(color: kTextSub),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Hạng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      // Icon rank theo bộ icon T12 (assets/icons/rank/)
                      Image.asset(iconRank(_mockHoSo['hangConVat'] as String), width: 28, height: 28),
                      const Spacer(),
                      Text(
                        '${_mockHoSo['rankScore']} điểm',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (_mockHoSo['tienTrinhHang'] as num).toDouble(),
                    color: kPrimary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 13, color: kTextSub),
                      children: [
                        TextSpan(text: 'Còn ${_mockHoSo['conLaiLenHang']} điểm tới hạng '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Image.asset(iconRank(_mockHoSo['hangTiepTheo'] as String), width: 18, height: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ChiSo('${_mockHoSo['diemTrungBinh']}', 'Điểm TB'),
                  _ChiSo('${_mockHoSo['luotLam']}', 'Lượt làm'),
                  _ChiSo('${_mockHoSo['tranThang']}', 'Trận thắng'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Trạng thái gói', style: TextStyle(fontSize: 13, color: kTextSub)),
                        const SizedBox(height: 2),
                        Text(
                          _mockHoSo['goiHienTai'] as String,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(96, 42)),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.mh29),
                    child: const Text('Xem gói'),
                  ),
                ],
              ),
            ),
          ),
          // Điểm vào khu Admin (L9): chỉ hiện với tài khoản Admin
          // nền tảng, đi thẳng MH-30 — không thêm mục vào thanh dưới.
          if (Session.laAdmin) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings_rounded, color: kPrimary),
                title: const Text('Quản trị nền tảng', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Tài khoản · Gói và hạn mức · Thống kê'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pushNamed(context, AppRoutes.mh30),
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Text('Cài đặt', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: SwitchListTile(
              title: const Text('Thông báo'),
              value: _thongBao,
              onChanged: (v) => setState(() => _thongBao = v),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: SwitchListTile(
              title: const Text('Âm thanh'),
              value: _amThanh,
              onChanged: (v) => setState(() => _amThanh = v),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: const Text('Âm thanh ASMR', style: TextStyle(color: kTextSub)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E1F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Sắp có', style: TextStyle(fontSize: 12, color: kTextSub, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.mh01,
                (_) => false,
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: kError, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChiSo extends StatelessWidget {
  final String giaTri;
  final String nhan;

  const _ChiSo(this.giaTri, this.nhan);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(giaTri, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(nhan, style: const TextStyle(fontSize: 12.5, color: kTextSub)),
      ],
    );
  }
}
