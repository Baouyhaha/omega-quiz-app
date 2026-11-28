import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../services/api_client.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-26 — Cài đặt bộ đề (chủ sở hữu chủ đề)
// Luồng: L4 (chủ sở hữu tạo nội dung)
// Vào từ: MH-25 (nút "Tạo bộ đề") / MH-08 (Cài đặt)
// Đi tới: quay lại MH-08 (chi tiết bộ đề) sau khi lưu
// Bố cục: dựng theo mockup Figma MH-26-cai-dat-bo-de (các hàng
//         cài đặt dạng thẻ trắng: nhãn trái, giá trị phải; 4 hàng
//         công tắc; hàng Mã PIN có chip; nút Lưu cài đặt
//         dính đáy màn hình)
// Chức năng thật: ĐÃ nối đủ ở T20 — có examId thì mở màn tự đọc
//         cài đặt thật (GET exams/{id}), mọi hàng đều sửa được
//         (khung giờ mở/đóng, thời gian làm, số lần làm, PIN,
//         xáo trộn câu/đáp án, trợ giúp, hiện đáp án, công bố
//         điểm) và Lưu ghi hết qua PATCH exams/{id}/settings.
//         Chưa gắn examId (bản xem thử) thì hiện giá trị mẫu.
// Nút "Xóa bộ đề" ở cuối danh sách (chốt bổ sung 28/11/2026):
//   gọi DELETE exams/{id}, chỉ chủ sở hữu; hộp xác nhận ghi rõ
//   lượt làm và yêu thích gắn với bộ đề cũng bị xóa.
// ============================================================
class Mh26CaiDatBoDeScreen extends StatefulWidget {
  const Mh26CaiDatBoDeScreen({super.key, this.examId, this.tenBoDe});

  /// Mã bộ đề thật (khi vào từ MH-08 của chủ sở hữu). Để trống khi
  /// chạy bản giao diện xem thử — khi đó màn hiện giá trị mẫu.
  final String? examId;

  /// Tên bộ đề, hiện trong hộp xác nhận xóa.
  final String? tenBoDe;

  @override
  State<Mh26CaiDatBoDeScreen> createState() => _Mh26CaiDatBoDeScreenState();
}

class _Mh26CaiDatBoDeScreenState extends State<Mh26CaiDatBoDeScreen> {
  bool _dangTai = false;
  bool _dangLuu = false;
  DateTime? _moLuc;
  DateTime? _dongLuc;
  int _thoiGianLam = 30;
  int _soLanLam = 3;
  bool _batPin = true;
  String _pin = '1234';
  bool _xaoTronCau = true;
  bool _xaoTronDapAn = true;
  bool _choTroGiup = true;
  // IMMEDIATELY / AFTER_CLOSE / NEVER (theo hop dong API)
  String _hienDapAn = 'AFTER_CLOSE';
  bool _congBoDiem = true;

  @override
  void initState() {
    super.initState();
    if (widget.examId == null) {
      // Ban xem thu: gia tri mau theo mockup Figma
      _moLuc = DateTime(2026, 11, 21, 8);
      _dongLuc = DateTime(2026, 11, 21, 18);
    } else {
      _taiCaiDat();
    }
  }

  /// Đọc cài đặt thật của bộ đề từ API khi mở màn.
  Future<void> _taiCaiDat() async {
    setState(() => _dangTai = true);
    try {
      final exam = await ApiClient().get('exams/${widget.examId}')
          as Map<String, dynamic>;
      final s = exam['settings'] as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _moLuc = s['openAt'] == null ? null : DateTime.parse(s['openAt'] as String).toLocal();
        _dongLuc = s['closeAt'] == null ? null : DateTime.parse(s['closeAt'] as String).toLocal();
        _thoiGianLam = (s['durationMinutes'] as num?)?.toInt() ?? 20;
        _soLanLam = (s['maxAttempts'] as num?)?.toInt() ?? 1;
        _pin = (s['pin'] as String?) ?? '1234';
        _batPin = s['pin'] != null;
        _xaoTronCau = s['shuffleQuestions'] as bool? ?? true;
        _xaoTronDapAn = s['shuffleOptions'] as bool? ?? true;
        _choTroGiup = s['allowHelpers'] as bool? ?? true;
        _hienDapAn = s['showAnswerMode'] as String? ?? 'AFTER_CLOSE';
        _congBoDiem = s['publishScore'] as bool? ?? true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tải được cài đặt: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  String _fmtGio(DateTime? t) {
    if (t == null) return 'Không đặt';
    String hai(int n) => n.toString().padLeft(2, '0');
    return '${hai(t.day)}/${hai(t.month)} ${hai(t.hour)}:${hai(t.minute)}';
  }

  String get _nhanHienDapAn {
    switch (_hienDapAn) {
      case 'IMMEDIATELY':
        return 'Hiện đáp án ngay';
      case 'NEVER':
        return 'Không hiện đáp án';
      default:
        return 'Sau khi nộp bài';
    }
  }

  /// Chọn/bỏ khung giờ mở hoặc đóng.
  Future<void> _chonKhungGio({required bool laGioMo}) async {
    final hienTai = laGioMo ? _moLuc : _dongLuc;
    final chon = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(laGioMo ? 'Khung giờ mở' : 'Khung giờ đóng'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'dat'),
            child: const Text('Chọn ngày và giờ'),
          ),
          if (hienTai != null)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 'bo'),
              child: const Text('Bỏ đặt (không giới hạn)'),
            ),
        ],
      ),
    );
    if (chon == null || !mounted) return;
    if (chon == 'bo') {
      setState(() {
        if (laGioMo) {
          _moLuc = null;
        } else {
          _dongLuc = null;
        }
      });
      return;
    }
    final now = DateTime.now();
    final ngay = await showDatePicker(
      context: context,
      initialDate: hienTai ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (ngay == null || !mounted) return;
    final gio = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(hienTai ?? now),
    );
    if (gio == null || !mounted) return;
    setState(() {
      final t = DateTime(ngay.year, ngay.month, ngay.day, gio.hour, gio.minute);
      if (laGioMo) {
        _moLuc = t;
      } else {
        _dongLuc = t;
      }
    });
  }

  /// Hộp nhập một số nguyên (thời gian làm, số lần làm).
  Future<void> _nhapSo(String tieuDe, int giaTriCu, ValueChanged<int> onXong) async {
    final controller = TextEditingController(text: '$giaTriCu');
    final ketQua = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tieuDe),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text)),
            child: const Text('Xong'),
          ),
        ],
      ),
    );
    if (ketQua != null && ketQua > 0) onXong(ketQua);
  }

  /// Đổi mã PIN (khi công tắc PIN đang bật).
  Future<void> _nhapPin() async {
    final controller = TextEditingController(text: _pin);
    final ketQua = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mã PIN của bộ đề'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          maxLength: 6,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Xong'),
          ),
        ],
      ),
    );
    if (ketQua != null && ketQua.isNotEmpty) {
      setState(() => _pin = ketQua);
    }
  }

  /// Chọn chế độ hiện đáp án.
  Future<void> _chonHienDapAn() async {
    final chon = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Hiện đáp án'),
        children: [
          for (final entry in const {
            'IMMEDIATELY': 'Hiện đáp án ngay',
            'AFTER_CLOSE': 'Sau khi nộp bài',
            'NEVER': 'Không hiện đáp án',
          }.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, entry.key),
              child: Text(entry.key == _hienDapAn ? '✓ ${entry.value}' : entry.value),
            ),
        ],
      ),
    );
    if (chon != null) setState(() => _hienDapAn = chon);
  }

  /// Chọn cách công bố điểm.
  Future<void> _chonCongBoDiem() async {
    final chon = await showDialog<bool>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Công bố điểm'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_congBoDiem ? '✓ Ngay sau khi nộp' : 'Ngay sau khi nộp'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(!_congBoDiem ? '✓ Sau khi đóng đề' : 'Sau khi đóng đề'),
          ),
        ],
      ),
    );
    if (chon != null) setState(() => _congBoDiem = chon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt bộ đề')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HangGiaTri(
                  nhan: 'Khung giờ mở',
                  giaTri: _fmtGio(_moLuc),
                  onTap: () => _chonKhungGio(laGioMo: true),
                ),
                _HangGiaTri(
                  nhan: 'Khung giờ đóng',
                  giaTri: _fmtGio(_dongLuc),
                  onTap: () => _chonKhungGio(laGioMo: false),
                ),
                _HangGiaTri(
                  nhan: 'Thời gian làm',
                  giaTri: '$_thoiGianLam phút',
                  onTap: () => _nhapSo('Thời gian làm (phút)', _thoiGianLam, (v) => setState(() => _thoiGianLam = v)),
                ),
                _HangGiaTri(
                  nhan: 'Số lần làm tối đa',
                  giaTri: '$_soLanLam',
                  onTap: () => _nhapSo('Số lần làm tối đa', _soLanLam, (v) => setState(() => _soLanLam = v)),
                ),
                _HangCongTac(
                  nhan: 'Mã PIN',
                  giaTriPhu: InkWell(
                    onTap: _batPin ? _nhapPin : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_pin, style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  bat: _batPin,
                  onChanged: (v) => setState(() => _batPin = v),
                ),
                _HangCongTac(
                  nhan: 'Xáo trộn câu hỏi',
                  bat: _xaoTronCau,
                  onChanged: (v) => setState(() => _xaoTronCau = v),
                ),
                _HangCongTac(
                  nhan: 'Xáo trộn đáp án',
                  bat: _xaoTronDapAn,
                  onChanged: (v) => setState(() => _xaoTronDapAn = v),
                ),
                _HangCongTac(
                  nhan: 'Cho phép trợ giúp',
                  bat: _choTroGiup,
                  onChanged: (v) => setState(() => _choTroGiup = v),
                ),
                _HangGiaTri(
                  nhan: 'Hiện đáp án',
                  giaTri: _nhanHienDapAn,
                  onTap: _chonHienDapAn,
                ),
                _HangGiaTri(
                  nhan: 'Công bố điểm',
                  giaTri: _congBoDiem ? 'Ngay sau khi nộp' : 'Sau khi đóng đề',
                  onTap: _chonCongBoDiem,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _xacNhanXoaBoDe,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Xóa bộ đề'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kError,
                    side: const BorderSide(color: kError),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: NutChinh(
              text: _dangTai ? 'Đang tải...' : (_dangLuu ? 'Đang lưu...' : 'Lưu cài đặt'),
              icon: Icons.save_rounded,
              onPressed: (_dangLuu || _dangTai) ? () {} : _bamLuuCaiDat,
            ),
          ),
        ],
      ),
    );
  }

  /// Lưu TOÀN BỘ cài đặt qua API khi màn đã gắn bộ đề (examId);
  /// bản giao diện xem thử giữ thông báo mẫu như trước.
  Future<void> _bamLuuCaiDat() async {
    if (widget.examId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cài đặt (bản giao diện, chưa lưu thật).')),
      );
      Navigator.pop(context);
      return;
    }
    if (_moLuc != null && _dongLuc != null && !_dongLuc!.isAfter(_moLuc!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khung giờ đóng phải sau khung giờ mở')),
      );
      return;
    }
    setState(() => _dangLuu = true);
    try {
      await ApiClient().patch('exams/${widget.examId}/settings', {
        'openAt': _moLuc?.toUtc().toIso8601String(),
        'closeAt': _dongLuc?.toUtc().toIso8601String(),
        'durationMinutes': _thoiGianLam,
        'maxAttempts': _soLanLam,
        'pin': _batPin ? _pin : null,
        'shuffleQuestions': _xaoTronCau,
        'shuffleOptions': _xaoTronDapAn,
        'allowHelpers': _choTroGiup,
        'showAnswerMode': _hienDapAn,
        'publishScore': _congBoDiem,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cài đặt.')),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _dangLuu = false);
    }
  }

  /// Hộp xác nhận xóa bộ đề. Có examId thì gọi API xóa thật rồi
  /// quay lại màn trước; chưa gắn bộ đề (bản giao diện) thì chỉ báo.
  Future<void> _xacNhanXoaBoDe() async {
    final ten = widget.tenBoDe ?? 'Bộ đề giữa kỳ';
    final dongY = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bộ đề?'),
        content: Text(
          'Xóa bộ đề "$ten"? Các lượt làm và mục yêu thích gắn với '
          'bộ đề này cũng bị xóa. Không hoàn tác được.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: kError),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (dongY != true || !mounted) return;
    if (widget.examId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bản giao diện: chưa gắn bộ đề thật để xóa.'),
        ),
      );
      return;
    }
    try {
      await ApiClient().delete('exams/${widget.examId}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa bộ đề.')),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }
}

class _HangGiaTri extends StatelessWidget {
  final String nhan;
  final String giaTri;
  final VoidCallback? onTap;

  const _HangGiaTri({required this.nhan, required this.giaTri, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(child: Text(nhan, style: const TextStyle(fontSize: 15.5))),
              Text(giaTri, style: const TextStyle(color: kTextSub, fontSize: 15)),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: kTextSub, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HangCongTac extends StatelessWidget {
  final String nhan;
  final Widget? giaTriPhu;
  final bool bat;
  final ValueChanged<bool> onChanged;

  const _HangCongTac({
    required this.nhan,
    this.giaTriPhu,
    required this.bat,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(nhan, style: const TextStyle(fontSize: 15.5))),
            if (giaTriPhu != null) ...[giaTriPhu!, const SizedBox(width: 10)],
            Switch(value: bat, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
