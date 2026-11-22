import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';
import 'mh30_admin_tai_khoan_mock.dart';

// ============================================================================
// Mã MH: MH-30 — Admin: Tài khoản
// Tên màn hình: Tài khoản (frame Figma: MH-30-admin-tai-khoan,
// node 83-125, khung 412 x 917, trang "Mockup màu").
// Thuộc luồng: L5 — Admin (Flow boards, flow-L5-admin).
// Vào màn hình này từ đâu:
//   - Từ màn quản trị (màn của thành viên khác, chưa làm xong).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Bấm vào thẻ Danh -> MH-31 Admin: Chi tiết tài khoản
//     (đích theo task, làm ở màn sau).
//   - Các thẻ Uy, Thịnh, chip lọc, ô tìm kiếm, nút "Khóa"/"Mở khóa"
//     không có interaction trong task.
//   - Không có nút quay lại và không có thanh điều hướng dưới
//     trong thiết kế của màn này.
// Dữ liệu giả đang dùng ở đâu:
//   - File mh30_admin_tai_khoan_mock.dart: 3 tài khoản,
//     số lượng hiển thị 3 / tổng 128.
//   - Khối dữ liệu đó có ghi chú // MOCK: ở dòng đầu.
// Chức năng thật sẽ nối ở task nào:
//   - Để giai đoạn chức năng: tìm kiếm, lọc, khóa/mở khóa thật qua API.
//     Kiến trúc: app gọi API, API mới qua Firebase.
//
// SỐ ĐO: theo task MH-30, xem bảng đầy đủ trong mh30_figma_tokens.md.
// Font Nunito, nền #F6F4FF, header tím đậm #4A32B8 cao 104px,
// tiêu đề trắng 24px, ô tìm kiếm 372x48, chip lọc cao 28px,
// thẻ tài khoản 372x84, avatar tròn 44x44.
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như các màn trước; riêng chip lọc dùng bo 14px, nút hành động
// dùng bo 15px.
// ============================================================================

/// Màn hình MH-30: danh sách tài khoản cho admin — tìm kiếm,
/// lọc theo trạng thái, khóa/mở khóa tài khoản.
class Mh30AdminTaiKhoanScreen extends StatefulWidget {
  const Mh30AdminTaiKhoanScreen({super.key});

  @override
  State<Mh30AdminTaiKhoanScreen> createState() =>
      _Mh30AdminTaiKhoanScreenState();
}

class _Mh30AdminTaiKhoanScreenState
    extends State<Mh30AdminTaiKhoanScreen> {
  // Chip lọc đang chọn: 0 = Tất cả, 1 = Đang hoạt động, 2 = Bị khóa.
  // Theo task, lúc mở màn chip "Tất cả" đang chọn.
  int _selectedFilter = 0;

  // Các chip lọc theo task, đúng thứ tự và chiều rộng trong Figma.
  static const List<String> _filterLabels = [
    'Tất cả',
    'Đang hoạt động',
    'Bị khóa',
  ];
  static const List<double> _filterWidths = [72, 136, 80];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header tím đậm: cao 104px, phủ toàn chiều ngang ---
          // Tiêu đề "Tài khoản" trắng 24px, "Quản trị" 13px #D9CFFF.
          Container(
            width: double.infinity,
            height: kAdminHeaderHeight,
            color: kAdminHeaderBackground,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tài khoản', style: kAdminHeaderTitleStyle),
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
                  // Header đáy -> ô tìm kiếm: 16px theo task.
                  const SizedBox(height: 16),

                  // Ô tìm kiếm 372x48, không có icon kính lúp theo task.
                  SizedBox(
                    width: double.infinity,
                    height: kSearchHeight,
                    child: TextField(
                      style: kFieldTextStyle,
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên/email...',
                        hintStyle: kFieldTextStyle.copyWith(
                          color: kTextSecondary,
                        ),
                        filled: true,
                        fillColor: kSurface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            kRadiusItem,
                          ),
                          borderSide: const BorderSide(
                            color: kInputBorder,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            kRadiusItem,
                          ),
                          borderSide: const BorderSide(
                            color: kInputBorder,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            kRadiusItem,
                          ),
                          borderSide: const BorderSide(
                            color: kPrimary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Ô tìm kiếm -> hàng chip lọc: 16px theo task.
                  const SizedBox(height: 16),

                  // 3 chip lọc. Khoảng cách theo task: chip 1 -> 2
                  // là 16px, chip 2 -> 3 là 8px.
                  Row(
                    children: [
                      for (int i = 0; i < _filterLabels.length; i++) ...[
                        if (i == 1) const SizedBox(width: 16),
                        if (i == 2) const SizedBox(width: 8),
                        _FilterChip(
                          label: _filterLabels[i],
                          width: _filterWidths[i],
                          selected: _selectedFilter == i,
                          onTap: () {
                            setState(() {
                              _selectedFilter = i;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                  // Chip lọc -> thẻ tài khoản đầu tiên: 16px.
                  const SizedBox(height: 16),

                  // 3 thẻ tài khoản, thẻ cách nhau 12px theo task.
                  // Chỉ thẻ Danh có interaction theo task (bấm vào
                  // sang MH-31); các thẻ còn lại bấm vào không đi đâu.
                  ...mockAdminAccounts.map(
                    (account) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AccountCard(
                        account: account,
                        onTap: account.name == 'Danh'
                            ? () {
                                // Đích theo task: MH-31 Chi tiết
                                // tài khoản. Route /mh31 sẽ có khi
                                // làm xong MH-31 ở màn sau.
                                Navigator.pushNamed(context, '/mh31');
                              }
                            : null,
                      ),
                    ),
                  ),
                  // Thẻ cuối -> chân trang: 15px theo task, trừ 12px
                  // padding dưới của thẻ cuối còn 3px.
                  const SizedBox(height: 3),
                  Center(
                    child: Text(
                      'Hiển thị $mockShownAccountCount / '
                      '$mockTotalAccountCount tài khoản',
                      style: kQuestionPreviewStyle,
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

/// Một chip lọc cao 28px theo task, hình viên thuốc (bo 14px).
/// Chỉ dùng ở MH-30 nên để trong file màn hình này.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: kTabHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              selected ? kPrimary : kTabUnselectedBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: kDifficultyLabelStyle.copyWith(
            color: selected ? kOnPrimary : kPrimary,
          ),
        ),
      ),
    );
  }
}

/// Một thẻ tài khoản 372x84 theo task: avatar tròn 44x44,
/// tên và dòng "vai trò · gói", trạng thái ở mép phải,
/// nút "Khóa"/"Mở khóa" ở góc dưới phải (nếu có).
/// Chỉ dùng ở MH-30 nên để trong file màn hình này.
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.onTap});

  final MockAdminAccount account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool locked =
        account.status == MockAccountStatus.locked;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: kAccountCardHeight,
        padding: const EdgeInsets.fromLTRB(14, 17, 16, 8),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kInputBorder, width: 1),
          borderRadius: BorderRadius.circular(kRadiusItem),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar tròn 44x44 với chữ cái đầu tên,
            // cách mép trên thẻ 20px (padding 17 + 3).
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: account.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  account.initial,
                  style: kAccountAvatarLetterStyle,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name, style: kAccountNameStyle),
                  // Theo task: tên Top 17px, dòng phụ Top 45px
                  // (cách nhau 5px theo hộp chữ Figma cao 23px,
                  // hộp chữ Flutter chỉ cao 17px nên gap là 11px).
                  const SizedBox(height: 11),
                  Text(
                    '${account.role} · ${account.plan}',
                    style: kQuestionPreviewStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Cột phải cao bằng chiều cao còn lại của thẻ
            // (84 - 17 - 8 = 59px), trạng thái ở trên cùng,
            // nút ở dưới cùng — đúng vị trí theo task
            // (trạng thái Top 19px, nút đáy cách đáy thẻ 8px)
            // mà không cộng dồn chiều cao nên không tràn.
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Trạng thái chỉ là chữ màu, không có nền pill.
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    locked ? 'Bị khóa' : 'Đang hoạt động',
                    style: kDifficultyLabelStyle.copyWith(
                      color: locked ? kHard : kEasy,
                    ),
                  ),
                ),
                // Nút hành động: "Khóa" đỏ hoặc "Mở khóa" xanh,
                // thẻ Uy không có nút.
                if (account.action != MockAccountAction.none)
                  SizedBox(
                    width: locked ? 72 : 60,
                    height: kActionButtonHeight,
                    child: OutlinedButton(
                      // Chưa có logic thật ở giai đoạn giao diện.
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: kSurface,
                        padding: EdgeInsets.zero,
                        side: BorderSide(
                          color: locked ? kEasy : kHard,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        locked ? 'Mở khóa' : 'Khóa',
                        style: kActionButtonTextStyle.copyWith(
                          color: locked ? kEasy : kHard,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
