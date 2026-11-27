import 'package:flutter/material.dart';

import '../core/dinh_api.dart';
import '../core/dinh_theme.dart';
import 'mh33_admin_thong_ke_mock.dart';

// ============================================================================
// Mã MH: MH-33 — Admin: Thống kê
// Tên màn hình: Thống kê hệ thống (frame Figma:
// MH-33-admin-thong-ke, node 83-230, khung 412 x 917,
// trang "Mockup màu").
// Thuộc luồng: L9 — Admin nền tảng (Flow boards, flow-L9-admin).
// Vào màn hình này từ đâu:
//   - Từ MH-30 / MH-32: bấm tab "Thống kê" ở thanh tab phụ dưới.
//     Điểm vào khu vực Admin là Hồ sơ (MH-03) -> mục "Quản trị nền
//     tảng" -> MH-30 (luồng đã chốt 24/11).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Thanh tab phụ dưới nằm ở màn host Admin (AdminHostScreen),
//     không nằm trong màn này: bấm tab "Tài khoản" sang MH-30, tab
//     "Gói và hạn mức" sang MH-32; thanh tab đứng yên, chỉ phần nội
//     dung trượt ngang.
//   - Nút quay lại "‹" ở header: về Hồ sơ (MH-03) — màn vào Admin.
//     Nút này không có trong thiết kế Figma, thêm theo luồng đã chốt.
// Dữ liệu thật đang dùng (nối API 25/11, UC28):
//   - 3 thẻ thống kê tổng: GET /admin/stats (token dev:admin) —
//     Tổng tài khoản = totalUsers, Tổng chủ đề = totalTopics,
//     Tổng lượt làm = totalAttempts. Dữ liệu là seed trong bộ nhớ
//     của API (5 tài khoản, 2 chủ đề, 0 lượt làm khi chưa tạo
//     lượt làm mẫu), restart server là reset — không phải 128 /
//     45 / 1.240 như mock cũ.
//   - Bảng theo bộ đề: GET /admin/stats/exams — số lượt làm,
//     điểm % TB / cao nhất / thấp nhất (T39 bước 2). Lượt bị tự
//     nộp (FORCE_SUBMITTED, chưa nộp bài) được API tính là 0%.
//   - Bảng theo chủ đề: GET /admin/stats/topics — số lượt làm,
//     điểm % TB, tỉ lệ câu đúng (T39 bước 3).
//   - Tài khoản gian lận: GET /admin/stats/violations — tổng vi
//     phạm, số lượt bị tự nộp, chi tiết từng lượt (T39 bước 3).
//     Nút "Xem" mở hộp thoại chi tiết từng lượt làm.
//   - Biểu đồ lượt làm theo ngày VẪN LÀ MOCK (mockChartBars
//     trong file mock): API chưa có endpoint trả lượt làm theo
//     ngày, nên không bịa số thật cho chỗ này. Khi quay video
//     bằng chứng T39 thì giải thích chỗ đó.
// Chức năng thật sẽ nối ở task nào:
//   - T39 (thống kê theo API): đã nối đủ 3 thẻ tổng + 2 bảng +
//     danh sách gian lận, xem hàm _loadStats. Kiến trúc: app gọi
//     API, API mới qua Firebase.
//
// SỐ ĐO: theo task MH-33, xem bảng đầy đủ trong mh33_figma_tokens.md.
// Font Nunito, nền #F6F4FF, header tím đậm #4A32B8 cao 104px,
// 3 thẻ thống kê 120x96 cách nhau 6px, thẻ biểu đồ 372x180,
// 5 cột tím rộng 36px, thẻ tài khoản gian lận 372x76.
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như các màn trước; riêng cột biểu đồ dùng bo 4px ở đỉnh.
// ============================================================================

/// Màn hình MH-33: thống kê hệ thống cho admin — 3 thẻ tổng,
/// biểu đồ cột lượt làm theo ngày, bảng theo bộ đề, bảng theo
/// chủ đề, danh sách tài khoản gian lận. Tất cả trừ biểu đồ đều
/// tải từ API admin; biểu đồ vẫn là mock vì API chưa có
/// endpoint cho lượt làm theo ngày.
class Mh33AdminThongKeScreen extends StatefulWidget {
  const Mh33AdminThongKeScreen({super.key});

  @override
  State<Mh33AdminThongKeScreen> createState() =>
      _Mh33AdminThongKeScreenState();
}

class _Mh33AdminThongKeScreenState
    extends State<Mh33AdminThongKeScreen> {
  ApiAdminStats? _stats;
  List<ApiExamStats> _examStats = [];
  List<ApiTopicStats> _topicStats = [];
  List<ApiViolationUser> _violationUsers = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// Tai so tong tu GET /admin/stats, roi tai song song 3 bang phu
  /// (theo bo de / theo chu de / gian lan). Bang phu nao loi thi
  /// de trong thay vi hong ca man hinh.
  Future<void> _loadStats() async {
    if (_stats == null) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final stats = await DinhApi.fetchAdminStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
        _error = null;
      });
      final lists = await Future.wait<dynamic>([
        _safeList(DinhApi.fetchExamStats),
        _safeList(DinhApi.fetchTopicStats),
        _safeList(DinhApi.fetchViolationStats),
      ]);
      if (!mounted) return;
      setState(() {
        _examStats = lists[0] as List<ApiExamStats>;
        _topicStats = lists[1] as List<ApiTopicStats>;
        _violationUsers = lists[2] as List<ApiViolationUser>;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (_stats == null) {
        setState(() => _error = e.message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  /// Hop thoai chi tiet cac luot lam vi pham cua 1 tai khoan
  /// (nut "Xem" o the gian lan).
  Future<void> _showViolationDetail(ApiViolationUser user) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng ${user.totalViolations} lần vi phạm · '
                '${user.forceSubmittedCount} lượt bị tự nộp'),
            const SizedBox(height: 12),
            for (final a in user.attempts) ...[
              Text(
                '${_examTitle(a.examId)}: ${a.violations} lần vi phạm '
                '(${_statusText(a.status)})',
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Ten bo de theo ma (de hien trong hop thoai vi pham);
  /// khong tim thay thi tra lai ma.
  String _examTitle(String? examId) {
    if (examId == null) return '—';
    for (final e in _examStats) {
      if (e.examId == examId) return e.title;
    }
    return examId;
  }

  /// Trang thai luot lam -> tieng Viet.
  String _statusText(String status) {
    switch (status) {
      case 'FORCE_SUBMITTED':
        return 'Bị tự nộp';
      case 'SUBMITTED':
        return 'Đã nộp';
      case 'IN_PROGRESS':
        return 'Đang làm';
      default:
        return status;
    }
  }

  /// 1240 -> '1.240' (dau phan cach hang nghin nhu mock cu).
  /// Khong dung goi intl.
  String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header tím đậm: cao 104px, phủ toàn chiều ngang ---
          // Nút quay lại "‹" trắng + tiêu đề "Thống kê hệ thống"
          // trắng 24px, "Quản trị" 13px #D9CFFF. Nút quay lại
          // không có trong thiết kế, thêm theo luồng đã chốt
          // (về Hồ sơ); kiểu nút giống MH-31 (nút Top 40, tiêu
          // đề Top 48, "Quản trị" Top 59).
          Container(
            width: double.infinity,
            height: kAdminHeaderHeight,
            color: kAdminHeaderBackground,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  // Quay về Hồ sơ (MH-03) — màn vào khu vực Admin.
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    '‹',
                    style: kBackStyle.copyWith(color: kOnPrimary),
                  ),
                ),
                const SizedBox(width: 22),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Thống kê hệ thống',
                    style: kAdminHeaderTitleStyle,
                  ),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(top: 19),
                  child: Text('Quản trị', style: kAdminHeaderBadgeStyle),
                ),
              ],
            ),
          ),

          // --- Nội dung: cuộn được nếu màn hình nhỏ ---
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error!,
                              style: kQuestionPreviewStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _loadStats,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadStats,
                        color: kPrimary,
                        child: SingleChildScrollView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: kSpacing20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header đáy -> thẻ thống kê: 16px theo task.
                              const SizedBox(height: 16),

                              // --- 3 thẻ thống kê: 120x96, cách nhau 6px ---
                              // So that tu GET /admin/stats.
                              Row(
                                children: [
                                  Expanded(
                                    child: _SystemStatCard(
                                      value: _formatNumber(
                                        stats!.totalUsers,
                                      ),
                                      label: 'Tổng tài khoản',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _SystemStatCard(
                                      value: _formatNumber(
                                        stats!.totalTopics,
                                      ),
                                      label: 'Tổng chủ đề',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _SystemStatCard(
                                      value: _formatNumber(
                                        stats!.totalAttempts,
                                      ),
                                      label: 'Tổng lượt làm',
                                    ),
                                  ),
                                ],
                              ),
                              // Thẻ thống kê -> tiêu đề biểu đồ: 16px theo task.
                              const SizedBox(height: 16),

                              // --- Biểu đồ lượt làm theo ngày ---
                              // VAN LA MOCK: API chua co endpoint tra
                              // luot lam theo ngay.
                              const Text(
                                'Lượt làm theo ngày',
                                style: kHeadingStyle,
                              ),
                              const SizedBox(height: 5),
                              const _ChartCard(),
                              // Thẻ biểu đồ -> tiêu đề bảng bộ đề: 16px.
                              const SizedBox(height: 16),

                              // --- Bảng thống kê theo bộ đề (T39 bước 2) ---
                              const Text(
                                'Thống kê theo bộ đề',
                                style: kHeadingStyle,
                              ),
                              const SizedBox(height: 5),
                              _ExamStatsTable(rows: _examStats),
                              // Bảng bộ đề -> tiêu đề bảng chủ đề: 16px.
                              const SizedBox(height: 16),

                              // --- Bảng thống kê theo chủ đề (T39 bước 3) ---
                              const Text(
                                'Thống kê theo chủ đề',
                                style: kHeadingStyle,
                              ),
                              const SizedBox(height: 5),
                              _TopicStatsTable(rows: _topicStats),
                              // Bảng chủ đề -> tiêu đề gian lận: 16px.
                              const SizedBox(height: 16),

                              // --- Tài khoản gian lận (dữ liệu thật) ---
                              const Text(
                                'Tài khoản gian lận',
                                style: kHeadingStyle,
                              ),
                              const SizedBox(height: 5),
                              if (_violationUsers.isEmpty)
                                const _EmptyCard(
                                  text: 'Không có tài khoản gian lận',
                                )
                              else
                                ..._violationUsers.map(
                                  (u) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8,
                                    ),
                                    child: _ViolationUserCard(
                                      user: u,
                                      onView: () =>
                                          _showViolationDetail(u),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

/// Một thẻ thống kê tổng theo task: 120x96, nền trắng,
/// viền 1px #E9E6F7, giá trị 24px 700 căn giữa cách đỉnh
/// thẻ 14px, nhãn 13px 400 cách đỉnh thẻ 51px.
/// Chỉ dùng ở MH-33 nên để trong file màn hình này.
class _SystemStatCard extends StatelessWidget {
  const _SystemStatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kStatCardHeight,
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 14),
          Text(
            value,
            style: kStatValueStyle.copyWith(color: kPrimary),
          ),
          // Giá trị -> nhãn: hộp giá trị trong Figma cao 33px
          // (font 24px), cách nhãn 4px theo mép hộp. Flutter
          // chữ cao đúng bằng font nên cộng thêm chênh lệch
          // hộp chữ 9px: 4 + 9 = 13px (bài học MH-30).
          const SizedBox(height: 13),
          Text(
            label,
            style: kQuestionPreviewStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Thẻ biểu đồ cột theo task: 372x180, nền trắng,
/// viền 1px #E9E6F7. 5 cột tím rộng 36px, cách nhau 32px,
/// giá trị trên cột cách đỉnh cột 3px, đường trục ngang
/// 1px #E9E6F7, nhãn ngày dưới trục 5px.
/// VẪN LÀ MOCK — API chưa có endpoint lượt làm theo ngày.
/// Chỉ dùng ở MH-33 nên để trong file màn hình này.
class _ChartCard extends StatelessWidget {
  const _ChartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kChartCardHeight,
      padding: const EdgeInsets.fromLTRB(16, 19, 16, 1),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng cột: giá trị + cột, đáy chung.
          // Chiều cao: cột cao nhất 116 + giá trị 18
          // + cách 3 = 137px.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < mockChartBars.length; i++) ...[
                if (i > 0) const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${mockChartBars[i].value}',
                        style: kChartValueStyle,
                      ),
                      // Giá trị -> cột: hộp giá trị trong Figma
                      // cao 18px (font 13px), cách cột 3px theo
                      // mép hộp. Flutter chữ cao đúng bằng font
                      // nên cộng thêm chênh lệch hộp chữ 5px:
                      // 3 + 5 = 8px (bài học MH-30).
                      const SizedBox(height: 8),
                      Container(
                        width: kChartBarWidth,
                        height: mockChartBars[i].height,
                        decoration: const BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          // Đường trục ngang 1px.
          Container(
            height: 1,
            color: kInputBorder,
          ),
          // Nhãn ngày dưới trục 4px (theo task 5px, trừ 1px
          // vì hộp chữ 13px trong Figma cao 18px).
          const SizedBox(height: 4),
          Row(
            children: [
              for (int i = 0; i < mockChartBars.length; i++) ...[
                if (i > 0) const SizedBox(width: 32),
                Expanded(
                  child: Text(
                    mockChartBars[i].day,
                    style: kQuestionPreviewStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Diem % (0-100) -> '75%' neu chan, '75.5%' neu le; null -> '—'.
String _formatPercent(double? v) {
  if (v == null) return '—';
  if (v == v.truncateToDouble()) return '${v.toInt()}%';
  return '${v.toStringAsFixed(1)}%';
}

/// Ti le 0-1 -> '50.0%'; null -> '—'.
String _formatRatio(double? r) {
  if (r == null) return '—';
  return '${(r * 100).toStringAsFixed(1)}%';
}

/// Tai 1 danh sach phu: loi thi tra ve danh sach trong thay vi
/// hong ca man hinh (cac bang phu khong chan 3 the tong).
Future<List<T>> _safeList<T>(Future<List<T>> Function() load) async {
  try {
    return await load();
  } catch (_) {
    return [];
  }
}

/// Mot hang trong bang thong ke: ten o trai (co dinh 3 phan),
/// cac so can phai (moi so 1 phan).
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.title,
    required this.values,
    this.isHeader = false,
  });

  final String title;
  final List<String> values;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final style = isHeader
        ? kQuestionPreviewStyle.copyWith(fontWeight: FontWeight.w700)
        : kQuestionPreviewStyle;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: style,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          for (final v in values)
            Expanded(
              child: Text(
                v,
                style: style,
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}

/// Bang thong ke theo bo de (GET /admin/stats/exams): cot
/// Bo de | Luot | TB | Cao | Thap.
class _ExamStatsTable extends StatelessWidget {
  const _ExamStatsTable({required this.rows});

  final List<ApiExamStats> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Column(
        children: [
          const _StatsRow(
            title: 'Bộ đề',
            values: ['Lượt', 'TB', 'Cao', 'Thấp'],
            isHeader: true,
          ),
          for (final r in rows) ...[
            const Divider(height: 1, color: kInputBorder),
            _StatsRow(
              title: r.title,
              values: [
                '${r.attempts}',
                _formatPercent(r.averagePercent),
                _formatPercent(r.highestPercent),
                _formatPercent(r.lowestPercent),
              ],
            ),
          ],
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Chưa có bộ đề nào',
                style: kQuestionPreviewStyle,
              ),
            ),
        ],
      ),
    );
  }
}

/// Bang thong ke theo chu de (GET /admin/stats/topics): cot
/// Chu de | Luot | TB | Dung (ti le cau dung).
class _TopicStatsTable extends StatelessWidget {
  const _TopicStatsTable({required this.rows});

  final List<ApiTopicStats> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Column(
        children: [
          const _StatsRow(
            title: 'Chủ đề',
            values: ['Lượt', 'TB', 'Đúng'],
            isHeader: true,
          ),
          for (final r in rows) ...[
            const Divider(height: 1, color: kInputBorder),
            _StatsRow(
              title: r.name,
              values: [
                '${r.attempts}',
                _formatPercent(r.averagePercent),
                _formatRatio(r.correctRatio),
              ],
            ),
          ],
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Chưa có chủ đề nào',
                style: kQuestionPreviewStyle,
              ),
            ),
        ],
      ),
    );
  }
}

/// The trang thai trong: nen trang, vien nhu the, chu o giua.
class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Text(
        text,
        style: kQuestionPreviewStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// The 1 tai khoan gian lan (du lieu that tu GET
/// /admin/stats/violations): avatar chu cai dau, ten, tong vi
/// pham + so luot bi tu nop, nut "Xem" mo hop thoai chi tiet.
class _ViolationUserCard extends StatelessWidget {
  const _ViolationUserCard({
    required this.user,
    required this.onView,
  });

  final ApiViolationUser user;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kCheatCardHeight,
      padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar tròn 44px, màu đỏ như thẻ Figma gốc.
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: kHard,
              shape: BoxShape.circle,
            ),
            child: Text(
              user.name.isNotEmpty ? user.name[0] : '?',
              style: kAccountAvatarLetterStyle,
            ),
          ),
          const SizedBox(width: 14),
          // Tên + dòng vi phạm. Canh từ đỉnh để tên nằm ở
          // Top +15 như task (canh giữa sẽ đẩy tên xuống
          // khoảng 3px).
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: kAccountNameStyle,
                ),
                // Tên -> dòng vi phạm: 9px theo số đo hộp
                // chữ trong Figma (bài học MH-30).
                const SizedBox(height: 9),
                Text(
                  '${user.totalViolations} lần vi phạm · '
                  '${user.forceSubmittedCount} lượt bị tự nộp',
                  style: kCheatViolationStyle,
                ),
              ],
            ),
          ),
          // Nút "Xem" 60x36: mở hộp thoại chi tiết từng lượt.
          SizedBox(
            width: 60,
            height: 36,
            child: OutlinedButton(
              onPressed: onView,
              style: OutlinedButton.styleFrom(
                backgroundColor: kSurface,
                side: const BorderSide(
                  color: kPrimary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text('Xem', style: kViewButtonTextStyle),
            ),
          ),
        ],
      ),
    );
  }
}
