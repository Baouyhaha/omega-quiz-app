import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import '../models/topic.dart';
import '../services/topic_service.dart';

class Mh08ChiTietBoDeScreen extends StatefulWidget {
  final String token;
  final Topic topic;
  final TopicExam exam;
  final int doneCount;

  const Mh08ChiTietBoDeScreen({
    super.key,
    required this.token,
    required this.topic,
    required this.exam,
    required this.doneCount,
  });

  @override
  State<Mh08ChiTietBoDeScreen> createState() =>
      _Mh08ChiTietBoDeScreenState();
}

class _Mh08ChiTietBoDeScreenState extends State<Mh08ChiTietBoDeScreen> {
  late final TopicService _service;
  int _difficultyCount = 0;
  bool _starting = false;
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinNodes = List.generate(4, (_) => FocusNode());
  final List<String> _pinDigits = ['', '', '', ''];
  bool _backspaceHandled = false;

  @override
  void initState() {
    super.initState();
    _service = TopicService(widget.token);
    _loadDifficulties();
  }

  @override
  void dispose() {
    for (final c in _pinControllers) {
      c.dispose();
    }
    for (final n in _pinNodes) {
      n.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDifficulties() async {
    try {
      final count = await _service.getDifficultyCount(widget.topic.id);
      if (!mounted) return;
      setState(() => _difficultyCount = count);
    } catch (_) {}
  }

  int get _attemptsLeft {
    if (widget.exam.maxAttempts <= 0) return -1;
    final left = widget.exam.maxAttempts - widget.doneCount;
    return left < 0 ? 0 : left;
  }

  bool get _canStart {
    if (widget.exam.status != 'open') return false;
    if (_attemptsLeft == 0) return false;
    return true;
  }

  String get _answerModeText {
    switch (widget.exam.showAnswerMode) {
      case 'IMMEDIATELY':
        return 'Hiện ngay';
      case 'NEVER':
        return 'Không hiện';
      default:
        return 'Sau khi nộp';
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _start() async {
    String? pin;
    if (widget.exam.hasPin) {
      pin = _pinDigits.join();
      if (pin.length < 4) {
        _showSnack('Nhập đủ 4 số của mã PIN');
        return;
      }
    }
    setState(() => _starting = true);
    try {
      final attemptId = await _service.startAttempt(
        widget.exam.id,
        pin: pin,
      );
      if (!mounted) return;
      setState(() => _starting = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Đã tạo lượt làm'),
          content: Text('Mã lượt làm: $attemptId\nMàn làm bài (MH-09) sẽ làm tiếp.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _starting = false);
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Widget _settingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label $value',
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1D1B2E),
        ),
      ),
    );
  }

  Widget _pinBox(int index) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _pinControllers[index].text.isEmpty &&
            index > 0) {
          _backspaceHandled = true;
          _pinDigits[index - 1] = '';
          _pinControllers[index - 1].clear();
          _pinNodes[index - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        width: 64,
        height: 64,
        child: TextField(
        controller: _pinControllers[index],
        focusNode: _pinNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        obscureText: false,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: '•',
          hintStyle: const TextStyle(
            fontSize: 24,
            color: Color(0xFF6E6A8A),
          ),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
        ),
        onChanged: (value) {
          if (value == '•') return;
          if (value.isNotEmpty) {
            _pinDigits[index] = value.characters.last;
            _pinControllers[index].value = const TextEditingValue(
              text: '•',
              selection: TextSelection.collapsed(offset: 1),
            );
            if (index < 3) _pinNodes[index + 1].requestFocus();
          } else {
            _pinDigits[index] = '';
            if (_backspaceHandled) {
              _backspaceHandled = false;
            } else if (index > 0) {
              _pinNodes[index - 1].requestFocus();
            }
          }
        },
      ),
      ),
    );
  }

  Widget _otherCard(String label) {
    return Expanded(
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showSnack('$label: sắp có'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1B2E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Sắp có',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6E6A8A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;
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
          exam.title,
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
          Text(
            exam.durationMinutes > 0
                ? '${exam.questionCount} câu · ${exam.durationMinutes} phút${_difficultyCount > 0 ? ' · $_difficultyCount mức độ' : ''}'
                : '${exam.questionCount} câu${_difficultyCount > 0 ? ' · $_difficultyCount mức độ' : ''}',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6E6A8A),
            ),
          ),
          if (exam.maxAttempts > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Còn $_attemptsLeft/${exam.maxAttempts} lượt làm',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6E6A8A),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _settingRow(
                  'Xáo trộn câu hỏi:',
                  exam.shuffleQuestions ? 'Bật' : 'Tắt',
                ),
                _settingRow('Hiện đáp án:', _answerModeText),
                _settingRow(
                  'Trợ giúp:',
                  exam.allowHelpers ? 'Cho phép' : 'Không cho phép',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nhập mã PIN để vào thi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1B2E),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, _pinBox),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canStart && !_starting ? _start : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                disabledBackgroundColor: kPrimary.withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _starting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Bắt đầu làm bài',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          if (!_canStart) ...[
            const SizedBox(height: 12),
            Text(
              exam.status == 'closed'
                  ? 'Bộ đề đã đóng'
                  : exam.status == 'upcoming'
                      ? 'Bộ đề chưa mở'
                      : 'Đã hết lượt làm',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6E6A8A)),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Khác',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D1B2E),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _otherCard('Flashcard'),
              const SizedBox(width: 12),
              _otherCard('Bình luận'),
              const SizedBox(width: 12),
              _otherCard('Đánh giá sao'),
            ],
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
