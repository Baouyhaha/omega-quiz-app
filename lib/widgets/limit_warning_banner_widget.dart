import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';

/// Hộp cảnh báo vàng nhạt với dấu "!" trong vòng tròn, ví dụ
/// "Gói miễn phí: tối đa 1 chủ đề" ở MH-20.
/// Tách riêng vì đây là khối dùng chung trong danh sách widget dự kiến
/// ("banner cảnh báo hết hạn" / cảnh báo hạn mức), sẽ dùng lại ở các
/// màn hình khác như MH-32 Admin: Gói và hạn mức. Đặt trong lib/widgets/.
class LimitWarningBanner extends StatelessWidget {
  const LimitWarningBanner({super.key, required this.text});

  /// Nội dung cảnh báo, ví dụ "Gói miễn phí: tối đa 1 chủ đề".
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Theo task: hộp cao 52px, nền #FFF3E0.
      height: kWarningHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: kWarningBackground,
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vòng tròn 20x20 #FF9F1C với dấu "!" trắng 13px.
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: kWarningOrange,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              '!',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: kSpacing3),
          Expanded(
            child: Text(
              text,
              style: kWarningTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
