/// MH-18 — Kết quả đợt thi.
/// Luồng: L7 (Thi theo khung giờ).
/// Vào từ: MH-17 Đợt thi khung giờ (đợt đã kết thúc — Xem kết quả,
///   kèm contestId + tongSoCau + tenDot qua arguments).
/// Đi tiếp tới: MH-17 (nút back), shell tab Trang chủ (Về trang chủ),
///   shell đúng tab khi bấm thanh dưới.
/// Thanh dưới tự gắn — sáng tab Thi đấu (kết quả đợt thi, theo Figma).
/// Dữ liệu thật: API GET /contests/:id/results qua DotThiViewModel
///   (task T28). Xếp hạng do server tính: số câu đúng giảm dần, bằng
///   nhau thì thời gian làm bài ngắn hơn xếp trên; điểm rank cộng 1 lần
///   khi đợt đóng (top 1 +20, hạng 2–3 +10, còn lại +2; người vào mà
///   không nộp bài được 0 điểm).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/dinh_dang.dart';
import '../viewmodels/dot_thi_viewmodel.dart';
import '../widgets/thanh_dieu_huong_duoi_widget.dart';

class Mh18KetQuaDotThiScreen extends StatelessWidget {
  const Mh18KetQuaDotThiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel riêng của màn này (như MH-17): kết quả tải trong
    // initState sau khi đọc contestId từ arguments.
    return ChangeNotifierProvider(
      create: (_) => DotThiViewModel(),
      child: const _Mh18NoiDung(),
    );
  }
}

class _Mh18NoiDung extends StatefulWidget {
  const _Mh18NoiDung();

  @override
  State<_Mh18NoiDung> createState() => _Mh18NoiDungState();
}

class _Mh18NoiDungState extends State<_Mh18NoiDung> {
  String? _contestId;
  int _tongSoCau = 0;
  String? _tenDot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _contestId = args['contestId'] as String?;
        _tongSoCau = args['tongSoCau'] as int? ?? 0;
        _tenDot = args['tenDot'] as String?;
      }
      final id = _contestId;
      if (id != null) {
        context.read<DotThiViewModel>().taiKetQua(id);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DotThiViewModel>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả đợt thi')),
      bottomNavigationBar: ThanhDieuHuongDuoi(
        selectedIndex: 2, // Thi đấu — kết quả đợt thi, theo Figma.
        onDestinationSelected: (i) =>
            ThanhDieuHuongDuoi.veShell(context, i),
      ),
      body: _noiDung(context, vm, textTheme),
    );
  }

  Widget _noiDung(
      BuildContext context, DotThiViewModel vm, TextTheme textTheme) {
    // Mở trực tiếp từ menu preview (không có arguments): chưa chọn đợt.
    if (_contestId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Chưa chọn đợt thi. Vào MH-17 chọn đợt đã kết thúc để xem kết quả.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextSecondary),
          ),
        ),
      );
    }
    // Trạng thái đang tải.
    if (vm.dangTaiKetQua) {
      return const Center(child: CircularProgressIndicator());
    }
    // Trạng thái lỗi + nút Thử lại.
    if (vm.loiKetQua != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(vm.loiKetQua!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kTextSecondary)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => vm.taiKetQua(_contestId!),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    // Đợt không có ai vào thi.
    if (vm.ketQua.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_tenDot != null) ...[
            Text(_tenDot!,
                style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
            const SizedBox(height: 8),
          ],
          const Text('Chưa có ai tham gia đợt thi này.',
              style: TextStyle(color: kTextSecondary)),
          const SizedBox(height: 16),
          _nutVeTrangChu(context),
        ],
      );
    }
    // Có kết quả: thẻ Top 1 + bảng xếp hạng các hạng còn lại.
    final top1 = vm.ketQua.first;
    final conLai = vm.ketQua.skip(1).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_tenDot != null) ...[
          Text(_tenDot!,
              style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
          const SizedBox(height: 8),
        ],
        // Thẻ Top 1 nổi bật — nền kWarningTint #FFF3E0 (vàng nhạt).
        Card(
          color: kWarningTint,
          shape: _vienThe(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top 1',
                    style:
                        textTheme.titleMedium?.copyWith(color: kWarning)),
                const SizedBox(height: 4),
                Text(
                  _tenHienThi(top1, vm),
                  style: textTheme.titleMedium
                      ?.copyWith(color: kTextPrimary),
                ),
                Text(
                  '${top1['correctCount']}/$_tongSoCau câu đúng · ${_thoiGian(top1)}',
                  style: const TextStyle(color: kTextPrimary),
                ),
                Text(_diemRank(top1),
                    style: const TextStyle(color: kSuccess)),
              ],
            ),
          ),
        ),
        if (conLai.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Bảng xếp hạng đợt',
              style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
          const SizedBox(height: 8),
          ...conLai.map((r) {
            final name = r['name'] as String? ?? '';
            final hang = r['rank'] as int? ?? 0;
            final laToi = r['userId'] == vm.uidCuaToi;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              // Dòng của mình: nền kPrimaryTint #EFECFE (theo Figma).
              color: laToi ? kPrimaryTint : null,
              shape: _vienThe(),
              child: ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$hang.',
                        style: textTheme.titleMedium
                            ?.copyWith(color: kPrimary)),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: _mauAvatar(hang),
                      child: Text(name.isEmpty ? '?' : name[0],
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                title: Text(_tenHienThi(r, vm),
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.w700)),
                subtitle: Text(
                    '${r['correctCount']}/$_tongSoCau câu đúng · ${_thoiGian(r)}',
                    style: const TextStyle(color: kTextSecondary)),
                trailing: Text(_diemRankNgan(r),
                    style: textTheme.titleMedium
                        ?.copyWith(color: kSuccess)),
              ),
            );
          }),
        ],
        const SizedBox(height: 8),
        const Text(
          'Xếp hạng theo số câu đúng, bằng nhau thì thời gian ngắn hơn xếp trên.',
          style: TextStyle(color: kTextSecondary),
        ),
        const SizedBox(height: 16),
        _nutVeTrangChu(context),
      ],
    );
  }

  Widget _nutVeTrangChu(BuildContext context) {
    // Figma: nút tím đặc (không phải nút viền).
    return ElevatedButton(
      onPressed: () => ThanhDieuHuongDuoi.veShell(context, 0),
      child: const Text('Về trang chủ'),
    );
  }

  /// Tên hiển thị: thêm "(Bạn)" nếu là dòng của mình.
  String _tenHienThi(Map<String, dynamic> r, DotThiViewModel vm) {
    final name = r['name'] as String? ?? '';
    return r['userId'] == vm.uidCuaToi ? '$name (Bạn)' : name;
  }

  /// Thời gian làm bài dạng m:ss; chưa nộp bài thì server trả null.
  String _thoiGian(Map<String, dynamic> r) {
    final giay = r['durationSeconds'] as int?;
    return giay == null ? '—' : dinhDangThoiGian(giay);
  }

  /// Điểm rank cộng thêm (đầy đủ cho thẻ Top 1).
  String _diemRank(Map<String, dynamic> r) {
    final delta = r['rankDelta'] as int? ?? 0;
    return delta > 0 ? '+$delta điểm xếp hạng' : '0 điểm xếp hạng';
  }

  /// Điểm rank dạng ngắn cho cột phải bảng xếp hạng.
  String _diemRankNgan(Map<String, dynamic> r) {
    final delta = r['rankDelta'] as int? ?? 0;
    return delta > 0 ? '+$delta' : '0';
  }
}

/// Viền thẻ theo Figma — kBorder #E9E6F7.
ShapeBorder _vienThe() => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: kBorder),
    );

/// Màu avatar theo hạng (Figma): hạng 2 tím, hạng 3 hồng (màu đáp án A),
/// hạng 4 xanh dương (màu đáp án B).
Color _mauAvatar(int hang) {
  switch (hang) {
    case 3:
      return kOptionColors[0];
    case 4:
      return kOptionColors[1];
    default:
      return kPrimary;
  }
}
