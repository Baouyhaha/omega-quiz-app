import 'package:flutter/material.dart';

import '../core/dinh_api.dart';
import '../core/dinh_theme.dart';

// ============================================================================
// Mã MH: MH-32 — Admin: Gói và hạn mức
// Tên màn hình: Gói và hạn mức (frame Figma:
// MH-32-admin-goi-va-han-muc, node 83-193, khung 412 x 917,
// trang "Mockup màu").
// Thuộc luồng: L9 — Admin nền tảng (Flow boards, flow-L9-admin).
// Vào màn hình này từ đâu:
//   - Từ MH-30 / MH-33: bấm tab "Gói và hạn mức" ở thanh tab phụ dưới.
//     Điểm vào khu vực Admin là Hồ sơ (MH-03) -> mục "Quản trị nền
//     tảng" -> MH-30 (luồng đã chốt 24/11).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Thanh tab phụ dưới nằm ở màn host Admin (AdminHostScreen),
//     không nằm trong màn này: bấm tab "Tài khoản" sang MH-30, tab
//     "Thống kê" sang MH-33; thanh tab đứng yên, chỉ phần nội dung
//     trượt ngang.
//   - Nút quay lại "‹" ở header: về Hồ sơ (MH-03) — màn vào Admin.
//     Nút này không có trong thiết kế Figma, thêm theo luồng đã chốt.
//   - Nút "Lưu thay đổi": gọi PUT /admin/plans/:id cho từng gói
//     có thay đổi (UC26).
// Dữ liệu thật đang dùng (nối API 25/11):
//   - GET /admin/plans (token dev:admin): danh sách 5 gói seed
//     (Miễn phí, Dùng thử, Gói 30 ngày, Gói 90 ngày, Gói 1 năm).
//   - Mỗi gói hiện 6 ô nhập: Giá (đ), Thời hạn (ngày) và 4 hạn mức
//     (Chủ đề tối đa, Bộ đề/chủ đề, Thành viên/chủ đề,
//     Câu hỏi/chủ đề). Bản mock cũ chỉ hiện 2 gói với số ô khác
//     nhau theo Figma; bản thật hiện đủ 5 gói, đủ 6 ô.
//   - Quy ước "không giới hạn": ô hạn mức hiện 999 khi API trả
//     null (theo quy ước của mock — gói 30 ngày hiện 999); lúc lưu,
//     999 hoặc để trống đều gửi lên là null. Ô Thời hạn để trống
//     cũng là không giới hạn (gửi null).
//   - Nút Lưu chỉ gửi PUT cho gói nào có thay đổi, giá trị nào
//     không phải số nguyên >= 0 thì báo lỗi và không lưu gói đó.
//   - Dữ liệu gói là seed trong bộ nhớ của API, restart server là
//     reset.
//   - File mock mh32_admin_goi_va_han_muc_mock.dart chỉ còn là dữ
//     liệu Figma gốc, màn này không dùng nữa.
// Chức năng thật sẽ nối ở task nào:
//   - UC26 (quản lý gói): đã nối API, xem các hàm _loadPlans / _save.
//     Kiến trúc: app gọi API, API mới qua Firebase.
//
// SỐ ĐO: theo task MH-32, xem bảng đầy đủ trong mh32_figma_tokens.md.
// Font Nunito, nền #F6F4FF, header tím đậm #4A32B8 cao 104px,
// thẻ gói 372x244 và 372x156, ô nhập 104x32,
// nút lưu 372x52 tím.
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như các màn trước; riêng ô nhập cao 32px dùng bo 8px.
// ============================================================================

/// Màn hình MH-32: chỉnh gói và hạn mức cho admin — các thẻ gói
/// với các ô nhập hạn mức, nút lưu thay đổi và ghi chú.
/// Dữ liệu tải từ API admin, không dùng mock nữa.
class Mh32AdminGoiVaHanMucScreen extends StatefulWidget {
  const Mh32AdminGoiVaHanMucScreen({super.key});

  @override
  State<Mh32AdminGoiVaHanMucScreen> createState() =>
      _Mh32AdminGoiVaHanMucScreenState();
}

class _Mh32AdminGoiVaHanMucScreenState
    extends State<Mh32AdminGoiVaHanMucScreen> {
  List<ApiAdminPlan> _plans = [];

  // O nhap cua tung goi, theo ma goi: 'price', 'days',
  // 'maxTopics', 'maxExamsPerTopic', 'maxMembersPerTopic',
  // 'maxQuestionsPerExam'.
  Map<String, Map<String, TextEditingController>> _controllers = {};

  bool _loading = true;
  String? _error;

  /// true = dang goi PUT luu thay doi.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final byField in _controllers.values) {
      for (final c in byField.values) {
        c.dispose();
      }
    }
    _controllers.clear();
  }

  /// Gia tri han muc hien trong o nhap: null (khong gioi han)
  /// hien '999' theo quy uoc cua mock (goi 30 ngay hien 999).
  String _limitText(int? value) => value == null ? '999' : '$value';

  /// Tai danh sach goi tu GET /admin/plans, tao o nhap cho tung goi.
  Future<void> _loadPlans() async {
    if (_plans.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final plans = await DinhApi.fetchAdminPlans();
      if (!mounted) return;
      _disposeControllers();
      final controllers =
          <String, Map<String, TextEditingController>>{};
      for (final plan in plans) {
        final limits = plan.limits;
        controllers[plan.id] = {
          'price': TextEditingController(text: '${plan.price}'),
          'days': TextEditingController(
            text: plan.days == null ? '' : '${plan.days}',
          ),
          'maxTopics': TextEditingController(
            text: _limitText(limits?.maxTopics),
          ),
          'maxExamsPerTopic': TextEditingController(
            text: _limitText(limits?.maxExamsPerTopic),
          ),
          'maxMembersPerTopic': TextEditingController(
            text: _limitText(limits?.maxMembersPerTopic),
          ),
          'maxQuestionsPerExam': TextEditingController(
            text: _limitText(limits?.maxQuestionsPerExam),
          ),
        };
      }
      setState(() {
        _plans = plans;
        _controllers = controllers;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (_plans.isEmpty) {
        setState(() => _error = e.message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  /// Gia tri bat buoc phai la so nguyen >= 0.
  int _parseRequiredInt(String text, String planName, String label) {
    final v = int.tryParse(text.trim());
    if (v == null || v < 0) throw _InvalidField(planName, label);
    return v;
  }

  /// Gia tri tuy chon: de trong la null (khong gioi han),
  /// co so thi phai la so nguyen >= 0.
  int? _parseOptionalInt(String text, String planName, String label) {
    final t = text.trim();
    if (t.isEmpty) return null;
    final v = int.tryParse(t);
    if (v == null || v < 0) throw _InvalidField(planName, label);
    return v;
  }

  /// Gia tri han muc: de trong hoac 999 la null (khong gioi han),
  /// co so thi phai la so nguyen >= 0.
  int? _parseLimit(String text, String planName, String label) {
    final t = text.trim();
    if (t.isEmpty || t == '999') return null;
    final v = int.tryParse(t);
    if (v == null || v < 0) throw _InvalidField(planName, label);
    return v;
  }

  /// Luu thay doi: chi gui PUT cho goi nao co thay doi.
  Future<void> _save() async {
    if (_saving || _plans.isEmpty) return;
    setState(() => _saving = true);
    try {
      var changed = 0;
      var failed = 0;
      for (final plan in _plans) {
        final c = _controllers[plan.id]!;
        final price = _parseRequiredInt(
          c['price']!.text,
          plan.name,
          'Giá (đ)',
        );
        final days = _parseOptionalInt(
          c['days']!.text,
          plan.name,
          'Thời hạn (ngày)',
        );
        final limits = ApiPlanLimits(
          maxTopics: _parseLimit(
            c['maxTopics']!.text,
            plan.name,
            'Chủ đề tối đa',
          ),
          maxExamsPerTopic: _parseLimit(
            c['maxExamsPerTopic']!.text,
            plan.name,
            'Bộ đề/chủ đề',
          ),
          maxMembersPerTopic: _parseLimit(
            c['maxMembersPerTopic']!.text,
            plan.name,
            'Thành viên/chủ đề',
          ),
          maxQuestionsPerExam: _parseLimit(
            c['maxQuestionsPerExam']!.text,
            plan.name,
            'Câu hỏi/chủ đề',
          ),
        );
        final old = plan.limits;
        final limitsChanged = limits.maxTopics != old?.maxTopics ||
            limits.maxExamsPerTopic != old?.maxExamsPerTopic ||
            limits.maxMembersPerTopic != old?.maxMembersPerTopic ||
            limits.maxQuestionsPerExam != old?.maxQuestionsPerExam;
        if (price == plan.price &&
            days == plan.days &&
            !limitsChanged) {
          continue;
        }
        try {
          await DinhApi.updateAdminPlan(plan.id, {
            'price': price,
            'days': days,
            'limits': limits.toJson(),
          });
          changed++;
        } on ApiException {
          failed++;
        }
      }
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failed > 0
                ? 'Đã lưu $changed gói, $failed gói lỗi'
                : changed == 0
                    ? 'Không có thay đổi nào'
                    : 'Đã lưu thay đổi cho $changed gói',
          ),
        ),
      );
      if (changed > 0) await _loadPlans();
    } on _InvalidField catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Giá trị không hợp lệ ở gói ${e.planName}, ô ${e.label}',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
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
          // Nút quay lại "‹" trắng + tiêu đề "Gói và hạn mức"
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
                    'Gói và hạn mức',
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
                              onPressed: _loadPlans,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPlans,
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
                              // Header đáy -> tiêu đề gói đầu tiên: 8px.
                              const SizedBox(height: 8),

                              // Cac the goi that tu API, mỗi thẻ gồm
                              // tiêu đề và các hàng hạn mức. Thẻ cách
                              // nhau: thẻ trên đáy -> tiêu đề thẻ dưới
                              // 8px, tiêu đề -> thẻ 5px.
                              for (int i = 0; i < _plans.length; i++) ...[
                                if (i > 0) const SizedBox(height: 8),
                                Text(_plans[i].name, style: kHeadingStyle),
                                const SizedBox(height: 5),
                                _PlanCard(
                                  plan: _plans[i],
                                  controllers: _controllers[_plans[i].id]!,
                                ),
                              ],
                              // Thẻ gói cuối -> nút lưu: 16px theo task.
                              const SizedBox(height: 16),

                              // --- Nút "Lưu thay đổi" 372x52 tím ---
                              SizedBox(
                                width: double.infinity,
                                height: kButtonHeight,
                                child: ElevatedButton(
                                  onPressed: _saving ? null : _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimary,
                                    foregroundColor: kOnPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        kRadiusButton,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _saving
                                        ? 'Đang lưu...'
                                        : 'Lưu thay đổi',
                                    style: kButtonTextStyle,
                                  ),
                                ),
                              ),
                              // Nút lưu -> ghi chú: 11px theo task.
                              const SizedBox(height: 11),
                              const Center(
                                child: Text(
                                  'Thay đổi chỉ áp dụng cho lượt đăng ký mới.',
                                  style: kQuestionPreviewStyle,
                                  textAlign: TextAlign.center,
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

/// Mot o trong 1 the goi: khoa de luu + nhan hien tren giao dien.
// Chi dung o MH-32 nen de trong file man hinh nay.
class _PlanField {
  const _PlanField(this.key, this.label);
  final String key;
  final String label;
}

/// Cac o han muc trong 1 the goi, theo thu tu hien.
const List<_PlanField> _limitFields = [
  _PlanField('maxTopics', 'Chủ đề tối đa'),
  _PlanField('maxExamsPerTopic', 'Bộ đề/chủ đề'),
  _PlanField('maxMembersPerTopic', 'Thành viên/chủ đề'),
  _PlanField('maxQuestionsPerExam', 'Câu hỏi/chủ đề'),
];

/// Loi khi 1 o nhap khong phai so nguyen >= 0.
class _InvalidField implements Exception {
  const _InvalidField(this.planName, this.label);
  final String planName;
  final String label;
}

/// Một thẻ gói theo task: nền trắng, viền 1px #E9E6F7,
/// các hàng hạn mức cách nhau 12px. Chiều cao thẻ theo số hàng.
/// Chỉ dùng ở MH-32 nên để trong file màn hình này.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.controllers});

  final ApiAdminPlan plan;
  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LimitRow(
            label: 'Giá (đ)',
            controller: controllers['price']!,
          ),
          const SizedBox(height: 12),
          _LimitRow(
            label: 'Thời hạn (ngày)',
            controller: controllers['days']!,
            hint: 'Không giới hạn',
          ),
          for (final f in _limitFields) ...[
            const SizedBox(height: 12),
            _LimitRow(
              label: f.label,
              controller: controllers[f.key]!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Một hàng hạn mức theo task: nhãn 15px ở trái,
/// ô nhập 104x32 ở phải với giá trị 15px 700 căn giữa.
/// Chỉ dùng ở MH-32 nên để trong file màn hình này.
class _LimitRow extends StatelessWidget {
  const _LimitRow({
    required this.label,
    required this.controller,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: kFieldTextStyle),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: kLimitInputWidth,
          height: kLimitInputHeight,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: kLimitValueStyle,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: kLimitValueStyle.copyWith(
                color: kTextSecondary,
              ),
              filled: true,
              fillColor: kSurface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: kInputBorder,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: kInputBorder,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: kPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
