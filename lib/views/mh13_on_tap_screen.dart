import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/api_client.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-13 — Ôn tập câu đã sai (Học + Ôn)
// Luồng: ôn tập sau khi làm bài (UC18)
// Vào từ: MH-03 Hồ sơ (mục "Ôn tập câu sai")
// Bố cục: chuyển chế độ Học/Ôn ở đầu màn; lọc theo chủ đề bằng
//         chip; Học = thẻ câu hỏi hiện sẵn đáp án đúng + giải
//         thích; Ôn = làm lại dạng trắc nghiệm, hết câu hiện
//         màn tổng kết (không quay vòng).
// Dữ liệu thật (T24): GET reviews/wrong — danh sách câu sai của
//         chính mình, server trả kèm đáp án đúng + giải thích.
//         Trả lời đúng ở chế độ Ôn hoặc bấm "Đã thuộc" ở chế
//         độ Học thì gỡ câu khỏi danh sách (DELETE
//         reviews/wrong/{questionId}).
// Theo chốt 27/11/2026: Học/Ôn là 2 chế độ trong cùng MH-13,
//         không tách màn riêng, không mã MH mới.
// ============================================================
class Mh13OnTapScreen extends StatefulWidget {
  const Mh13OnTapScreen({super.key});

  @override
  State<Mh13OnTapScreen> createState() => _Mh13OnTapScreenState();
}

class _Mh13OnTapScreenState extends State<Mh13OnTapScreen> {
  bool _dangTai = true;
  String? _loi;
  List<Map<String, dynamic>> _tatCa = [];
  final Map<String, String> _tenChuDe = {};
  String? _chuDeLoc; // null = tat ca
  bool _cheDoOn = false;

  // Trang thai phien On
  List<Map<String, dynamic>> _dsOn = [];
  int _chiSo = 0;
  int? _daChon;
  int _soDung = 0;
  bool _xongOn = false;

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  Future<void> _taiDuLieu() async {
    setState(() {
      _dangTai = true;
      _loi = null;
    });
    try {
      final wrong = await ApiClient().get('reviews/wrong') as List<dynamic>;
      // Ten chu de chi de hien nhan loc — loi thi bo qua, dung ma thay the
      try {
        final mine = await ApiClient().get('topics/mine') as List<dynamic>;
        for (final t in mine) {
          final m = t as Map<String, dynamic>;
          _tenChuDe[m['id'] as String] =
              (m['name'] ?? m['title'] ?? 'Chủ đề') as String;
        }
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _tatCa = wrong.cast<Map<String, dynamic>>();
        _dangTai = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loi = e.message;
        _dangTai = false;
      });
    }
  }

  List<Map<String, dynamic>> get _dsLoc => _chuDeLoc == null
      ? _tatCa
      : _tatCa.where((q) => q['topicId'] == _chuDeLoc).toList();

  String _nhanMucDo(String? d) {
    switch (d) {
      case 'easy':
        return 'Dễ';
      case 'hard':
        return 'Khó';
      default:
        return 'Trung bình';
    }
  }

  Future<void> _goCau(Map<String, dynamic> q) async {
    try {
      await ApiClient().delete('reviews/wrong/${q['id']}');
    } catch (_) {
      // Go that bai thi giu cau trong danh sach, bao loi o duoi
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa gỡ được câu này, thử lại sau.')),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _tatCa.removeWhere((x) => x['id'] == q['id']);
      _dsOn.removeWhere((x) => x['id'] == q['id']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gỡ câu khỏi danh sách câu sai.')),
    );
  }

  void _batDauOn() {
    setState(() {
      _dsOn = List.of(_dsLoc);
      _chiSo = 0;
      _daChon = null;
      _soDung = 0;
      _xongOn = false;
    });
  }

  Future<void> _traLoi(int chon) async {
    if (_daChon != null) return;
    final q = _dsOn[_chiSo];
    final dung = chon == (q['correctOption'] as num).toInt();
    setState(() {
      _daChon = chon;
      if (dung) _soDung++;
    });
    if (dung) {
      // Tra loi dung khi on = da thuoc: go khoi danh sach cau sai
      try {
        await ApiClient().delete('reviews/wrong/${q['id']}');
        if (!mounted) return;
        setState(() => _tatCa.removeWhere((x) => x['id'] == q['id']));
      } catch (_) {}
    }
  }

  void _cauTiep() {
    if (_chiSo + 1 >= _dsOn.length) {
      setState(() => _xongOn = true);
    } else {
      setState(() {
        _chiSo++;
        _daChon = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ôn tập câu sai')),
      body: _dangTai
          ? const Center(child: CircularProgressIndicator())
          : _loi != null
              ? _manLoi()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            icon: Icon(Icons.menu_book_rounded),
                            label: Text('Học'),
                          ),
                          ButtonSegment(
                            value: true,
                            icon: Icon(Icons.quiz_rounded),
                            label: Text('Ôn'),
                          ),
                        ],
                        selected: {_cheDoOn},
                        onSelectionChanged: (s) {
                          setState(() => _cheDoOn = s.first);
                          if (s.first) _batDauOn();
                        },
                      ),
                    ),
                    _hangLocChuDe(),
                    Expanded(child: _cheDoOn ? _thanOn() : _thanHoc()),
                  ],
                ),
    );
  }

  Widget _manLoi() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: kTextSecondary),
            const SizedBox(height: 12),
            Text(_loi!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            NutChinh(text: 'Thử lại', icon: Icons.refresh_rounded, onPressed: _taiDuLieu),
          ],
        ),
      ),
    );
  }

  Widget _hangLocChuDe() {
    final chuDes = _tatCa.map((q) => q['topicId'] as String).toSet().toList();
    if (chuDes.length < 2) return const SizedBox(height: 8);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('Tất cả (${_tatCa.length})'),
              selected: _chuDeLoc == null,
              onSelected: (_) {
                setState(() => _chuDeLoc = null);
                if (_cheDoOn) _batDauOn();
              },
            ),
          ),
          for (final id in chuDes)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_tenChuDe[id] ?? 'Chủ đề'),
                selected: _chuDeLoc == id,
                onSelected: (_) {
                  setState(() => _chuDeLoc = id);
                  if (_cheDoOn) _batDauOn();
                },
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- Che do Hoc ----------------

  Widget _thanHoc() {
    final ds = _dsLoc;
    if (ds.isEmpty) return _trong();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ds.length,
      itemBuilder: (ctx, i) => _theCauHoi(ds[i]),
    );
  }

  Widget _theCauHoi(Map<String, dynamic> q) {
    final options = (q['options'] as List<dynamic>).cast<String>();
    final dung = (q['correctOption'] as num).toInt();
    final giaiThich = (q['explanation'] as String?) ?? '';
    final goiY = (q['hint'] as String?) ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(_nhanMucDo(q['difficulty'] as String?)),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tenChuDe[q['topicId']] ?? '',
                    style: const TextStyle(color: kTextSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              q['content'] as String,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < options.length; i++)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: i == dung ? kSuccessTint : kSurface,
                  border: Border.all(color: i == dung ? kSuccess : kBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      '${String.fromCharCode(65 + i)}. ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: i == dung ? kSuccess : kTextSecondary,
                      ),
                    ),
                    Expanded(child: Text(options[i])),
                    if (i == dung) const Icon(Icons.check_circle_rounded, color: kSuccess, size: 20),
                  ],
                ),
              ),
            if (goiY.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 8),
                child: Text('Gợi ý: $goiY', style: const TextStyle(color: kTextSecondary)),
              ),
            if (giaiThich.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Giải thích: $giaiThich'),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _goCau(q),
                icon: const Icon(Icons.bookmark_remove_rounded, size: 18),
                label: const Text('Đã thuộc — gỡ khỏi danh sách'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Che do On ----------------

  Widget _thanOn() {
    if (_xongOn) return _manTongKet();
    if (_dsOn.isEmpty) return _trong();
    final q = _dsOn[_chiSo];
    final options = (q['options'] as List<dynamic>).cast<String>();
    final dung = (q['correctOption'] as num).toInt();
    final giaiThich = (q['explanation'] as String?) ?? '';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text('Câu ${_chiSo + 1}/${_dsOn.length}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            Text('Đúng: $_soDung', style: const TextStyle(color: kTextSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_chiSo + (_daChon != null ? 1 : 0)) / _dsOn.length,
          backgroundColor: kProgressTrack,
        ),
        const SizedBox(height: 16),
        Text(
          q['content'] as String,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < options.length; i++) _nutDapAn(i, options[i], dung),
        if (_daChon != null) ...[
          if (giaiThich.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: kPrimaryTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Giải thích: $giaiThich'),
            ),
          NutChinh(
            text: _chiSo + 1 >= _dsOn.length ? 'Xem kết quả' : 'Câu tiếp theo',
            icon: Icons.arrow_forward_rounded,
            onPressed: _cauTiep,
          ),
        ],
      ],
    );
  }

  Widget _nutDapAn(int i, String text, int dung) {
    final daTraLoi = _daChon != null;
    Color nen = kSurface;
    Color vien = kBorder;
    if (daTraLoi) {
      if (i == dung) {
        nen = kSuccessTint;
        vien = kSuccess;
      } else if (i == _daChon) {
        nen = kError.withValues(alpha: 0.10);
        vien = kError;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: nen,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: vien, width: 1.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: daTraLoi ? null : () => _traLoi(i),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: kOptionColors[i],
                  child: Text(
                    String.fromCharCode(65 + i),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(text, style: const TextStyle(fontSize: 15.5))),
                if (daTraLoi && i == dung)
                  const Icon(Icons.check_circle_rounded, color: kSuccess, size: 20),
                if (daTraLoi && i == _daChon && i != dung)
                  const Icon(Icons.cancel_rounded, color: kError, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _manTongKet() {
    final tong = _dsOn.length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 56, color: kAccent),
            const SizedBox(height: 12),
            Text(
              'Đúng $_soDung/$tong câu',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              _soDung == tong
                  ? 'Xuất sắc! Các câu đúng đã được gỡ khỏi danh sách câu sai.'
                  : 'Câu trả lời đúng đã được gỡ khỏi danh sách; các câu còn sai ở lại để ôn tiếp.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSecondary),
            ),
            const SizedBox(height: 20),
            if (_dsLoc.isNotEmpty)
              NutChinh(
                text: 'Ôn tiếp các câu còn lại',
                icon: Icons.replay_rounded,
                onPressed: _batDauOn,
              ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, size: 52, color: kSuccess),
            const SizedBox(height: 12),
            const Text(
              'Không còn câu sai nào',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Các câu trả lời sai khi làm bài sẽ xuất hiện ở đây để ôn lại.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
