import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';
import 'mh24_import_excel_mock.dart';

// ============================================================================
// Mã MH: MH-24 — Import Excel
// Tên màn hình: Import Excel (frame Figma: MH-24-import-excel,
// node 83-1523, khung 412 x 917, trang "Mockup màu").
// Thuộc luồng: L4 — Chủ sở hữu (Flow boards, flow-L4-chu-so-huu).
// Vào màn hình này từ đâu:
//   - Từ MH-22 Quản lý câu hỏi, bấm "Import Excel".
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Bấm "Xác nhận nhập 18 câu" -> MH-22 Quản lý câu hỏi
//     (đích theo task).
//   - Nút quay lại "<" -> quay về màn hình trước.
//   - Bottom nav (đích theo task):
//     Trang chủ -> MH-02, Chủ đề -> MH-05, Thi đấu -> MH-17,
//     Xếp hạng -> MH-14, Hồ sơ -> MH-03.
//   - Nút "Chọn file khác" không có interaction trong task.
// Dữ liệu giả đang dùng ở đâu:
//   - File mh24_import_excel_mock.dart: tên file, tiến trình 65%,
//     3 dòng xem trước, 2 lỗi theo dòng, 18/20 câu hợp lệ.
//   - Khối dữ liệu đó có ghi chú // MOCK: ở dòng đầu.
// Chức năng thật sẽ nối ở task nào:
//   - Để giai đoạn chức năng: chọn file Excel thật, đọc file thật
//     qua API, nhập các câu hợp lệ thật. Kiến trúc: app gọi API,
//     API mới qua Firebase.
//
// SỐ ĐO: theo task MH-24, xem bảng đầy đủ trong mh24_figma_tokens.md.
// Font Nunito, nền #F6F4FF, tím #6C4CF1, chữ #1D1B2E, thẻ file
// 372x104, thanh tiến trình 372x8, dòng xem trước 372x56,
// hộp lỗi 372x64 nền #FFE9E9, nút xác nhận 372x52 tím,
// thanh điều hướng dưới 412x76 (không mục nào được chọn theo task).
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như MH-20/22/23; riêng thanh tiến trình 8px dùng bo 4px.
// ============================================================================

/// Màn hình MH-24: nhập câu hỏi từ file Excel, xem trước từng dòng,
/// xem lỗi theo dòng rồi xác nhận nhập các câu hợp lệ.
class Mh24ImportExcelScreen extends StatefulWidget {
  const Mh24ImportExcelScreen({super.key});

  @override
  State<Mh24ImportExcelScreen> createState() =>
      _Mh24ImportExcelScreenState();
}

class _Mh24ImportExcelScreenState extends State<Mh24ImportExcelScreen> {
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
                  const Text('Import Excel', style: kPageTitleStyle),
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
                    // Đáy tiêu đề -> thẻ file: 35px theo task,
                    // trừ 12px padding dưới của header còn 23px.
                    const SizedBox(height: 23),
                    const _SelectedFileCard(),
                    // Thẻ file -> dòng tiến trình: 17px theo task.
                    const SizedBox(height: 17),
                    Text(
                      'Đang đọc file... '
                      '${(mockImportProgress * 100).round()}%',
                      style: kWarningTextStyle,
                    ),
                    // Dòng chữ -> thanh tiến trình: 7px theo task.
                    const SizedBox(height: 7),
                    Container(
                      width: double.infinity,
                      height: kProgressBarHeight,
                      decoration: BoxDecoration(
                        color: kProgressTrackBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: mockImportProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    // Thanh tiến trình -> tiêu đề "Xem trước": 12px.
                    const SizedBox(height: 12),
                    const Text('Xem trước', style: kHeadingStyle),
                    // Tiêu đề -> dòng xem trước đầu tiên: 5px.
                    const SizedBox(height: 5),

                    // 3 dòng xem trước, dòng cách nhau 10px theo task.
                    ...mockPreviewRows.map(
                      (row) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PreviewRow(row: row),
                      ),
                    ),
                    // Dòng cuối -> tiêu đề "Lỗi theo dòng": 16px,
                    // trừ 10px padding dưới của dòng cuối còn 6px.
                    const SizedBox(height: 6),
                    const Text('Lỗi theo dòng', style: kHeadingStyle),
                    // Tiêu đề -> hộp lỗi: 5px theo task.
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      height: kErrorBoxHeight,
                      padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
                      decoration: BoxDecoration(
                        color: kHardBackground,
                        borderRadius:
                            BorderRadius.circular(kRadiusItem),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mockImportErrors[0],
                            style: kErrorTextStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mockImportErrors[1],
                            style: kErrorTextStyle,
                          ),
                        ],
                      ),
                    ),
                    // Hộp lỗi -> dòng tổng kết: 20px theo task.
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        '$mockValidQuestionCount/'
                        '$mockTotalQuestionCount câu hợp lệ',
                        style: kHeadingStyle,
                      ),
                    ),
                    // Dòng tổng kết -> nút xác nhận: 106px theo task.
                    const SizedBox(height: 106),
                    SizedBox(
                      width: double.infinity,
                      height: kButtonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Đích theo task: MH-22 Quản lý câu hỏi.
                          Navigator.pushNamed(context, '/mh22');
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
                        child: Text(
                          'Xác nhận nhập $mockValidQuestionCount câu',
                          style: kButtonTextStyle,
                        ),
                      ),
                    ),
                    // Nút xác nhận -> thanh điều hướng: 20px theo task.
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

/// Thẻ file đã chọn 372x104 theo task: nhãn "Đã chọn:", tên file,
/// nút "Chọn file khác". Chỉ dùng ở MH-24 nên để trong file này.
class _SelectedFileCard extends StatelessWidget {
  const _SelectedFileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kFileCardHeight,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 10),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Đã chọn:', style: kLabelStyle),
          const SizedBox(height: 4),
          Text(
            mockImportFileName,
            style: kFieldTextStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: 160,
            height: 32,
            child: OutlinedButton(
              // Nút này không có interaction trong task.
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: kSurface,
                side: const BorderSide(color: kPrimary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kRadiusButton),
                ),
              ),
              child: const Text(
                'Chọn file khác',
                style: kChooseFileTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Một dòng xem trước 372x56 theo task: vòng tròn trạng thái
/// (tick xanh khi hợp lệ, X đỏ khi lỗi), nội dung dòng, nhãn
/// trạng thái ở mép phải. Chỉ dùng ở MH-24 nên để trong file này.
class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.row});

  final MockPreviewRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kPreviewRowHeight,
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Row(
        children: [
          // Vòng tròn trạng thái 24x24.
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: row.valid ? kEasy : kHard,
              shape: BoxShape.circle,
            ),
            child: Icon(
              row.valid ? Icons.check : Icons.close,
              size: 14,
              color: kOnPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${row.label} — ${row.preview}',
              style: kFieldTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            row.valid ? 'Hợp lệ' : 'Lỗi',
            style: kDifficultyLabelStyle.copyWith(
              color: row.valid ? kEasy : kHard,
            ),
          ),
        ],
      ),
    );
  }
}
