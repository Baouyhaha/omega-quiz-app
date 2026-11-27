import 'package:flutter/material.dart';

import '../core/dinh_api.dart';
import '../core/dinh_theme.dart';

// ============================================================================
// Mã MH: MH-31 — Admin: Chi tiết tài khoản
// Tên màn hình: Chi tiết tài khoản (frame Figma:
// MH-31-admin-chi-tiet-tai-khoan, node 83-162, khung 412 x 917,
// trang "Mockup màu").
// Thuộc luồng: L9 — Admin nền tảng (Flow boards, flow-L9-admin).
// Vào màn hình này từ đâu:
//   - Từ MH-30 Admin: Tài khoản, bấm vào bất kỳ thẻ tài khoản nào;
//     mã tài khoản được truyền sang (luồng đã chốt 24/11).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Nút quay lại "<" -> quay về màn hình trước (MH-30).
//     Nút này không có trong thiết kế, thêm theo yêu cầu
//     của user cho giống các màn trước.
//   - Không có thanh điều hướng dưới trong thiết kế.
//   - Nút "Khóa tài khoản"/"Mở khóa tài khoản": gọi API lock/unlock,
//     có hộp xác nhận (T15 bước 3). Tài khoản ADMIN không có nút này.
//   - Nút "Gán gói": chọn gói trong hộp thoại rồi gọi API gán gói
//     (POST /admin/users/:id/subscription) — KHÔNG sang MH-32
//     (luồng đã chốt: gán gói là gọi API trong MH-31, MH-32 chỉ là
//     cấu hình gói). Nút "Gia hạn gói": gán lại gói đang dùng.
// Dữ liệu thật đang dùng (T15, nối API 25/11):
//   - GET /admin/users/:id (token dev:admin) + GET /admin/plans
//     để đổi mã gói thành tên gói và tính hạn.
//   - Lịch sử gói: chỉ có 2 mốc thật từ API (ngày tạo tài khoản,
//     ngày bắt đầu gói) — API chưa có endpoint lịch sử gói.
//   - File mock mh31_admin_chi_tiet_tai_khoan_mock.dart chỉ còn là
//     dữ liệu Figma gốc, màn này không dùng nữa.
// Chức năng thật sẽ nối ở task nào:
//   - T15 bước 2 (chi tiết) và bước 3 (khóa/mở khóa, gán/gia hạn
//     gói): đã nối API, xem các hàm _load / _toggleLock /
//     _assignPlan / _renewPlan.
//     Kiến trúc: app gọi API, API mới qua Firebase.
//
// SỐ ĐO: theo task MH-31, xem bảng đầy đủ trong mh31_figma_tokens.md.
// Font Nunito, nền #F6F4FF, header tím đậm #4A32B8 cao 104px,
// thẻ tài khoản 372x152, avatar tròn 56x56, thẻ gói 372x84,
// nút khóa 372x52 đỏ, 2 nút gói 180x52 viền tím,
// thẻ lịch sử 372x88.
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như các màn trước.
// ============================================================================

/// Màn hình MH-31: chi tiết một tài khoản cho admin — thông tin
/// tài khoản, gói đang dùng, khóa tài khoản, gán/gia hạn gói
/// và lịch sử gói.
/// [accountId]: mã tài khoản cần xem (MH-30 truyền sang). Mở trực
/// tiếp không có mã thì mặc định xem tài khoản Danh (như bản mock cũ).
class Mh31AdminChiTietTaiKhoanScreen extends StatefulWidget {
  const Mh31AdminChiTietTaiKhoanScreen({super.key, this.accountId});

  final String? accountId;

  @override
  State<Mh31AdminChiTietTaiKhoanScreen> createState() =>
      _Mh31AdminChiTietTaiKhoanScreenState();
}

class _Mh31AdminChiTietTaiKhoanScreenState
    extends State<Mh31AdminChiTietTaiKhoanScreen> {
  String get _accountId => widget.accountId ?? 'danh';

  ApiAdminUserDetail? _detail;
  List<ApiAdminPlan> _plans = [];

  bool _loading = true;
  String? _error;

  /// true = dang goi khoa/mo khoa/gan goi (de vo hieu hoa cac nut).
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Tai chi tiet tai khoan + danh sach goi tu API.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        DinhApi.fetchAdminUserDetail(_accountId),
        DinhApi.fetchAdminPlans(),
      ]);
      if (!mounted) return;
      setState(() {
        _detail = results[0] as ApiAdminUserDetail;
        _plans = results[1] as List<ApiAdminPlan>;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  /// Tai lai chi tiet (sau khi gan/gia han goi) ma khong hien
  /// vong quay toan man hinh.
  Future<void> _refreshDetail() async {
    try {
      final detail = await DinhApi.fetchAdminUserDetail(_accountId);
      if (!mounted) return;
      setState(() => _detail = detail);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  /// Ten goi dang dung, doi tu ma goi (subscription.planId).
  String get _planName {
    final planId = _detail?.subscription?.planId;
    if (planId == null || planId.isEmpty) return 'Chưa có gói';
    for (final p in _plans) {
      if (p.id == planId) return p.name;
    }
    return planId;
  }

  /// 'Hết hạn dd/MM/yyyy — còn N ngày' / 'Đã hết hạn ...' /
  /// 'Không hết hạn' / 'Chưa có gói'.
  String get _planExpiryText {
    final sub = _detail?.subscription;
    if (sub == null) return 'Chưa có gói';
    final exp = sub.expiresAt;
    if (exp == null) return 'Không hết hạn';
    final d = DateTime.tryParse(exp);
    if (d == null) return 'Hết hạn $exp';
    final daysLeft = d.difference(DateTime.now()).inDays;
    final date = _formatDate(exp);
    if (daysLeft < 0) return 'Đã hết hạn $date';
    return 'Hết hạn $date — còn $daysLeft ngày';
  }

  /// Lich su goi: chi co 2 moc that tu API (ngay bat dau goi,
  /// ngay tao tai khoan) — API chua co endpoint lich su goi.
  List<_HistoryEntry> get _historyEntries {
    final d = _detail;
    if (d == null) return [];
    final rows = <_HistoryEntry>[];
    final sub = d.subscription;
    if (sub != null && sub.startedAt.isNotEmpty) {
      rows.add(_HistoryEntry(
        date: _formatShortDate(sub.startedAt),
        action: 'Bắt đầu gói $_planName',
      ));
    }
    if (d.createdAt.isNotEmpty) {
      rows.add(_HistoryEntry(
        date: _formatShortDate(d.createdAt),
        action: 'Tạo tài khoản mới',
      ));
    }
    return rows;
  }

  /// '2026-11-21T...' -> '21/11/2026'. Khong dung goi intl.
  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day}/${d.month}/${d.year}';
  }

  /// '2026-11-21T...' -> '21/11'.
  String _formatShortDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day}/${d.month}';
  }

  /// Khoa/mo khoa tai khoan: hoi xac nhan truoc, goi API xong cap
  /// nhat trang thai ngay tren man hinh (T15 buoc 3).
  Future<void> _toggleLock() async {
    final detail = _detail;
    if (detail == null || _acting) return;
    final lock = !detail.locked;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lock ? 'Khóa tài khoản?' : 'Mở khóa tài khoản?'),
        content: Text(
          lock
              ? 'Khóa tài khoản ${detail.name}? Tài khoản bị khóa sẽ không đăng nhập được.'
              : 'Mở khóa tài khoản ${detail.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(lock ? 'Khóa' : 'Mở khóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _acting = true);
    try {
      if (lock) {
        await DinhApi.lockAdminUser(detail.uid);
      } else {
        await DinhApi.unlockAdminUser(detail.uid);
      }
      if (!mounted) return;
      setState(() {
        _detail = _detail!.copyWith(locked: lock);
        _acting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lock
                ? 'Đã khóa tài khoản ${detail.name}'
                : 'Đã mở khóa tài khoản ${detail.name}',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _acting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  /// Gan goi: chon goi trong hop thoai roi goi API, xong tai lai
  /// chi tiet de thay goi + han moi.
  Future<void> _assignPlan() async {
    if (_detail == null || _plans.isEmpty || _acting) return;
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Gán gói'),
        children: [
          for (final p in _plans)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, p.id),
              child: Text(
                p.days == null ? p.name : '${p.name} — ${p.days} ngày',
              ),
            ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    await _doAssignPlan(picked, 'Đã gán gói cho tài khoản');
  }

  /// Gia han goi: gan lai chinh goi dang dung (han moi tinh tu hom nay).
  Future<void> _renewPlan() async {
    final planId = _detail?.subscription?.planId;
    if (planId == null || planId.isEmpty || _acting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gia hạn gói?'),
        content: Text('Gia hạn gói $_planName cho tài khoản này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Gia hạn'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _doAssignPlan(planId, 'Đã gia hạn gói cho tài khoản');
  }

  Future<void> _doAssignPlan(String planId, String doneMessage) async {
    final detail = _detail;
    if (detail == null) return;
    setState(() => _acting = true);
    try {
      await DinhApi.assignAdminPlan(detail.uid, planId);
      if (!mounted) return;
      setState(() => _acting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(doneMessage)),
      );
      await _refreshDetail();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _acting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header tím đậm: cao 104px, phủ toàn chiều ngang ---
          // Nút quay lại "‹" trắng 34px + tiêu đề "Chi tiết tài
          // khoản" trắng 24px + "Quản trị" 13px #D9CFFF.
          // Nút quay lại không có trong thiết kế, thêm theo yêu
          // cầu của user cho giống các màn trước (nút Top 40,
          // tiêu đề Top 48, "Quản trị" Top 59 như MH-30).
          Container(
            width: double.infinity,
            height: kAdminHeaderHeight,
            color: kAdminHeaderBackground,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  // Quay về màn hình trước đó (MH-30).
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
                    'Chi tiết tài khoản',
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
                              onPressed: _load,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _buildContent(_detail!),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ApiAdminUserDetail detail) {
    final history = _historyEntries;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpacing20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header đáy -> thẻ tài khoản: 16px theo task.
          const SizedBox(height: 16),

          // --- Thẻ tài khoản 372x152 ---
          Container(
            width: double.infinity,
            height: kAccountDetailCardHeight,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kInputBorder, width: 1),
              borderRadius: BorderRadius.circular(kRadiusItem),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar tròn 56x56 với chữ cái đầu tên.
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        detail.initial,
                        style: kDetailAvatarLetterStyle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tên và email. Tên cách mép trên thẻ
                    // 18px (padding 16 + 2).
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.name,
                              style: kDetailNameStyle,
                            ),
                            // Theo task: tên Top 18px,
                            // email Top 47px (hộp chữ Figma
                            // cao 27px, hộp Flutter cao 20px
                            // nên gap là 9px).
                            const SizedBox(height: 9),
                            Text(
                              detail.email,
                              style: kDetailEmailStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Avatar đáy -> đường phân cách: 8px.
                const SizedBox(height: 8),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: kInputBorder,
                ),
                // Đường phân cách -> vai trò: 10px.
                const SizedBox(height: 10),
                Text(
                  'Vai trò: ${detail.role.toLowerCase()}',
                  style: kDetailInfoStyle,
                ),
                // Vai trò -> trạng thái: 11px theo task
                // (hộp chữ Figma cao 20px, hộp Flutter
                // cao 15px nên gap là 11px).
                const SizedBox(height: 11),
                Row(
                  children: [
                    const Text(
                      'Trạng thái:',
                      style: kDetailInfoStyle,
                    ),
                    const SizedBox(width: 18),
                    Text(
                      detail.statusText,
                      style: kDetailStatusStyle.copyWith(
                        color: detail.locked ? kHard : kEasy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Thẻ tài khoản -> thẻ gói: 12px theo task.
          const SizedBox(height: 12),

          // --- Thẻ gói 372x84 ---
          Container(
            width: double.infinity,
            height: kAccountCardHeight,
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 3),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kInputBorder, width: 1),
              borderRadius: BorderRadius.circular(kRadiusItem),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gói đang dùng', style: kLabelStyle),
                // Theo task: nhãn Top 13px, tên gói
                // Top 36px (hộp chữ Figma cao 18px,
                // hộp Flutter cao 13px nên gap là 10px).
                const SizedBox(height: 10),
                Text(
                  _planName,
                  style: kPlanNameStyle,
                ),
                // Theo task: tên gói Top 36px, hạn gói
                // Top 63px (hộp chữ Figma cao 25px,
                // hộp Flutter cao 18px nên gap là 9px).
                const SizedBox(height: 9),
                Text(
                  _planExpiryText,
                  style: kQuestionPreviewStyle,
                ),
              ],
            ),
          ),
          // Thẻ gói -> nút khóa: 16px theo task.
          const SizedBox(height: 16),

          // --- Nút "Khóa tài khoản" / "Mở khóa tài khoản" 372x52 ---
          // Tài khoản ADMIN không có nút này.
          if (!detail.isAdmin) ...[
            SizedBox(
              width: double.infinity,
              height: kButtonHeight,
              child: ElevatedButton(
                onPressed: _acting ? null : _toggleLock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: detail.locked ? kEasy : kHard,
                  foregroundColor: kOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      kRadiusButton,
                    ),
                  ),
                ),
                child: Text(
                  detail.locked
                      ? 'Mở khóa tài khoản'
                      : 'Khóa tài khoản',
                  style: kButtonTextStyle,
                ),
              ),
            ),
            // Nút khóa -> hàng 2 nút: 12px theo task.
            const SizedBox(height: 12),
          ],

          // --- Hàng 2 nút: "Gán gói" và "Gia hạn gói" ---
          // Dùng Expanded như MH-22 để không tràn trên
          // máy ảo hẹp hơn 412px.
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: kButtonHeight,
                  child: OutlinedButton(
                    onPressed: _acting ? null : _assignPlan,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: kSurface,
                      side: const BorderSide(
                        color: kPrimary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          kRadiusButton,
                        ),
                      ),
                    ),
                    child: Text(
                      'Gán gói',
                      style: kButtonTextStyle.copyWith(
                        color: kPrimary,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: kButtonHeight,
                  child: OutlinedButton(
                    onPressed: _acting ? null : _renewPlan,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: kSurface,
                      side: const BorderSide(
                        color: kPrimary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          kRadiusButton,
                        ),
                      ),
                    ),
                    child: Text(
                      'Gia hạn gói',
                      style: kButtonTextStyle.copyWith(
                        color: kPrimary,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Hàng nút -> tiêu đề "Lịch sử gói": 12px.
          const SizedBox(height: 12),
          const Text('Lịch sử gói', style: kHeadingStyle),
          // Tiêu đề -> thẻ lịch sử: 5px theo task.
          const SizedBox(height: 5),

          // --- Thẻ lịch sử gói 372x88 ---
          Container(
            width: double.infinity,
            height: kHistoryCardHeight,
            padding: const EdgeInsets.fromLTRB(16, 19, 16, 11),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kInputBorder, width: 1),
              borderRadius: BorderRadius.circular(kRadiusItem),
            ),
            child: history.isEmpty
                ? const Text(
                    'Chưa có lịch sử gói',
                    style: kDetailInfoStyle,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < history.length; i++) ...[
                        if (i > 0) const SizedBox(height: 23),
                        _HistoryRow(entry: history[i]),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Mot dong lich su goi that tu API (ngay bat dau goi / ngay tao
/// tai khoan). Chi dung o MH-31 nen de trong file man hinh nay.
class _HistoryEntry {
  const _HistoryEntry({required this.date, required this.action});

  final String date;
  final String action;
}

/// Một dòng lịch sử gói: ngày in đậm, hành động ở bên phải.
/// Chỉ dùng ở MH-31 nên để trong file màn hình này.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final _HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(entry.date, style: kHistoryDateStyle),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            entry.action,
            style: kDetailInfoStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
