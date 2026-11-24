import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../models/topic.dart';
import '../services/topic_service.dart';
import 'mh06_chi_tiet_chu_de_screen.dart';

class Mh05ChuDeScreen extends StatefulWidget {
  final String token;

  const Mh05ChuDeScreen({super.key, required this.token});

  @override
  State<Mh05ChuDeScreen> createState() => _Mh05ChuDeScreenState();
}

class _Mh05ChuDeScreenState extends State<Mh05ChuDeScreen> {
  late final TopicService _service;
  final TextEditingController _searchController = TextEditingController();
  List<Topic> _topics = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = TopicService(widget.token);
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.getPublic(
        query: _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _topics = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openDetail(Topic topic) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => Mh06ChiTietChuDeScreen(
          token: widget.token,
          topic: topic,
        ),
      ),
    );
    if (changed == true && mounted) _load();
  }

  Future<void> _showForm({Topic? topic}) async {
    final nameController = TextEditingController(text: topic?.name ?? '');
    final descController =
        TextEditingController(text: topic?.description ?? '');
    bool isPublic = topic?.isPublic ?? true;
    bool saving = false;
    String? formError;
    final isEdit = topic != null;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa chủ đề' : 'Tạo chủ đề'),
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
                        if (isEdit) {
                          await _service.updateTopic(
                            id: topic.id,
                            name: name,
                            description: descController.text,
                            isPublic: isPublic,
                          );
                        } else {
                          await _service.createTopic(
                            name: name,
                            description: descController.text,
                            isPublic: isPublic,
                          );
                        }
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx, true);
                      } catch (e) {
                        setDialogState(() {
                          saving = false;
                          formError =
                              e.toString().replaceFirst('Exception: ', '');
                        });
                      }
                    },
              child: Text(isEdit ? 'Lưu' : 'Tạo'),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      nameController.dispose();
      descController.dispose();
    });
    if (ok == true) {
      await _load();
      if (!mounted) return;
      _showSnack(isEdit ? 'Đã sửa chủ đề' : 'Đã tạo chủ đề');
    }
  }

  Widget _topicCard(Topic topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: () => _openDetail(topic),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1D1B2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${topic.memberCount} thành viên · ${topic.examCount} bộ đề',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6E6A8A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 96,
              height: 36,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEDE9FE),
                  disabledBackgroundColor: const Color(0xFFEDE9FE),
                  disabledForegroundColor: kPrimary,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tham gia',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F4FF),
        elevation: 0,
        title: const Text(
          'Chủ đề công khai',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D1B2E),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: kError)),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _load,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm chủ đề công khai...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF6E6A8A),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD1D5DB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFD1D5DB),
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _load(),
                    ),
                    const SizedBox(height: 16),
                    if (_topics.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Không tìm thấy chủ đề',
                            style: TextStyle(color: kTextSub),
                          ),
                        ),
                      )
                    else
                      ..._topics.map(_topicCard),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showForm(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          '+ Tạo chủ đề',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
