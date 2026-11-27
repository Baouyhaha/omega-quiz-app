/// MH-14 — Bảng xếp hạng.
/// Luồng: L7 (Xếp hạng).
/// Vào từ: thanh dưới mục Xếp hạng.
/// Đi tiếp tới: MH-03 Hồ sơ (bấm vào 1 người — để giai đoạn chức năng).
/// Thanh dưới do shell (khung điều hướng) cấp — màn này không tự gắn nav.
/// Chức năng thật: T29 nối API leaderboard (BangXepHangViewModel) — 2 phạm
///   vi Toàn hệ thống / Bạn bè, thẻ rank của tôi + thanh "còn X điểm lên
///   rank sau", dialog chúc mừng khi lên rank. Lọc tuần/tháng/chủ đề chờ
///   API (đã hỏi Uy), chưa vẽ chip giả cho phần đó.
/// Avatar rank dùng icon con vật thống nhất của nhóm (assets/icons qua
///   iconRank trong rank_helper) — thay avatar chữ cái cũ.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../services/api_client.dart';
import '../services/sound_service.dart';
import '../utils/rank_helper.dart';
import '../viewmodels/bang_xep_hang_viewmodel.dart';

// Viền thẻ theo Figma — kBorder #E9E6F7.
BorderSide get _vienThe => BorderSide(color: kBorder);

class Mh14BangXepHangScreen extends StatelessWidget {
  const Mh14BangXepHangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BangXepHangViewModel(ApiClient())..load(),
      child: const _Mh14NoiDung(),
    );
  }
}

/// Phần giao diện cũ của MH-14 (StatefulWidget như trước, chỉ đổi tên).
class _Mh14NoiDung extends StatefulWidget {
  const _Mh14NoiDung();

  @override
  State<_Mh14NoiDung> createState() => _Mh14NoiDungState();
}

class _Mh14NoiDungState extends State<_Mh14NoiDung> {
  // 0 = Toàn hệ thống, 1 = Bạn bè.
  int _selectedFilter = 0;

  // Rank đã hiện dialog chúc mừng — chặn hiện 2 dialog khi màn hình
  // build lại 2 lần trước khi dialog kịp mở.
  String? _rankDaHienDialog;

  @override
  Widget build(BuildContext context) {
    return Consumer<BangXepHangViewModel>(
      builder: (context, vm, _) {
        // Vừa lên rank thì hiện dialog chúc mừng 1 lần.
        final rankMoi = vm.lenRankMoi;
        if (rankMoi != null && rankMoi != _rankDaHienDialog) {
          _rankDaHienDialog = rankMoi;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // T13: tiếng lên rank kèm dialog chúc mừng.
            SoundService.instance.playRankUp();
            _hienDialogLenRank(context, rankMoi);
            vm.xacNhanDaXemLenRank();
          });
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Bảng xếp hạng')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    _ChipLoc(
                      label: 'Toàn hệ thống',
                      selected: _selectedFilter == 0,
                      onSelected: (_) {
                        setState(() => _selectedFilter = 0);
                        context
                            .read<BangXepHangViewModel>()
                            .doiPhamVi(PhamViBxh.toanHeThong);
                      },
                    ),
                    const SizedBox(width: 8),
                    _ChipLoc(
                      label: 'Bạn bè',
                      selected: _selectedFilter == 1,
                      onSelected: (_) {
                        setState(() => _selectedFilter = 1);
                        context
                            .read<BangXepHangViewModel>()
                            .doiPhamVi(PhamViBxh.banBe);
                      },
                    ),
                  ],
                ),
              ),
              const Expanded(child: _BangXepHang()),
            ],
          ),
        );
      },
    );
  }

  /// Dialog chúc mừng lên rank: hoạt ảnh scale + fade (không cần package).
  /// Âm thanh rank_up gắn sau khi T13 xong.
  void _hienDialogLenRank(BuildContext context, String rankMoi) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, giaTri, child) {
            return Opacity(
              opacity: giaTri.clamp(0.0, 1.0),
              child: Transform.scale(scale: giaTri, child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AvatarRank(animal: rankMoi, radius: 36),
              const SizedBox(height: 16),
              const Text('Chúc mừng!',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
              const SizedBox(height: 8),
              Text('Bạn đã lên rank $rankMoi!', textAlign: TextAlign.center),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }
}

/// Chip lọc "Toàn hệ thống / Bạn bè" theo Figma: chip đang chọn nền tím
/// đặc + chữ trắng, chip chưa chọn nền tím nhạt + chữ xám tím. Màu đặt
/// trực tiếp trên từng chip, không dùng chipTheme chung (selectedColor
/// tint trong theme là sai cho màn này).
class _ChipLoc extends StatelessWidget {
  const _ChipLoc({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      side: BorderSide.none,
      // Nền chip chưa chọn theo Figma #F0EEF9 — dùng kPrimaryTint
      // #EFECFE (lệch ≤5/kênh, mắt thường không phân biệt được).
      backgroundColor: kPrimaryTint,
      selectedColor: kPrimary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : kTextSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Nội dung 1 tab BXH: thẻ rank của tôi + bục top 3 + các hạng tiếp theo.
/// Dữ liệu thật từ ViewModel, đủ 3 trạng thái loading/rỗng/lỗi.
class _BangXepHang extends StatelessWidget {
  const _BangXepHang();

  @override
  Widget build(BuildContext context) {
    return Consumer<BangXepHangViewModel>(
      builder: (context, vm, _) {
        if (vm.dangTai) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.loi != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(vm.loi!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: vm.load,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        final danhSach = vm.danhSach;
        if (danhSach.isEmpty) {
          return Center(
            child: Text(
              vm.phamVi == PhamViBxh.banBe
                  ? 'Chưa có bạn bè nào trong bảng xếp hạng.'
                  : 'Chưa có dữ liệu xếp hạng.',
            ),
          );
        }
        // Top 3 lên bục, từ hạng 4 trở đi xuống danh sách.
        final top3 = danhSach.take(3).toList();
        final conLai = danhSach.skip(3).toList();
        // Bục hiển thị theo thứ tự [hạng 2, hạng 1, hạng 3] để hạng 1 ở giữa,
        // giống bố cục Figma. Ít hơn 3 người thì giữ thứ tự hạng.
        final buc =
            top3.length == 3 ? [top3[1], top3[0], top3[2]] : top3;
        final textTheme = Theme.of(context).textTheme;
        final uidCuaToi = vm.uidCuaToi;
        return RefreshIndicator(
          onRefresh: vm.lamMoi,
          child: ListView(
            // Luôn kéo được để tải lại, kể cả khi danh sách ngắn.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const _TheRankCuaToi(),
              Text('Top 3',
                  style:
                      textTheme.titleMedium?.copyWith(color: kTextPrimary)),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: _vienThe,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final e in buc)
                        Expanded(
                          child: _BucTop3(
                            entry: e,
                            isMe: e['uid'] == uidCuaToi,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (conLai.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Các hạng tiếp theo',
                    style: textTheme.titleMedium
                        ?.copyWith(color: kTextPrimary)),
                const SizedBox(height: 8),
                for (final e in conLai)
                  _HangBxh(
                    entry: e,
                    isMe: e['uid'] == uidCuaToi,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Thẻ điểm của tài khoản đang đăng nhập: icon rank + số điểm +
/// thanh "còn X điểm nữa lên rank sau".
/// (Uy yêu cầu 27/11: bỏ chữ "Bạn đang là <rank>", chỉ hiện điểm —
/// thanh tiến trình lên rank vẫn giữ.)
class _TheRankCuaToi extends StatelessWidget {
  const _TheRankCuaToi();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BangXepHangViewModel>();
    final diem = vm.diemCuaToi;
    final rank = vm.rankCuaToi;
    if (diem == null || rank == null) return const SizedBox.shrink();
    final conThieu = pointsToNextRank(diem);
    final rankSau = tenRankSau(diem);
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: _vienThe,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _AvatarRank(animal: rank),
                const SizedBox(width: 12),
                Text('$diem điểm',
                    style: textTheme.titleMedium
                        ?.copyWith(color: kTextPrimary)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: tienTrinhLenRank(diem),
              backgroundColor: kProgressTrack,
              color: animalColor(rank),
            ),
            const SizedBox(height: 8),
            Text(
              conThieu == null
                  ? 'Bạn đã đạt rank cao nhất!'
                  : 'Còn $conThieu điểm nữa lên $rankSau',
              style: const TextStyle(color: kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1 cột trên bục top 3: hạng, avatar chữ cái, tên, hạng thú · điểm.
/// Hạng 1 ở giữa, avatar to hơn; cột của mình có nhãn "Bạn".
class _BucTop3 extends StatelessWidget {
  const _BucTop3({required this.entry, required this.isMe});

  final Map<String, dynamic> entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final rank = entry['rank'] as int;
    final name = entry['name'] as String;
    final animal = entry['animalRank'] as String;
    final isTop1 = rank == 1;
    // Avatar dùng icon con vật (T29); số hạng giữ màu Figma (hạng 1 vàng
    // cam, hạng 2–3 tím).
    final rankColor = isTop1 ? kWarning : kPrimary;
    final textTheme = Theme.of(context).textTheme;
    final column = Column(
      children: [
        if (isMe)
          const Chip(
            label: Text('Bạn', style: TextStyle(color: Colors.white)),
            backgroundColor: kPrimary,
            side: BorderSide.none,
          ),
        Text('$rank',
            style: textTheme.titleLarge?.copyWith(color: rankColor)),
        const SizedBox(height: 4),
        _AvatarRank(animal: animal, radius: isTop1 ? 28 : 22),
        const SizedBox(height: 4),
        Text(name,
            style: textTheme.titleMedium?.copyWith(color: kTextPrimary)),
        Text('$animal · ${entry['rankScore']}',
            style: const TextStyle(color: kTextSecondary)),
      ],
    );
    if (!isMe) return column;
    // Cột của mình có nền kPrimaryTint #EFECFE theo Figma.
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryTint,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: column,
    );
  }
}

/// 1 hàng hạng 4 trở đi: số hạng, avatar icon con vật, tên + hạng thú, điểm.
/// Dòng của mình có nền tím nhạt + nhãn "Bạn".
class _HangBxh extends StatelessWidget {
  const _HangBxh({required this.entry, required this.isMe});

  final Map<String, dynamic> entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final name = entry['name'] as String;
    final animal = entry['animalRank'] as String;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isMe ? kPrimaryTint : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: _vienThe,
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${entry['rank']}',
                style:
                    textTheme.titleMedium?.copyWith(color: kTextPrimary)),
            const SizedBox(width: 8),
            _AvatarRank(animal: animal),
          ],
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(name,
                  style: const TextStyle(
                      color: kTextPrimary, fontWeight: FontWeight.w700)),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              const Chip(
                label:
                    Text('Bạn', style: TextStyle(color: Colors.white)),
                backgroundColor: kPrimary,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
        subtitle: Text('Hạng $animal',
            style: const TextStyle(color: kTextSecondary)),
        trailing: Text('${entry['rankScore']} điểm',
            style: textTheme.titleMedium?.copyWith(color: kPrimary)),
      ),
    );
  }
}

/// Avatar rank: icon con vật thống nhất của nhóm (assets/icons) trên nền
/// tròn màu nhạt theo màu con vật (E2). Thay avatar chữ cái cũ.
class _AvatarRank extends StatelessWidget {
  const _AvatarRank({required this.animal, this.radius = 20});

  final String animal;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: animalColor(animal).withValues(alpha: 0.18),
      child: Image.asset(
        iconRank(animal),
        width: radius * 1.5,
        height: radius * 1.5,
      ),
    );
  }
}
