import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';
import '../widgets/difficulty_filter_chip_widget.dart';
import '../widgets/question_card_widget.dart';
import 'mh22_quan_ly_cau_hoi_mock.dart';

// ============================================================================
// Mã MH: MH-22 — Quản lý câu hỏi
// Tên màn hình: Quản lý câu hỏi (frame Figma: MH-22-quan-ly-cau-hoi,
// node 83-1412, khung 412 x 917, trang "Mockup màu").
// Thuộc luồng: L4 — Chủ sở hữu (Flow boards, flow-L4-chu-so-huu).
// Vào màn hình này từ đâu:
//   - Từ MH-20 Tạo/Sửa chủ đề, bấm "Lưu chủ đề".
//   - Từ MH-05 Chủ đề (màn của thành viên khác, chưa làm xong).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Bấm "Import Excel" -> MH-24 Import Excel (đích theo task).
//   - Bấm "+ Thêm câu hỏi" -> MH-23 Soạn/Sửa câu hỏi (đích theo task).
//   - Thẻ câu hỏi: không có interaction trong task, bấm chưa đi đâu.
//   - Thẻ AI: không có interaction trong task (trạng thái "Sắp có").
//   - Nút quay lại "<" -> quay về màn hình trước.
//   - Bottom nav (đích theo task):
//     Trang chủ -> MH-02, Chủ đề -> đang ở đây,
//     Thi đấu -> MH-17, Xếp hạng -> MH-14, Hồ sơ -> MH-03.
// Dữ liệu giả đang dùng ở đâu:
//   - File mh22_quan_ly_cau_hoi_mock.dart, biến mockQuestions
//     (3 câu theo task) và mockTopicTitle ("Toán cao cấp").
//   - Khối dữ liệu đó có ghi chú // MOCK: ở dòng đầu.
// Chức năng thật sẽ nối ở task nào:
//   - Để giai đoạn chức năng: lấy danh sách câu hỏi thật qua API,
//     lọc theo độ khó thật, import Excel thật, thêm/sửa câu hỏi thật.
//     Kiến trúc: app gọi API, API mới qua Firebase.
//
// SỐ ĐO: theo task MH-22, xem bảng
// đầy đủ trong mh22_figma_tokens.md. Font Nunito, nền #F6F4FF,
// tím #6C4CF1, chữ #1D1B2E, thẻ câu hỏi 372x72 viền 1px #E9E6F7,
// nút 180x52, tab lọc cao 28px, thẻ AI 372x88.
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như MH-20.
// ============================================================================

/// Màn hình MH-22: danh sách câu hỏi của một chủ đề,
/// kèm tab lọc theo độ khó và thẻ AI soạn nháp (Sắp có).
class Mh22QuanLyCauHoiScreen extends StatefulWidget {
  const Mh22QuanLyCauHoiScreen({super.key});

  @override
  State<Mh22QuanLyCauHoiScreen> createState() =>
      _Mh22QuanLyCauHoiScreenState();
}

class _Mh22QuanLyCauHoiScreenState extends State<Mh22QuanLyCauHoiScreen> {
  // Tab loc dang chon: all = Tất cả, easy = Dễ,
  // medium = Trung bình, hard = Khó.
  MockDifficulty _selectedDifficulty = MockDifficulty.all;

  // Tab đang chọn ở thanh điều hướng dưới. 1 = Chủ đề, vì màn này
  // thuộc luồng chủ đề.
  int _selectedIndex = 1;

  /// Danh sách câu hỏi sau khi lọc theo tab đang chọn.
  List<MockQuestion> get _visibleQuestions {
    if (_selectedDifficulty == MockDifficulty.all) {
      return mockQuestions;
    }
    return mockQuestions
        .where((q) => q.difficulty == _selectedDifficulty)
        .toList();
  }

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
                    'Câu hỏi — $mockTopicTitle',
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
                    // Đáy tiêu đề -> hàng tab: 35px.
                    const SizedBox(height: 23),
                    // Hàng tab lọc độ khó, cao 28px.
                    // Khoảng cách giữa các pill theo task: 10, 10, 2.
                    Row(
                      children: [
                        _buildFilterTab(
                          MockDifficulty.all,
                          'Tất cả',
                          72,
                        ),
                        const SizedBox(width: 10),
                        _buildFilterTab(
                          MockDifficulty.easy,
                          'Dễ',
                          40,
                        ),
                        const SizedBox(width: 10),
                        _buildFilterTab(
                          MockDifficulty.medium,
                          'Trung bình',
                          104,
                        ),
                        const SizedBox(width: 2),
                        _buildFilterTab(
                          MockDifficulty.hard,
                          'Khó',
                          48,
                        ),
                      ],
                    ),
                    // Đáy tab -> hàng nút: 14px.
                    const SizedBox(height: 14),

                    // Hàng nút: Import Excel (trái) — + Thêm câu hỏi (phải).
                    // Theo task mỗi nút 180x52, cách nhau 12px, tổng 372px.
                    // Máy thật rộng 411.4px nên 372 + lề 40 = 412.6px,
                    // tràn 0.571px — dùng Expanded để hai nút tự chia
                    // đều chiều rộng còn lại, vẫn giữ cao 52px và gap 12px.
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: kButtonHeight,
                            child: OutlinedButton(
                            onPressed: () {
                              // Đích theo task: MH-24 Import Excel.
                              Navigator.pushNamed(context, '/mh24');
                            },
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
                            child: const Text(
                              'Import Excel',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: kPrimary,
                                height: 1.0,
                              ),
                            ),
                          ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: kButtonHeight,
                            child: ElevatedButton(
                            onPressed: () {
                              // Đích theo task: MH-23 Soạn/Sửa câu hỏi.
                              Navigator.pushNamed(context, '/mh23');
                            },
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
                              '+ Thêm câu hỏi',
                              style: kButtonTextStyle,
                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Hàng nút -> thẻ đầu tiên: 16px.
                    const SizedBox(height: 16),

                    // Danh sách thẻ câu hỏi, thẻ cách nhau 12px.
                    ..._visibleQuestions.map(
                      (question) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: QuestionCard(question: question),
                      ),
                    ),

                    // Đáy thẻ cuối -> thẻ AI: 24px.
                    const SizedBox(height: 12),
                    const _AiDraftCard(),
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
      // Đích theo task: Trang chủ -> /mh02, Chủ đề -> đang ở đây,
      // Thi đấu -> /mh17, Xếp hạng -> /mh14, Hồ sơ -> /mh03.
      // Các màn đó chưa làm xong nên onTap hiện chỉ đổi tab đang chọn.
      // Khi các màn đó xong, thay bằng Navigator.pushNamed tương ứng.
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(
            top: BorderSide(color: kInputBorder, width: 1),
          ),
        ),
        child: SizedBox(
          height: 76,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: kSurface,
            elevation: 0,
            currentIndex: _selectedIndex,
            selectedItemColor: kPrimary,
            unselectedItemColor: kNavUnselected,
            selectedLabelStyle: kNavLabelStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
            unselectedLabelStyle: kNavLabelStyle,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.layers_outlined),
                label: 'Chủ đề',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined),
                label: 'Thi đấu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                label: 'Xếp hạng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Hồ sơ',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Một tab lọc độ khó. Mức đang chọn nền tím chữ trắng,
  /// mức chưa chọn nền #EFECFE chữ tím.
  Widget _buildFilterTab(
    MockDifficulty difficulty,
    String label,
    double width,
  ) {
    final bool selected = _selectedDifficulty == difficulty;
    return DifficultyFilterChip(
      label: label,
      width: width,
      backgroundColor:
          selected ? kPrimary : kTabUnselectedBackground,
      textColor: selected ? kOnPrimary : kPrimary,
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
    );
  }
}

/// Thẻ AI soạn nháp câu hỏi (372x88), trạng thái "Sắp có".
/// Chỉ dùng ở MH-22 nên để trong file màn hình này, không tách
/// ra widget dùng chung.
/// Theo task: nền trắng viền 1px #E9E6F7, phủ trắng 62% lên
/// toàn bộ thẻ (làm thẻ trông mờ), vòng tròn 44x44 nền #EFECFE
/// chữ "AI" tím, huy hiệu "Sắp có" nền #E5E7EB.
class _AiDraftCard extends StatelessWidget {
  const _AiDraftCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kAiCardHeight,
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 22, 16, 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vòng tròn AI 44x44.
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: kTabUnselectedBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI soạn nháp câu hỏi',
                        style: kQuestionTitleStyle,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tự động tạo câu hỏi từ tài liệu',
                        style: kQuestionPreviewStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Huy hiệu "Sắp có" 72x28.
                Container(
                  width: 72,
                  height: kTabHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kComingSoonBackground,
                    borderRadius: BorderRadius.circular(kRadiusItem),
                  ),
                  child: Text(
                    'Sắp có',
                    style: kDifficultyLabelStyle.copyWith(
                      color: kTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lớp phủ trắng 62% theo task, làm thẻ trông mờ.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.62),
                borderRadius: BorderRadius.circular(kRadiusItem),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
