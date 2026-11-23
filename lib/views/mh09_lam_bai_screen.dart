/// MH-09 — Làm bài.
/// Luồng: L2 (Làm bài thường); L6/L7 khi thi đấu (đối kháng / đợt thi).
/// Vào từ: MH-02 Trang chủ (Trả lời ngay) / MH-08 Chi tiết bộ đề (Bắt đầu)
///   kèm examId qua arguments; mở trực tiếp từ menu preview thì dùng đề
///   mẫu 'exam_giuaky'. MH-09 tự tạo lượt làm khi mở (T22) — chỉ 1 chỗ
///   duy nhất tạo lượt làm, nút ngoài màn chỉ điều hướng kèm examId.
/// Đi tiếp tới: MH-09b Hộp thoại nộp bài (bấm Nộp bài) → MH-10 Kết quả;
///   đủ 5 vi phạm → hộp "Bài đã tự nộp" → MH-10 (trạng thái bị nộp
///   cưỡng bức, không điểm).
/// Không có thanh dưới (theo Figma).
/// Chức năng thật: T22 nối chống gian lận (đếm rời app + tự nộp đủ 5 lần);
///   T23 hiện câu hỏi thật từ API + chọn đáp án + chuyển câu (phục vụ
///   nộp bài — câu hỏi phát từ server KHÔNG kèm đáp án đúng/giải thích).
///   Đồng hồ đếm ngược + Tip/Trợ giúp vẫn mock, thuộc task làm bài.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../services/api_client.dart';
import '../viewmodels/exam_attempt_viewmodel.dart';
import 'mh09b_hop_thoai_nop_bai_screen.dart';

class Mh09LamBaiScreen extends StatefulWidget {
  const Mh09LamBaiScreen({super.key});

  @override
  State<Mh09LamBaiScreen> createState() => _Mh09LamBaiScreenState();
}

class _Mh09LamBaiScreenState extends State<Mh09LamBaiScreen>
    with WidgetsBindingObserver {
  // Đánh dấu đã rời app, để khi quay lại mới đếm 1 lần.
  bool _daRoiApp = false;
  // Vị trí câu đang xem trong danh sách đề (0 = câu đầu).
  int _cauHienTai = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Tạo lượt làm khi vào màn. examId lấy từ arguments (mở từ nút
    // "Trả lời ngay"/"Bắt đầu"); mở trực tiếp từ menu thì dùng đề mẫu.
    // Lưu ý: hot restart (R) chạy lại initState nên tạo lượt làm mới —
    // lượt làm dở (IN_PROGRESS) không tính vào giới hạn 3 lượt, chỉ lượt
    // đã nộp/bị nộp mới tính, nên test thoải mái; hết 3 lượt đã nộp
    // thì restart API để reset dữ liệu.
    WidgetsBinding.instance.addPostFrameCallback((_) => _batDauLuotLam());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Tạo lượt làm khi vào màn. Lỗi (hết lượt, API tắt...) thì hiện
  /// SnackBar để biết lý do thay vì im lặng không đếm được vi phạm.
  Future<void> _batDauLuotLam() async {
    final examId =
        ModalRoute.of(context)?.settings.arguments as String? ??
            'exam_giuaky';
    try {
      await context.read<ExamAttemptViewModel>().startAttempt(examId);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Không bắt đầu được lượt làm. Kiểm tra API local đã chạy chưa.')));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final vm = context.read<ExamAttemptViewModel>();

    // Chỉ đếm khi lượt làm còn đang làm dở.
    if (vm.status != AttemptStatus.inProgress) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App bị rời khỏi màn hình (bấm Home, chuyển app, khóa máy...).
      // Không đếm ở `inactive` (kéo thanh thông báo, hộp thoại hệ thống)
      // vì đó chỉ là che tạm thời, đếm sẽ oan.
      _daRoiApp = true;
    } else if (state == AppLifecycleState.resumed && _daRoiApp) {
      // Vừa quay lại app sau khi đã rời -> tính 1 lần vi phạm.
      // Đếm khi quay lại chứ không đếm ngay khi rời: để gọi API + hiện
      // cảnh báo luôn trong 1 lần, tránh gọi API lúc app đang nền.
      _daRoiApp = false;
      _xuLyQuayLaiSauKhiRoiApp();
    }
  }

  /// Quay lại sau khi rời app: báo vi phạm lên server rồi hiện hộp cảnh báo.
  /// Đủ 5 lần thì hiện hộp "Bài đã tự nộp" rồi sang MH-10 ở trạng thái
  /// bị nộp cưỡng bức (không điểm). Khi bị nộp cưỡng bức thì KHÔNG gọi
  /// submit() nữa — server đã tự đóng lượt làm.
  Future<void> _xuLyQuayLaiSauKhiRoiApp() async {
    final vm = context.read<ExamAttemptViewModel>();

    final biNopCuongBuc = await vm.reportViolation();
    if (!mounted) return;

    if (biNopCuongBuc) {
      await showDialog(
        context: context,
        barrierDismissible:
            false, // bắt buộc bấm nút, không tắt bằng cách khác
        builder: (_) => AlertDialog(
          title: const Text('Bài đã tự nộp'),
          content: const Text(
              'Bạn đã rời bài đủ 5 lần nên bài làm đã tự nộp.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/mh10',
        arguments: {'forceSubmitted': true},
      );
    } else {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Cảnh báo rời bài'),
          content: Text(
              'Bạn đã rời bài ${vm.violations}/5 lần. '
              'Đủ 5 lần bài sẽ tự nộp.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tiếp tục làm bài'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExamAttemptViewModel>();
    final violations = vm.violations;
    const maxViolations = ExamAttemptViewModel.maxViolations;
    final questions = vm.questions;
    final total = questions.length;

    // Đề chưa tải xong (đang gọi API hoặc lỗi): hiện vòng xoay, không
    // hiện câu hỏi giả — tránh nộp nhầm đáp án của câu không có thật.
    if (total == 0) {
      return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text('Làm bài')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Đang tải đề...',
                  style: TextStyle(color: kTextSecondary)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _batDauLuotLam,
                child: const Text('Tải lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Kẹp vị trí câu trong giới hạn đề (đề mới tải có thể ít câu hơn).
    if (_cauHienTai >= total) _cauHienTai = total - 1;
    final cau = questions[_cauHienTai];
    final questionId = cau['id'] as String;
    final options = List<String>.from(cau['options'] as List);
    final daChon = vm.selectedAnswers[questionId];
    final soCauChuaTraLoi = total - vm.selectedAnswers.length;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Câu ${_cauHienTai + 1}/$total'),
        actions: [
          // Đồng hồ đếm ngược — chạy thật ở task làm bài.
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined,
                    size: 20, color: kTextPrimary),
                const SizedBox(width: 4),
                Text('12:34',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: kTextPrimary)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh tiến trình làm bài — nền kProgressTrack #E4E0F5,
            // phần đã làm tím đặc kPrimary.
            LinearProgressIndicator(
              value: (_cauHienTai + 1) / total,
              color: kPrimary,
              backgroundColor: kProgressTrack,
            ),
            const SizedBox(height: 16),
            Card(
              // Viền thẻ kBorder #E9E6F7.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: kBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cau['content'] as String,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: kTextPrimary)),
                    const SizedBox(height: 4),
                    const Text('Chọn 1 đáp án đúng',
                        style: TextStyle(color: kTextSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 4 ô đáp án — màu huy hiệu chữ lấy từ hằng số kOptionColors.
            // Bấm để chọn, đáp án lưu vào ViewModel (nộp ở MH-09b).
            ...List.generate(options.length, (i) {
              return _AnswerOption(
                letter: 'ABCD'[i],
                text: options[i],
                color: kOptionColors[i],
                selected: daChon == i,
                onTap: () =>
                    context.read<ExamAttemptViewModel>().selectAnswer(
                          questionId,
                          i,
                        ),
              );
            }),
            const SizedBox(height: 4),
            // Chuyển câu — Figma không vẽ nút này, thêm để làm được đề
            // nhiều câu (task làm bài có thể thay bằng lưới câu hỏi).
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _cauHienTai > 0
                      ? () => setState(() => _cauHienTai--)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Câu trước'),
                ),
                TextButton.icon(
                  onPressed: _cauHienTai < total - 1
                      ? () => setState(() => _cauHienTai++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Câu sau'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    // Nút Tip: nền trắng + viền/chữ tím (Figma).
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Tip'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Trợ giúp'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Panel trợ giúp — Figma vẽ sẵn dạng mở; khi làm thật thì panel
            // này mở ra từ nút Trợ giúp (giai đoạn chức năng).
            const _TroGiupPanel(),
            const SizedBox(height: 12),
            // Cảnh báo rời bài — số thật từ ViewModel (T22), chỉ hiện khi
            // đã vi phạm ít nhất 1 lần. Figma chỉ vẽ dòng chữ đỏ, không
            // nền, không icon.
            if (violations > 0)
              Text(
                'Đã rời bài $violations/$maxViolations lần — '
                'đủ $maxViolations lần bài sẽ tự nộp',
                style: const TextStyle(
                    color: kError, fontWeight: FontWeight.w700),
              ),
            if (violations > 0) const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                // Lớp mờ sau dialog #000000 opacity 0.55 (Figma).
                barrierColor: Colors.black.withValues(alpha: 0.55),
                builder: (_) => Mh09bHopThoaiNopBai(
                    unanswered: soCauChuaTraLoi),
              ),
              child: const Text('Nộp bài'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1 ô đáp án: huy hiệu chữ màu (A–D) + nội dung; viền màu của đáp án
/// đó (chưa chọn 2px, đang chọn 3px); đáp án đang chọn tô nền tint
/// theo màu của đáp án đó (Figma: B chọn → nền #E3F2FD).
class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.letter,
    required this.text,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final String text;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: selected ? color.withValues(alpha: 0.12) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color, width: selected ? 3 : 2),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(letter,
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(text, style: const TextStyle(color: kTextPrimary)),
        onTap: onTap,
      ),
    );
  }
}

/// Panel trợ giúp: 50:50, thêm giờ, đổi câu, khiên an toàn.
/// "Hỏi Cộng Đồng" đã lọc khỏi phạm vi — vẽ DISABLED kèm nhãn "Sắp có".
class _TroGiupPanel extends StatelessWidget {
  const _TroGiupPanel();

  @override
  Widget build(BuildContext context) {
    // Chip trợ giúp: nền kPrimaryTint #EFECFE + chữ tím.
    return Card(
      // Viền thẻ kBorder #E9E6F7.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trợ giúp',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: kTextPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  backgroundColor: kPrimaryTint,
                  label: const Text('50:50',
                      style: TextStyle(color: kPrimary)),
                  onPressed: () {},
                ),
                ActionChip(
                  backgroundColor: kPrimaryTint,
                  label: const Text('Thêm giờ +15s',
                      style: TextStyle(color: kPrimary)),
                  onPressed: () {},
                ),
                ActionChip(
                  backgroundColor: kPrimaryTint,
                  label: const Text('Đổi câu',
                      style: TextStyle(color: kPrimary)),
                  onPressed: () {},
                ),
                ActionChip(
                  backgroundColor: kPrimaryTint,
                  label: const Text('Khiên an toàn',
                      style: TextStyle(color: kPrimary)),
                  onPressed: () {},
                ),
                // Đã lọc khỏi phạm vi — onPressed null = disabled.
                // Figma: nền xám #E5E7EB + chữ #6E6A8A.
                ActionChip(
                  backgroundColor:
                      kDisabledBg,
                  disabledColor:
                      kDisabledBg,
                  label: const Text('Hỏi Cộng Đồng · Sắp có',
                      style: TextStyle(color: kTextSecondary)),
                  onPressed: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
