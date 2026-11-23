import 'package:flutter/material.dart';

import '../core/dinh_api.dart';
import '../core/dinh_theme.dart';
import 'mh23_soan_sua_cau_hoi_mock.dart';

// ============================================================================
// Mã MH: MH-23 — Soạn/Sửa câu hỏi
// Tên màn hình: Soạn câu hỏi (frame Figma: MH-23-soan-sua-cau-hoi,
// node 83-1473, khung 412 x 917, trang "Mockup màu").
// Thuộc luồng: L4 — Chủ sở hữu (Flow boards, flow-L4-chu-so-huu).
// Vào màn hình này từ đâu:
//   - Từ MH-22 Quản lý câu hỏi, bấm "+ Thêm câu hỏi" (soạn mới).
//   - Từ MH-22, bấm thẻ câu hỏi để sửa (nối ở T18 bước 2).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Bấm "Lưu câu hỏi" -> validate đạt thì gọi API lưu (POST #17
//     khi soạn mới, PATCH #18 khi sửa), lưu xong quay về MH-22;
//     validate không đạt thì ở lại và báo đỏ.
//   - Nút quay lại "<" -> quay về màn hình trước.
//   - Không có thanh điều hướng dưới trong task.
// Dữ liệu giả đang dùng ở đâu:
//   - File mh23_soan_sua_cau_hoi_mock.dart, biến mockQuestionDraft
//     (câu mẫu theo task, đáp án đúng là B) và mockQuestionDraftEmpty
//     (bản trống để soạn mới). Chỉ dùng khi mở màn hình không kèm
//     câu hỏi (chạy thử độc lập); MH-22 mở sửa thì điền từ câu
//     hỏi thật lấy từ API.
//   - Khối dữ liệu đó có ghi chú // MOCK: ở dòng đầu.
// Chức năng thật sẽ nối ở task nào:
//   - T18 bước 1 (đã làm ở file này): validate form — nội dung và
//     4 đáp án không được trống, đáp án đúng đang chọn phải có nội
//     dung, mức độ phải chọn 1 trong 3, thời gian và điểm phải là
//     số nguyên lớn hơn 0; gợi ý và giải thích không bắt buộc.
//   - T18 bước 2 (đã làm ở file này): nút Lưu gọi DinhApi —
//     POST #17 khi soạn mới, PATCH #18 khi sửa. Field đáp án đúng
//     gửi lên API là "correctOption" (không phải correctIndex).
//     Nút "Xóa câu hỏi" ở góc phải trên ô Nội dung (chỉ ở chế
//     độ Sửa khi MH-22 mở kèm câu hỏi thật) gọi DELETE #19 sau
//     khi xác nhận, xóa xong quay về MH-22 tải lại danh sách.
//     Kiến trúc: app gọi API, API mới qua Firebase.
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
/// dữ liệu, soạn mới thì để trống.
class Mh23SoanSuaCauHoiScreen extends StatefulWidget {
  const Mh23SoanSuaCauHoiScreen({
    super.key,
    this.isEdit = false,
    this.topicId = 'topic_anh',
    this.existing,
  });

  /// true = chế độ Sửa (điền sẵn dữ liệu), false = chế độ Soạn mới.
  final bool isEdit;

  /// Id chủ đề câu hỏi thuộc về (mặc định topic_anh của dinh).
  final String topicId;

  /// Câu hỏi đang sửa (lấy từ API qua MH-22). null = soạn mới
  /// hoặc chạy thử độc lập (dùng dữ liệu mẫu).
  final ApiQuestion? existing;

  @override
  State<Mh23SoanSuaCauHoiScreen> createState() =>
      _Mh23SoanSuaCauHoiScreenState();
}

class _Mh23SoanSuaCauHoiScreenState
    extends State<Mh23SoanSuaCauHoiScreen> {
  // Dữ liệu mẫu theo task: sửa thì lấy bản đã điền, soạn mới thì lấy bản trống.
  // MH-22 mở sửa thì ưu tiên câu hỏi thật (existing) thay cho mẫu.
  MockQuestionDraft get _draft =>
      widget.isEdit ? mockQuestionDraft : mockQuestionDraftEmpty;

  /// Key của Form — dùng để chạy validate khi bấm Lưu.
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _contentController;
  late final List<TextEditingController> _answerControllers;
  late final TextEditingController _timeController;
  late final TextEditingController _pointsController;
  late final TextEditingController _hintController;
  late final TextEditingController _explanationController;

  /// Mức độ đang chọn: 1 trong 3 giá trị "Dễ" / "Trung bình" / "Khó".
  late String _difficulty;

  // Vị trí đáp án đúng đang chọn: 0 = A, 1 = B, 2 = C, 3 = D.
  // Theo task, đáp án đúng mẫu là B.
  late int _correctIndex;

  /// Dòng báo lỗi chung của nhóm đáp án (null = không lỗi).
  /// Hàng đáp án là ô cố định 52px nên không gắn errorText vào
  /// từng hàng được — lỗi hiện bằng viền đỏ ở hàng trống + 1 dòng
  /// chữ đỏ dưới nhóm đáp án.
  String? _answersError;

  /// Vị trí các đáp án đang trống sau lần bấm Lưu gần nhất,
  /// để tô viền đỏ đúng hàng.
  Set<int> _emptyAnswers = {};

  /// true = đang chờ API lưu (nút Lưu mờ + hiện vòng xoay).
  bool _saving = false;

  /// true = đang chờ API xóa (nút Xóa mờ).
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _contentController = TextEditingController(
      text: existing?.content ?? _draft.content,
    );
    _answerControllers = (existing?.options ?? _draft.answers)
        .map((a) => TextEditingController(text: a))
        .toList();
    _difficulty = existing?.difficultyVi ?? _draft.difficulty;
    _timeController = TextEditingController(
      text: (existing?.timeSeconds ?? _draft.timeSeconds).toString(),
    );
    _pointsController = TextEditingController(
      text: (existing?.points ?? _draft.points).toString(),
    );
    _hintController = TextEditingController(
      text: existing?.hint ?? _draft.hint,
    );
    _explanationController = TextEditingController(
      text: existing?.explanation ?? _draft.explanation,
    );
    _correctIndex = existing?.correctOption ?? _draft.correctIndex;
  }

  @override
  void dispose() {
    _contentController.dispose();
    for (final c in _answerControllers) {
      c.dispose();
    }
    _timeController.dispose();
    _pointsController.dispose();
    _hintController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  /// Validate nhóm đáp án (T18 bước 1): đủ 4 đáp án không trống,
  /// đáp án đúng đang chọn phải có nội dung. Radio luôn chọn đúng
  /// 1 đáp án nên quy tắc "đúng 1 đáp án đúng" được giữ bằng cấu
  /// trúc chọn; lỗi chỉ xảy ra khi đáp án đang chọn bị để trống.
  String? _validateAnswers() {
    final empty = <int>[];
    for (var i = 0; i < 4; i++) {
      if (_answerControllers[i].text.trim().isEmpty) {
        empty.add(i);
      }
    }
    _emptyAnswers = empty.toSet();
    if (empty.isNotEmpty) {
      final letters = empty.map((i) => 'ABCD'[i]).join(', ');
      return 'Điền đủ 4 đáp án (đang trống: $letters).';
    }
    if (_answerControllers[_correctIndex].text.trim().isEmpty) {
      return 'Đáp án đúng đang chọn chưa có nội dung.';
    }
    return null;
  }

  /// Bấm "Lưu câu hỏi": chạy validate toàn form. Không đạt thì ở
  /// lại màn hình, trường lỗi báo đỏ + SnackBar; đạt thì gọi API
  /// lưu (POST #17 khi soạn mới, PATCH #18 khi sửa). Lưu xong
  /// quay về MH-22 với kết quả true để MH-22 tải lại danh sách.
  Future<void> _save() async {
    if (_saving) return;
    final formOk = _formKey.currentState!.validate();
    final answersError = _validateAnswers();
    setState(() {
      _answersError = answersError;
    });
    if (!formOk || answersError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chưa đủ thông tin — kiểm tra lại các trường báo đỏ.',
          ),
        ),
      );
      return;
    }

    // Body gửi lên API: field đáp án đúng là "correctOption".
    final body = {
      'content': _contentController.text.trim(),
      'options':
          _answerControllers.map((c) => c.text.trim()).toList(),
      'correctOption': _correctIndex,
      'difficulty': difficultyToEn(_difficulty),
      'timeSeconds': int.parse(_timeController.text.trim()),
      'points': int.parse(_pointsController.text.trim()),
      'hint': _hintController.text.trim(),
      'explanation': _explanationController.text.trim(),
    };

    setState(() {
      _saving = true;
    });
    try {
      final existing = widget.existing;
      if (existing != null) {
        await DinhApi.updateQuestion(existing.id, body);
      } else {
        await DinhApi.createQuestion(widget.topicId, body);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  /// Xóa câu hỏi đang sửa (chỉ có ở chế độ Sửa, khi MH-22 mở kèm
  /// câu hỏi thật): hỏi xác nhận trước, rồi gọi DELETE #19.
  /// Xóa xong quay về MH-22 với kết quả true để tải lại danh sách.
  Future<void> _deleteQuestion() async {
    final existing = widget.existing;
    if (existing == null || _deleting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Xóa câu hỏi này?',
          style: kQuestionTitleStyle,
        ),
        content: const Text(
          'Câu hỏi sẽ bị xóa khỏi chủ đề và không khôi phục được.',
          style: kFieldTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: kLabelStyle),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Xóa',
              style: kLabelStyle.copyWith(color: kHard),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _deleting = true;
    });
    try {
      await DinhApi.deleteQuestion(existing.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
        });
      }
    }
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nhãn cách tiêu đề 10px theo task; padding dưới
                      // của header (12px) đã cho gần đúng nên không thêm.
                      // Hàng nhãn Nội dung + nút Xóa ở góc phải.
                      // Nút Xóa chỉ hiện ở chế độ Sửa khi có câu
                      // hỏi thật (soạn mới thì chưa có gì để xóa).
                      // Nút: nền hồng nhạt kHardBackground, chữ +
                      // icon đỏ kHard — cùng cặp màu đỏ với mức
                      // Khó và chữ báo lỗi, bo góc 16 như khung.
                      Row(
                        children: [
                          const Text(
                            'Nội dung câu hỏi',
                            style: kLabelStyle,
                          ),
                          const Spacer(),
                          if (widget.existing != null)
                            SizedBox(
                              height: 32,
                              child: TextButton.icon(
                                onPressed: _deleting
                                    ? null
                                    : _deleteQuestion,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: kHard,
                                ),
                                label: const Text(
                                  'Xóa câu hỏi',
                                  style: kDeleteButtonTextStyle,
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: kHardBackground,
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      kRadiusItem,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: kSpacing3),
                      _buildField(
                        controller: _contentController,
                        hint: 'Nhập nội dung câu hỏi',
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Nhập nội dung câu hỏi.';
                          }
                          return null;
                        },
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
                            hasError:
                                _emptyAnswers.contains(index),
                            onTap: () {
                              setState(() {
                                _correctIndex = index;
                              });
                            },
                          ),
                        );
                      }),

                      // Dòng báo lỗi của nhóm đáp án (chỉ hiện khi
                      // bấm Lưu mà còn đáp án trống).
                      if (_answersError != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _answersError!,
                          style: kErrorTextStyle,
                        ),
                      ],

                      // Đáy hàng D -> nhãn Mức độ: 0px theo task.
                      const Text('Mức độ', style: kLabelStyle),
                      const SizedBox(height: kSpacing3),
                      _buildDifficultyField(),
                      // Ô -> nhãn tiếp theo: 13px theo task.
                      const SizedBox(height: kSpacing13),
                      const Text('Thời gian (giây)', style: kLabelStyle),
                      const SizedBox(height: kSpacing3),
                      _buildField(
                        controller: _timeController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) {
                            return 'Nhập thời gian (giây).';
                          }
                          final n = int.tryParse(text);
                          if (n == null || n <= 0) {
                            return 'Thời gian phải là số nguyên lớn hơn 0.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: kSpacing13),
                      const Text('Điểm', style: kLabelStyle),
                      const SizedBox(height: kSpacing3),
                      _buildField(
                        controller: _pointsController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) {
                            return 'Nhập điểm.';
                          }
                          final n = int.tryParse(text);
                          if (n == null || n <= 0) {
                            return 'Điểm phải là số nguyên lớn hơn 0.';
                          }
                          return null;
                        },
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
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: kOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                kRadiusButton,
                              ),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
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
            ),
          ],
        ),
      ),
    );
  }

  /// Một ô nhập 372x52 theo task: nền trắng, viền 1.5px #E9E6F7,
  /// chữ trong ô 15px. Rộng theo màn hình (dùng double.infinity
  /// trong cột đã có lề 20px) để không tràn như hàng nút MH-22.
  /// Có validator thì báo lỗi đỏ dưới ô khi validate không đạt.
  Widget _buildField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: kFieldHeight,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
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
          errorBorder: kFieldBorder.copyWith(
            borderSide: const BorderSide(color: kHard, width: 1.5),
          ),
          focusedErrorBorder: kFieldBorder.copyWith(
            borderSide: const BorderSide(color: kHard, width: 1.5),
          ),
          contentPadding: kFieldPadding,
        ),
      ),
    );
  }

  /// Ô chọn mức độ: 3 giá trị "Dễ" / "Trung bình" / "Khó" theo
  /// thẻ T18. Trước đây là ô chỉ đọc có icon mũi tên nhưng bấm
  /// không mở gì — giờ là dropdown thật, validate bắt buộc chọn.
  Widget _buildDifficultyField() {
    return SizedBox(
      height: kFieldHeight,
      child: DropdownButtonFormField<String>(
        value: _difficulty,
        items: const ['Dễ', 'Trung bình', 'Khó']
            .map(
              (d) => DropdownMenuItem<String>(
                value: d,
                child: Text(d, style: kFieldTextStyle),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _difficulty = value;
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Chọn mức độ.';
          }
          return null;
        },
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: kTextSecondary,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: kSurface,
          border: kFieldBorder,
          enabledBorder: kFieldBorder,
          focusedBorder: kFieldFocusedBorder,
          errorBorder: kFieldBorder.copyWith(
            borderSide: const BorderSide(color: kHard, width: 1.5),
          ),
          focusedErrorBorder: kFieldBorder.copyWith(
            borderSide: const BorderSide(color: kHard, width: 1.5),
          ),
          contentPadding: kFieldPadding,
        ),
      ),
    );
  }
}

/// Một hàng đáp án 372x52 theo task: huy hiệu chữ cái 28x28,
/// giá trị đáp án 18px 700, radio 22x22 ở mép phải.
/// Hàng đang chọn viền 2px tím, hàng chưa chọn viền 1.5px #E9E6F7.
/// Hàng trống sau khi bấm Lưu thì viền đỏ (kHard).
/// Chỉ dùng ở MH-23 nên để trong file màn hình này.
class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.letter,
    required this.controller,
    required this.selected,
    required this.onTap,
    this.hasError = false,
  });

  /// Chữ cái A, B, C hoặc D.
  final String letter;

  /// Giá trị đáp án người dùng nhập.
  final TextEditingController controller;

  /// true = đáp án đúng đang được chọn.
  final bool selected;

  /// Bấm để chọn đáp án này làm đáp án đúng.
  final VoidCallback onTap;

  /// true = hàng này đang trống sau khi bấm Lưu -> viền đỏ.
  final bool hasError;

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
            color: hasError
                ? kHard
                : (selected ? kPrimary : kInputBorder),
            width: (hasError || selected) ? 2 : 1.5,
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
