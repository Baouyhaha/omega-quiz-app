import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';
import 'mh33_admin_thong_ke_mock.dart';

// ============================================================================
// Mã MH: MH-33 — Admin: Thống kê
// Tên màn hình: Thống kê hệ thống (frame Figma:
// MH-33-admin-thong-ke, node 83-230, khung 412 x 917,
// trang "Mockup màu").
// Thuộc luồng: L5 — Admin (Flow boards, flow-L9-admin).
// Vào màn hình này từ đâu:
//   - Từ màn quản trị (màn của thành viên khác, chưa làm xong).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Không có interaction nào trong task, không có nút quay lại
//     và không có thanh điều hướng dưới trong thiết kế.
//   - Nút "Xem" ở hàng tài khoản gian lận chưa có logic thật
//     ở giai đoạn giao diện.
// Dữ liệu giả đang dùng ở đâu:
//   - File mh33_admin_thong_ke_mock.dart: 3 thẻ thống kê tổng,
//     5 cột biểu đồ lượt làm theo ngày, 1 tài khoản gian lận.
//   - Khối dữ liệu đó có ghi chú // MOCK: ở dòng đầu.
// Chức năng thật sẽ nối ở task nào:
//   - Để giai đoạn chức năng: lấy thống kê thật qua API.
//     Kiến trúc: app gọi API, API mới qua Firebase.
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
class Mh33AdminThongKeScreen extends StatelessWidget {
  const Mh33AdminThongKeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header tím đậm: cao 104px, phủ toàn chiều ngang ---
          // Tiêu đề "Thống kê hệ thống" trắng 24px,
          // "Quản trị" 13px #D9CFFF.
          Container(
            width: double.infinity,
            height: kAdminHeaderHeight,
            color: kAdminHeaderBackground,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thống kê hệ thống',
                  style: kAdminHeaderTitleStyle,
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(top: 11),
                  child: Text('Quản trị', style: kAdminHeaderBadgeStyle),
                ),
              ],
            ),
          ),

          // --- Nội dung: cuộn được nếu màn hình nhỏ ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacing20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header đáy -> thẻ thống kê: 16px theo task.
                  const SizedBox(height: 16),

                  // --- 3 thẻ thống kê: 120x96, cách nhau 6px ---
                  Row(
                    children: [
                      for (int i = 0; i < mockSystemStats.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(child: _SystemStatCard(
                          stat: mockSystemStats[i],
                        )),
                      ],
                    ],
                  ),
                  // Thẻ thống kê -> tiêu đề biểu đồ: 16px theo task.
                  const SizedBox(height: 16),

                  // --- Biểu đồ lượt làm theo ngày ---
                  const Text('Lượt làm theo ngày', style: kHeadingStyle),
                  const SizedBox(height: 5),
                  const _ChartCard(),
                  // Thẻ biểu đồ -> tiêu đề gian lận: 16px theo task.
                  const SizedBox(height: 16),

                  // --- Tài khoản gian lận ---
                  const Text('Tài khoản gian lận', style: kHeadingStyle),
                  const SizedBox(height: 5),
                  const _CheatAccountCard(),
                  const SizedBox(height: 20),
                ],
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
  const _SystemStatCard({required this.stat});

  final MockSystemStat stat;

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
            stat.value,
            style: kStatValueStyle.copyWith(color: stat.color),
          ),
          // Giá trị -> nhãn: hộp giá trị trong Figma cao 33px
          // (font 24px), cách nhãn 4px theo mép hộp. Flutter
          // chữ cao đúng bằng font nên cộng thêm chênh lệch
          // hộp chữ 9px: 4 + 9 = 13px (bài học MH-30).
          const SizedBox(height: 13),
          Text(
            stat.label,
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
