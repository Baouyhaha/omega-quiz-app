import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';
import 'mh23_soan_sua_cau_hoi_mock.dart';

// ============================================================================
// Mã MH: MH-23 — Soạn/Sửa câu hỏi
// Tên màn hình: Soạn câu hỏi (frame Figma: MH-23-soan-sua-cau-hoi,
// node 83-1473, khung 412 x 917, trang "Mockup màu").
// Thuộc luồng: L4 — Chủ sở hữu (Flow boards, flow-L4-chu-so-huu).
// Vào màn hình này từ đâu:
//   - Từ MH-22 Quản lý câu hỏi, bấm "+ Thêm câu hỏi" (soạn mới).
//   - Từ MH-22, bấm thẻ câu hỏi để sửa (giai đoạn chức năng mới
//     nối bấm thẻ, hiện tại thẻ câu hỏi chưa có interaction theo task).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Bấm "Lưu câu hỏi" -> MH-22 Quản lý câu hỏi (đích theo task).
//   - Nút quay lại "<" -> quay về màn hình trước.
//   - Không có thanh điều hướng dưới trong task.
// Dữ liệu giả đang dùng ở đâu:
//   - File mh23_soan_sua_cau_hoi_mock.dart, biến mockQuestionDraft
//     (câu mẫu theo task, đáp án đúng là B) và mockQuestionDraftEmpty
//     (bản trống để soạn mới).
//   - Khối dữ liệu đó có ghi chú // MOCK: ở dòng đầu.
// Chức năng thật sẽ nối ở task nào:
//   - Để giai đoạn chức năng: lưu câu hỏi thật qua API, chọn đáp án
//     đúng thật, chọn mức độ thật. Kiến trúc: app gọi API, API mới
//     qua Firebase.
//
// SỐ ĐO: theo task MH-23, xem bảng đầy đủ trong mh23_figma_tokens.md.
// Font Nunito, nền #F6F4FF, tím #6C4CF1, chữ #1D1B2E, nhãn 13px 700
// #6E6A8A, ô nhập 372x52 trắng viền 1.5px #E9E6F7, chữ trong ô 15px,
// hàng đáp án 372x52, huy hiệu chữ cái 28x28, giá trị đáp án 18px 700,
// radio 22x22, nút Lưu 372x52 tím.
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như MH-20/MH-22.
// ============================================================================

/// Màn hình MH-23: soạn mới hoặc sửa một câu hỏi.
/// Tạo và sửa dùng chung một form (giống MH-20): sửa thì điền sẵn
/// dữ liệu mẫu, soạn mới thì để trống.
class Mh23SoanSuaCauHoiScreen extends StatefulWidget {
  const Mh23SoanSuaCauHoiScreen({super.key, this.isEdit = false});

  /// true = chế độ Sửa (điền sẵn dữ liệu), false = chế độ Soạn mới.
  final bool isEdit;

  @override
  State<Mh23SoanSuaCauHoiScreen> createState() =>
      _Mh23SoanSuaCauHoiScreenState();
}

class _Mh23SoanSuaCauHoiScreenState
    extends State<Mh23SoanSuaCauHoiScreen> {
  // Dữ liệu mẫu theo task: sửa thì lấy bản đã điền, soạn mới thì lấy bản trống.
  MockQuestionDraft get _draft =>
      widget.isEdit ? mockQuestionDraft : mockQuestionDraftEmpty;

  late final TextEditingController _contentController;
  late final List<TextEditingController> _answerControllers;
  late final TextEditingController _difficultyController;
  late final TextEditingController _timeController;
  late final TextEditingController _pointsController;
  late final TextEditingController _hintController;
  late final TextEditingController _explanationController;

  // Vị trí đáp án đúng đang chọn: 0 = A, 1 = B, 2 = C, 3 = D.
  // Theo task, đáp án đúng mẫu là B.
  late int _correctIndex;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: _draft.content);
    _answerControllers = _draft.answers
        .map((a) => TextEditingController(text: a))
        .toList();
    _difficultyController =
        TextEditingController(text: _draft.difficulty);
    _timeController =
        TextEditingController(text: _draft.timeSeconds.toString());
    _pointsController =
        TextEditingController(text: _draft.points.toString());
    _hintController = TextEditingController(text: _draft.hint);
    _explanationController =
        TextEditingController(text: _draft.explanation);
    _correctIndex = _draft.correctIndex;
  }

  @override
  void dispose() {
    _contentController.dispose();
    for (final c in _answerControllers) {
      c.dispose();
    }
    _difficultyController.dispose();
    _timeController.dispose();
    _pointsController.dispose();
    _hintController.dispose();
    _explanationController.dispose();
    super.dispose();
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
                    widget.isEdit ? 'Sửa câu hỏi' : 'Soạn câu hỏi',
                    style: kPageTitleStyle,
                  ),
                ],
              ),
            ),

            // --- Nội dung: cuộn được vì form dài hơn màn hình ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacing20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nhãn cách tiêu đề 10px theo task; padding dưới
                    // của header (12px) đã cho gần đúng nên không thêm.
                    const Text(
                      'Nội dung câu hỏi',
                      style: kLabelStyle,
                    ),
                    const SizedBox(height: kSpacing3),
                    _buildField(
                      controller: _contentController,
                      hint: 'Nhập nội dung câu hỏi',
                    ),
                    // Ô Nội dung -> nhãn Đáp án: 7px theo task.
                    const SizedBox(height: 7),
                    const Text(
                      'Đáp án — chọn đáp án đúng',
                      style: kLabelStyle,
                    ),
                    const SizedBox(height: kSpacing3),

                    // 4 hàng đáp án, hàng cách nhau 6px theo task.
                    // Bấm hàng hoặc radio để đổi đáp án đúng.
                    ...List.generate(4, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == 3 ? 0 : 6,
                        ),
                        child: _AnswerRow(
                          letter: 'ABCD'[index],
                          controller: _answerControllers[index],
                          selected: _correctIndex == index,
                          onTap: () {
                            setState(() {
                              _correctIndex = index;
                            });
                          },
                        ),
                      );
                    }),

                    // Đáy hàng D -> nhãn Mức độ: 0px theo task.
                    const Text('Mức độ', style: kLabelStyle),
                    const SizedBox(height: kSpacing3),
                    _buildField(
                      controller: _difficultyController,
                      readOnly: true,
                      suffixIcon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: kTextSecondary,
                      ),
                    ),
                    // Ô -> nhãn tiếp theo: 13px theo task.
                    const SizedBox(height: kSpacing13),
                    const Text('Thời gian (giây)', style: kLabelStyle),
                    const SizedBox(height: kSpacing3),
                    _buildField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: kSpacing13),
                    const Text('Điểm', style: kLabelStyle),
                    const SizedBox(height: kSpacing3),
                    _buildField(
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: kSpacing13),
                    const Text('Gợi ý', style: kLabelStyle),
                    const SizedBox(height: kSpacing3),
                    _buildField(
                      controller: _hintController,
                      hint: 'Nhập gợi ý cho người làm bài',
                    ),
                    const SizedBox(height: kSpacing13),
                    const Text('Giải thích', style: kLabelStyle),
                    const SizedBox(height: kSpacing3),
                    _buildField(
                      controller: _explanationController,
                      hint: 'Nhập giải thích đáp án đúng',
                    ),
                    // Ô Giải thích -> nút Lưu: 14px theo task.
                    const SizedBox(height: 14),
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
                        child: const Text(
                          'Lưu câu hỏi',
                          style: kButtonTextStyle,
                        ),
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
    );
  }

  /// Một ô nhập 372x52 theo task: nền trắng, viền 1.5px #E9E6F7,
  /// chữ trong ô 15px. Rộng theo màn hình (dùng double.infinity
  /// trong cột đã có lề 20px) để không tràn như hàng nút MH-22.
  Widget _buildField({
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: kFieldHeight,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: kFieldTextStyle,
        decoration: InputDecoration(
          hintText: widget.isEdit ? null : hint,
          hintStyle: kFieldTextStyle.copyWith(color: kNavUnselected),
          // Nền trắng theo task: TextField mặc định trong suốt nên
          // nền tím nhạt #F6F4FF của màn hình lộ ra, phải tô trắng.
          filled: true,
          fillColor: kSurface,
          border: kFieldBorder,
          enabledBorder: kFieldBorder,
          focusedBorder: kFieldFocusedBorder,
          contentPadding: kFieldPadding,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

/// Một hàng đáp án 372x52 theo task: huy hiệu chữ cái 28x28,
/// giá trị đáp án 18px 700, radio 22x22 ở mép phải.
/// Hàng đang chọn viền 2px tím, hàng chưa chọn viền 1.5px #E9E6F7.
/// Chỉ dùng ở MH-23 nên để trong file màn hình này.
class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.letter,
    required this.controller,
    required this.selected,
    required this.onTap,
  });

  /// Chữ cái A, B, C hoặc D.
  final String letter;

  /// Giá trị đáp án người dùng nhập.
  final TextEditingController controller;

  /// true = đáp án đúng đang được chọn.
  final bool selected;

  /// Bấm để chọn đáp án này làm đáp án đúng.
  final VoidCallback onTap;

  Color get _badgeColor {
    switch (letter) {
      case 'A':
        return kOptionA;
      case 'B':
        return kOptionB;
      case 'C':
        return kOptionC;
      case 'D':
        return kOptionD;
      default:
        return kPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: kFieldHeight,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(
            color: selected ? kPrimary : kInputBorder,
            width: selected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(kRadiusItem),
        ),
        child: Row(
          children: [
            // Huy hiệu chữ cái 28x28.
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _badgeColor,
                shape: BoxShape.circle,
              ),
              child: Text(letter, style: kAnswerBadgeStyle),
            ),
            const SizedBox(width: 10),
            // Giá trị đáp án, nhập được trực tiếp trong hàng.
            // Chữ phải ngang hàng với huy hiệu chữ cái (cao 28px):
            // bản không isCollapsed thì chữ thấp quá, bản isCollapsed
            // thì chữ cao quá, nên giữ isCollapsed và chèn thêm
            // padding trên 4px để đẩy chữ xuống đúng giữa huy hiệu.
            Expanded(
              child: SizedBox(
                height: 28,
                child: TextField(
                  controller: controller,
                  style: kAnswerValueStyle,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.only(top: 4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Radio 22x22, vẽ bằng Container (theo cách đã sửa
            // ở MH-20: Radio có sẵn của Flutter có vùng bấm 40x40
            // nên không căn đúng 22x22 theo task).
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? kPrimary : kRadioBorder,
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
