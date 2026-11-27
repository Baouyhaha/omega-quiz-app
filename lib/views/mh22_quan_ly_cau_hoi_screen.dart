import 'package:flutter/material.dart';

import '../core/dinh_api.dart';
import '../core/dinh_theme.dart';
import '../widgets/difficulty_filter_chip_widget.dart';
import '../widgets/question_card_widget.dart';
import 'mh22_quan_ly_cau_hoi_mock.dart';
import 'mh23_soan_sua_cau_hoi_screen.dart';

// ============================================================================
// Mã MH: MH-22 — Quản lý câu hỏi
// Tên màn hình: Quản lý câu hỏi (frame Figma: MH-22-quan-ly-cau-hoi,
// node 83-1412, khung 412 x 917, trang "Mockup màu").
// Thuộc luồng: L4 — Chủ sở hữu (Flow boards, flow-L4-chu-so-huu).
// Vào màn hình này từ đâu:
//   - Từ MH-20 Tạo/Sửa chủ đề, bấm "Lưu chủ đề".
//   - Từ MH-05 Chủ đề (màn của thành viên khác, chưa làm xong).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Bấm "Import Excel" -> MH-24 Import Excel (đích theo task).
//   - Bấm "+ Thêm câu hỏi" -> MH-23 Soạn/Sửa câu hỏi (đích theo task).
//   - Bấm thẻ câu hỏi -> MH-23 chế độ Sửa (nối ở T18 bước 2).
//   - Bấm giữ thẻ câu hỏi -> vào trạng thái chọn nhiều: bấm
//     thêm thẻ để chọn/bỏ chọn, nút Xóa ở thanh dưới xóa các
//     câu đã chọn qua API #19, nút Hủy thoát trạng thái chọn.
//     Hàng "Chọn tất cả" chỉ chọn các câu đang hiện trên màn
//     hình (đã lọc độ khó/tìm kiếm) — xóa chỉ ảnh hưởng nhóm đó.
//   - Nút quay lại "<" -> quay về màn hình trước.
//   - Bottom nav (đích theo task):
//     Trang chủ -> MH-02, Chủ đề -> đang ở đây,
//     Thi đấu -> MH-17, Xếp hạng -> MH-14, Hồ sơ -> MH-03.
// Dữ liệu đang dùng ở đâu:
//   - T18 bước 2: danh sách câu hỏi thật lấy qua DinhApi.fetchQuestions
//     (#16 GET /topics/:id/questions) của chủ đề topic_anh (Tiếng Anh,
//     thuộc về dev:dinh). File mock mh22_quan_ly_cau_hoi_mock.dart chỉ
//     còn dùng kiểu MockQuestion/MockDifficulty để vẽ thẻ QuestionCard.
//   - Lọc theo tab độ khó + ô tìm kiếm lọc ở phía app (theo nội dung).
//   - Ô tìm kiếm là phần thêm theo thẻ T18 bước 2, không có trong Figma.
// Chức năng thật sẽ nối ở task nào:
//   - T18 bước 2 (đã làm ở file này): GET #16, DELETE #19 (xóa
//     1 câu từ MH-23 hoặc xóa nhiều câu đã chọn ở MH-22); MH-23
//     nối POST #17/PATCH #18. Kiến trúc: app gọi API, API mới
//     qua Firebase.
//
// SỐ ĐO: theo task MH-22, xem bảng
// đầy đủ trong mh22_figma_tokens.md. Font Nunito, nền #F6F4FF,
// tím #6C4CF1, chữ #1D1B2E, thẻ câu hỏi 372x72 viền 1px #E9E6F7,
// nút 180x52, tab lọc cao 28px, thẻ AI 372x88.
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như MH-20.
// ============================================================================

/// Màn hình MH-22: danh sách câu hỏi của một chủ đề,
/// kèm tab lọc theo độ khó và thẻ AI soạn nháp (Sắp có).
class Mh22QuanLyCauHoiScreen extends StatefulWidget {
  const Mh22QuanLyCauHoiScreen({
    super.key,
    this.topicId = 'topic_anh',
    this.topicTitle = 'Tiếng Anh',
  });

  /// Id chủ đề lấy danh sách câu hỏi (mặc định topic_anh của dinh).
  final String topicId;

  /// Tên chủ đề hiện ở header.
  final String topicTitle;

  @override
  State<Mh22QuanLyCauHoiScreen> createState() =>
      _Mh22QuanLyCauHoiScreenState();
}

class _Mh22QuanLyCauHoiScreenState extends State<Mh22QuanLyCauHoiScreen> {
  // Tab loc dang chon: all = Tất cả, easy = Dễ,
  // medium = Trung bình, hard = Khó.
  MockDifficulty _selectedDifficulty = MockDifficulty.all;

  // Tab đang chọn ở thanh điều hướng dưới. 1 = Chủ đề, vì màn này
  // thuộc luồng chủ đề.
  int _selectedIndex = 1;

  /// Toàn bộ câu hỏi lấy từ API (#16).
  List<ApiQuestion> _questions = [];

  /// true = đang tải danh sách.
  bool _loading = true;

  /// Lỗi tải danh sách (null = không lỗi). Hiện kèm nút Thử lại.
  String? _error;

  /// Từ khóa tìm kiếm (lọc theo nội dung, không phân biệt hoa thường).
  String _searchQuery = '';
  late final TextEditingController _searchController;

  /// Id các câu hỏi đang được chọn ở trạng thái chọn nhiều.
  /// Tập rỗng = không ở trạng thái chọn.
  final Set<String> _selectedIds = {};

  /// true = đang ở trạng thái chọn nhiều (đã chọn ít nhất 1 câu).
  bool get _selecting => _selectedIds.isNotEmpty;

  /// true = đang chờ API xóa các câu đã chọn.
  bool _deletingSelected = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadQuestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Tải danh sách câu hỏi của chủ đề qua API #16.
  /// Chỉ hiện spinner khi chưa có dữ liệu (lần tải đầu); tải lại
  /// (kéo xuống, quay về từ MH-23/MH-24) thì giữ danh sách cũ hiển
  /// thị tại chỗ cho đến khi dữ liệu mới về.
  Future<void> _loadQuestions() async {
    setState(() {
      _loading = _questions.isEmpty;
      _error = null;
    });
    try {
      final questions = await DinhApi.fetchQuestions(widget.topicId);
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      final hadData = _questions.isNotEmpty;
      setState(() {
        _loading = false;
        // Chưa có dữ liệu thì hiện hộp lỗi + nút "Thử lại";
        // đã có dữ liệu thì giữ danh sách cũ, báo lỗi bằng SnackBar.
        _error = hadData ? null : e.message;
      });
      if (hadData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  /// Danh sách câu hỏi sau khi lọc theo tab độ khó + ô tìm kiếm.
  List<ApiQuestion> get _visibleQuestions {
    return _questions.where((q) {
      if (_selectedDifficulty != MockDifficulty.all) {
        final want = _selectedDifficulty == MockDifficulty.easy
            ? 'easy'
            : _selectedDifficulty == MockDifficulty.medium
                ? 'medium'
                : 'hard';
        if (q.difficulty != want) return false;
      }
      if (_searchQuery.isNotEmpty) {
        if (!q.content
            .toLowerCase()
            .contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Mở MH-23 sửa câu hỏi. Lưu xong (trả về true) thì tải lại danh sách.
  Future<void> _openEdit(ApiQuestion question) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => Mh23SoanSuaCauHoiScreen(
          isEdit: true,
          topicId: widget.topicId,
          existing: question,
        ),
      ),
    );
    if (saved == true) _loadQuestions();
  }

  /// Mở MH-23 soạn câu hỏi mới. Lưu xong thì tải lại danh sách.
  Future<void> _openCreate() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => Mh23SoanSuaCauHoiScreen(
          topicId: widget.topicId,
        ),
      ),
    );
    if (saved == true) _loadQuestions();
  }

  /// Bấm giữ thẻ -> vào trạng thái chọn nhiều, chọn luôn thẻ đó.
  void _enterSelection(ApiQuestion question) {
    setState(() {
      _selectedIds.add(question.id);
    });
  }

  /// Bấm thẻ ở trạng thái chọn nhiều -> chọn/bỏ chọn thẻ đó.
  /// Bỏ chọn câu cuối cùng thì tự thoát trạng thái chọn.
  void _toggleSelect(ApiQuestion question) {
    setState(() {
      if (_selectedIds.contains(question.id)) {
        _selectedIds.remove(question.id);
      } else {
        _selectedIds.add(question.id);
      }
    });
  }

  /// Nút Hủy ở thanh dưới -> thoát trạng thái chọn nhiều.
  void _cancelSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  /// true = mọi câu hỏi đang hiện đều đã được chọn.
  bool get _allVisibleSelected =>
      _visibleQuestions.isNotEmpty &&
      _visibleQuestions.every((q) => _selectedIds.contains(q.id));

  /// "Chọn tất cả" / "Bỏ chọn tất cả": chỉ tác động các câu
  /// hỏi ĐANG HIỆN trên màn hình (đã lọc theo tab độ khó +
  /// ô tìm kiếm). Ví dụ lọc "Dễ" rồi chọn tất cả thì chỉ
  /// chọn các câu dễ đang hiện — câu độ khó khác giữ nguyên.
  void _toggleSelectAllVisible() {
    setState(() {
      if (_allVisibleSelected) {
        for (final q in _visibleQuestions) {
          _selectedIds.remove(q.id);
        }
      } else {
        for (final q in _visibleQuestions) {
          _selectedIds.add(q.id);
        }
      }
    });
  }

  /// Nút Xóa ở thanh dưới -> hỏi xác nhận rồi xóa từng câu đã
  /// chọn qua API #19, xong tải lại danh sách và thoát trạng
  /// thái chọn.
  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty || _deletingSelected) return;
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa $count câu hỏi đã chọn?'),
        content: const Text(
          'Các câu hỏi đã chọn sẽ bị xóa khỏi chủ đề và không khôi phục được.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Xóa',
              style: TextStyle(color: kHard),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _deletingSelected = true;
    });
    var failed = 0;
    for (final id in _selectedIds.toList()) {
      try {
        await DinhApi.deleteQuestion(id);
      } on ApiException {
        failed++;
      }
    }
    if (!mounted) return;
    setState(() {
      _selectedIds.clear();
      _deletingSelected = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed == 0
              ? 'Đã xóa $count câu hỏi'
              : 'Đã xóa ${count - failed}/$count câu hỏi ($failed câu lỗi)',
        ),
      ),
    );
    _loadQuestions();
  }

  /// Đổi ApiQuestion sang MockQuestion để vẽ thẻ QuestionCard
  /// (thẻ chỉ cần số thứ tự, nội dung xem trước và độ khó).
  MockQuestion _toMockQuestion(ApiQuestion q) {
    final index = _questions.indexOf(q);
    final difficulty = q.difficulty == 'easy'
        ? MockDifficulty.easy
        : q.difficulty == 'hard'
            ? MockDifficulty.hard
            : MockDifficulty.medium;
    return MockQuestion(
      number: index + 1,
      preview: q.content,
      difficulty: difficulty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Hàng tiêu đề: nút quay lại "‹" 34px + tiêu đề 24px ---
            // Theo task: nút Left 20px, tiêu đề Left 52px (cách nút 22px).
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kSpacing20,
                kSpacing12,
                kSpacing20,
                kSpacing12,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    // Ở trạng thái chọn nhiều: nút quay lại thoát
                    // trạng thái chọn; bình thường: quay về màn trước.
                    onTap: () {
                      if (_selecting) {
                        _cancelSelection();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('‹', style: kBackStyle),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Text(
                      _selecting
                          ? 'Đã chọn ${_selectedIds.length}'
                          : 'Câu hỏi — ${widget.topicTitle}',
                      style: kPageTitleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // --- Nội dung: cuộn được nếu màn hình nhỏ ---
            // Kéo xuống khi đã ở đầu trang để tải lại danh sách (#16).
            // AlwaysScrollableScrollPhysics để kéo được cả khi danh
            // sách ngắn chưa kín màn hình.
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadQuestions,
                color: kPrimary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpacing20,
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ô tìm kiếm (thêm theo thẻ T18 bước 2,
                    // không có trong Figma): lọc theo nội dung.
                    SizedBox(
                      height: kFieldHeight,
                      child: TextField(
                        controller: _searchController,
                        style: kFieldTextStyle,
                        decoration: InputDecoration(
                          hintText: 'Tìm câu hỏi...',
                          hintStyle: kFieldTextStyle.copyWith(
                            color: kNavUnselected,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: kTextSecondary,
                          ),
                          filled: true,
                          fillColor: kSurface,
                          border: kFieldBorder,
                          enabledBorder: kFieldBorder,
                          focusedBorder: kFieldFocusedBorder,
                          contentPadding: kFieldPadding,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim();
                          });
                        },
                      ),
                    ),
                    // Ô tìm kiếm -> hàng tab: 14px.
                    const SizedBox(height: 14),
                    // Hàng tab lọc độ khó, cao 28px.
                    // Khoảng cách giữa các pill theo task: 10, 10, 2.
                    Row(
                      children: [
                        _buildFilterTab(
                          MockDifficulty.all,
                          'Tất cả',
                          72,
                        ),
                        const SizedBox(width: 10),
                        _buildFilterTab(
                          MockDifficulty.easy,
                          'Dễ',
                          40,
                        ),
                        const SizedBox(width: 10),
                        _buildFilterTab(
                          MockDifficulty.medium,
                          'Trung bình',
                          104,
                        ),
                        const SizedBox(width: 2),
                        _buildFilterTab(
                          MockDifficulty.hard,
                          'Khó',
                          48,
                        ),
                      ],
                    ),
                    // Đáy tab -> hàng nút: 14px.
                    const SizedBox(height: 14),

                    // Hàng nút: Import Excel (trái) — + Thêm câu hỏi (phải).
                    // Theo task mỗi nút 180x52, cách nhau 12px, tổng 372px.
                    // Máy thật rộng 411.4px nên 372 + lề 40 = 412.6px,
                    // tràn 0.571px — dùng Expanded để hai nút tự chia
                    // đều chiều rộng còn lại, vẫn giữ cao 52px và gap 12px.
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: kButtonHeight,
                            child: OutlinedButton(
                            onPressed: () async {
                              // Đích theo task: MH-24 Import Excel.
                              // MH-24 pop(true) khi xac nhan luu thanh cong
                              // (#21) thi tai lai danh sach de hien cac cau
                              // vua nhap; pop khong co gia tri (nut quay
                              // lai / huy) thi giu nguyen danh sach cu.
                              final imported = await Navigator.pushNamed(
                                context,
                                '/mh24',
                              );
                              if (imported == true) _loadQuestions();
                            },
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
                            child: const Text(
                              'Import Excel',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: kPrimary,
                                height: 1.0,
                              ),
                            ),
                          ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: kButtonHeight,
                            child: ElevatedButton(
                            onPressed: _openCreate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: kOnPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  kRadiusButton,
                                ),
                              ),
                            ),
                            child: const Text(
                              '+ Thêm câu hỏi',
                              style: kButtonTextStyle,
                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Hàng nút -> thẻ đầu tiên: 16px.
                    const SizedBox(height: 16),

                    // Hàng "Chọn tất cả" (chỉ ở trạng thái chọn
                    // nhiều): chọn/bỏ chọn toàn bộ câu hỏi ĐANG
                    // HIỆN trên màn hình — tức đã lọc theo tab
                    // độ khó + ô tìm kiếm. Bấm khi đang lọc "Dễ"
                    // thì chỉ chọn các câu dễ đang hiện, câu độ
                    // khó khác giữ nguyên khi xóa.
                    if (_selecting)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: _toggleSelectAllVisible,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _allVisibleSelected
                                    ? 'Bỏ chọn tất cả'
                                    : 'Chọn tất cả',
                                style: kDifficultyLabelStyle.copyWith(
                                  color: kPrimary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_selectedIds.length} đã chọn',
                              style: kQuestionPreviewStyle,
                            ),
                          ],
                        ),
                      ),

                    // Trạng thái tải / lỗi / danh sách.
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Không tải được danh sách: $_error',
                              style: kErrorTextStyle,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadQuestions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimary,
                                foregroundColor: kOnPrimary,
                              ),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    else if (_visibleQuestions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'Chưa có câu hỏi nào.',
                            style: kQuestionPreviewStyle,
                          ),
                        ),
                      )
                    else
                      // Danh sách thẻ câu hỏi, thẻ cách nhau 12px.
                      // Bình thường: bấm thẻ -> sửa, bấm giữ thẻ ->
                      // vào trạng thái chọn nhiều. Ở trạng thái
                      // chọn: bấm thẻ -> chọn/bỏ chọn.
                      ..._visibleQuestions.map(
                        (question) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => _selecting
                                ? _toggleSelect(question)
                                : _openEdit(question),
                            onLongPress: () =>
                                _enterSelection(question),
                            child: QuestionCard(
                              question:
                                  _toMockQuestion(question),
                              selecting: _selecting,
                              selected: _selectedIds.contains(
                                question.id,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Đáy thẻ cuối -> thẻ AI: 24px.
                    const SizedBox(height: 12),
                    const _AiDraftCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              ),
            ),

            // --- Thanh tác vụ trạng thái chọn: cố định dưới
            // danh sách (nằm trên thanh điều hướng), chỉ hiện
            // khi đang chọn nhiều. Danh sách cuộn lên xuống thì
            // thanh này vẫn ở đó để bấm Xóa / Hủy.
            if (_selecting) _buildSelectionBar(),
          ],
        ),
      ),
      // --- Thanh điều hướng dưới: cao 76px, nền trắng,
      // đường phân cách trên 1px #E9E6F7, nhãn 12px #9A94B8 ---
      // Đích theo task: Trang chủ -> /mh02, Chủ đề -> đang ở đây,
      // Thi đấu -> /mh17, Xếp hạng -> /mh14, Hồ sơ -> /mh03.
      // Các màn đó chưa làm xong nên onTap hiện chỉ đổi tab đang chọn.
      // Khi các màn đó xong, thay bằng Navigator.pushNamed tương ứng.
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(
            top: BorderSide(color: kInputBorder, width: 1),
          ),
        ),
        child: SizedBox(
          height: 76,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: kSurface,
            elevation: 0,
            currentIndex: _selectedIndex,
            selectedItemColor: kPrimary,
            unselectedItemColor: kNavUnselected,
            selectedLabelStyle: kNavLabelStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
            unselectedLabelStyle: kNavLabelStyle,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.layers_outlined),
                label: 'Chủ đề',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined),
                label: 'Thi đấu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                label: 'Xếp hạng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Hồ sơ',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Thanh tác vụ khi đang chọn nhiều: nút Hủy (thoát trạng thái
  /// chọn) + nút Xóa các mục đã chọn (đỏ kHard, kèm số lượng).
  /// Nằm cố định dưới danh sách nên lướt lên xuống vẫn bấm được.
  Widget _buildSelectionBar() {
    final count = _selectedIds.length;
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(
          top: BorderSide(color: kInputBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed:
                    _deletingSelected ? null : _cancelSelection,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: kRadioBorder,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(kRadiusButton),
                  ),
                ),
                child: const Text(
                  'Hủy',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextSecondary,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed:
                    _deletingSelected ? null : _deleteSelected,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: kOnPrimary,
                ),
                label: Text(
                  _deletingSelected
                      ? 'Đang xóa...'
                      : 'Xóa ($count)',
                  style: kButtonTextStyle.copyWith(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kHard,
                  foregroundColor: kOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(kRadiusButton),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Một tab lọc độ khó. Mức đang chọn nền tím chữ trắng,
  /// mức chưa chọn nền #EFECFE chữ tím.
  Widget _buildFilterTab(
    MockDifficulty difficulty,
    String label,
    double width,
  ) {
    final bool selected = _selectedDifficulty == difficulty;
    return DifficultyFilterChip(
      label: label,
      width: width,
      backgroundColor:
          selected ? kPrimary : kTabUnselectedBackground,
      textColor: selected ? kOnPrimary : kPrimary,
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
    );
  }
}

/// Thẻ AI soạn nháp câu hỏi (372x88), trạng thái "Sắp có".
/// Chỉ dùng ở MH-22 nên để trong file màn hình này, không tách
/// ra widget dùng chung.
/// Theo task: nền trắng viền 1px #E9E6F7, phủ trắng 62% lên
/// toàn bộ thẻ (làm thẻ trông mờ), vòng tròn 44x44 nền #EFECFE
/// chữ "AI" tím, huy hiệu "Sắp có" nền #E5E7EB.
class _AiDraftCard extends StatelessWidget {
  const _AiDraftCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kAiCardHeight,
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 22, 16, 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vòng tròn AI 44x44.
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: kTabUnselectedBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kPrimary,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI soạn nháp câu hỏi',
                        style: kQuestionTitleStyle,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tự động tạo câu hỏi từ tài liệu',
                        style: kQuestionPreviewStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Huy hiệu "Sắp có" 72x28.
                Container(
                  width: 72,
                  height: kTabHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kComingSoonBackground,
                    borderRadius: BorderRadius.circular(kRadiusItem),
                  ),
                  child: Text(
                    'Sắp có',
                    style: kDifficultyLabelStyle.copyWith(
                      color: kTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lớp phủ trắng 62% theo task, làm thẻ trông mờ.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.62),
                borderRadius: BorderRadius.circular(kRadiusItem),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
