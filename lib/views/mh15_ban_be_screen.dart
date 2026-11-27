import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/uy_theme.dart';
import '../models/friend.dart';
import '../services/friend_service.dart';

class Mh15BanBeScreen extends StatefulWidget {
  final String token;

  const Mh15BanBeScreen({super.key, required this.token});

  @override
  State<Mh15BanBeScreen> createState() => _Mh15BanBeScreenState();
}

class _Mh15BanBeScreenState extends State<Mh15BanBeScreen> {
  late final FriendService _service;
  late final String _myUid;
  final TextEditingController _emailController = TextEditingController();
  List<Friend> _friends = [];
  List<FriendRequest> _pending = [];
  bool _loading = true;
  String? _error;
  String? _busyId;
  bool _sending = false;
  String? _searchMessage;
  bool _searchOk = false;

  @override
  void initState() {
    super.initState();
    _service = FriendService(widget.token);
    _myUid = widget.token.contains(':')
        ? widget.token.split(':').last
        : widget.token;
    _load();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.getFriends();
      if (!mounted) return;
      setState(() {
        _friends = result.friends;
        _pending = result.pending;
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

  Future<void> _accept(FriendRequest request) async {
    setState(() => _busyId = request.id);
    try {
      await _service.acceptRequest(request.id);
      await _load();
      if (!mounted) return;
      _showSnack('Đã kết bạn với ${request.from.name}');
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _reject(FriendRequest request) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối lời mời'),
        content: Text(
          'Từ chối lời mời kết bạn của ${request.from.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busyId = request.id);
    try {
      await _service.rejectRequest(request.id);
      await _load();
      if (!mounted) return;
      _showSnack('Đã từ chối lời mời');
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _unfriend(Friend friend) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy kết bạn'),
        content: Text('Hủy kết bạn với ${friend.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hủy kết bạn',
              style: TextStyle(color: kError),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busyId = friend.uid);
    try {
      await _service.unfriend(friend.uid);
      await _load();
      if (!mounted) return;
      _showSnack('Đã hủy kết bạn');
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _showFriendDetail(Friend friend) {
    final next = pointsToNextRank(friend.rankScore);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: _avatarColor(friend),
              child: Text(
                friend.initial,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              friend.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(friend.email, style: const TextStyle(color: kTextSub)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hạng', style: TextStyle(color: kTextSub)),
                Text(
                  friend.animalRank,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Điểm rank', style: TextStyle(color: kTextSub)),
                Text(
                  '${friend.rankScore} điểm',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
            if (next > 0) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Còn thiếu', style: TextStyle(color: kTextSub)),
                  Text('$next điểm lên hạng sau'),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: null,
            child: const Text('Mời đấu (T27)'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _unfriend(friend);
            },
            child: const Text(
              'Hủy kết bạn',
              style: TextStyle(color: kError),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRequest() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() {
        _searchMessage = 'Nhập đúng email, ví dụ 0306241504@caothang.edu.vn';
        _searchOk = false;
      });
      return;
    }
    setState(() {
      _sending = true;
      _searchMessage = null;
    });
    try {
      await _service.sendRequest(email);
      _emailController.clear();
      await _load();
      if (!mounted) return;
      setState(() {
        _searchMessage = 'Đã gửi lời mời kết bạn';
        _searchOk = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchMessage = e.toString().replaceFirst('Exception: ', '');
        _searchOk = false;
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Color _avatarColor(Friend friend) {
    switch (friend.uid) {
      case 'uy':
        return const Color(0xFF6C4CF1);
      case 'thinh':
        return const Color(0xFF118AB2);
      case 'dinh':
        return const Color(0xFFEF476F);
      case 'danh':
        return const Color(0xFF00BFA6);
    }
    const palette = [
      Color(0xFF6C4CF1),
      Color(0xFF118AB2),
      Color(0xFFEF476F),
      Color(0xFF00BFA6),
      Color(0xFFFF9F1C),
    ];
    var hash = 0;
    for (final code in friend.uid.codeUnits) {
      hash = (hash * 31 + code) % palette.length;
    }
    return palette[hash];
  }

  Widget _avatar(Friend friend) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: _avatarColor(friend),
      child: Text(
        friend.initial,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1D1B2E),
        ),
      ),
    );
  }

  Widget _requestCard(FriendRequest request) {
    final busy = _busyId == request.id;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(request.from),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.from.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D1B2E),
                      ),
                    ),
                    if (request.from.rankScore > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${request.from.animalRank} · ${request.from.rankScore} điểm',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6E6A8A),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: busy ? null : () => _accept(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Chấp nhận',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: busy ? null : () => _reject(request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimary,
                      side: const BorderSide(color: kPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Từ chối',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _friendRow(Friend friend) {
    final busy = _busyId == friend.uid;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: () => _showFriendDetail(friend),
        onLongPress: busy ? null : () => _unfriend(friend),
        child: Row(
          children: [
            _avatar(friend),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1D1B2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: friend.isOnline
                              ? kSuccess
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        friend.isOnline ? 'Đang online' : 'Ngoại tuyến',
                        style: TextStyle(
                          fontSize: 13,
                          color: friend.isOnline
                              ? kSuccess
                              : const Color(0xFF6E6A8A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (friend.uid != _myUid)
              SizedBox(
                width: 96,
                height: 36,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    disabledBackgroundColor: kPrimary,
                    disabledForegroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đấu 1-1',
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

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(message, style: const TextStyle(color: kTextSub)),
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
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Bạn bè',
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
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_sending,
                          decoration: InputDecoration(
                            hintText: 'Tìm bạn theo tên/email',
                            hintStyle: const TextStyle(
                              color: Color(0xFF6E6A8A),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
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
                          onSubmitted: (_) => _sendRequest(),
                        ),
                        if (_searchMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _searchMessage!,
                            style: TextStyle(
                              color: _searchOk ? kSuccess : kError,
                            ),
                          ),
                        ],
                        _sectionTitle('Lời mời kết bạn'),
                        if (_pending.isEmpty)
                          _emptyState('Không có lời mời nào đang chờ')
                        else
                          ..._pending.map(_requestCard),
                        _sectionTitle('Bạn bè'),
                        if (_friends.isEmpty)
                          _emptyState('Chưa có bạn bè nào')
                        else
                          ..._friends.map(_friendRow),
                      ],
                    ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kPrimary,
        unselectedItemColor: const Color(0xFF6E6A8A),
        selectedLabelStyle: const TextStyle(fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        currentIndex: 4,
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
