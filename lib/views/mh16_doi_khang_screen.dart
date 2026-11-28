import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../services/api_client.dart';
import '../utils/rank_helper.dart';
import '../widgets/nut_chinh_widget.dart';

// ============================================================
// MH-16 — Đối kháng 1-1 (T27)
// Luồng: L6 (Đối kháng 1-1)
// Vào từ: tab Thi đấu của khung điều hướng
// Bố cục: dựng theo mockup Figma MH-16-doi-khang-1-1 (thẻ chủ
//         đề đã chọn, nút Tạo phòng, thẻ mã phòng, thẻ chờ đối
//         thủ, thẻ người chơi có tiến trình đối thủ) — các thẻ
//         đó nay hiện dữ liệu thật theo từng giai đoạn phòng.
// Chức năng thật (T27): trọn luồng trong MH-16 — tạo phòng
//         (server rút ngẫu nhiên câu từ kho chủ đề, chốt vào
//         phòng), vào phòng bằng mã, cả hai bấm Sẵn sàng thì
//         trận bắt đầu, thi đồng thời và thấy tiến độ đối thủ,
//         nộp bài chờ nhau, kết quả thắng/hòa/thua cộng/trừ
//         điểm hạng +15/0/−10. Đồng bộ bằng cách hỏi lại trạng
//         thái phòng từ server mỗi 2–3 giây (không websocket).
// API: POST battles · POST battles/{mã}/join · POST
//         battles/{id}/ready · GET battles/{id} · POST
//         battles/{id}/progress · POST battles/{id}/submit
// ============================================================

enum _GiaiDoan { sanh, cho, thi, choKetQua, ketQua }

class Mh16DoiKhangScreen extends StatefulWidget {
  const Mh16DoiKhangScreen({super.key});

  @override
  State<Mh16DoiKhangScreen> createState() => _Mh16DoiKhangScreenState();
}

class _Mh16DoiKhangScreenState extends State<Mh16DoiKhangScreen> {
  // Ho so cua minh + danh sach chu de
  bool _dangTaiDau = true;
  String? _loiDau;
  String? _myUid;
  String _myName = '';
  int _myRank = 0;
  List<Map<String, dynamic>> _chuDes = [];
  String? _chuDeId;
  int _soCau = 10;
  final _maController = TextEditingController();
  bool _dangXuLy = false;

  // Phong va tran
  _GiaiDoan _gd = _GiaiDoan.sanh;
  Map<String, dynamic>? _phong;
  Timer? _timer;
  bool _dangPoll = false;

  // Phien thi
  List<Map<String, dynamic>> _cauHoi = [];
  int _chiSo = 0;
  final Map<String, int> _chon = {};
  DateTime? _batDauLuc;

  @override
  void initState() {
    super.initState();
    _taiBanDau();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _maController.dispose();
    super.dispose();
  }

  Future<void> _taiBanDau() async {
    setState(() {
      _dangTaiDau = true;
      _loiDau = null;
    });
    try {
      final me = await ApiClient().get('me') as Map<String, dynamic>;
      final mine = await ApiClient().get('topics/mine') as List<dynamic>;
      var topics = mine.cast<Map<String, dynamic>>();
      if (topics.isEmpty) {
        final pub = await ApiClient().get('topics/public') as Map<String, dynamic>;
        topics = (pub['items'] as List<dynamic>).cast<Map<String, dynamic>>();
      }
      if (!mounted) return;
      setState(() {
        _myUid = me['id'] as String?;
        _myName = (me['name'] ?? '') as String;
        _myRank = (me['rankScore'] as num?)?.toInt() ?? 0;
        _chuDes = topics;
        _chuDeId = topics.isNotEmpty ? topics.first['id'] as String : null;
        _dangTaiDau = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loiDau = e.message;
        _dangTaiDau = false;
      });
    }
  }

  String _tenChuDe(String? id) {
    for (final t in _chuDes) {
      if (t['id'] == id) return (t['name'] ?? t['title'] ?? 'Chủ đề') as String;
    }
    return 'Chủ đề';
  }

  List<dynamic> get _players =>
      (_phong?['players'] as List<dynamic>?) ?? const [];

  Map<String, dynamic>? get _doiThu {
    for (final p in _players) {
      final m = p as Map<String, dynamic>;
      if (m['uid'] != _myUid) return m;
    }
    return null;
  }

  bool get _laChuPhong => _phong?['hostId'] == _myUid;

  void _baoLoi(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e is ApiException ? e.message : 'Đã có lỗi xảy ra')),
    );
  }

  // ---------------- Sanh ----------------

  Future<void> _taoPhong() async {
    if (_chuDeId == null) return;
    setState(() => _dangXuLy = true);
    try {
      final phong = await ApiClient().post('battles', {
        'topicId': _chuDeId,
        'questionCount': _soCau,
      }) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _phong = phong;
        _gd = _GiaiDoan.cho;
      });
      _batPoll(const Duration(seconds: 2));
    } catch (e) {
      _baoLoi(e);
    } finally {
      if (mounted) setState(() => _dangXuLy = false);
    }
  }

  Future<void> _vaoPhong() async {
    final ma = _maController.text.trim().toUpperCase();
    if (ma.isEmpty) {
      _baoLoi(ApiException('Hãy nhập mã phòng'));
      return;
    }
    setState(() => _dangXuLy = true);
    try {
      final phong = await ApiClient().post('battles/$ma/join', {})
          as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _phong = phong;
        _gd = _GiaiDoan.cho;
      });
      _batPoll(const Duration(seconds: 2));
    } catch (e) {
      _baoLoi(e);
    } finally {
      if (mounted) setState(() => _dangXuLy = false);
    }
  }

  Future<void> _chonChuDe() async {
    final chon = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Chọn chủ đề thi đấu'),
        children: [
          for (final t in _chuDes)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, t['id'] as String),
              child: Text(
                (t['id'] == _chuDeId ? '✓ ' : '') +
                    ((t['name'] ?? t['title'] ?? 'Chủ đề') as String),
              ),
            ),
        ],
      ),
    );
    if (chon != null) setState(() => _chuDeId = chon);
  }

  // ---------------- Phong cho + dong bo ----------------

  void _batPoll(Duration nhip) {
    _timer?.cancel();
    _timer = Timer.periodic(nhip, (_) => _poll());
  }

  Future<void> _poll() async {
    if (_dangPoll || _phong == null) return;
    _dangPoll = true;
    try {
      final data = await ApiClient().get('battles/${_phong!['id']}')
          as Map<String, dynamic>;
      if (!mounted) return;
      final status = data['status'] as String?;
      if (_gd == _GiaiDoan.cho && status == 'IN_PROGRESS') {
        final qs = data['questions'] as List<dynamic>?;
        setState(() => _phong = data);
        if (qs != null) _vaoTran(qs);
      } else if (_gd == _GiaiDoan.choKetQua && status == 'FINISHED') {
        _timer?.cancel();
        setState(() {
          _phong = data;
          _gd = _GiaiDoan.ketQua;
        });
      } else {
        setState(() => _phong = data);
      }
    } catch (_) {
      // Loi mang tam thoi khi poll: bo qua, lan poll sau thu lai
    } finally {
      _dangPoll = false;
    }
  }

  Future<void> _sanSang() async {
    setState(() => _dangXuLy = true);
    try {
      final data = await ApiClient().post('battles/${_phong!['id']}/ready', {})
          as Map<String, dynamic>;
      if (!mounted) return;
      setState(() => _phong = data);
      final qs = data['questions'] as List<dynamic>?;
      if (data['status'] == 'IN_PROGRESS' && qs != null) _vaoTran(qs);
    } catch (e) {
      _baoLoi(e);
    } finally {
      if (mounted) setState(() => _dangXuLy = false);
    }
  }

  void _roiPhong() {
    _timer?.cancel();
    setState(() {
      _phong = null;
      _gd = _GiaiDoan.sanh;
      _cauHoi = [];
      _chon.clear();
    });
  }

  // ---------------- Trong tran ----------------

  void _vaoTran(List<dynamic> qs) {
    _timer?.cancel();
    setState(() {
      _cauHoi = qs.cast<Map<String, dynamic>>();
      _chiSo = 0;
      _chon.clear();
      _batDauLuc = DateTime.now();
      _gd = _GiaiDoan.thi;
    });
    _batPoll(const Duration(seconds: 3));
  }

  Future<void> _traLoi(int chon) async {
    final q = _cauHoi[_chiSo];
    setState(() => _chon[q['id'] as String] = chon);
    try {
      await ApiClient().post('battles/${_phong!['id']}/progress', {
        'answeredCount': _chon.length,
      });
    } catch (_) {}
    if (!mounted) return;
    if (_chiSo + 1 < _cauHoi.length) {
      setState(() => _chiSo++);
    }
  }

  Future<void> _nopBai() async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nộp bài?'),
        content: Text(
          'Bạn đã trả lời ${_chon.length}/${_cauHoi.length} câu. '
          'Nộp rồi không sửa được nữa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Làm tiếp'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );
    if (dongY != true || !mounted) return;
    setState(() => _dangXuLy = true);
    try {
      final answers = [
        for (final e in _chon.entries)
          {'questionId': e.key, 'selectedOption': e.value},
      ];
      final giay = _batDauLuc == null
          ? 0
          : DateTime.now().difference(_batDauLuc!).inSeconds;
      final data = await ApiClient().post('battles/${_phong!['id']}/submit', {
        'answers': answers,
        'durationSeconds': giay,
      }) as Map<String, dynamic>;
      if (!mounted) return;
      _timer?.cancel();
      setState(() {
        _phong = data;
        _gd = data['status'] == 'FINISHED'
            ? _GiaiDoan.ketQua
            : _GiaiDoan.choKetQua;
      });
      if (_gd == _GiaiDoan.choKetQua) _batPoll(const Duration(seconds: 2));
    } catch (e) {
      _baoLoi(e);
    } finally {
      if (mounted) setState(() => _dangXuLy = false);
    }
  }

  void _veSanh() {
    _timer?.cancel();
    setState(() {
      _phong = null;
      _gd = _GiaiDoan.sanh;
      _cauHoi = [];
      _chon.clear();
    });
    _taiBanDau(); // nap lai diem hang sau tran
  }

  // ---------------- Giao dien ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đối kháng 1-1')),
      body: _dangTaiDau
          ? const Center(child: CircularProgressIndicator())
          : _loiDau != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_loiDau!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        NutChinh(text: 'Thử lại', icon: Icons.refresh_rounded, onPressed: _taiBanDau),
                      ],
                    ),
                  ),
                )
              : switch (_gd) {
                  _GiaiDoan.sanh => _thanSanh(),
                  _GiaiDoan.cho => _thanCho(),
                  _GiaiDoan.thi => _thanThi(),
                  _GiaiDoan.choKetQua => _thanChoKetQua(),
                  _GiaiDoan.ketQua => _thanKetQua(),
                },
    );
  }

  Widget _thanSanh() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chủ đề đã chọn', style: TextStyle(fontSize: 13, color: kTextSub)),
                      const SizedBox(height: 2),
                      Text(_tenChuDe(_chuDeId), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(64, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: _chuDes.length > 1 ? _chonChuDe : null,
                  child: const Text('Đổi'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Số câu mỗi trận:', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            for (final n in [5, 10, 15, 20])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('$n'),
                  selected: _soCau == n,
                  onSelected: (_) => setState(() => _soCau = n),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        NutChinh(
          text: _dangXuLy ? 'Đang tạo phòng...' : 'Tạo phòng',
          icon: Icons.sports_esports_rounded,
          onPressed: _dangXuLy ? () {} : _taoPhong,
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('hoặc vào phòng có sẵn', style: TextStyle(color: kTextSub)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _maController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Mã phòng',
                      hintText: 'VD: X7K2P9',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                NutChinh(
                  text: 'Vào phòng',
                  onPressed: _dangXuLy ? () {} : _vaoPhong,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _theNguoiChoi(
          ten: _myName.isEmpty ? 'Bạn' : _myName,
          laToi: true,
          hang: animalRank(_myRank),
          diem: _myRank,
        ),
      ],
    );
  }

  Widget _thanCho() {
    final phong = _phong!;
    final doiThu = _doiThu;
    final toi = _players.cast<Map<String, dynamic>?>().firstWhere(
          (p) => p?['uid'] == _myUid,
          orElse: () => null,
        );
    final toiSanSang = toi?['ready'] == true;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mã phòng', style: TextStyle(fontSize: 13, color: kTextSub)),
                      const SizedBox(height: 2),
                      Text(
                        phong['code'] as String? ?? '',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kPrimary, letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(64, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Mã phòng: ${phong['code']} — gửi mã này cho đối thủ')),
                    );
                  },
                  child: const Text('Chia sẻ mã'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Chủ đề: ${_tenChuDe(phong['topicId'] as String?)} · ${phong['questionCount']} câu · Máy chủ rút ngẫu nhiên',
          style: const TextStyle(color: kTextSub),
        ),
        const SizedBox(height: 12),
        if (doiThu == null)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(color: kPrimary, strokeWidth: 3),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đang chờ đối thủ…', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        SizedBox(height: 2),
                        Text('Chia sẻ mã phòng cho bạn bè', style: TextStyle(color: kTextSub)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          _theNguoiChoi(
            ten: doiThu['name'] as String? ?? 'Đối thủ',
            laToi: false,
            sanSang: doiThu['ready'] == true,
          ),
        const SizedBox(height: 12),
        _theNguoiChoi(
          ten: _myName.isEmpty ? 'Bạn' : _myName,
          laToi: true,
          hang: animalRank(_myRank),
          diem: _myRank,
          sanSang: toiSanSang,
        ),
        const SizedBox(height: 16),
        if (doiThu != null && !toiSanSang)
          NutChinh(
            text: _dangXuLy ? 'Đang gửi...' : 'Sẵn sàng',
            icon: Icons.check_circle_rounded,
            onPressed: _dangXuLy ? () {} : _sanSang,
          )
        else if (doiThu != null)
          const Center(
            child: Text('Đã sẵn sàng — chờ đối thủ bấm Sẵn sàng là trận bắt đầu',
                textAlign: TextAlign.center, style: TextStyle(color: kTextSub)),
          )
        else
          const Center(
            child: Text('Đối thủ vào phòng rồi cả hai cùng bấm Sẵn sàng',
                textAlign: TextAlign.center, style: TextStyle(color: kTextSub)),
          ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _roiPhong,
          child: Text(_laChuPhong ? 'Hủy phòng' : 'Rời phòng'),
        ),
      ],
    );
  }

  /// Thẻ người chơi dùng ở sảnh, phòng chờ và kết quả.
  Widget _theNguoiChoi({
    required String ten,
    required bool laToi,
    String? hang,
    int? diem,
    bool? sanSang,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kPrimary,
              child: Text(
                ten.isEmpty ? '?' : ten[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ten, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  if (hang != null && diem != null)
                    Row(
                      children: [
                        const Text('Hạng ', style: TextStyle(color: kTextSub)),
                        Image.asset(iconRank(hang), width: 20, height: 20),
                        const SizedBox(width: 6),
                        Text('$diem điểm', style: const TextStyle(color: kTextSub)),
                      ],
                    )
                  else
                    Text(laToi ? 'Bạn' : 'Đối thủ', style: const TextStyle(color: kTextSub)),
                ],
              ),
            ),
            if (sanSang != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (sanSang ? kSuccess : kTextSub).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sanSang ? 'Đã sẵn sàng' : 'Chưa sẵn sàng',
                  style: TextStyle(color: sanSang ? kSuccess : kTextSub, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _thanThi() {
    final q = _cauHoi[_chiSo];
    final options = (q['options'] as List<dynamic>).cast<String>();
    final doiThu = _doiThu;
    final tongCau = (_phong?['questionCount'] as num?)?.toInt() ?? _cauHoi.length;
    final doiThuDaLam = (doiThu?['answeredCount'] as num?)?.toInt() ?? 0;
    final daChon = _chon[q['id']];
    final laCauCuoi = _chiSo + 1 >= _cauHoi.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đối thủ đã làm $doiThuDaLam/$tongCau câu',
                  style: const TextStyle(color: kTextSub),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: tongCau == 0 ? 0 : doiThuDaLam / tongCau,
                  color: kSuccess,
                  backgroundColor: kProgressTrack,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text('Câu ${_chiSo + 1}/${_cauHoi.length}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            Text('Đã trả lời ${_chon.length}/${_cauHoi.length}',
                style: const TextStyle(color: kTextSub)),
          ],
        ),
        const SizedBox(height: 10),
        Text(q['content'] as String,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: daChon == i ? kPrimaryTint : kSurface,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: daChon == i ? kPrimary : kBorder,
                  width: 1.4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _traLoi(i),
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
                      Expanded(child: Text(options[i], style: const TextStyle(fontSize: 15.5))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (_chiSo > 0)
              OutlinedButton(
                onPressed: () => setState(() => _chiSo--),
                child: const Text('Câu trước'),
              ),
            const Spacer(),
            if (laCauCuoi)
              NutChinh(
                text: _dangXuLy ? 'Đang nộp...' : 'Nộp bài',
                icon: Icons.send_rounded,
                onPressed: _dangXuLy ? () {} : _nopBai,
              )
            else
              const Text('Chọn đáp án để sang câu tiếp theo',
                  style: TextStyle(color: kTextSub, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _thanChoKetQua() {
    final doiThu = _doiThu;
    final doiThuDaNop = doiThu?['submitted'] == true;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(color: kPrimary, strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            const Text('Đã nộp bài của bạn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              doiThuDaNop
                  ? 'Đối thủ cũng đã nộp — đang tính kết quả…'
                  : 'Đang chờ đối thủ nộp bài…',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSub),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thanKetQua() {
    final phong = _phong!;
    final results = phong['results'] as Map<String, dynamic>?;
    final winner = results?['winner'] as String?;
    final deltas = (results?['deltas'] as Map<String, dynamic>?) ?? const {};
    final subs = (results?['submissions'] as Map<String, dynamic>?) ?? const {};
    final deltaToi = (deltas[_myUid] as num?)?.toInt() ?? 0;
    final thang = winner != null && winner == _myUid;
    final hoa = winner == null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  hoa
                      ? Icons.handshake_rounded
                      : thang
                          ? Icons.emoji_events_rounded
                          : Icons.sentiment_dissatisfied_rounded,
                  size: 52,
                  color: hoa ? kTextSub : (thang ? kAccent : kError),
                ),
                const SizedBox(height: 10),
                Text(
                  hoa ? 'Hòa!' : (thang ? 'Bạn thắng!' : 'Bạn thua'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  deltaToi > 0
                      ? '+$deltaToi điểm xếp hạng'
                      : deltaToi < 0
                          ? '$deltaToi điểm xếp hạng'
                          : 'Không đổi điểm xếp hạng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: deltaToi > 0 ? kSuccess : (deltaToi < 0 ? kError : kTextSub),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final p in _players)
          Builder(builder: (ctx) {
            final m = p as Map<String, dynamic>;
            final uid = m['uid'] as String;
            final sub = subs[uid] as Map<String, dynamic>?;
            final dung = (sub?['correct'] as num?)?.toInt() ?? 0;
            final giay = (sub?['durationSeconds'] as num?)?.toInt() ?? 0;
            final d = (deltas[uid] as num?)?.toInt() ?? 0;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kPrimary,
                  child: Text(
                    (m['name'] as String? ?? '?')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
                title: Text(
                  '${m['name'] ?? ''}${uid == _myUid ? ' (bạn)' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text('Đúng $dung/${phong['questionCount']} câu · ${giay ~/ 60} phút ${giay % 60} giây'),
                trailing: Text(
                  d > 0 ? '+$d' : '$d',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: d > 0 ? kSuccess : (d < 0 ? kError : kTextSub),
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 8),
        NutChinh(
          text: 'Chơi trận mới',
          icon: Icons.replay_rounded,
          onPressed: _veSanh,
        ),
      ],
    );
  }
}
