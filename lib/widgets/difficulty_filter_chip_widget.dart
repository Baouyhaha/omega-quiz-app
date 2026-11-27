import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';

/// Pill 28px hien nhan do kho, dung o 2 cho:
///
/// - Hang tab loc o MH-22: bam duoc, muc dang chon nen tim #6C4CF1
///   chu trang, muc chua chon nen #EFECFE chu tim.
/// - Huy hieu do kho trong the cau hoi: khong bam duoc, nen va chu
///   theo tung muc do kho (De / Trung binh / Kho).
/// Dat trong lib/widgets/ theo quy tac chung.
class DifficultyFilterChip extends StatelessWidget {
  const DifficultyFilterChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.width,
    this.onTap,
  });

  /// Nhan hien thi, vi du "Tất cả", "Dễ", "Trung bình", "Khó".
  final String label;

  /// Mau nen cua pill.
  final Color backgroundColor;

  /// Mau chu cua pill.
  final Color textColor;

  /// Rong cua pill theo task (72 / 40 / 104 / 48).
  /// De null thi pill vua theo chu.
  final double? width;

  /// Bam de loc; de null thi chip chi de hien, khong bam duoc.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget chip = Container(
      width: width,
      height: kTabHeight,
      alignment: Alignment.center,
      padding: width == null
          ? const EdgeInsets.symmetric(horizontal: 12)
          : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Text(
        label,
        style: kDifficultyLabelStyle.copyWith(color: textColor),
        textAlign: TextAlign.center,
      ),
    );
    if (onTap == null) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }
}
