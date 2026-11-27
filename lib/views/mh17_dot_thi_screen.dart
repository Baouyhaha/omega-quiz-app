/// MH-17 — Đợt thi khung giờ.
/// Luồng: L7 (Thi theo khung giờ).
/// Vào từ: thanh dưới mục Thi đấu.
/// Đi tiếp tới: MH-09 Làm bài (bấm Vào thi) /
///   MH-18 Kết quả đợt thi (đợt đã kết thúc — Xem kết quả).
/// Thanh dưới do shell (khung điều hướng) cấp — màn này không tự gắn nav.
/// Dữ liệu thật: API contests qua DotThiViewModel (task T28).
/// Không có lobby — mô hình cũ đã bỏ, đợt thi theo khung giờ (UC20).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/dinh_dang.dart';
import '../services/api_client.dart';
import '../viewmodels/dot_thi_viewmodel.dart';

class Mh17DotThiScreen extends StatelessWidget {
  const Mh17DotThiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel riêng của màn này (như MH-14): tạo + tải danh sách ngay.
    return ChangeNotifierProvider(
      create: (_) => DotThiViewModel()..taiDanhSachDotThi(),
      child: const _Mh17NoiDung(),
    );
  }
}

class _Mh17NoiDung extends StatefulWidget {
  const _Mh17NoiDung();

  @override
  State<_Mh17NoiDung> createState() => _Mh17NoiDungState();
}

class _Mh17NoiDungState extends State<_Mh17NoiDung> {
  Timer? _dongHo;

  @override
  void initState() {
    super.initState();
    // Cập nhật dòng đếm ngược mỗi giây (chỉ vẽ lại giao diện,
    // không gọi API — dữ liệu đợt thi chỉ tải lại khi kéo xuống).
    _dongHo = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _dongHo?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DotThiViewModel>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Đợt thi khung giờ')),
      body: _noiDung(context, vm, textTheme),
    );
  }

  Widget _noiDung(
      BuildContext context, DotThiViewModel vm, TextTheme textTheme) {
    // Trạng thái đang tải.
    if (vm.dangTai) {
      return const Center(child: CircularProgressIndicator());
    }
    // Trạng thái lỗi (API chưa chạy / mất mạng) + nút Thử lại.
    if (vm.loi != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(vm.loi!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kTextSecondary)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: vm.taiDanhSachDotThi,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    // Trạng thái rỗng: chưa có đợt thi nào trong hệ thống.
    final rong = vm.dangMo.isEmpty && vm.sapMo.isEmpty && vm.daKetThuc.isEmpty;
    if (rong) {
      return RefreshIndicator(
        onRefresh: vm.taiDanhSachDotThi,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text('Chưa có đợt thi nào.',
                  style: TextStyle(color: kTextSecondary)),
            ),
          ],
        ),
      );
    }
    // Có dữ liệu: 3 mục theo trạng thái đợt thi.
    return RefreshIndicator(
      onRefresh: vm.taiDanhSachDotThi,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _tieuDeMuc(textTheme, 'Đang mở'),
          if (vm.dangMo.isEmpty) _dongRong('Chưa có đợt thi nào đang mở.'),
          ...vm.dangMo.map((c) => _TheDotThi(
                dot: c,
                tenChuDe: vm.tenChuDe[c['topicId']] ?? 'Chủ đề',
                mauDemNguoc: kWarning,
                dongDemNguoc: _dongDemNguoc(c),
                nutChinh: 'Vào thi',
                onNutChinh: () => _vaoThi(context, c),
              )),
          const SizedBox(height: 16),
          _tieuDeMuc(textTheme, 'Sắp mở'),
          if (vm.sapMo.isEmpty) _dongRong('Chưa có đợt thi nào sắp mở.'),
          // Đợt sắp mở chưa có nút (theo Figma).
          ...vm.sapMo.map((c) => _TheDotThi(
                dot: c,
                tenChuDe: vm.tenChuDe[c['topicId']] ?? 'Chủ đề',
                mauDemNguoc: kPrimary,
                dongDemNguoc: _dongDemNguoc(c),
              )),
          const SizedBox(height: 16),
          _tieuDeMuc(textTheme, 'Đã kết thúc'),
          if (vm.daKetThuc.isEmpty) _dongRong('Chưa có đợt thi nào kết thúc.'),
          ...vm.daKetThuc.map((c) => _TheDotThi(
                dot: c,
                tenChuDe: vm.tenChuDe[c['topicId']] ?? 'Chủ đề',
                dongDemNguoc: _dongDemNguoc(c),
                nutChinh: 'Xem kết quả',
                laNutPhu: true,
                onNutChinh: () => Navigator.pushNamed(context, '/mh18',
                    arguments: {
                      'contestId': c['id'],
                      'tongSoCau': (c['questionIds'] as List).length,
                      'tenDot': c['title'],
                    }),
              )),
        ],
      ),
    );
  }

  Widget _tieuDeMuc(TextTheme textTheme, String ten) {
    return Text(ten,
        style: textTheme.titleMedium?.copyWith(color: kTextPrimary));
  }

  Widget _dongRong(String noiDung) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(noiDung, style: const TextStyle(color: kTextSecondary)),
    );
  }

  /// Vào thi 1 đợt (T28): gọi API vào thi — API tạo lượt làm + trả đề.
  /// Thành công thì sang MH-09 kèm lượt làm đã tạo sẵn (attemptId + đề
  /// + giờ đóng đợt qua arguments dạng Map); lỗi (đợt chưa mở, đã vào
  /// rồi — mỗi tài khoản 1 lượt) thì hiện thông báo của server.
  /// Quay lại MH-17 sau khi nộp/thoát: tải lại danh sách để cập nhật
  /// số người đã vào + trạng thái đợt.
  Future<void> _vaoThi(BuildContext context, Map<String, dynamic> c) async {
    final vm = context.read<DotThiViewModel>();
    try {
      final data = await vm.vaoThi(c['id'] as String);
      if (!context.mounted) return;
      await Navigator.pushNamed(context, '/mh09', arguments: {
        'contestAttemptId': data['attemptId'],
        'contestQuestions': data['questions'],
        'contestCloseAt': c['closeAt'],
      });
      await vm.taiDanhSachDotThi();
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Không vào thi được. Kiểm tra API local đã chạy chưa.')));
    }
  }
}

/// Thẻ 1 đợt thi: tên + chủ đề · số câu · số người đã vào + đếm ngược
/// + nút toàn chiều rộng (Vào thi / Xem kết quả — hoặc không có nút).
class _TheDotThi extends StatelessWidget {
  const _TheDotThi({
    required this.dot,
    required this.tenChuDe,
    required this.dongDemNguoc,
    this.mauDemNguoc,
    this.nutChinh,
    this.laNutPhu = false,
    this.onNutChinh,
  });

  final Map<String, dynamic> dot;
  final String tenChuDe;
  final String dongDemNguoc;
  // Màu đếm ngược theo Figma: cam (đang mở) / tím (sắp mở).
  final Color? mauDemNguoc;
  final String? nutChinh;
  final bool laNutPhu;
  final VoidCallback? onNutChinh;

  @override
  Widget build(BuildContext context) {
    final soCau = (dot['questionIds'] as List).length;
    final soNguoi = dot['enteredCount'] as int? ?? 0;
    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      shape: _vienThe(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(dot['title'] as String? ?? '',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: kTextPrimary)),
            Text('$tenChuDe · $soCau câu · $soNguoi người đã vào',
                style: const TextStyle(color: kTextSecondary)),
            if (dongDemNguoc.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(dongDemNguoc,
                  style: TextStyle(color: mauDemNguoc ?? kTextSecondary)),
            ],
            if (nutChinh != null) ...[
              const SizedBox(height: 12),
              if (laNutPhu)
                OutlinedButton(
                  onPressed: onNutChinh,
                  child: Text(nutChinh!),
                )
              else
                ElevatedButton(
                  onPressed: onNutChinh,
                  child: Text(nutChinh!),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dòng đếm ngược theo trạng thái đợt thi (tính lại mỗi giây nhờ Timer
/// ở _Mh17NoiDungState — chỉ là phép tính giờ, không gọi API).
String _dongDemNguoc(Map<String, dynamic> c) {
  final status = c['status'] as String?;
  if (status == 'OPEN') {
    final dong = DateTime.tryParse(c['closeAt'] as String? ?? '');
    if (dong == null) return '';
    final con = dong.difference(DateTime.now());
    if (con.isNegative) return 'Sắp đóng';
    return 'Còn ${_dinhDangConLai(con)} thì đóng';
  }
  if (status == 'UPCOMING') {
    final mo = DateTime.tryParse(c['openAt'] as String? ?? '');
    if (mo == null) return '';
    final con = mo.difference(DateTime.now());
    if (con.isNegative) return 'Sắp mở';
    return 'Mở sau ${_dinhDangConLai(con)}';
  }
  // CLOSED: hiện giờ đóng của đợt.
  final closeAt = c['closeAt'] as String?;
  return closeAt == null ? '' : 'Đã đóng lúc ${dinhDangNgayGio(closeAt)}';
}

/// Định dạng khoảng thời gian còn lại: "02:15:30" hoặc "1 ngày 04:00".
String _dinhDangConLai(Duration d) {
  final ngay = d.inDays;
  final gio = (d.inHours % 24).toString().padLeft(2, '0');
  final phut = (d.inMinutes % 60).toString().padLeft(2, '0');
  final giay = (d.inSeconds % 60).toString().padLeft(2, '0');
  if (ngay > 0) return '$ngay ngày $gio:$phut';
  return '$gio:$phut:$giay';
}

/// Viền thẻ theo Figma — kBorder #E9E6F7.
ShapeBorder _vienThe() => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: kBorder),
    );
