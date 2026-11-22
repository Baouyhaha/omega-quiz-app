import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// Vong xoay tai du lieu, co the kem dong chu mo ta trang thai
// (dang xac thuc, dang cho doi thu, dang phat de...)
class TrangThaiTai extends StatelessWidget {
  final String? text;

  const TrangThaiTai({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: kPrimary),
          if (text != null) ...[
            const SizedBox(height: 14),
            Text(text!, style: const TextStyle(color: kTextSub, fontSize: 15)),
          ],
        ],
      ),
    );
  }
}
