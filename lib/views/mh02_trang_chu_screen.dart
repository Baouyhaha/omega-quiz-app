/// MH-02 — Trang chủ.
/// Luồng: L2 (Trang chủ).
/// Vào từ: MH-01 Đăng nhập (sau đăng nhập Google) / thanh dưới mục Trang chủ.
/// Đi tiếp tới: MH-06 Chi tiết chủ đề, MH-28 Danh sách gói (banner dùng thử),
///   MH-04 Tìm kiếm (Figma MH-02 chưa có nút vào — để nhóm chốt điểm vào).
/// Thanh dưới do shell (khung điều hướng) cấp — màn này không tự gắn nav.
/// Dữ liệu giả: khối // MOCK: đầu file này.
/// Chức năng thật: nối ở task T40 (để giai đoạn chức năng).
import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// MOCK: dữ liệu giả cho MH-02 — thay bằng API topics/invitations ở giai đoạn chức năng.
const _mockTenNguoiDung = 'Danh';
const _mockNgayDungThuConLai = 3;
const _mockLoiMoi = {'topic': 'Tiếng Anh'};
const _mockMyTopics = [
  {'name': 'Toán cao cấp', 'stats': '60 câu · 4 bộ đề · 86 thành viên'},
  {'name': 'Tiếng Anh', 'stats': '60 câu · 4 bộ đề · 120 thành viên'},
];
const _mockFeaturedTopics = [
  {'name': 'Tiếng Anh', 'stats': '60 câu · 4 bộ đề · 120 thành viên'},
  {'name': 'Toán cao cấp', 'stats': '60 câu · 4 bộ đề · 86 thành viên'},
  {'name': 'Lập trình C++', 'stats': '45 câu · 3 bộ đề · 64 thành viên'},
];

class Mh02TrangChuScreen extends StatelessWidget {
  const Mh02TrangChuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Chào hỏi + avatar — thay AppBar như Figma.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Xin chào, $_mockTenNguoiDung',
                    style: textTheme.titleLarge?.copyWith(color: kTextPrimary)),
                const CircleAvatar(
                  backgroundColor: kPrimary,
                  child: Text('D',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Banner gói dùng thử — bấm "Gia hạn ngay" sang MH-28.
            _BannerDungThu(
              ngayConLai: _mockNgayDungThuConLai,
              onGiaHan: () => Navigator.pushNamed(context, '/mh28'),
            ),
            const SizedBox(height: 16),
            // Lời mời tham gia chủ đề — nền kSuccessTint #E4F8EC (xanh mint nhạt).
            Card(
              color: kSuccessTint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: kBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bạn được mời vào chủ đề',
                        style: TextStyle(color: kTextPrimary)),
                    const SizedBox(height: 4),
                    Text(_mockLoiMoi['topic']!,
                        style: textTheme.titleMedium
                            ?.copyWith(color: kPrimary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Tham gia'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Từ chối'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Chủ đề của tôi',
                style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
            ..._mockMyTopics.map((t) => _TheChuDe(
                  ten: t['name']!,
                  thongKe: t['stats']!,
                  nhan: 'Của tôi',
                  onTap: () => Navigator.pushNamed(context, '/mh06'),
                )),
            const SizedBox(height: 16),
            Text('Chủ đề công khai nổi bật',
                style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
            ..._mockFeaturedTopics.map((t) => _TheChuDe(
                  ten: t['name']!,
                  thongKe: t['stats']!,
                  nhan: 'Công khai',
                  onTap: () => Navigator.pushNamed(context, '/mh06'),
                )),
          ],
        ),
      ),
    );
  }
}

/// Banner gói dùng thử — nền kWarningTint #FFF3E0 (vàng cam nhạt).
/// Chữ "Gia hạn ngay" màu cam kWarning theo Figma.
class _BannerDungThu extends StatelessWidget {
  const _BannerDungThu({required this.ngayConLai, required this.onGiaHan});

  final int ngayConLai;
  final VoidCallback onGiaHan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWarningTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gói dùng thử còn $ngayConLai ngày',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: kTextPrimary)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onGiaHan,
            child: const Text('Gia hạn ngay ›',
                style:
                    TextStyle(color: kWarning, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// Thẻ 1 chủ đề: tên + thống kê + nhãn (Của tôi / Công khai).
class _TheChuDe extends StatelessWidget {
  const _TheChuDe({
    required this.ten,
    required this.thongKe,
    required this.nhan,
    required this.onTap,
  });

  final String ten;
  final String thongKe;
  final String nhan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Nhãn pill phân màu theo Figma: "Của tôi" nền tím nhạt + chữ tím,
    // "Công khai" nền xanh lá nhạt + chữ xanh lá.
    final laCuaToi = nhan == 'Của tôi';
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBorder),
      ),
      child: ListTile(
        title: Text(ten,
            style: const TextStyle(
                color: kTextPrimary, fontWeight: FontWeight.w700)),
        subtitle: Text(thongKe, style: const TextStyle(color: kTextSecondary)),
        trailing: Chip(
          label: Text(nhan,
              style: TextStyle(
                  color: laCuaToi ? kPrimary : kSuccess,
                  fontWeight: FontWeight.w700)),
          backgroundColor: laCuaToi
              ? kPrimaryTint
              : kSuccessTint,
          side: BorderSide.none,
        ),
        onTap: onTap,
      ),
    );
  }
}
