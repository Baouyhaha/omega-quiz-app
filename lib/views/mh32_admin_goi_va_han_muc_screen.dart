import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';
import 'mh32_admin_goi_va_han_muc_mock.dart';

// ============================================================================
// Mã MH: MH-32 — Admin: Gói và hạn mức
// Tên màn hình: Gói và hạn mức (frame Figma:
// MH-32-admin-goi-va-han-muc, node 83-193, khung 412 x 917,
// trang "Mockup màu").
// Thuộc luồng: L5 — Admin (Flow boards, flow-L9-admin).
// Vào màn hình này từ đâu:
//   - Từ màn quản trị (màn của thành viên khác, chưa làm xong).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Không có interaction nào trong task, không có nút quay lại
//     và không có thanh điều hướng dưới trong thiết kế.
//   - Nút "Lưu thay đổi" chưa có logic thật ở giai đoạn giao diện.
// Dữ liệu giả đang dùng ở đâu:
//   - File mh32_admin_goi_va_han_muc_mock.dart: 2 gói
//     ("Gói 30 ngày" 5 hạn mức, "Gói miễn phí" 3 hạn mức)
//     và ghi chú dưới nút lưu.
//   - Khối dữ liệu đó có ghi chú // MOCK: ở dòng đầu.
// Chức năng thật sẽ nối ở task nào:
//   - Để giai đoạn chức năng: lưu hạn mức thật qua API.
//     Kiến trúc: app gọi API, API mới qua Firebase.
//
// SỐ ĐO: theo task MH-32, xem bảng đầy đủ trong mh32_figma_tokens.md.
// Font Nunito, nền #F6F4FF, header tím đậm #4A32B8 cao 104px,
// thẻ gói 372x244 và 372x156, ô nhập 104x32,
// nút lưu 372x52 tím.
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như các màn trước; riêng ô nhập cao 32px dùng bo 8px.
// ============================================================================

/// Màn hình MH-32: chỉnh gói và hạn mức cho admin — 2 thẻ gói
/// với các ô nhập hạn mức, nút lưu thay đổi và ghi chú.
class Mh32AdminGoiVaHanMucScreen extends StatelessWidget {
  const Mh32AdminGoiVaHanMucScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header tím đậm: cao 104px, phủ toàn chiều ngang ---
          // Tiêu đề "Gói và hạn mức" trắng 24px,
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
                  'Gói và hạn mức',
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
                  // Header đáy -> tiêu đề gói đầu tiên: 8px.
                  const SizedBox(height: 8),

                  // 2 thẻ gói, mỗi thẻ gồm tiêu đề và các hàng
                  // hạn mức. Thẻ cách nhau: thẻ trên đáy -> tiêu
                  // đề thẻ dưới 8px, tiêu đề -> thẻ 5px.
                  for (int i = 0; i < mockPlans.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Text(mockPlans[i].name, style: kHeadingStyle),
                    const SizedBox(height: 5),
                    _PlanCard(plan: mockPlans[i]),
                  ],
                  // Thẻ gói cuối -> nút lưu: 16px theo task.
                  const SizedBox(height: 16),

                  // --- Nút "Lưu thay đổi" 372x52 tím ---
                  SizedBox(
                    width: double.infinity,
                    height: kButtonHeight,
                    child: ElevatedButton(
                      // Chưa có logic thật ở giai đoạn giao diện.
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: kOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            kRadiusButton,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Lưu thay đổi',
                        style: kButtonTextStyle,
                      ),
                    ),
                  ),
                  // Nút lưu -> ghi chú: 11px theo task.
                  const SizedBox(height: 11),
                  Center(
                    child: Text(
                      mockPlanNote,
                      style: kQuestionPreviewStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
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

/// Một thẻ gói theo task: nền trắng, viền 1px #E9E6F7,
/// các hàng hạn mức cách nhau 12px. Chiều cao thẻ theo số hàng
/// (5 hàng: 244px, 3 hàng: 156px theo task).
/// Chỉ dùng ở MH-32 nên để trong file màn hình này.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final MockPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < plan.limits.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _LimitRow(limit: plan.limits[i]),
          ],
        ],
      ),
    );
  }
}

/// Một hàng hạn mức theo task: nhãn 15px ở trái,
/// ô nhập 104x32 ở phải với giá trị 15px 700 căn giữa.
/// Chỉ dùng ở MH-32 nên để trong file màn hình này.
class _LimitRow extends StatelessWidget {
  const _LimitRow({required this.limit});

  final MockPlanLimit limit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(limit.label, style: kFieldTextStyle),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: kLimitInputWidth,
          height: kLimitInputHeight,
          child: TextFormField(
            initialValue: limit.value,
            textAlign: TextAlign.center,
            style: kLimitValueStyle,
            decoration: InputDecoration(
              filled: true,
              fillColor: kSurface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: kInputBorder,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: kInputBorder,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: kPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
