import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/topic.dart';
import '../services/topic_service.dart';
import 'mh03_ho_so_screen.dart';

class Mh20TaoSuaChuDeScreen extends StatefulWidget {
  final String token;
  final Topic? topic;

  const Mh20TaoSuaChuDeScreen({super.key, required this.token, this.topic});

  @override
  State<Mh20TaoSuaChuDeScreen> createState() =>
      _Mh20TaoSuaChuDeScreenState();
}

class _Mh20TaoSuaChuDeScreenState extends State<Mh20TaoSuaChuDeScreen> {
  late final TopicService _service;
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late bool _isPublic;
  bool _saving = false;
  String? _error;
  File? _coverImage;

  bool get _isEdit => widget.topic != null;

  @override
  void initState() {
    super.initState();
    _service = TopicService(widget.token);
    _nameController = TextEditingController(text: widget.topic?.name ?? '');
    _descController =
        TextEditingController(text: widget.topic?.description ?? '');
    _isPublic = widget.topic?.isPublic ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path != null && mounted) {
      setState(() => _coverImage = File(path));
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Nhập tên chủ đề');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (_isEdit) {
        await _service.updateTopic(
          id: widget.topic!.id,
          name: name,
          description: _descController.text,
          isPublic: _isPublic,
        );
      } else {
        await _service.createTopic(
          name: name,
          description: _descController.text,
          isPublic: _isPublic,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF6E6A8A)),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
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
        leadingWidth: 40,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          color: const Color(0xFF1D1B2E),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _isEdit ? 'Sửa chủ đề' : 'Tạo chủ đề',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D1B2E),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                _label('Tên chủ đề'),
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _nameController,
                    decoration: _fieldDecoration('Nhập tên chủ đề'),
                  ),
                ),
                const SizedBox(height: 14),
                _label('Mô tả'),
                TextField(
                  controller: _descController,
                  decoration: _fieldDecoration('Nhập mô tả'),
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                _label('Ảnh bìa'),
                InkWell(
                  onTap: _pickCover,
                  child: _coverImage == null
                      ? CustomPaint(
                          painter: _DashedBorderPainter(
                            color: const Color(0xFFD1D5DB),
                            radius: 12,
                          ),
                          child: Container(
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 24,
                                  color: Color(0xFF6E6A8A),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Chọn ảnh bìa',
                                  style: TextStyle(color: Color(0xFF6E6A8A)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _coverImage!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chế độ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D1B2E),
                  ),
                ),
                const SizedBox(height: 4),
                RadioGroup<bool>(
                  groupValue: _isPublic,
                  onChanged: (v) => setState(() => _isPublic = v ?? true),
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        title: const Text('Công khai — ai cũng xem được'),
                        value: true,
                        fillColor: WidgetStatePropertyAll(kPrimary),
                      ),
                      RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        title: const Text('Riêng tư — chỉ thành viên'),
                        value: false,
                        fillColor: WidgetStatePropertyAll(kPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3C4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error, color: Color(0xFFF59E0B)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Gói miễn phí: tối đa 1 chủ đề',
                          style: TextStyle(color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: kError)),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _saving ? 'Đang lưu...' : 'Lưu chủ đề',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
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

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 4.0;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics().first;
    var distance = 0.0;
    while (distance < metrics.length) {
      final segment = metrics.extractPath(
        distance,
        (distance + dash).clamp(0.0, metrics.length),
      );
      canvas.drawPath(segment, paint);
      distance += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
