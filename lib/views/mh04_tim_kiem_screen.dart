/// MH-04 — Tìm kiếm.
/// Luồng: L2 (Trang chủ — tìm chủ đề/bộ đề để làm bài).
/// Vào từ: MH-02 Trang chủ (icon tìm kiếm tạm cạnh avatar — Figma chưa vẽ
///   nút vào, chờ nhóm chốt vị trí chính thức).
/// Đi tiếp tới: MH-06 Chi tiết chủ đề, MH-08 Chi tiết bộ đề,
///   shell đúng tab khi bấm thanh dưới.
/// Thanh dưới tự gắn — sáng tab Trang chủ (màn con của luồng Trang chủ).
/// Dữ liệu thật từ TimKiemViewModel (API search) — nối ở T40 (B2).
/// Bộ lọc độ khó CHƯA làm được (exam chưa có độ khó trong API) nên chip
/// "Độ khó" vẽ mờ — đã hỏi Uy bổ sung.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/topic.dart';
import '../services/api_client.dart';
import '../viewmodels/tim_kiem_viewmodel.dart';
import '../viewmodels/trang_chu_viewmodel.dart';
import '../widgets/thanh_dieu_huong_duoi_widget.dart';

// Nhãn chip lọc loại — chỉ là nhãn, không phải dữ liệu giả.
const _boLocLoai = ['Tất cả', 'Chủ đề', 'Bộ đề'];

class Mh04TimKiemScreen extends StatefulWidget {
  const Mh04TimKiemScreen({super.key});

  @override
  State<Mh04TimKiemScreen> createState() => _Mh04TimKiemScreenState();
}

class _Mh04TimKiemScreenState extends State<Mh04TimKiemScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      bottomNavigationBar: ThanhDieuHuongDuoi(
        selectedIndex: 0, // Trang chủ — màn con của luồng Trang chủ.
        onDestinationSelected: (i) =>
            ThanhDieuHuongDuoi.veShell(context, i),
      ),
      body: Consumer<TimKiemViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  onChanged: viewModel.nhapTuKhoa,
                  style: const TextStyle(color: kTextPrimary),
                  decoration: InputDecoration(
                    hintText: 'Tìm chủ đề, bộ đề...',
                    hintStyle: const TextStyle(color: kTextSecondary),
                    prefixIcon:
                        const Icon(Icons.search, color: kTextSecondary),
                    // Đang tìm thì hiện spinner nhỏ ở cuối ô tìm.
                    suffixIcon: viewModel.dangTim
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          )
                        : null,
                    // Viền kBorder #E9E6F7 theo Figma. (Figma không vẽ icon
                    // tìm kiếm; màu icon tạm lấy theo màu placeholder.)
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: kBorder, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: kBorder, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: kBorder, width: 1.5),
                    ),
                  ),
                ),
              ),
              // Bộ lọc loại kết quả: Tất cả / Chủ đề / Bộ đề.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final loai in _boLocLoai)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        // Màu chip đặt trực tiếp theo Figma, KHÔNG dùng chipTheme
                        // chung (selectedColor tint của theme là sai cho màn này):
                        // chip đang chọn nền tím đặc + chữ trắng, chip chưa chọn
                        // nền kPrimaryTint #EFECFE + chữ tím.
                        child: ChoiceChip(
                          label: Text(loai),
                          labelStyle: TextStyle(
                              color: viewModel.boLocLoai == loai
                                  ? Colors.white
                                  : kPrimary),
                          selected: viewModel.boLocLoai == loai,
                          selectedColor: kPrimary,
                          backgroundColor: kPrimaryTint,
                          showCheckmark: false,
                          side: BorderSide.none,
                          onSelected: (_) =>
                              viewModel.chonBoLocLoai(loai),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Bộ lọc chủ đề: hàng chip ngang cuộn được.
              SizedBox(
                height: 40,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _chipChuDe(
                        'Tất cả chủ đề',
                        viewModel.chuDeDangChon == null,
                        () => viewModel.chonChuDe(null),
                      ),
                      for (final t in viewModel.danhSachChuDe)
                        _chipChuDe(
                          t.name,
                          viewModel.chuDeDangChon == t.id,
                          () => viewModel.chonChuDe(t.id),
                        ),
                    ],
                  ),
                ),
              ),
              // Bộ lọc độ khó: CHƯA làm được (exam chưa có độ khó trong API)
              // nên chip vẽ mờ (disabled), không lọc sai.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Độ khó'),
                      selected: false,
                      onSelected: null,
                      showCheckmark: false,
                      side: BorderSide.none,
                    ),
                    const SizedBox(width: 8),
                    const Text('Chờ API bổ sung độ khó',
                        style: TextStyle(
                            color: kTextSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildKetQua(viewModel)),
            ],
          );
        },
      ),
    );
  }

  /// 1 chip lọc chủ đề — cùng style với chip lọc loại cho đồng bộ.
  Widget _chipChuDe(String ten, bool dangChon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(ten),
        labelStyle:
            TextStyle(color: dangChon ? Colors.white : kPrimary),
        selected: dangChon,
        selectedColor: kPrimary,
        backgroundColor: kPrimaryTint,
        showCheckmark: false,
        side: BorderSide.none,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildKetQua(TimKiemViewModel viewModel) {
    // Lỗi → dòng lỗi + nút Thử lại (không để màn trắng).
    if (viewModel.loi != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(viewModel.loi!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: viewModel.timKiem,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    // Chưa gõ gì → dòng gợi ý.
    if (viewModel.tuKhoa.trim().isEmpty) {
      return const Center(
        child: Text('Gõ tên chủ đề hoặc bộ đề để tìm kiếm',
            style: TextStyle(color: kTextSecondary)),
      );
    }
    final hienChuDe = viewModel.boLocLoai != 'Bộ đề';
    final hienBoDe = viewModel.boLocLoai != 'Chủ đề';
    final topics =
        hienChuDe ? viewModel.ketQuaChuDe : const <Topic>[];
    final exams = hienBoDe
        ? viewModel.ketQuaBoDe
        : const <Map<String, dynamic>>[];
    // Đã tìm xong mà không có kết quả → dòng "không tìm thấy".
    if (!viewModel.dangTim && topics.isEmpty && exams.isEmpty) {
      return Center(
        child: Text(
            'Không tìm thấy kết quả cho "${viewModel.tuKhoa}"',
            style: const TextStyle(color: kTextSecondary)),
      );
    }
    return ListView(
      children: [
        for (final t in topics)
          _theKetQua(
            ten: t.name,
            phu: 'Chủ đề',
            onTap: () => Navigator.pushNamed(context, '/mh06'),
          ),
        for (final e in exams)
          _theKetQua(
            ten: e['title'] as String? ?? '',
            phu:
                'Bộ đề · ${_tenChuDe(viewModel, e['topicId'] as String? ?? '')}',
            onTap: () => _moChiTietBoDe(context, e['id'] as String),
          ),
        if (viewModel.dangTim)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  /// Tên chủ đề của 1 bộ đề — tra từ danh sách chủ đề đã tải (kết quả
  /// search chỉ có topicId, không có tên chủ đề).
  String _tenChuDe(TimKiemViewModel viewModel, String topicId) {
    for (final t in viewModel.danhSachChuDe) {
      if (t.id == topicId) return t.name;
    }
    return '';
  }

  /// Bấm thẻ bộ đề → lấy chi tiết thật (dùng lại hàm của TrangChuViewModel)
  /// rồi mở MH-08 kèm đối tượng Exam. Lỗi thì hiện SnackBar.
  Future<void> _moChiTietBoDe(BuildContext context, String examId) async {
    try {
      final exam = await context
          .read<TrangChuViewModel>()
          .layChiTietBoDe(examId);
      if (!context.mounted) return;
      Navigator.pushNamed(context, '/mh08', arguments: exam);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  /// Thẻ 1 kết quả — giữ nguyên style Card + ListTile của bản UI.
  Widget _theKetQua({
    required String ten,
    required String phu,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBorder),
      ),
      child: ListTile(
        title: Text(ten,
            style: const TextStyle(
                color: kTextPrimary, fontWeight: FontWeight.w700)),
        subtitle: Text(phu, style: const TextStyle(color: kTextSecondary)),
        // Figma không vẽ icon chevron trên thẻ kết quả; màu
        // icon tạm lấy theo màu chữ phụ.
        trailing:
            const Icon(Icons.chevron_right, color: kTextSecondary),
        onTap: onTap,
      ),
    );
  }
}
