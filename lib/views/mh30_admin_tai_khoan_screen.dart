import 'package:flutter/material.dart';

import '../core/dinh_api.dart';
import '../core/dinh_theme.dart';

// ============================================================================
// Mã MH: MH-30 — Admin: Tài khoản
// Tên màn hình: Tài khoản (frame Figma: MH-30-admin-tai-khoan,
// node 83-125, khung 412 x 917, trang "Mockup màu").
// Thuộc luồng: L9 — Admin nền tảng (Flow boards, flow-L9-admin).
// Vào màn hình này từ đâu:
//   - Từ Hồ sơ (MH-03): bấm mục "Quản trị nền tảng" (chỉ hiện với
//     tài khoản Admin) là vào thẳng màn này. MH-30 chính là
//     "màn Quản trị", không có màn trung gian (luồng đã chốt 24/11).
//   - Từ MH-32 / MH-33: bấm tab "Tài khoản" ở thanh tab phụ dưới.
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Bấm vào thẻ tài khoản (tất cả các thẻ) -> MH-31 Admin:
//     Chi tiết tài khoản, truyền mã tài khoản sang (luồng đã chốt).
//   - Thanh tab phụ dưới nằm ở màn host Admin (AdminHostScreen),
//     không nằm trong màn này: bấm tab "Gói và hạn mức" sang MH-32,
//     tab "Thống kê" sang MH-33; thanh tab đứng yên, chỉ phần nội
//     dung trượt ngang.
//   - Nút quay lại "‹" ở header: về Hồ sơ (MH-03) — màn vào Admin.
//     Nút này không có trong thiết kế Figma, thêm theo luồng đã chốt.
// Dữ liệu thật đang dùng (T15, nối API 25/11):
//   - GET /admin/users (token dev:admin — dev:dinh bị 403 vì chỉ
//     role ADMIN mới gọi được): danh sách 5 tài khoản seed.
//   - Gói của từng thẻ: GET /admin/users/:id (subscription.planId)
//     + GET /admin/plans để đổi mã gói thành tên gói.
//   - Nút Khóa/Mở khóa: POST /admin/users/:id/lock|unlock, có hộp
//     xác nhận trước khi gọi (T15 bước 3). Tài khoản ADMIN không
//     có nút khóa.
//   - Tìm kiếm + chip lọc làm ở phía client trên danh sách đã tải
//     (theo mẫu MH-22).
//   - Dữ liệu admin là seed trong bộ nhớ của API, restart server là
//     reset; tổng thật là 5 tài khoản, không phải 128 như mock cũ.
//   - File mock mh30_admin_tai_khoan_mock.dart chỉ còn là dữ liệu
//     Figma gốc, màn này không dùng nữa.
// Chức năng thật sẽ nối ở task nào:
//   - T15 bước 1-2 (danh sách + chi tiết) và bước 3 (khóa/mở khóa):
//     đã nối API, xem các hàm _loadUsers / _toggleLock.
//     Kiến trúc: app gọi API, API mới qua Firebase.
//
// SỐ ĐO: theo task MH-30, xem bảng đầy đủ trong mh30_figma_tokens.md.
// Font Nunito, nền #F6F4FF, header tím đậm #4A32B8 cao 104px,
// tiêu đề trắng 24px, ô tìm kiếm 372x48, chip lọc cao 28px,
// thẻ tài khoản 372x84, avatar tròn 44x44.
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như các màn trước; riêng chip lọc dùng bo 14px, nút hành động
// dùng bo 15px.
// ============================================================================

/// Màn hình MH-30: danh sách tài khoản cho admin — tìm kiếm,
/// lọc theo trạng thái, khóa/mở khóa tài khoản.
/// Dữ liệu tải từ API admin, không dùng mock nữa.
class Mh30AdminTaiKhoanScreen extends StatefulWidget {
  const Mh30AdminTaiKhoanScreen({super.key});

  @override
  State<Mh30AdminTaiKhoanScreen> createState() =>
      _Mh30AdminTaiKhoanScreenState();
}

class _Mh30AdminTaiKhoanScreenState
    extends State<Mh30AdminTaiKhoanScreen> {
  // Chip lọc đang chọn: 0 = Tất cả, 1 = Đang hoạt động, 2 = Bị khóa.
  // Theo task, lúc mở màn chip "Tất cả" đang chọn.
  int _selectedFilter = 0;

  // Các chip lọc theo task, đúng thứ tự và chiều rộng trong Figma.
  static const List<String> _filterLabels = [
    'Tất cả',
    'Đang hoạt động',
    'Bị khóa',
  ];
  static const List<double> _filterWidths = [72, 136, 80];

  // Mau avatar xoay vong theo ma tai khoan — chi dung mau co san
  // trong theme, khong hard-code.
  static const List<Color> _avatarColors = [
    kPrimary,
    kOptionB,
    kOptionD,
    kOptionA,
    kMedium,
  ];

  Color _avatarColorFor(String uid) =>
      _avatarColors[uid.hashCode.abs() % _avatarColors.length];

  // Danh sach tai khoan that tu API + ten goi cua tung tai khoan.
  List<ApiAdminUser> _users = [];
  Map<String, String> _planNames = {};

  // Trang thai tai: true = dang tai lan dau (chua co du lieu).
  bool _loading = true;

  // Loi tai (chi hien khi chua co du lieu); tai lai ma da co du lieu
  // thi giu danh sach cu va bao bang SnackBar (theo mau MH-22).
  String? _error;

  // Tu khoa tim kiem (loc theo ten hoac email, phia client).
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  // Ma tai khoan dang goi khoa/mo khoa (de vo hieu hoa nut do).
  String? _actingUid;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Tai danh sach tai khoan tu GET /admin/users, kem ten goi cua
  /// tung tai khoan (GET /admin/users/:id + GET /admin/plans).
  Future<void> _loadUsers() async {
    if (_users.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final users = await DinhApi.fetchAdminUsers();
      final plans = await DinhApi.fetchAdminPlans();
      final planById = {for (final p in plans) p.id: p.name};
      final names = <String, String>{};
      await Future.wait(users.map((u) async {
        try {
          final detail = await DinhApi.fetchAdminUserDetail(u.uid);
          final planId = detail.subscription?.planId;
          if (planId != null) names[u.uid] = planById[planId] ?? planId;
        } catch (_) {
          // Khong lay duoc goi cua nguoi nay thi the van hien,
          // cho goi la '—'.
        }
      }));
      if (!mounted) return;
      setState(() {
        _users = users;
        _planNames = names;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (_users.isEmpty) {
        setState(() => _error = e.message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  /// Danh sach dang hien sau khi loc theo tu khoa + chip trang thai.
  List<ApiAdminUser> get _visibleUsers {
    final q = _query.trim().toLowerCase();
    return _users.where((u) {
      final matchQuery = q.isEmpty ||
          u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
      if (!matchQuery) return false;
      if (_selectedFilter == 1) return !u.locked;
      if (_selectedFilter == 2) return u.locked;
      return true;
    }).toList();
  }

  /// Khoa/mo khoa 1 tai khoan: hoi xac nhan truoc, goi API xong cap
  /// nhat trang thai ngay tren danh sach (T15 buoc 3).
  Future<void> _toggleLock(ApiAdminUser user) async {
    if (_actingUid != null) return;
    final lock = !user.locked;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lock ? 'Khóa tài khoản?' : 'Mở khóa tài khoản?'),
        content: Text(
          lock
              ? 'Khóa tài khoản ${user.name}? Tài khoản bị khóa sẽ không đăng nhập được.'
              : 'Mở khóa tài khoản ${user.name}?',
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
    setState(() => _actingUid = user.uid);
    try {
      if (lock) {
        await DinhApi.lockAdminUser(user.uid);
      } else {
        await DinhApi.unlockAdminUser(user.uid);
      }
      if (!mounted) return;
      setState(() {
        final i = _users.indexWhere((u) => u.uid == user.uid);
        if (i >= 0) _users[i] = _users[i].copyWith(locked: lock);
        _actingUid = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lock
                ? 'Đã khóa tài khoản ${user.name}'
                : 'Đã mở khóa tài khoản ${user.name}',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _actingUid = null);
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
          // Nút quay lại "‹" trắng + tiêu đề "Tài khoản" trắng 24px,
          // "Quản trị" 13px #D9CFFF. Nút quay lại không có trong thiết
          // kế, thêm theo luồng đã chốt (về Hồ sơ); kiểu nút giống
          // MH-31 (nút Top 40, tiêu đề Top 48, "Quản trị" Top 59).
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
                  child: Text('Tài khoản', style: kAdminHeaderTitleStyle),
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
                              onPressed: _loadUsers,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
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
                              // Header đáy -> ô tìm kiếm: 16px theo task.
                              const SizedBox(height: 16),

                              // Ô tìm kiếm 372x48, không có icon kính lúp theo task.
                              SizedBox(
                                width: double.infinity,
                                height: kSearchHeight,
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() => _query = value);
                                  },
                                  style: kFieldTextStyle,
                                  decoration: InputDecoration(
                                    hintText: 'Tìm theo tên/email...',
                                    hintStyle: kFieldTextStyle.copyWith(
                                      color: kTextSecondary,
                                    ),
                                    filled: true,
                                    fillColor: kSurface,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        kRadiusItem,
                                      ),
                                      borderSide: const BorderSide(
                                        color: kInputBorder,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        kRadiusItem,
                                      ),
                                      borderSide: const BorderSide(
                                        color: kInputBorder,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        kRadiusItem,
                                      ),
                                      borderSide: const BorderSide(
                                        color: kPrimary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Ô tìm kiếm -> hàng chip lọc: 16px theo task.
                              const SizedBox(height: 16),

                              // 3 chip lọc. Khoảng cách theo task: chip 1 -> 2
                              // là 16px, chip 2 -> 3 là 8px.
                              Row(
                                children: [
                                  for (int i = 0;
                                      i < _filterLabels.length;
                                      i++) ...[
                                    if (i == 1) const SizedBox(width: 16),
                                    if (i == 2) const SizedBox(width: 8),
                                    _FilterChip(
                                      label: _filterLabels[i],
                                      width: _filterWidths[i],
                                      selected: _selectedFilter == i,
                                      onTap: () {
                                        setState(() {
                                          _selectedFilter = i;
                                        });
                                      },
                                    ),
                                  ],
                                ],
                              ),
                              // Chip lọc -> thẻ tài khoản đầu tiên: 16px.
                              const SizedBox(height: 16),

                              // Cac the tai khoan that tu API, the cach nhau
                              // 12px theo task. Tat ca cac the deu bam duoc:
                              // bam vao sang MH-31, truyen ma tai khoan sang.
                              ..._visibleUsers.map(
                                (account) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 12),
                                  child: _AccountCard(
                                    account: account,
                                    planName:
                                        _planNames[account.uid] ?? '—',
                                    avatarColor:
                                        _avatarColorFor(account.uid),
                                    acting: _actingUid == account.uid,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/mh31',
                                        arguments: account.uid,
                                      );
                                    },
                                    onLockToggle: () =>
                                        _toggleLock(account),
                                  ),
                                ),
                              ),
                              if (_visibleUsers.isEmpty)
                                const Center(
                                  child: Text(
                                    'Không tìm thấy tài khoản nào',
                                    style: kQuestionPreviewStyle,
                                  ),
                                ),
                              // Thẻ cuối -> chân trang: 15px theo task, trừ 12px
                              // padding dưới của thẻ cuối còn 3px.
                              const SizedBox(height: 3),
                              Center(
                                child: Text(
                                  'Hiển thị ${_visibleUsers.length} / '
                                  '${_users.length} tài khoản',
                                  style: kQuestionPreviewStyle,
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

/// Một chip lọc cao 28px theo task, hình viên thuốc (bo 14px).
/// Chỉ dùng ở MH-30 nên để trong file màn hình này.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: kTabHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? kPrimary : kTabUnselectedBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: kDifficultyLabelStyle.copyWith(
            color: selected ? kOnPrimary : kPrimary,
          ),
        ),
      ),
    );
  }
}

/// Một thẻ tài khoản 372x84 theo task: avatar tròn 44x44,
/// tên và dòng "vai trò · gói", trạng thái ở mép phải,
/// nút "Khóa"/"Mở khóa" ở góc dưới phải (nếu có).
/// Chỉ dùng ở MH-30 nên để trong file màn hình này.
class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.planName,
    required this.avatarColor,
    required this.acting,
    required this.onTap,
    required this.onLockToggle,
  });

  final ApiAdminUser account;
  final String planName;
  final Color avatarColor;

  /// true = nut khoa/mo khoa cua the nay dang goi API.
  final bool acting;
  final VoidCallback onTap;
  final VoidCallback onLockToggle;

  @override
  Widget build(BuildContext context) {
    final bool locked = account.locked;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: kAccountCardHeight,
        padding: const EdgeInsets.fromLTRB(14, 17, 16, 8),
        decoration: BoxDecoration(
          color: kSurface,
          border: Border.all(color: kInputBorder, width: 1),
          borderRadius: BorderRadius.circular(kRadiusItem),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar tròn 44x44 với chữ cái đầu tên,
            // cách mép trên thẻ 20px (padding 17 + 3).
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  account.initial,
                  style: kAccountAvatarLetterStyle,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name, style: kAccountNameStyle),
                  // Theo task: tên Top 17px, dòng phụ Top 45px
                  // (cách nhau 5px theo hộp chữ Figma cao 23px,
                  // hộp chữ Flutter chỉ cao 17px nên gap là 11px).
                  const SizedBox(height: 11),
                  Text(
                    '${account.role.toLowerCase()} · $planName',
                    style: kQuestionPreviewStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Cột phải cao bằng chiều cao còn lại của thẻ
            // (84 - 17 - 8 = 59px), trạng thái ở trên cùng,
            // nút ở dưới cùng — đúng vị trí theo task
            // (trạng thái Top 19px, nút đáy cách đáy thẻ 8px)
            // mà không cộng dồn chiều cao nên không tràn.
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Trạng thái chỉ là chữ màu, không có nền pill.
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    account.statusText,
                    style: kDifficultyLabelStyle.copyWith(
                      color: locked ? kHard : kEasy,
                    ),
                  ),
                ),
                // Nút hành động: "Khóa" đỏ hoặc "Mở khóa" xanh.
                // Tài khoản ADMIN không có nút. Khi đang gọi API
                // thì hiện vòng quay nhỏ thay cho nút.
                if (!account.isAdmin)
                  if (acting)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: kPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    SizedBox(
                      width: locked ? 72 : 60,
                      height: kActionButtonHeight,
                      child: OutlinedButton(
                        onPressed: onLockToggle,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: kSurface,
                          padding: EdgeInsets.zero,
                          side: BorderSide(
                            color: locked ? kEasy : kHard,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          locked ? 'Mở khóa' : 'Khóa',
                          style: kActionButtonTextStyle.copyWith(
                            color: locked ? kEasy : kHard,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
