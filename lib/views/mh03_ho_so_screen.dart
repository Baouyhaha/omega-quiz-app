import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../routes.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
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
// Dữ liệu thật: GET /me (tên, email, hạng, điểm TB, lượt làm,
//         trận thắng) + GET /me/subscription (gói + số ngày còn lại)
// Chức năng thật nối ở: T14 (hồ sơ + đăng xuất), T29 (điểm xếp
//         hạng), UC02 (gói)
// ============================================================

class Mh03HoSoScreen extends StatefulWidget {
  const Mh03HoSoScreen({super.key});

  @override
  State<Mh03HoSoScreen> createState() => _Mh03HoSoScreenState();
}

class _Mh03HoSoScreenState extends State<Mh03HoSoScreen> {
  bool _thongBao = true;
  bool _amThanh = true;

  bool _dangTai = true;
  String? _loi;
  Map<String, dynamic>? _me;
  Map<String, dynamic>? _goi;

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  /// Tải hồ sơ thật + trạng thái gói. Lỗi ở phần gói không chặn
  /// màn hình (vẫn hiện hồ sơ, gói lấy tạm từ /me).
  Future<void> _taiDuLieu() async {
    setState(() {
      _dangTai = true;
      _loi = null;
    });
    try {
      final me = await ApiClient().get('me') as Map<String, dynamic>;
      Map<String, dynamic>? goi;
      try {
        goi = await ApiClient().get('me/subscription')
            as Map<String, dynamic>;
      } catch (_) {
        goi = null;
      }
      if (!mounted) return;
      setState(() {
        _me = me;
        _goi = goi;
        _dangTai = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loi = e.message;
        _dangTai = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loi = 'Không tải được hồ sơ. Kiểm tra API đã chạy chưa.';
        _dangTai = false;
      });
    }
  }

  /// Đăng xuất thật: thoát Google + Firebase và xóa phiên đã lưu
  /// (trước đây nút này chỉ chuyển màn hình, phiên vẫn còn nên mở
  /// lại app là vào thẳng). Chế độ dev chưa có Firebase thì chỉ
  /// cần xóa phiên lưu trên máy.
  Future<void> _dangXuat() async {
    try {
      await AuthService().signOut();
    } catch (_) {
      await Session.clear();
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.mh01,
      (_) => false,
    );
  }

  /// Dòng trạng thái gói: "Dùng thử — còn 7 ngày".
  String get _dongGoi {
    final goi = _goi;
    if (goi != null) {
      final ten = goi['planName'] as String? ?? 'Gói thuê';
      final conLai = (goi['daysLeft'] as num?)?.toInt();
      if (conLai == null) return ten;
      if (conLai <= 0) return '$ten — đã hết hạn';
      return '$ten — còn $conLai ngày';
    }
    final sub = _me?['subscription'] as Map<String, dynamic>?;
    if (sub != null) return sub['planName'] as String? ?? 'Gói thuê';
    return 'Chưa có gói';
  }

  @override
  Widget build(BuildContext context) {
    if (_dangTai) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hồ sơ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final me = _me;
    if (me == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hồ sơ')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loi ?? 'Không tải được hồ sơ',
                  style: const TextStyle(color: kTextSub)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _taiDuLieu,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final ten = me['name'] as String? ?? 'Người dùng';
    final email = me['email'] as String? ?? '';
    final photoUrl = me['photoUrl'] as String?;
    final rankScore = (me['rankScore'] as num?)?.toInt() ?? 0;
    final hang = me['animalRank'] as String? ?? animalRank(rankScore);
    final hangSau = tenRankSau(rankScore);
    final conLaiDiem = pointsToNextRank(rankScore);
    final diemTB = (me['averagePercent'] as num?)?.toDouble();
    final luotLam = (me['attemptCount'] as num?)?.toInt() ?? 0;
    final tranThang = (me['battleWins'] as num?)?.toInt() ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: kPrimary,
              backgroundImage:
                  (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : null,
              child: (photoUrl != null && photoUrl.isNotEmpty)
                  ? null
                  : Text(
                      ten.isNotEmpty ? ten[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              ten,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              email,
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
                      const Text('Hạng',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      // Icon rank theo bộ icon T12 (assets/icons/rank/)
                      Image.asset(iconRank(hang), width: 28, height: 28),
                      const Spacer(),
                      Text(
                        '$rankScore điểm',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: tienTrinhLenRank(rankScore),
                    color: kPrimary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  if (hangSau != null && conLaiDiem != null)
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 13, color: kTextSub),
                        children: [
                          TextSpan(text: 'Còn $conLaiDiem điểm tới hạng '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Image.asset(iconRank(hangSau),
                                width: 18, height: 18),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text('Đã đạt hạng cao nhất',
                        style: TextStyle(fontSize: 13, color: kTextSub)),
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
                  _ChiSo(
                      diemTB == null ? '—' : (diemTB / 10).toStringAsFixed(1),
                      'Điểm TB'),
                  _ChiSo('$luotLam', 'Lượt làm'),
                  _ChiSo('$tranThang', 'Trận thắng'),
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
                        const Text('Trạng thái gói',
                            style: TextStyle(fontSize: 13, color: kTextSub)),
                        const SizedBox(height: 2),
                        Text(
                          _dongGoi,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(96, 42)),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.mh29),
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
                leading: const Icon(Icons.admin_panel_settings_rounded,
                    color: kPrimary),
                title: const Text('Quản trị nền tảng',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle:
                    const Text('Tài khoản · Gói và hạn mức · Thống kê'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pushNamed(context, AppRoutes.mh30),
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Text('Cài đặt',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
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
              title: const Text('Âm thanh ASMR',
                  style: TextStyle(color: kTextSub)),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E1F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Sắp có',
                    style: TextStyle(
                        fontSize: 12,
                        color: kTextSub,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _dangXuat,
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                    color: kError, fontSize: 16, fontWeight: FontWeight.w700),
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
        Text(giaTri,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(nhan, style: const TextStyle(fontSize: 12.5, color: kTextSub)),
      ],
    );
  }
}
