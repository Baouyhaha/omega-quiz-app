import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../routes.dart';
import '../services/api_client.dart';
import 'mh26_cai_dat_bo_de_screen.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-25 — Tạo/Sửa bộ đề (chủ sở hữu chủ đề)
// Luồng: L4 (chủ sở hữu tạo nội dung)
// Vào từ: MH-07 (danh sách bộ đề, nút Tạo bộ đề) / MH-08 (Sửa)
// Đi tới: MH-26 (cài đặt bộ đề) sau khi tạo xong phần nội dung
// Bố cục: dựng theo mockup Figma MH-25-tao-sua-bo-de (ô tên bộ đề,
//         2 thẻ chọn cách tạo dạng radio, 3 ô số lượng theo mức độ
//         Dễ 8 / Trung bình 8 / Khó 4, tổng 20 câu, nút Tạo bộ đề
//         dính đáy màn hình)
// Dữ liệu giả: _mockCauHoi ngay dưới đây (chỉ hiện khi chọn
//             Ghép thủ công ở bản xem thử chưa gắn chủ đề)
// Chức năng thật: ĐÃ nối ở T20 — có topicId thì tạo thật qua
//             POST topics/{topicId}/exams (ngẫu nhiên theo số câu
//             từng mức, hoặc ghép thủ công từ kho câu của chủ đề);
//             có examId (vào từ Sửa) thì chỉ PATCH lại tên bộ đề.
// ============================================================

// MOCK: vai cau hoi cua chu de Toan cao cap de ghep thu cong
const _mockCauHoi = [
  {'noiDung': 'Đạo hàm của hàm số f(x) = x² là gì?', 'mucDo': 'Dễ'},
  {'noiDung': 'Giới hạn lim (x→0) sin(x)/x bằng bao nhiêu?', 'mucDo': 'Trung bình'},
  {'noiDung': 'Tích phân ∫(0→1) x·e^x dx bằng bao nhiêu?', 'mucDo': 'Khó'},
  {'noiDung': 'Định thức của ma trận [[1,2],[3,4]] bằng bao nhiêu?', 'mucDo': 'Dễ'},
  {'noiDung': 'Nghiệm của phương trình vi phân y\' = 2y là gì?', 'mucDo': 'Khó'},
];

class Mh25TaoSuaBoDeScreen extends StatefulWidget {
  const Mh25TaoSuaBoDeScreen({super.key, this.topicId, this.examId, this.tenCoSan});

  /// Chủ đề sẽ chứa bộ đề (vào từ MH-07 của chủ sở hữu). Để trống
  /// khi chạy bản giao diện xem thử — khi đó dùng dữ liệu mẫu.
  final String? topicId;

  /// Mã bộ đề khi vào từ nút Sửa ở MH-08: màn chuyển sang lưu tên.
  final String? examId;

  /// Tên bộ đề có sẵn (hiện sẵn trong ô tên khi sửa).
  final String? tenCoSan;

  @override
  State<Mh25TaoSuaBoDeScreen> createState() => _Mh25TaoSuaBoDeScreenState();
}

class _Mh25TaoSuaBoDeScreenState extends State<Mh25TaoSuaBoDeScreen> {
  // 0: trich ngau nhien, 1: ghep thu cong
  int _cachTao = 0;
  final Set<int> _cauDaChon = {0, 1};
  final _tenController = TextEditingController();
  final _deController = TextEditingController(text: '8');
  final _tbController = TextEditingController(text: '8');
  final _khoController = TextEditingController(text: '4');
  bool _dangTao = false;
  // Kho cau hoi that cua chu de (ghep thu cong); null = chua tai/ban xem thu
  List<Map<String, dynamic>>? _khoCauHoi;
  final Set<String> _cauThatDaChon = {};

  bool get _cheDoSua => widget.examId != null;

  @override
  void initState() {
    super.initState();
    if (widget.tenCoSan != null) _tenController.text = widget.tenCoSan!;
    if (widget.topicId != null) _taiKhoCauHoi();
  }

  @override
  void dispose() {
    _tenController.dispose();
    _deController.dispose();
    _tbController.dispose();
    _khoController.dispose();
    super.dispose();
  }

  Future<void> _taiKhoCauHoi() async {
    try {
      final data = await ApiClient().get('topics/${widget.topicId}/questions');
      if (!mounted) return;
      setState(() {
        _khoCauHoi = (data as List).cast<Map<String, dynamic>>();
      });
    } on ApiException {
      // Tai kho that bai: phan ghep thu cong se bao loi khi bam Tao.
    }
  }

  int get _tongNgauNhien =>
      (int.tryParse(_deController.text) ?? 0) +
      (int.tryParse(_tbController.text) ?? 0) +
      (int.tryParse(_khoController.text) ?? 0);

  String _nhanMucDo(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'Dễ';
      case 'medium':
        return 'Trung bình';
      case 'hard':
        return 'Khó';
      default:
        return difficulty;
    }
  }

  Future<void> _bamTaoBoDe() async {
    final ten = _tenController.text.trim();
    if (_cheDoSua) {
      if (ten.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa nhập tên bộ đề')),
        );
        return;
      }
      setState(() => _dangTao = true);
      try {
        await ApiClient().patch('exams/${widget.examId}', {'title': ten});
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu tên bộ đề.')),
        );
        Navigator.pop(context);
      } on ApiException catch (e) {
        if (!mounted) return;
        setState(() => _dangTao = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
      return;
    }
    if (widget.topicId == null) {
      // Ban giao dien xem thu: giu luong cu, di tiep sang MH-26.
      Navigator.pushNamed(context, AppRoutes.mh26);
      return;
    }
    if (ten.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa nhập tên bộ đề')),
      );
      return;
    }
    final Map<String, dynamic> body;
    if (_cachTao == 0) {
      if (_tongNgauNhien <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tổng số câu phải lớn hơn 0')),
        );
        return;
      }
      body = {
        'title': ten,
        'mode': 'RANDOM',
        'counts': {
          'easy': int.tryParse(_deController.text) ?? 0,
          'medium': int.tryParse(_tbController.text) ?? 0,
          'hard': int.tryParse(_khoController.text) ?? 0,
        },
      };
    } else {
      if (_cauThatDaChon.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa chọn câu hỏi nào')),
        );
        return;
      }
      body = {
        'title': ten,
        'mode': 'MANUAL',
        'questionIds': _cauThatDaChon.toList(),
      };
    }
    setState(() => _dangTao = true);
    try {
      final exam = await ApiClient().post(
        'topics/${widget.topicId}/exams',
        body,
      ) as Map<String, dynamic>;
      if (!mounted) return;
      // Tao xong -> sang MH-26 cai dat, mang theo ma bo de vua tao.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Mh26CaiDatBoDeScreen(
            examId: exam['id'] as String,
            tenBoDe: ten,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _dangTao = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_cheDoSua ? 'Sửa bộ đề' : 'Tạo bộ đề')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Tên bộ đề', style: TextStyle(color: kTextSub)),
                const SizedBox(height: 6),
                TextField(
                  controller: _tenController,
                  decoration: const InputDecoration(hintText: 'Ví dụ: Giữa kỳ — Đạo hàm'),
                ),
                const SizedBox(height: 18),
                const Text('Cách tạo bộ đề', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                _TheCachTao(
                  dangChon: _cachTao == 0,
                  tieuDe: 'Trích ngẫu nhiên',
                  moTa: 'Rút câu theo mức độ từ kho câu hỏi',
                  onTap: () => setState(() => _cachTao = 0),
                ),
                const SizedBox(height: 10),
                _TheCachTao(
                  dangChon: _cachTao == 1,
                  tieuDe: 'Ghép thủ công',
                  moTa: 'Tự chọn từng câu trong kho',
                  onTap: () => setState(() => _cachTao = 1),
                ),
                const SizedBox(height: 16),
                if (_cachTao == 0) ...[
                  Row(
                    children: [
                      Expanded(child: _OSoLuong(nhan: 'Dễ', controller: _deController, mauSo: kSuccess, onChanged: () => setState(() {}))),
                      const SizedBox(width: 10),
                      Expanded(child: _OSoLuong(nhan: 'Trung bình', controller: _tbController, mauSo: const Color(0xFFEF8A2A), onChanged: () => setState(() {}))),
                      const SizedBox(width: 10),
                      Expanded(child: _OSoLuong(nhan: 'Khó', controller: _khoController, mauSo: kError, onChanged: () => setState(() {}))),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text('Tổng: $_tongNgauNhien câu', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Câu hỏi được rút ngẫu nhiên từ kho',
                      style: TextStyle(color: kTextSub),
                    ),
                  ),
                ] else if (_khoCauHoi != null) ...[
                  Text(
                    'Chọn câu hỏi (đã chọn ${_cauThatDaChon.length}/${_khoCauHoi!.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  for (final q in _khoCauHoi!)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        value: _cauThatDaChon.contains(q['id']),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _cauThatDaChon.add(q['id'] as String);
                          } else {
                            _cauThatDaChon.remove(q['id']);
                          }
                        }),
                        title: Text(q['content'] as String),
                        subtitle: Text('Mức độ: ${_nhanMucDo(q['difficulty'] as String)}'),
                      ),
                    ),
                ] else ...[
                  Text(
                    'Chọn câu hỏi (đã chọn ${_cauDaChon.length}/${_mockCauHoi.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < _mockCauHoi.length; i++)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        value: _cauDaChon.contains(i),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _cauDaChon.add(i);
                          } else {
                            _cauDaChon.remove(i);
                          }
                        }),
                        title: Text(_mockCauHoi[i]['noiDung']!),
                        subtitle: Text('Mức độ: ${_mockCauHoi[i]['mucDo']}'),
                      ),
                    ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: NutChinh(
              text: _dangTao ? 'Đang xử lý...' : (_cheDoSua ? 'Lưu thay đổi' : 'Tạo bộ đề'),
              onPressed: _dangTao ? () {} : _bamTaoBoDe,
            ),
          ),
        ],
      ),
    );
  }
}

class _TheCachTao extends StatelessWidget {
  final bool dangChon;
  final String tieuDe;
  final String moTa;
  final VoidCallback onTap;

  const _TheCachTao({
    required this.dangChon,
    required this.tieuDe,
    required this.moTa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dangChon ? kPrimary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: dangChon ? kPrimary : kTextSub, width: 2),
              ),
              alignment: Alignment.center,
              child: dangChon
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tieuDe, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                  Text(moTa, style: const TextStyle(fontSize: 13, color: kTextSub)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OSoLuong extends StatelessWidget {
  final String nhan;
  final TextEditingController controller;
  final Color mauSo;
  final VoidCallback onChanged;

  const _OSoLuong({
    required this.nhan,
    required this.controller,
    required this.mauSo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(nhan, style: const TextStyle(fontSize: 13, color: kTextSub)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: mauSo),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
