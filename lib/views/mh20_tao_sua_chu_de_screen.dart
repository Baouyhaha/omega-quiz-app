import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../core/dinh_theme.dart';
import '../widgets/limit_warning_banner_widget.dart';
import '../widgets/topic_mode_option_widget.dart';
import 'mh20_tao_sua_chu_de_mock.dart';

// ============================================================================
// Mã MH: MH-20 — Tạo/Sửa chủ đề
// Tên màn hình: Tạo/Sửa chủ đề (frame Figma: MH-20-tao-sua-chu-de,
// node 83-1312, khung 412 x 917, trang "Mockup màu").
// Thuộc luồng: L4 — Chủ sở hữu (Flow boards, flow-L4-chu-so-huu).
// Vào màn hình này từ đâu:
//   - Từ MH-02 Trang chủ, mục "Chủ đề của tôi", bấm "Tạo chủ đề".
//   - Chế độ sửa dùng chung form này, các trường điền sẵn dữ liệu
//     của chủ đề (Figma chỉ vẽ 1 frame, không có frame sửa riêng).
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Bấm "Lưu chủ đề" -> MH-22 Quản lý câu hỏi (Interaction trong
//     Theo task: On click -> Navigate to MH-22-quan-ly-cau-hoi).
//   - Nút quay lại "<" -> quay về màn hình trước (Chủ đề của tôi).
//   - Bấm "Chọn ảnh bìa" -> mở trình chọn ảnh (không chuyển màn hình).
//   - Radio Công khai / Riêng tư -> chỉ đổi lựa chọn, không chuyển màn.
//   - Bottom nav (đích theo task):
//     Trang chủ -> MH-02, Chủ đề -> MH-05, Thi đấu -> MH-17,
//     Xếp hạng -> MH-14, Hồ sơ -> MH-03.
// Dữ liệu giả đang dùng ở đâu:
//   - File mh20_tao_sua_chu_de_mock.dart, biến mockTopic.
//   - Khối dữ liệu đó có ghi chú // MOCK: ở dòng đầu.
// Chức năng thật sẽ nối ở task nào:
//   - Để giai đoạn chức năng: lưu chủ đề thật qua API, chọn ảnh bìa
//     thật, kiểm tra hạn mức gói trước khi tạo (miễn phí tối đa
//     1 chủ đề, 10 thành viên/khóa đề — ghi chú dưới bảng Flow L4).
//
// SỐ ĐO: theo task MH-20, xem bảng
// đầy đủ trong mh20_figma_tokens.md. Font Nunito, nền #F6F4FF,
// tím #6C4CF1, chữ #1D1B2E, hộp vàng #FFF3E0, ô nhập 372x52,
// hộp ảnh bìa 372x96 nét đứt (dashes 6, 5), nút 372x52.
// Dev Mode của Figma yêu cầu nâng cấp gói nên không lấy được mã CSS;
// bo góc không hiển thị trong Properties nên đang dùng tạm 16px.
// ============================================================================

/// Màn hình MH-20: form tạo mới hoặc sửa một chủ đề.
/// Cùng một form cho cả hai chế độ: [isEdit] = false thì tiêu đề là
/// "Tạo chủ đề", = true thì tiêu đề là "Sửa chủ đề".
class Mh20TaoSuaChuDeScreen extends StatefulWidget {
  const Mh20TaoSuaChuDeScreen({super.key, this.isEdit = false});

  /// true = đang sửa chủ đề có sẵn, false = đang tạo chủ đề mới.
  final bool isEdit;

  @override
  State<Mh20TaoSuaChuDeScreen> createState() =>
      _Mh20TaoSuaChuDeScreenState();
}

class _Mh20TaoSuaChuDeScreenState extends State<Mh20TaoSuaChuDeScreen> {
  // Ô nhập tên và mô tả. Khởi tạo bằng dữ liệu giả theo dữ liệu
  // của task ("Toán cao cấp" / "Ôn tập đạo hàm, tích phân") để
  // ảnh chụp màn hình khớp thiết kế. Khi nối chức năng: chế độ tạo
  // để trống, chế độ sửa điền dữ liệu thật của chủ đề.
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  // Chế độ đang chọn: 'public' = Công khai, 'private' = Riêng tư.
  String _mode = mockTopic.mode;

  // Tab đang chọn ở thanh điều hướng dưới. 1 = Chủ đề, vì màn này
  // thuộc luồng chủ đề.
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: mockTopic.name);
    _descriptionController =
        TextEditingController(text: mockTopic.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Hàng tiêu đề: nút quay lại "‹" 34px + "Tạo chủ đề" 24px ---
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
                    // Quay về màn hình trước đó.
                    onTap: () => Navigator.pop(context),
                    child: const Text('‹', style: kBackStyle),
                  ),
                  const SizedBox(width: 22),
                  Text(
                    widget.isEdit ? 'Sửa chủ đề' : 'Tạo chủ đề',
                    style: kPageTitleStyle,
                  ),
                ],
              ),
            ),

            // --- Form: cuộn được nếu màn hình nhỏ ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacing20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trường "Tên chủ đề". Nhãn 13px -> ô nhập 3px.
                    const Text('Tên chủ đề', style: kLabelStyle),
                    const SizedBox(height: kSpacing3),
                    SizedBox(
                      height: kFieldHeight,
                      child: TextField(
                        controller: _nameController,
                        style: kFieldTextStyle,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: kSurface,
                          border: kFieldBorder,
                          enabledBorder: kFieldBorder,
                          focusedBorder: kFieldFocusedBorder,
                          contentPadding: kFieldPadding,
                        ),
                      ),
                    ),
                    // Ô nhập -> nhãn tiếp theo: 13px.
                    const SizedBox(height: kSpacing13),

                    // Trường "Mô tả".
                    const Text('Mô tả', style: kLabelStyle),
                    const SizedBox(height: kSpacing3),
                    SizedBox(
                      height: kFieldHeight,
                      child: TextField(
                        controller: _descriptionController,
                        style: kFieldTextStyle,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: kSurface,
                          border: kFieldBorder,
                          enabledBorder: kFieldBorder,
                          focusedBorder: kFieldFocusedBorder,
                          contentPadding: kFieldPadding,
                        ),
                      ),
                    ),
                    const SizedBox(height: kSpacing13),

                    // Ô "Ảnh bìa": 372x96, viền nét đứt 1.5px #C9C4DE,
                    // dashes 6, 5. Đang trống, bấm để chọn ảnh.
                    const Text('Ảnh bìa', style: kLabelStyle),
                    const SizedBox(height: kSpacing3),
                    DottedBorder(
                      // dotted_border 3.x doi API: khong truyen
                      // dashPattern/color/... truc tiep nua, ma gom
                      // vao RoundedRectDottedBorderOptions.
                      options: const RoundedRectDottedBorderOptions(
                        dashPattern: [6, 5],
                        strokeWidth: 1.5,
                        color: kRadioBorder,
                        radius: Radius.circular(kRadiusItem),
                      ),
                      child: InkWell(
                        // Mở trình chọn ảnh — để giai đoạn chức năng.
                        onTap: () {},
                        borderRadius: BorderRadius.circular(
                          kRadiusItem,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: kCoverHeight,
                          color: kSurface,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Dấu "+" 28px, #6E6A8A.
                              Text(
                                '+',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: kTextSecondary,
                                  height: 1.0,
                                ),
                              ),
                              // "Chọn ảnh bìa" 15px, #6E6A8A.
                              Text(
                                'Chọn ảnh bìa',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: kTextSecondary,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: kSpacing13),

                    // Nhóm "Chế độ": tiêu đề 20px, radio 1 cách 12px,
                    // radio 1 -> radio 2 cách 16px.
                    const Text('Chế độ', style: kHeadingStyle),
                    const SizedBox(height: 12),
                    TopicModeOption(
                      title: 'Công khai',
                      description: 'ai cũng xem được',
                      value: 'public',
                      groupValue: _mode,
                      onChanged: (value) {
                        setState(() {
                          _mode = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TopicModeOption(
                      title: 'Riêng tư',
                      description: 'chỉ thành viên',
                      value: 'private',
                      groupValue: _mode,
                      onChanged: (value) {
                        setState(() {
                          _mode = value!;
                        });
                      },
                    ),
                    // Radio 2 -> hộp cảnh báo: 23px.
                    const SizedBox(height: 23),

                    // Hộp cảnh báo hạn mức gói miễn phí, cao 52px.
                    const LimitWarningBanner(
                      text: 'Gói miễn phí: tối đa 1 chủ đề',
                    ),
                    const SizedBox(height: kSpacing20),
                  ],
                ),
              ),
            ),

            // --- Nút chính "Lưu chủ đề", cao 52px ---
            // Theo task: hộp cảnh báo -> nút cách 199px (khoảng trống lớn),
            // nút đặt gần đáy, trên thanh điều hướng 20px.
            Padding(
              padding: const EdgeInsets.all(kSpacing20),
              child: SizedBox(
                width: double.infinity,
                height: kButtonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    // Chỉ điều hướng ở giai đoạn giao diện, chưa lưu thật.
                    // Theo task, sau khi lưu đi tới
                    // MH-22 Quản lý câu hỏi.
                    Navigator.pushNamed(context, '/mh22');
                  },
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
                    'Lưu chủ đề',
                    style: kButtonTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // --- Thanh điều hướng dưới: cao 76px, nền trắng,
      // đường phân cách trên 1px #E9E6F7, nhãn 12px #9A94B8 ---
      // Đích theo task: Trang chủ -> /mh02, Chủ đề -> /mh05,
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
            selectedLabelStyle: kNavLabelStyle,
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
}
