import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';
import 'mh27_thong_ke_chu_de_mock.dart';

// ============================================================================
// Mã MH: MH-27 — Thống kê chủ đề
// Tên màn hình: Thống kê chủ đề (frame Figma: MH-27-thong-ke-chu-de,
// node 83-1697, khung 412 x 917, trang "Mockup màu").
// Thuộc luồng: L4 — Chủ sở hữu (Flow boards, flow-L4-chu-so-huu).
// Vào màn hình này từ đâu:
//   - Từ màn chủ đề (màn của thành viên khác, chưa làm xong).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Nút quay lại "<" -> quay về màn hình trước.
//   - Bottom nav (đích theo task):
//     Trang chủ -> MH-02, Chủ đề -> MH-05, Thi đấu -> MH-17,
//     Xếp hạng -> MH-14, Hồ sơ -> MH-03.
//   - Các thẻ thống kê, thẻ bộ đề và hàng thành viên không có
//     interaction trong task.
// Dữ liệu giả đang dùng ở đâu:
//   - File mh27_thong_ke_chu_de_mock.dart: 3 thẻ thống kê,
//     2 bộ đề, 2 thành viên tích cực.
//   - Khối dữ liệu đó có ghi chú // MOCK: ở dòng đầu.
// Chức năng thật sẽ nối ở task nào:
//   - Để giai đoạn chức năng: lấy số liệu thống kê thật qua API.
//     Kiến trúc: app gọi API, API mới qua Firebase.
//
// SỐ ĐO: theo task MH-27, xem bảng đầy đủ trong mh27_figma_tokens.md.
// Font Nunito, nền #F6F4FF, tím #6C4CF1, chữ #1D1B2E, thẻ thống kê
// 116x96, thẻ bộ đề 372x76, hàng thành viên 372x64,
// thanh điều hướng dưới 412x76 (không mục nào được chọn theo task).
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như các màn trước; riêng thanh tiến trình 8px dùng bo 4px.
// ============================================================================

/// Màn hình MH-27: thống kê của một chủ đề — 3 thẻ tổng,
/// tỉ lệ đúng theo bộ đề và thành viên tích cực.
class Mh27ThongKeChuDeScreen extends StatefulWidget {
  const Mh27ThongKeChuDeScreen({super.key});

  @override
  State<Mh27ThongKeChuDeScreen> createState() =>
      _Mh27ThongKeChuDeScreenState();
}

class _Mh27ThongKeChuDeScreenState
    extends State<Mh27ThongKeChuDeScreen> {
  // Tab đang chọn ở thanh điều hướng dưới. -1 = chưa mục nào được
  // chọn, đúng như task (cả 5 mục đều xám #9A94B8 lúc mở màn).
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Hàng tiêu đề: nút quay lại "‹" 34px + tiêu đề 24px ---
            // Theo task: nút Left 20px, tiêu đề Left 52px (cách nút 22px).
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kSpacing20,
                kSpacing12,
                kSpacing20,
                kSpacing12,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    // Quay về màn hình trước đó.
                    onTap: () => Navigator.pop(context),
                    child: const Text('‹', style: kBackStyle),
                  ),
                  const SizedBox(width: 22),
                  Text(
                    'Thống kê — $mockTopicTitle',
                    style: kPageTitleStyle,
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
                    // Đáy tiêu đề -> hàng thẻ thống kê: 35px theo task,
                    // trừ 12px padding dưới của header còn 23px.
                    const SizedBox(height: 23),

                    // 3 thẻ thống kê, thẻ cách nhau 12px theo task.
                    Row(
                      children: [
                        for (int i = 0; i < mockStatCards.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(child: _StatCard(card: mockStatCards[i])),
                        ],
                      ],
                    ),
                    // Thẻ thống kê -> tiêu đề "Theo bộ đề": 20px.
                    const SizedBox(height: 20),
                    const Text('Theo bộ đề', style: kHeadingStyle),
                    // Tiêu đề -> thẻ bộ đề đầu tiên: 5px theo task.
                    const SizedBox(height: 5),

                    // 2 thẻ bộ đề, thẻ cách nhau 12px theo task.
                    ...mockExamStats.map(
                      (exam) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExamStatCard(exam: exam),
                      ),
                    ),
                    // Thẻ bộ đề cuối -> tiêu đề "Thành viên tích cực":
                    // 16px theo task, trừ 12px padding dưới của thẻ
                    // cuối còn 4px.
                    const SizedBox(height: 4),
                    const Text(
                      'Thành viên tích cực',
                      style: kHeadingStyle,
                    ),
                    // Tiêu đề -> hàng thành viên đầu tiên: 5px.
                    const SizedBox(height: 5),

                    // 2 hàng thành viên, hàng cách nhau 12px theo task.
                    ...mockActiveMembers.map(
                      (member) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ActiveMemberRow(member: member),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // --- Thanh điều hướng dưới: cao 76px, nền trắng,
      // đường phân cách trên 1px #E9E6F7, nhãn 12px #9A94B8 ---
      // Đích theo task: Trang chủ -> MH-02, Chủ đề -> MH-05,
      // Thi đấu -> MH-17, Xếp hạng -> MH-14, Hồ sơ -> MH-03.
      // Các màn đó chưa làm xong nên onTap hiện chỉ đổi tab đang chọn.
      // Khi các màn đó xong, thay bằng Navigator.pushNamed tương ứng.
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(
            top: BorderSide(color: kInputBorder, width: 1),
          ),
        ),
        height: 76,
        child: Row(
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Trang chủ'),
            _buildNavItem(1, Icons.layers_outlined, 'Chủ đề'),
            _buildNavItem(2, Icons.emoji_events_outlined, 'Thi đấu'),
            _buildNavItem(3, Icons.bar_chart_outlined, 'Xếp hạng'),
            _buildNavItem(4, Icons.person_outline, 'Hồ sơ'),
          ],
        ),
      ),
    );
  }

  /// Một mục ở thanh điều hướng dưới. Lúc mở màn chưa mục nào
  /// được chọn theo task (tất cả xám); bấm vào thì mục đó tím lên.
  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool selected = _selectedIndex == index;
    final Color color = selected ? kPrimary : kNavUnselected;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: kNavLabelStyle.copyWith(
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Một thẻ thống kê 116x96 theo task: giá trị 24px 700 căn giữa,
/// nhãn 13px #6E6A8A căn giữa. Chỉ dùng ở MH-27 nên để trong
/// file màn hình này.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.card});

  final MockStatCard card;

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.value,
            style: kStatValueStyle.copyWith(color: card.color),
          ),
          const SizedBox(height: 4),
          Text(
            card.label,
            style: kQuestionPreviewStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Một thẻ bộ đề 372x76 theo task: tên bộ đề và phần trăm ở hàng
/// trên, thanh tiến trình ở dưới. Chỉ dùng ở MH-27 nên để trong
/// file màn hình này.
class _ExamStatCard extends StatelessWidget {
  const _ExamStatCard({required this.exam});

  final MockExamStat exam;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kExamCardHeight,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 0),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exam.name,
                  style: kQuestionTitleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(exam.percent * 100).round()}%',
                style: kQuestionTitleStyle.copyWith(color: kPrimary),
              ),
            ],
          ),
          // Nhãn -> thanh tiến trình: 11px theo task.
          const SizedBox(height: 11),
          Container(
            width: double.infinity,
            height: kProgressBarHeight,
            decoration: BoxDecoration(
              color: kProgressTrackBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: exam.percent,
              child: Container(
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Một hàng thành viên 372x64 theo task: avatar tròn 40x40,
/// tên và dòng phụ, số lượt làm ở mép phải.
/// Chỉ dùng ở MH-27 nên để trong file màn hình này.
class _ActiveMemberRow extends StatelessWidget {
  const _ActiveMemberRow({required this.member});

  final MockActiveMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kMemberRowHeight,
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Row(
        children: [
          // Avatar tròn 40x40 với chữ cái đầu tên.
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: member.avatarColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              member.initial,
              style: kAvatarLetterStyle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(member.name, style: kQuestionTitleStyle),
                const SizedBox(height: 4),
                Text(
                  '${member.rank} • ${member.points} điểm',
                  style: kQuestionPreviewStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${member.attempts} lượt làm',
            style: kWarningTextStyle.copyWith(color: kPrimary),
          ),
        ],
      ),
    );
  }
}
