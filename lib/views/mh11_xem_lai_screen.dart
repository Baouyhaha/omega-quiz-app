/// MH-11 — Xem lại bài đã làm.
/// Luồng: L2 (Làm bài thường).
/// Vào từ: MH-10 Kết quả (Xem lại) / MH-12 Lịch sử.
/// Đi tiếp tới: quay lại MH-10 / MH-12.
/// Không có thanh dưới (theo Figma).
/// Dữ liệu giả: khối // MOCK: đầu file này.
/// Chức năng thật: nối ở task T18 (để giai đoạn chức năng).
import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// MOCK: dữ liệu giả cho MH-11 — thay bằng API xem lại bài làm ở giai đoạn chức năng.
// Đáp án ghi theo chữ cái (A–D) như Figma; câu sai có giải thích.
const _mockReview = [
  {
    'q': 'Đạo hàm của x² là gì?',
    'yours': 'B',
    'correct': 'B',
    'isCorrect': true,
    'explanation': '',
  },
  {
    'q': 'Đạo hàm của ln(x) là gì?',
    'yours': 'A',
    'correct': 'C',
    'isCorrect': false,
    'explanation': 'đạo hàm của ln(x) là 1/x.',
  },
  {
    'q': 'Đạo hàm của sin(x) là gì?',
    'yours': 'D',
    'correct': 'D',
    'isCorrect': true,
    'explanation': '',
  },
];

class Mh11XemLaiScreen extends StatelessWidget {
  const Mh11XemLaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xem lại bài')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockReview.length + 1,
        itemBuilder: (context, i) {
          // Dòng cuối: ghi chú đáp án hiện theo cài đặt của bộ đề.
          if (i == _mockReview.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Đáp án hiện theo cài đặt của bộ đề',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: kTextSecondary),
              ),
            );
          }
          final r = _mockReview[i];
          final isCorrect = r['isCorrect'] as bool;
          final explanation = r['explanation'] as String;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            // Viền thẻ kBorder #E9E6F7.
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side:
                  BorderSide(color: kBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? kSuccess : kError,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Câu ${i + 1}: ${r['q']}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: kTextPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCorrect
                        ? 'Bạn chọn ${r['yours']} — Đúng'
                        : 'Bạn chọn ${r['yours']} — Sai, '
                            'đáp án đúng: ${r['correct']}',
                    style: TextStyle(
                      color: isCorrect ? kSuccess : kError,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!isCorrect && explanation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Giải thích: $explanation',
                        style: const TextStyle(color: kTextSecondary)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
