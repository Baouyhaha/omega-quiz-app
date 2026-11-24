import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';

/// Một lựa chọn radio trong nhóm "Chế độ" của MH-20:
/// tiêu đề đậm + mô tả, trên cùng một dòng, ví dụ
/// "Công khai — ai cũng xem được".
/// Tách riêng vì khối này lặp lại 2 lần (Công khai / Riêng tư)
/// trong cùng màn hình, và có thể dùng lại ở màn hình khác có
/// lựa chọn chế độ. Đặt trong lib/widgets/ theo quy tắc chung.
///
/// Theo task: vòng radio 22x22, viền 2px, đã chọn viền #6C4CF1
/// chấm trong 11x11 #6C4CF1, chưa chọn viền #C9C4DE,
/// nhãn cách vòng radio 10px.
/// Không dùng widget Radio có sẵn của Flutter ở đây vì nó có
/// vùng bấm và padding mặc định làm vòng tròn lệch khỏi chữ  q
/// và khoảng cách radio → chữ không đúng 10px theo task.
/// Vẽ vòng tròn bằng Container để khớp đúng số đo theo task.
class TopicModeOption extends StatelessWidget {
  const TopicModeOption({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  /// Tiêu đề lựa chọn, ví dụ "Công khai".
  final String title;

  /// Mô tả sau dấu gạch ngang, ví dụ "ai cũng xem được".
  final String description;

  /// Giá trị của lựa chọn này, ví dụ 'public'.
  final String value;

  /// Giá trị đang được chọn trong nhóm.
  final String groupValue;

  /// Gọi khi người dùng chọn lựa chọn này.
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vòng radio 22x22 theo task.
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
            // Chấm trong 11x11 khi đã chọn.
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
          // Nhãn cách vòng radio 10px theo task.
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: kFieldTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' — $description',
                    style: kFieldTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
