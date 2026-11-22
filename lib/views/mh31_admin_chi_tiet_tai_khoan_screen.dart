import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';
import 'mh31_admin_chi_tiet_tai_khoan_mock.dart';

// ============================================================================
// Mã MH: MH-31 — Admin: Chi tiết tài khoản
// Tên màn hình: Chi tiết tài khoản (frame Figma:
// MH-31-admin-chi-tiet-tai-khoan, node 83-162, khung 412 x 917,
// trang "Mockup màu").
// Thuộc luồng: L5 — Admin (Flow boards, flow-L9-admin).
// Vào màn hình này từ đâu:
//   - Từ MH-30 Admin: Tài khoản, bấm vào thẻ Danh.
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Nút quay lại "<" -> quay về màn hình trước (MH-30).
//     Nút này không có trong thiết kế, thêm theo yêu cầu
//     của user cho giống các màn trước.
//   - Không có thanh điều hướng dưới trong thiết kế.
//   - Nút "Khóa tài khoản", "Gán gói", "Gia hạn gói" chưa có
//     logic thật ở giai đoạn giao diện.
// Dữ liệu giả đang dùng ở đâu:
//   - File mh31_admin_chi_tiet_tai_khoan_mock.dart: chi tiết
//     tài khoản Danh (email, vai trò, trạng thái, gói, lịch sử).
//   - Khối dữ liệu đó có ghi chú // MOCK: ở dòng đầu.
// Chức năng thật sẽ nối ở task nào:
//   - Để giai đoạn chức năng: khóa/mở khóa, gán/gia hạn gói thật
//     qua API. Kiến trúc: app gọi API, API mới qua Firebase.
//
// SỐ ĐO: theo task MH-31, xem bảng đầy đủ trong mh31_figma_tokens.md.
// Font Nunito, nền #F6F4FF, header tím đậm #4A32B8 cao 104px,
// thẻ tài khoản 372x152, avatar tròn 56x56, thẻ gói 372x84,
// nút khóa 372x52 đỏ, 2 nút gói 180x52 viền tím,
// thẻ lịch sử 372x88.
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như các màn trước.
// ============================================================================

/// Màn hình MH-31: chi tiết một tài khoản cho admin — thông tin
/// tài khoản, gói đang dùng, khóa tài khoản, gán/gia hạn gói
/// và lịch sử gói.
class Mh31AdminChiTietTaiKhoanScreen extends StatelessWidget {
  const Mh31AdminChiTietTaiKhoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header tím đậm: cao 104px, phủ toàn chiều ngang ---
          // Nút quay lại "‹" trắng 34px + tiêu đề "Chi tiết tài
          // khoản" trắng 24px + "Quản trị" 13px #D9CFFF.
          // Nút quay lại không có trong thiết kế, thêm theo yêu
          // cầu của user cho giống các màn trước (nút Top 40,
          // tiêu đề Top 48, "Quản trị" Top 59 như MH-30).
          Container(
            width: double.infinity,
            height: kAdminHeaderHeight,
            color: kAdminHeaderBackground,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  // Quay về màn hình trước đó (MH-30).
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
                    'Chi tiết tài khoản',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: kSpacing20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header đáy -> thẻ tài khoản: 16px theo task.
                  const SizedBox(height: 16),

                  // --- Thẻ tài khoản 372x152 ---
                  Container(
                    width: double.infinity,
                    height: kAccountDetailCardHeight,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
                    decoration: BoxDecoration(
                      color: kSurface,
                      border: Border.all(color: kInputBorder, width: 1),
                      borderRadius:
                          BorderRadius.circular(kRadiusItem),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar tròn 56x56 với chữ cái đầu tên.
                            Container(
                              width: 56,
                              height: 56,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: kPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                mockAccountDetail.initial,
                                style: kDetailAvatarLetterStyle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Tên và email. Tên cách mép trên thẻ
                            // 18px (padding 16 + 2).
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mockAccountDetail.name,
                                    style: kDetailNameStyle,
                                  ),
                                  // Theo task: tên Top 18px,
                                  // email Top 47px (hộp chữ Figma
                                  // cao 27px, hộp Flutter cao 20px
                                  // nên gap là 9px).
                                  const SizedBox(height: 9),
                                  Text(
                                    mockAccountDetail.email,
                                    style: kDetailEmailStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Avatar đáy -> đường phân cách: 8px.
                        const SizedBox(height: 8),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: kInputBorder,
                        ),
                        // Đường phân cách -> vai trò: 10px.
                        const SizedBox(height: 10),
                        Text(
                          'Vai trò: ${mockAccountDetail.role}',
                          style: kDetailInfoStyle,
                        ),
                        // Vai trò -> trạng thái: 11px theo task
                        // (hộp chữ Figma cao 20px, hộp Flutter
                        // cao 15px nên gap là 11px).
                        const SizedBox(height: 11),
                        Row(
                          children: [
                            const Text(
                              'Trạng thái:',
                              style: kDetailInfoStyle,
                            ),
                            const SizedBox(width: 18),
                            Text(
                              mockAccountDetail.status,
                              style: kDetailStatusStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Thẻ tài khoản -> thẻ gói: 12px theo task.
                  const SizedBox(height: 12),

                  // --- Thẻ gói 372x84 ---
                  Container(
                    width: double.infinity,
                    height: kAccountCardHeight,
                    padding: const EdgeInsets.fromLTRB(16, 13, 16, 3),
                    decoration: BoxDecoration(
                      color: kSurface,
                      border: Border.all(color: kInputBorder, width: 1),
                      borderRadius:
                          BorderRadius.circular(kRadiusItem),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gói đang dùng', style: kLabelStyle),
                        // Theo task: nhãn Top 13px, tên gói
                        // Top 36px (hộp chữ Figma cao 18px,
                        // hộp Flutter cao 13px nên gap là 10px).
                        const SizedBox(height: 10),
                        Text(
                          mockAccountDetail.planName,
                          style: kPlanNameStyle,
                        ),
                        // Theo task: tên gói Top 36px, hạn gói
                        // Top 63px (hộp chữ Figma cao 25px,
                        // hộp Flutter cao 18px nên gap là 9px).
                        const SizedBox(height: 9),
                        Text(
                          mockAccountDetail.planExpiry,
                          style: kQuestionPreviewStyle,
                        ),
                      ],
                    ),
                  ),
                  // Thẻ gói -> nút khóa: 16px theo task.
                  const SizedBox(height: 16),

                  // --- Nút "Khóa tài khoản" 372x52 đỏ ---
                  SizedBox(
                    width: double.infinity,
                    height: kButtonHeight,
                    child: ElevatedButton(
                      // Chưa có logic thật ở giai đoạn giao diện.
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kHard,
                        foregroundColor: kOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            kRadiusButton,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Khóa tài khoản',
                        style: kButtonTextStyle,
                      ),
                    ),
                  ),
                  // Nút khóa -> hàng 2 nút: 12px theo task.
                  const SizedBox(height: 12),

                  // --- Hàng 2 nút: "Gán gói" và "Gia hạn gói" ---
                  // Dùng Expanded như MH-22 để không tràn trên
                  // máy ảo hẹp hơn 412px.
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: kButtonHeight,
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
                                borderRadius: BorderRadius.circular(
                                  kRadiusButton,
                                ),
                              ),
                            ),
                            child: Text(
                              'Gán gói',
                              style: kButtonTextStyle.copyWith(
                                color: kPrimary,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: kButtonHeight,
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
                                borderRadius: BorderRadius.circular(
                                  kRadiusButton,
                                ),
                              ),
                            ),
                            child: Text(
                              'Gia hạn gói',
                              style: kButtonTextStyle.copyWith(
                                color: kPrimary,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Hàng nút -> tiêu đề "Lịch sử gói": 12px.
                  const SizedBox(height: 12),
                  const Text('Lịch sử gói', style: kHeadingStyle),
                  // Tiêu đề -> thẻ lịch sử: 5px theo task.
                  const SizedBox(height: 5),

                  // --- Thẻ lịch sử gói 372x88 ---
                  Container(
                    width: double.infinity,
                    height: kHistoryCardHeight,
                    padding: const EdgeInsets.fromLTRB(16, 19, 16, 11),
                    decoration: BoxDecoration(
                      color: kSurface,
                      border: Border.all(color: kInputBorder, width: 1),
                      borderRadius:
                          BorderRadius.circular(kRadiusItem),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0;
                            i < mockAccountDetail.planHistory.length;
                            i++) ...[
                          if (i > 0) const SizedBox(height: 23),
                          _HistoryRow(
                            history: mockAccountDetail.planHistory[i],
                          ),
                        ],
                      ],
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

/// Một dòng lịch sử gói: ngày in đậm, hành động ở bên phải.
/// Chỉ dùng ở MH-31 nên để trong file màn hình này.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.history});

  final MockPlanHistory history;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(history.date, style: kHistoryDateStyle),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            history.action,
            style: kDetailInfoStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
