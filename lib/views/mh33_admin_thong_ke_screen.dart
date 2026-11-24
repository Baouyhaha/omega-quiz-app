import 'package:flutter/material.dart';

import '../core/dinh_api.dart';
import '../core/dinh_theme.dart';
import 'mh33_admin_thong_ke_mock.dart';

// ============================================================================
// Mã MH: MH-33 — Admin: Thống kê
// Tên màn hình: Thống kê hệ thống (frame Figma:
// MH-33-admin-thong-ke, node 83-230, khung 412 x 917,
// trang "Mockup màu").
// Thuộc luồng: L9 — Admin nền tảng (Flow boards, flow-L9-admin).
// Vào màn hình này từ đâu:
//   - Từ MH-30 / MH-32: bấm tab "Thống kê" ở thanh tab phụ dưới.
//     Điểm vào khu vực Admin là Hồ sơ (MH-03) -> mục "Quản trị nền
//     tảng" -> MH-30 (luồng đã chốt 24/11).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Thanh tab phụ dưới nằm ở màn host Admin (AdminHostScreen),
//     không nằm trong màn này: bấm tab "Tài khoản" sang MH-30, tab
//     "Gói và hạn mức" sang MH-32; thanh tab đứng yên, chỉ phần nội
//     dung trượt ngang.
//   - Nút quay lại "‹" ở header: về Hồ sơ (MH-03) — màn vào Admin.
//     Nút này không có trong thiết kế Figma, thêm theo luồng đã chốt.
//   - Nút "Xem" ở hàng tài khoản gian lận chưa có logic thật
//     ở giai đoạn giao diện.
// Dữ liệu thật đang dùng (nối API 25/11, UC28):
//   - 3 thẻ thống kê tổng: GET /admin/stats (token dev:admin) —
//     Tổng tài khoản = totalUsers, Tổng chủ đề = totalTopics,
//     Tổng lượt làm = totalAttempts. Dữ liệu là seed trong bộ nhớ
//     của API (5 tài khoản, 2 chủ đề, 0 lượt làm), restart server
//     là reset — không phải 128 / 45 / 1.240 như mock cũ.
//   - Biểu đồ lượt làm theo ngày và thẻ tài khoản gian lận VẪN
//     LÀ MOCK (mockChartBars, mockCheatAccount trong file mock):
//     API chưa có endpoint trả lượt làm theo ngày hay danh sách
//     tài khoản gian lận, nên không bịa số thật cho 2 chỗ này.
//     Khi quay video bằng chứng T39 thì giải thích 2 chỗ đó.
//   - Bảng thống kê theo bộ đề và theo chủ đề mà T39 yêu cầu
//     cũng chưa có endpoint — màn này hiện chưa có 2 bảng đó
//     (đúng như bản Figma gốc, cũng không có).
// Chức năng thật sẽ nối ở task nào:
//   - T39 bước 3 (thống kê theo API): đã nối phần số tổng, xem
//     hàm _loadStats. Kiến trúc: app gọi API, API mới qua Firebase.
//
// SỐ ĐO: theo task MH-33, xem bảng đầy đủ trong mh33_figma_tokens.md.
// Font Nunito, nền #F6F4FF, header tím đậm #4A32B8 cao 104px,
// 3 thẻ thống kê 120x96 cách nhau 6px, thẻ biểu đồ 372x180,
// 5 cột tím rộng 36px, thẻ tài khoản gian lận 372x76.
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như các màn trước; riêng cột biểu đồ dùng bo 4px ở đỉnh.
// ============================================================================

/// Màn hình MH-33: thống kê hệ thống cho admin — 3 thẻ tổng,
/// biểu đồ cột lượt làm theo ngày, danh sách tài khoản gian lận.
/// 3 thẻ tổng tải từ API admin; biểu đồ và thẻ gian lận vẫn là
/// mock vì API chưa có endpoint cho 2 chỗ đó.
class Mh33AdminThongKeScreen extends StatefulWidget {
  const Mh33AdminThongKeScreen({super.key});

  @override
  State<Mh33AdminThongKeScreen> createState() =>
      _Mh33AdminThongKeScreenState();
}

class _Mh33AdminThongKeScreenState
    extends State<Mh33AdminThongKeScreen> {
  ApiAdminStats? _stats;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// Tai so tong tu GET /admin/stats.
  Future<void> _loadStats() async {
    if (_stats == null) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final stats = await DinhApi.fetchAdminStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (_stats == null) {
        setState(() => _error = e.message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  /// 1240 -> '1.240' (dau phan cach hang nghin nhu mock cu).
  /// Khong dung goi intl.
  String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header tím đậm: cao 104px, phủ toàn chiều ngang ---
          // Nút quay lại "‹" trắng + tiêu đề "Thống kê hệ thống"
          // trắng 24px, "Quản trị" 13px #D9CFFF. Nút quay lại
          // không có trong thiết kế, thêm theo luồng đã chốt
          // (về Hồ sơ); kiểu nút giống MH-31 (nút Top 40, tiêu
          // đề Top 48, "Quản trị" Top 59).
          Container(
            width: double.infinity,
            height: kAdminHeaderHeight,
            color: kAdminHeaderBackground,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  // Quay về Hồ sơ (MH-03) — màn vào khu vực Admin.
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    '‹',
                    style: kBackStyle.copyWith(color: kOnPrimary),
                  ),
                ),
                const SizedBox(width: 22),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Thống kê hệ thống',
                    style: kAdminHeaderTitleStyle,
                  ),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(top: 19),
                  child: Text('Quản trị', style: kAdminHeaderBadgeStyle),
                ),
              ],
            ),
          ),

          // --- Nội dung: cuộn được nếu màn hình nhỏ ---
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error!,
                              style: kQuestionPreviewStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _loadStats,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStats,
                        color: kPrimary,
                        child: SingleChildScrollView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: kSpacing20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header đáy -> thẻ thống kê: 16px theo task.
                              const SizedBox(height: 16),

                              // --- 3 thẻ thống kê: 120x96, cách nhau 6px ---
                              // So that tu GET /admin/stats.
                              Row(
                                children: [
                                  Expanded(
                                    child: _SystemStatCard(
                                      value: _formatNumber(
                                        stats!.totalUsers,
                                      ),
                                      label: 'Tổng tài khoản',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _SystemStatCard(
                                      value: _formatNumber(
                                        stats!.totalTopics,
                                      ),
                                      label: 'Tổng chủ đề',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _SystemStatCard(
                                      value: _formatNumber(
                                        stats!.totalAttempts,
                                      ),
                                      label: 'Tổng lượt làm',
                                    ),
                                  ),
                                ],
                              ),
                              // Thẻ thống kê -> tiêu đề biểu đồ: 16px theo task.
                              const SizedBox(height: 16),

                              // --- Biểu đồ lượt làm theo ngày ---
                              // VAN LA MOCK: API chua co endpoint tra
                              // luot lam theo ngay.
                              const Text(
                                'Lượt làm theo ngày',
                                style: kHeadingStyle,
                              ),
                              const SizedBox(height: 5),
                              const _ChartCard(),
                              // Thẻ biểu đồ -> tiêu đề gian lận: 16px theo task.
                              const SizedBox(height: 16),

                              // --- Tài khoản gian lận ---
                              // VAN LA MOCK: API chua co endpoint tra
                              // danh sach tai khoan gian lan.
                              const Text(
                                'Tài khoản gian lận',
                                style: kHeadingStyle,
                              ),
                              const SizedBox(height: 5),
                              const _CheatAccountCard(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

/// Một thẻ thống kê tổng theo task: 120x96, nền trắng,
/// viền 1px #E9E6F7, giá trị 24px 700 căn giữa cách đỉnh
/// thẻ 14px, nhãn 13px 400 cách đỉnh thẻ 51px.
/// Chỉ dùng ở MH-33 nên để trong file màn hình này.
class _SystemStatCard extends StatelessWidget {
  const _SystemStatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kStatCardHeight,
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 14),
          Text(
            value,
            style: kStatValueStyle.copyWith(color: kPrimary),
          ),
          // Giá trị -> nhãn: hộp giá trị trong Figma cao 33px
          // (font 24px), cách nhãn 4px theo mép hộp. Flutter
          // chữ cao đúng bằng font nên cộng thêm chênh lệch
          // hộp chữ 9px: 4 + 9 = 13px (bài học MH-30).
          const SizedBox(height: 13),
          Text(
            label,
            style: kQuestionPreviewStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Thẻ biểu đồ cột theo task: 372x180, nền trắng,
/// viền 1px #E9E6F7. 5 cột tím rộng 36px, cách nhau 32px,
/// giá trị trên cột cách đỉnh cột 3px, đường trục ngang
/// 1px #E9E6F7, nhãn ngày dưới trục 5px.
/// VẪN LÀ MOCK — API chưa có endpoint lượt làm theo ngày.
/// Chỉ dùng ở MH-33 nên để trong file màn hình này.
class _ChartCard extends StatelessWidget {
  const _ChartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kChartCardHeight,
      padding: const EdgeInsets.fromLTRB(16, 19, 16, 1),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng cột: giá trị + cột, đáy chung.
          // Chiều cao: cột cao nhất 116 + giá trị 18
          // + cách 3 = 137px.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < mockChartBars.length; i++) ...[
                if (i > 0) const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${mockChartBars[i].value}',
                        style: kChartValueStyle,
                      ),
                      // Giá trị -> cột: hộp giá trị trong Figma
                      // cao 18px (font 13px), cách cột 3px theo
                      // mép hộp. Flutter chữ cao đúng bằng font
                      // nên cộng thêm chênh lệch hộp chữ 5px:
                      // 3 + 5 = 8px (bài học MH-30).
                      const SizedBox(height: 8),
                      Container(
                        width: kChartBarWidth,
                        height: mockChartBars[i].height,
                        decoration: const BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          // Đường trục ngang 1px.
          Container(
            height: 1,
            color: kInputBorder,
          ),
          // Nhãn ngày dưới trục 4px (theo task 5px, trừ 1px
          // vì hộp chữ 13px trong Figma cao 18px).
          const SizedBox(height: 4),
          Row(
            children: [
              for (int i = 0; i < mockChartBars.length; i++) ...[
                if (i > 0) const SizedBox(width: 32),
                Expanded(
                  child: Text(
                    mockChartBars[i].day,
                    style: kQuestionPreviewStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Thẻ tài khoản gian lận theo task: 372x76, nền trắng,
/// viền 1px #E9E6F7. Avatar tròn 44px #FF5A5F chữ "A",
/// tên 17px 700, "12 lần vi phạm" 13px 700 #FF5A5F,
/// nút "Xem" 60x36 viền tím ở phải.
/// VẪN LÀ MOCK — API chưa có endpoint tài khoản gian lận.
/// Chỉ dùng ở MH-33 nên để trong file màn hình này.
class _CheatAccountCard extends StatelessWidget {
  const _CheatAccountCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kCheatCardHeight,
      padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar tròn 44px.
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: mockCheatAccount.avatarColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              mockCheatAccount.avatarLetter,
              style: kAccountAvatarLetterStyle,
            ),
          ),
          const SizedBox(width: 14),
          // Tên + dòng vi phạm. Canh từ đỉnh để tên nằm ở
          // Top +15 như task (canh giữa sẽ đẩy tên xuống
          // khoảng 3px).
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  mockCheatAccount.name,
                  style: kAccountNameStyle,
                ),
                // Tên -> dòng vi phạm: 9px theo số đo hộp
                // chữ trong Figma (bài học MH-30).
                const SizedBox(height: 9),
                Text(
                  mockCheatAccount.violationText,
                  style: kCheatViolationStyle,
                ),
              ],
            ),
          ),
          // Nút "Xem" 60x36.
          SizedBox(
            width: 60,
            height: 36,
            child: OutlinedButton(
              // Chưa có logic thật ở giai đoạn giao diện.
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: kSurface,
                side: const BorderSide(
                  color: kPrimary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text('Xem', style: kViewButtonTextStyle),
            ),
          ),
        ],
      ),
    );
  }
}
