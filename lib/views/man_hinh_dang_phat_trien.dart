import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// Man hinh tam cho cac MH chua duoc dung (phan cua thanh vien khac).
// Khi man hinh that xong chi can thay entry tuong ung trong routes.dart.
class ManHinhDangPhatTrien extends StatelessWidget {
  final String maMH;
  final String ten;

  const ManHinhDangPhatTrien({super.key, required this.maMH, required this.ten});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$maMH — $ten')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded, size: 52, color: kTextSub),
              const SizedBox(height: 14),
              Text(
                '$maMH — $ten',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Màn hình này chưa được dựng.\nXem phân chia ở docs/PHAN_CHIA_CODE_GIAO_DIEN.md',
                style: TextStyle(color: kTextSub),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
