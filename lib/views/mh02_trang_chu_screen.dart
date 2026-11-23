/// MH-02 — Trang chủ.
/// Luồng: L2 (Trang chủ).
/// Vào từ: MH-01 Đăng nhập (sau đăng nhập Google) / thanh dưới mục Trang chủ.
/// Đi tiếp tới: MH-06 Chi tiết chủ đề, MH-28 Danh sách gói (banner dùng thử),
///   MH-04 Tìm kiếm (icon tìm kiếm tạm cạnh avatar — Figma chưa vẽ nút vào,
///   chờ nhóm chốt vị trí chính thức), MH-08 Chi tiết bộ đề (bấm thẻ bộ đề),
///   MH-09 Làm bài (nút "Trả lời ngay" kèm examId).
/// Thanh dưới do shell (khung điều hướng) cấp — màn này không tự gắn nav.
/// Dữ liệu thật từ TrangChuViewModel (API topics/invitations) — nối ở T40.
/// Gói thuê bao (banner dùng thử) chờ task khác — banner hiện giữ số tạm.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/chuyen_canh.dart';
import '../services/sound_service.dart';
import 'mh09_lam_bai_screen.dart';
import '../models/exam.dart';
import '../services/api_client.dart';
import '../viewmodels/trang_chu_viewmodel.dart';

// Tên hiển thị tạm — tài khoản dev là Ngô Thành Danh; chờ API hồ sơ
// (task khác) rồi nối tên thật sau. Số ngày dùng thử cũng tạm thời,
// chờ task gói thuê bao nối API thật — không phải số liệu bịa để khoe.
const _tenNguoiDungTam = 'Danh';
const _ngayDungThuConLaiTam = 3;

class Mh02TrangChuScreen extends StatelessWidget {
  const Mh02TrangChuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrangChuViewModel>(
      builder: (context, viewModel, _) {
        final daCoDuLieu = viewModel.chuDeCuaToi.isNotEmpty ||
            viewModel.chuDeCongKhai.isNotEmpty ||
            viewModel.boDeMoi.isNotEmpty;
        // Chưa có dữ liệu mà đang tải → spinner ở giữa màn.
        if (viewModel.dangTai && !daCoDuLieu) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Chưa có dữ liệu mà lỗi → dòng lỗi + nút Thử lại (không để màn trắng).
        if (viewModel.loi != null && !daCoDuLieu) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(viewModel.loi!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: viewModel.taiTrangChu,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final textTheme = Theme.of(context).textTheme;
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Chào hỏi + nút tìm kiếm (tạm) + avatar.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Xin chào, $_tenNguoiDungTam',
                        style:
                            textTheme.titleLarge?.copyWith(color: kTextPrimary)),
                    Row(
                      children: [
                        // Điểm vào MH-04 TẠM THỜI — Figma chưa vẽ nút vào,
                        // chờ nhóm chốt vị trí chính thức.
                        IconButton(
                          icon:
                              const Icon(Icons.search, color: kTextPrimary),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/mh04'),
                        ),
                        const CircleAvatar(
                          backgroundColor: kPrimary,
                          child: Text('D',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Banner gói dùng thử — bấm "Gia hạn ngay" sang MH-28.
                _BannerDungThu(
                  ngayConLai: _ngayDungThuConLaiTam,
                  onGiaHan: () => Navigator.pushNamed(context, '/mh28'),
                ),
                const SizedBox(height: 16),
                // Lời mời chờ — chỉ hiện khi có lời mời, không có thì ẩn hẳn.
                // Dữ liệu mẫu hiện chưa có lời mời nào cho tài khoản dev
                // nên thẻ này chưa hiện — bình thường, không phải lỗi.
                for (final loiMoi in viewModel.loiMoiCho) ...[
                  _TheLoiMoi(
                    key: ValueKey(loiMoi['id']),
                    loiMoi: loiMoi,
                    viewModel: viewModel,
                  ),
                  const SizedBox(height: 16),
                ],
                Text('Chủ đề của tôi',
                    style: textTheme.titleMedium
                        ?.copyWith(color: kTextPrimary)),
                if (viewModel.chuDeCuaToi.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Chưa có chủ đề nào.',
                        style: TextStyle(color: kTextSecondary)),
                  ),
                ...viewModel.chuDeCuaToi.map((t) => _TheChuDe(
                      ten: t.name,
                      thongKe:
                          '${t.questionCount} câu · ${t.examCount} bộ đề · ${t.memberCount} thành viên',
                      nhan: 'Của tôi',
                      onTap: () => Navigator.pushNamed(context, '/mh06'),
                    )),
                const SizedBox(height: 16),
                Text('Chủ đề công khai nổi bật',
                    style: textTheme.titleMedium
                        ?.copyWith(color: kTextPrimary)),
                if (viewModel.chuDeCongKhai.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Chưa có chủ đề công khai nào.',
                        style: TextStyle(color: kTextSecondary)),
                  ),
                ...viewModel.chuDeCongKhai.map((t) => _TheChuDe(
                      ten: t.name,
                      thongKe:
                          '${t.questionCount} câu · ${t.examCount} bộ đề · ${t.memberCount} thành viên',
                      nhan: 'Công khai',
                      onTap: () => Navigator.pushNamed(context, '/mh06'),
                    )),
                const SizedBox(height: 16),
                Text('Bộ đề mới',
                    style: textTheme.titleMedium
                        ?.copyWith(color: kTextPrimary)),
                if (viewModel.boDeMoi.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Chưa có bộ đề nào.',
                        style: TextStyle(color: kTextSecondary)),
                  ),
                ...viewModel.boDeMoi.map((boDe) => _TheBoDe(
                      boDe: boDe,
                      // T13: vào MH-09 bằng chuyển cảnh mờ dần 250ms.
                      onTraLoiNgay: () => Navigator.push(
                          context,
                          routeChuyenCanh(const Mh09LamBaiScreen(),
                              arguments: boDe.id)),
                      onTap: () =>
                          _moChiTietBoDe(context, viewModel, boDe.id),
                    )),
                // T13 — CÔNG TẮC ÂM THANH TẠM: mục Cài đặt nằm trong MH-03
                // (màn của Uy), Danh không tự sửa MH-03 nên tạm đặt công
                // tắc ở cuối MH-02 để nghiệm thu được ngay. Khi Uy gắn
                // công tắc vào MH-03 thì xóa khối này ở đây.
                const SizedBox(height: 16),
                const _CongTacAmThanh(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Bấm thẻ bộ đề → lấy chi tiết thật rồi mở MH-08 kèm đối tượng Exam.
  /// Lỗi (ví dụ API tắt) thì hiện SnackBar thay vì crash.
  Future<void> _moChiTietBoDe(BuildContext context,
      TrangChuViewModel viewModel, String examId) async {
    try {
      final exam = await viewModel.layChiTietBoDe(examId);
      if (!context.mounted) return;
      Navigator.pushNamed(context, '/mh08', arguments: exam);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// Công tắc bật/tắt âm thanh (T13, TẠM ở MH-02 — xem ghi chú ở chỗ
/// dùng). SoundService đọc lại SharedPreferences mỗi lần phát nên gạt
/// tắt là tiếng dừng ngay, không cần restart app.
class _CongTacAmThanh extends StatefulWidget {
  const _CongTacAmThanh();

  @override
  State<_CongTacAmThanh> createState() => _CongTacAmThanhState();
}

class _CongTacAmThanhState extends State<_CongTacAmThanh> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SoundService.instance.isSoundEnabled,
      builder: (context, snapshot) {
        final enabled = snapshot.data ?? true;
        return SwitchListTile(
          title: const Text('Âm thanh'),
          value: enabled,
          onChanged: (value) async {
            await SoundService.instance.setSoundEnabled(value);
            setState(() {});
          },
        );
      },
    );
  }
}

/// Thẻ 1 lời mời chờ: tên chủ đề + nút Tham gia / Từ chối.
/// Nút Từ chối chưa có endpoint (API chỉ có chấp nhận) nên tạm thời
/// chỉ ẩn thẻ ở phía app — đã hỏi Uy thêm endpoint từ chối.
class _TheLoiMoi extends StatefulWidget {
  const _TheLoiMoi({super.key, required this.loiMoi, required this.viewModel});

  final Map<String, dynamic> loiMoi;
  final TrangChuViewModel viewModel;

  @override
  State<_TheLoiMoi> createState() => _TheLoiMoiState();
}

class _TheLoiMoiState extends State<_TheLoiMoi> {
  bool _daTuChoi = false;
  bool _dangChapNhan = false;

  @override
  Widget build(BuildContext context) {
    if (_daTuChoi) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: kSuccessTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn được mời vào chủ đề',
                style: TextStyle(color: kTextPrimary)),
            const SizedBox(height: 4),
            Text(widget.loiMoi['topicName'] as String? ?? '',
                style: textTheme.titleMedium?.copyWith(color: kPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _dangChapNhan ? null : _chapNhan,
                    child: _dangChapNhan
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Tham gia'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _daTuChoi = true),
                    child: const Text('Từ chối'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chapNhan() async {
    setState(() => _dangChapNhan = true);
    try {
      await widget.viewModel
          .chapNhanLoiMoi(widget.loiMoi['id'] as String);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _dangChapNhan = false);
    }
  }
}

/// Banner gói dùng thử — nền kWarningTint #FFF3E0 (vàng cam nhạt).
/// Chữ "Gia hạn ngay" màu cam kWarning theo Figma.
class _BannerDungThu extends StatelessWidget {
  const _BannerDungThu({required this.ngayConLai, required this.onGiaHan});

  final int ngayConLai;
  final VoidCallback onGiaHan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWarningTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gói dùng thử còn $ngayConLai ngày',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: kTextPrimary)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onGiaHan,
            child: const Text('Gia hạn ngay ›',
                style:
                    TextStyle(color: kWarning, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// Thẻ 1 chủ đề: tên + thống kê + nhãn (Của tôi / Công khai).
class _TheChuDe extends StatelessWidget {
  const _TheChuDe({
    required this.ten,
    required this.thongKe,
    required this.nhan,
    required this.onTap,
  });

  final String ten;
  final String thongKe;
  final String nhan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Nhãn pill phân màu theo Figma: "Của tôi" nền tím nhạt + chữ tím,
    // "Công khai" nền xanh lá nhạt + chữ xanh lá.
    final laCuaToi = nhan == 'Của tôi';
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBorder),
      ),
      child: ListTile(
        title: Text(ten,
            style: const TextStyle(
                color: kTextPrimary, fontWeight: FontWeight.w700)),
        subtitle: Text(thongKe, style: const TextStyle(color: kTextSecondary)),
        trailing: Chip(
          label: Text(nhan,
              style: TextStyle(
                  color: laCuaToi ? kPrimary : kSuccess,
                  fontWeight: FontWeight.w700)),
          backgroundColor: laCuaToi
              ? kPrimaryTint
              : kSuccessTint,
          side: BorderSide.none,
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Thẻ 1 bộ đề (mới ở T40): tên + số câu/thời gian + thống kê (chưa có
/// nên hiện "—") + nút "Trả lời ngay" mở MH-09 kèm examId.
/// Bấm vào thẻ (ngoài nút) thì sang màn chi tiết MH-08.
class _TheBoDe extends StatelessWidget {
  const _TheBoDe({
    required this.boDe,
    required this.onTraLoiNgay,
    required this.onTap,
  });

  final Exam boDe;
  final VoidCallback onTraLoiNgay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(boDe.title,
                  style: const TextStyle(
                      color: kTextPrimary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${boDe.questionCount} câu · ${boDe.durationMinutes} phút',
                  style: const TextStyle(color: kTextSecondary)),
              const SizedBox(height: 4),
              const Text('Lượt làm: — · Điểm TB: —',
                  style: TextStyle(color: kTextSecondary)),
              const Text('Thống kê sẽ hiện khi API bổ sung',
                  style: TextStyle(color: kTextSecondary, fontSize: 12)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTraLoiNgay,
                  child: const Text('Trả lời ngay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
