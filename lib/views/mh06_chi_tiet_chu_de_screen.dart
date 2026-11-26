import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../models/topic.dart';
import '../services/topic_service.dart';
import 'mh07_danh_sach_bo_de_screen.dart';
import 'mh20_tao_sua_chu_de_screen.dart';

class Mh06ChiTietChuDeScreen extends StatefulWidget {
  final String token;
  final Topic topic;

  const Mh06ChiTietChuDeScreen({
    super.key,
    required this.token,
    required this.topic,
  });

  @override
  State<Mh06ChiTietChuDeScreen> createState() =>
      _Mh06ChiTietChuDeScreenState();
}

class _Mh06ChiTietChuDeScreenState extends State<Mh06ChiTietChuDeScreen> {
  late final TopicService _service;
  late Topic _topic;
  List<TopicExam> _exams = [];
  bool _loadingExams = true;
  String? _examsError;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _service = TopicService(widget.token);
    _topic = widget.topic;
    _loadExams();
    _checkOwner();
  }

  Future<void> _checkOwner() async {
    try {
      final mine = await _service.getMine();
      for (final t in mine) {
        if (t.id == _topic.id && t.myRole != null && mounted) {
          setState(() => _topic = _topic.copyWith(myRole: t.myRole));
          return;
        }
      }
    } catch (_) {}
  }

  Future<void> _loadExams() async {
    setState(() {
      _loadingExams = true;
      _examsError = null;
    });
    try {
      final list = await _service.getExams(_topic.id);
      if (!mounted) return;
      setState(() {
        _exams = list;
        _loadingExams = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _examsError = e.toString().replaceFirst('Exception: ', '');
        _loadingExams = false;
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showForm() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => Mh20TaoSuaChuDeScreen(
          token: widget.token,
          topic: _topic,
        ),
      ),
    );
    if (changed == true && mounted) {
      _showSnack('Đã sửa chủ đề');
      Navigator.pop(context, true);
    }
  }

  Future<void> _createExamQuick() async {
    final titleController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo bộ đề nhanh'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'Nhập tên bộ đề',
            labelText: 'Tên bộ đề',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
    final title = titleController.text.trim();
    titleController.dispose();
    if (ok != true || title.isEmpty) return;
    try {
      await _service.createExamRandom(topicId: _topic.id, title: title);
      if (!mounted) return;
      _showSnack('Đã tạo bộ đề');
      await _loadExams();
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _confirmDelete() async {
    final hasContent = _topic.examCount > 0 || _topic.questionCount > 0;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa chủ đề'),
        content: Text(
          hasContent
              ? 'Chủ đề này còn ${_topic.examCount} bộ đề và ${_topic.questionCount} câu hỏi. Xóa chủ đề sẽ làm các bộ đề và câu hỏi đó không còn chủ đề. Vẫn xóa?'
              : 'Xóa chủ đề ${_topic.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: kError)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busyId = _topic.id);
    try {
      await _service.deleteTopic(_topic.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D1B2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6E6A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, {Color? color, Color? background}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? (color ?? kPrimary).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color ?? kPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = _topic.ownerExpired;
    final busy = _busyId == _topic.id;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F4FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          color: const Color(0xFF1D1B2E),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _topic.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D1B2E),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              _topic.isPublic
                  ? _chip(
                      'Công khai',
                      color: const Color(0xFF1E9E5A),
                      background: const Color(0xFFE9F8F0),
                    )
                  : _chip('Riêng tư'),
              if (readOnly) ...[
                const SizedBox(width: 8),
                _chip('Chỉ đọc', color: const Color(0xFFFF9F1C)),
              ],
            ],
          ),
          if (_topic.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _topic.description,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1D1B2E),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                _stat('${_topic.questionCount}', 'câu hỏi'),
                _stat('${_topic.examCount}', 'bộ đề'),
                _stat('${_topic.memberCount}', 'thành viên'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                disabledBackgroundColor:
                    readOnly ? const Color(0xFFDDD6FE) : kPrimary,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: readOnly
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Chỉ đọc',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    )
                  : const Text(
                      'Tham gia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          if (readOnly) ...[
            const SizedBox(height: 12),
            const Text(
              'Chủ đề chỉ đọc — chủ sở hữu đã hết hạn gói',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF9F1C),
              ),
            ),
          ],
          if (_topic.isOwner && !readOnly) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _createExamQuick,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  '+ Tạo bộ đề nhanh',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Bộ đề',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D1B2E),
            ),
          ),
          const SizedBox(height: 12),
          if (_loadingExams)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: kPrimary),
              ),
            )
          else if (_examsError != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_examsError!, style: const TextStyle(color: kError)),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loadExams,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          else if (_exams.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Chưa có bộ đề nào',
                  style: TextStyle(color: kTextSub),
                ),
              ),
            )
          else
            ..._exams.map(
              (exam) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    title: Text(
                      exam.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      exam.durationMinutes > 0
                          ? '${exam.questionCount} câu · ${exam.durationMinutes} phút'
                          : '${exam.questionCount} câu',
                      style: const TextStyle(color: Color(0xFF6E6A8A)),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Mh07DanhSachBoDeScreen(
                            token: widget.token,
                            topic: _topic,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          if (_topic.isOwner && !readOnly) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: busy ? null : _showForm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimary,
                        side: const BorderSide(color: kPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Sửa chủ đề',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: busy ? null : _confirmDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kError,
                        side: const BorderSide(color: kError),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Xóa chủ đề',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kPrimary,
        unselectedItemColor: const Color(0xFF6E6A8A),
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            activeIcon: Icon(Icons.layers),
            label: 'Chủ đề',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Thi đấu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Xếp hạng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
