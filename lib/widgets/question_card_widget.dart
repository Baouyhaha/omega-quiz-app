import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';
import '../views/mh22_quan_ly_cau_hoi_mock.dart';
import 'difficulty_filter_chip_widget.dart';

/// The cau hoi 372x72 o MH-22: "Câu n" + noi dung xem truoc +
/// huy hieu do kho o goc phai.
/// Theo task: nen trang, vien 1px #E9E6F7, "Câu n" 15px dam,
// noi dung xem truoc 13px #6E6A8A. The khong co interaction
// trong task nen khong gan dieu huong — de giai doan chuc nang
// moi noi bam the de sua cau hoi.
// Dat trong lib/widgets/ theo quy tac chung.
class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question});

  /// Cau hoi hien thi, lay tu file mock.
  final MockQuestion question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kQuestionCardHeight,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Câu ${question.number}', style: kQuestionTitleStyle),
                const SizedBox(height: 4),
                Text(
                  question.preview,
                  style: kQuestionPreviewStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          DifficultyFilterChip(
            label: question.difficultyLabel,
            backgroundColor: _badgeBackground(question.difficulty),
            textColor: _badgeText(question.difficulty),
            width: _badgeWidth(question.difficulty),
          ),
        ],
      ),
    );
  }

  Color _badgeBackground(MockDifficulty difficulty) {
    switch (difficulty) {
      case MockDifficulty.easy:
        return kEasyBackground;
      case MockDifficulty.medium:
        return kMediumBackground;
      case MockDifficulty.hard:
        return kHardBackground;
      case MockDifficulty.all:
        return kTabUnselectedBackground;
    }
  }

  Color _badgeText(MockDifficulty difficulty) {
    switch (difficulty) {
      case MockDifficulty.easy:
        return kEasy;
      case MockDifficulty.medium:
        return kMedium;
      case MockDifficulty.hard:
        return kHard;
      case MockDifficulty.all:
        return kPrimary;
    }
  }

  double _badgeWidth(MockDifficulty difficulty) {
    switch (difficulty) {
      case MockDifficulty.easy:
        return 40;
      case MockDifficulty.medium:
        return 104;
      case MockDifficulty.hard:
        return 48;
      case MockDifficulty.all:
        return 72;
    }
  }
}
