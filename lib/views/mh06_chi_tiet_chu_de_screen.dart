import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../models/topic.dart';
import '../services/topic_service.dart';
import 'mh07_danh_sach_bo_de_screen.dart';

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
    final nameController = TextEditingController(text: _topic.name);
    final descController = TextEditingController(text: _topic.description);
    bool isPublic = _topic.isPublic;
    bool saving = false;
    String? formError;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Sửa chủ đề'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Tên chủ đề',
                  labelText: 'Tên chủ đề',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  hintText: 'Mô tả',
                  labelText: 'Mô tả',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Công khai'),
                subtitle: const Text('Tắt là chủ đề riêng tư'),
                value: isPublic,
                onChanged: (v) => setDialogState(() => isPublic = v),
              ),
              if (formError != null) ...[
                const SizedBox(height: 8),
                Text(formError!, style: const TextStyle(color: kError)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        setDialogState(
                          () => formError = 'Nhập tên chủ đề',
                        );
                        return;
                      }
                      setDialogState(() {
                        saving = true;
                        formError = null;
                      });
                      try {
                        final updated = await _service.updateTopic(
                          id: _topic.id,
                          name: name,
                          description: descController.text,
                          isPublic: isPublic,
                        );
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx, true);
                        setState(() => _topic = updated);
                      } catch (e) {
                        setDialogState(() {
                          saving = false;
                          formError =
                              e.toString().replaceFirst('Exception: ', '');
                        });
                      }
                    },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      nameController.dispose();
      descController.dispose();
    });
    if (ok == true && mounted) _showSnack('Đã sửa chủ đề');
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
        actions: [
          if (_topic.isOwner && !readOnly) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: const Color(0xFF1D1B2E),
              onPressed: busy ? null : _showForm,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: kError,
              onPressed: busy ? null : _confirmDelete,
            ),
          ],
        ],
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
