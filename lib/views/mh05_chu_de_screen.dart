import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../models/topic.dart';
import '../services/topic_service.dart';
import 'mh03_ho_so_screen.dart';
import 'mh06_chi_tiet_chu_de_screen.dart';
import 'mh20_tao_sua_chu_de_screen.dart';

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
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => Mh20TaoSuaChuDeScreen(
          token: widget.token,
          topic: topic,
        ),
      ),
    );
    if (changed == true) {
      await _load();
      if (!mounted) return;
      _showSnack(topic != null ? 'Đã sửa chủ đề' : 'Đã tạo chủ đề');
    }
  }

  Widget _topicCard(Topic topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    SizedBox(
                      height: 48,
                      child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Tìm chủ đề công khai...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6E6A8A),
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
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
        selectedLabelStyle: const TextStyle(fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: 1,
        onTap: (i) {
          if (i == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Mh03HoSoScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.layers_outlined), label: 'Chủ đề'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Thi đấu'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Xếp hạng'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
