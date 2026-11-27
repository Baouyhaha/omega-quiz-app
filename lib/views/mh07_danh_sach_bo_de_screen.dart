import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/topic.dart';
import '../services/topic_service.dart';
import 'mh03_ho_so_screen.dart';
import 'mh05_chu_de_screen.dart';
import 'mh08_chi_tiet_bo_de_screen.dart';

class Mh07DanhSachBoDeScreen extends StatefulWidget {
  final String token;
  final Topic topic;

  const Mh07DanhSachBoDeScreen({
    super.key,
    required this.token,
    required this.topic,
  });

  @override
  State<Mh07DanhSachBoDeScreen> createState() =>
      _Mh07DanhSachBoDeScreenState();
}

class _Mh07DanhSachBoDeScreenState
    extends State<Mh07DanhSachBoDeScreen> {
  late final TopicService _service;
  bool _loading = true;
  String? _error;
  List<TopicExam> _exams = [];
  Map<String, int> _done = {};

  @override
  void initState() {
    super.initState();
    _service = TopicService(widget.token);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final exams = await _service.getExams(widget.topic.id);
      final done = await _service.getDoneAttempts();
      if (!mounted) return;
      setState(() {
        _exams = exams;
        _done = done;
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

  String _attemptsText(TopicExam exam) {
    if (exam.maxAttempts <= 0) return '';
    final left = exam.maxAttempts - (_done[exam.id] ?? 0);
    return ' · còn ${left < 0 ? 0 : left} lượt';
  }

  Widget _statusChip(TopicExam exam) {
    final Color text;
    final Color background;
    switch (exam.status) {
      case 'upcoming':
        text = const Color(0xFFFF9F1C);
        background = const Color(0xFFFFF7E6);
        break;
      case 'closed':
        text = const Color(0xFF6E6A8A);
        background = const Color(0xFFF1F1F4);
        break;
      default:
        text = const Color(0xFF1E9E5A);
        background = const Color(0xFFE9F8F0);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        exam.statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _examCard(TopicExam exam) {
    return Container(
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
                ? '${exam.questionCount} câu · ${exam.durationMinutes} phút${_attemptsText(exam)}'
                : '${exam.questionCount} câu${_attemptsText(exam)}',
            style: const TextStyle(color: Color(0xFF6E6A8A)),
          ),
          trailing: _statusChip(exam),
          onTap: () {
            if (exam.status != 'open') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    exam.status == 'closed'
                        ? 'Bộ đề đã đóng'
                        : 'Bộ đề chưa mở',
                  ),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Mh08ChiTietBoDeScreen(
                  token: widget.token,
                  topic: widget.topic,
                  exam: exam,
                  doneCount: _done[exam.id] ?? 0,
                ),
              ),
            ).then((_) => _load());
          },
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
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          color: const Color(0xFF1D1B2E),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bộ đề — ${widget.topic.name}',
          style: const TextStyle(
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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_outlined,
                          size: 48,
                          color: Color(0xFF6E6A8A),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF6E6A8A)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : _exams.isEmpty
                  ? const Center(
                      child: Text(
                        'Chưa có bộ đề nào',
                        style: TextStyle(color: Color(0xFF6E6A8A)),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: _exams.map(_examCard).toList(),
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
        onTap: (i) {
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Mh05ChuDeScreen(token: widget.token),
              ),
            );
          } else if (i == 4) {
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
