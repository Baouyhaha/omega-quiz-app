import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../core/dinh_api.dart';
import '../core/dinh_theme.dart';

// ============================================================================
// Mã MH: MH-24 — Import Excel
// Tên màn hình: Import Excel (frame Figma: MH-24-import-excel,
// node 83-1523, khung 412 x 917, trang "Mockup màu").
// Thuộc luồng: L4 — Chủ sở hữu (Flow boards, flow-L4-chu-so-huu).
// Vào màn hình này từ đâu:
//   - Từ MH-22 Quản lý câu hỏi, bấm "Import Excel".
// Từ màn hình này đi tiếp tới những màn hình nào:
//   - Bấm "Xác nhận nhập N câu" -> luu cac cau hop le qua API (#21)
//     roi quay ve MH-22 (pop true de MH-22 tai lai danh sach).
//   - Nút quay lại "<" -> quay về màn hình trước.
//   - Bottom nav (đích theo task):
//     Trang chủ -> MH-02, Chủ đề -> MH-05, Thi đấu -> MH-17,
//     Xếp hạng -> MH-14, Hồ sơ -> MH-03.
//   - Nút "Chọn file khác" mo hop chon file .xlsx that.
// Dữ liệu đang dùng ở đâu:
//   - API that cua Uy: #20 import (upload file, tra xem truoc + loi theo
//     dong + previewToken), #21 confirm (luu cac cau hop le).
//   - File mock mh24_import_excel_mock.dart chi con de tham chieu giao dien
//     goc theo task, man hinh nay khong dung mock nua.
// Chức năng thật nối ở task nào:
//   - T19 buoc 3: man hinh Xem truoc > xac nhan > goi API nhap cau hoi de
//     luu, bao so cau da nhap / so cau loi. Kien truc: app goi API, API
//     moi qua Firebase.
//   - Luu y: #20 tra 422 khi file co loi nhung data van dung duoc
//     (previewToken de xac nhan luu cac cau hop le) — xem importQuestions
//     trong dinh_api.dart.
//   - Phu thuoc moi: file_picker ^13.0.0 (them vao pubspec.yaml roi chay
//     flutter pub get) de chon file .xlsx that tren may. Ban 8.x tu ghi
//     cung compileSdk 34 trong file build cua no nen bi loi AAR; ban
//     13.x doc theo gia tri mac dinh cua Flutter 3.50.0 (36) nen het
//     loi, khong can doi compileSdk cua app. API 13.x: FilePicker.
//     pickFiles() tra thang List<PlatformFile> (rong = huy chon),
//     doc bytes bang file.readAsBytes(), khong con FilePicker.platform
//     hay withData nhu ban cu.
//   - topicId mac dinh 'topic_anh' (chu de Tieng Anh cua Dinh) — giong
//     MH-22/MH-23 o T18. Vao tu MH-22 thi truyen topicId that qua route.
//
// SỐ ĐO: theo task MH-24, xem bảng đầy đủ trong mh24_figma_tokens.md.
// Font Nunito, nền #F6F4FF, tím #6C4CF1, chữ #1D1B2E, thẻ file
// 372x104, thanh tiến trình 372x8, dòng xem trước 372x56,
// hộp lỗi 372x64 nền #FFE9E9, nút xác nhận 372x52 tím,
// thanh điều hướng dưới 412x76 (không mục nào được chọn theo task).
// Bo góc không hiển thị trong Properties nên đang dùng tạm 16px
// như MH-20/22/23; riêng thanh tiến trình 8px dùng bo 4px.
// ============================================================================

/// Màn hình MH-24: nhập câu hỏi từ file Excel, xem trước từng dòng,
/// xem lỗi theo dòng rồi xác nhận nhập các câu hợp lệ.
class Mh24ImportExcelScreen extends StatefulWidget {
  const Mh24ImportExcelScreen({super.key, this.topicId = 'topic_anh'});

  /// Chu de se nhap cau hoi vao (mac dinh chu de Tieng Anh cua Dinh).
  final String topicId;

  @override
  State<Mh24ImportExcelScreen> createState() =>
      _Mh24ImportExcelScreenState();
}

class _Mh24ImportExcelScreenState extends State<Mh24ImportExcelScreen> {
  // Tab đang chọn ở thanh điều hướng dưới. -1 = chưa mục nào được
  // chọn, đúng như task (cả 5 mục đều xám #9A94B8 lúc mở màn).
  int _selectedIndex = -1;

  /// Ten file .xlsx da chon (null = chua chon file).
  String? _fileName;

  /// Ket qua #20 sau khi upload (null = chua upload xong).
  ImportResult? _result;

  /// true = dang upload + cho server doc file.
  bool _uploading = false;

  /// true = dang goi #21 xac nhan luu.
  bool _confirming = false;

  /// Chon file .xlsx that roi upload ngay qua #20.
  Future<void> _pickAndUpload() async {
    // file_picker 13.x: FilePicker.pickFiles tra thang List<PlatformFile>
    // (danh sach rong = nguoi dung huy chon file), khong con
    // FilePicker.platform hay withData; doc bytes bang readAsBytes().
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (files.isEmpty) return;
    final file = files.single;
    late final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không đọc được file đã chọn')),
      );
      return;
    }
    setState(() {
      _fileName = file.name;
      _uploading = true;
      _result = null;
    });
    try {
      final result = await DinhApi.importQuestions(
        widget.topicId,
        bytes,
        file.name,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _uploading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  /// Goi #21 luu cac cau hop le, bao so cau da luu roi ve MH-22.
  Future<void> _confirm() async {
    final result = _result;
    if (result == null || result.validCount == 0 || _confirming) return;
    setState(() {
      _confirming = true;
    });
    try {
      final saved = await DinhApi.confirmImport(
        widget.topicId,
        result.previewToken,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu $saved câu hỏi')),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _confirming = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    // Dong xem truoc: cac cau hop le (tick xanh) + moi dong loi (X do).
    final previewRows = <({String label, String preview, bool valid})>[
      if (result != null)
        for (var i = 0; i < result.preview.length; i++)
          (
            label: 'Câu ${i + 1}',
            preview: result.preview[i].content,
            valid: true,
          ),
      if (result != null)
        for (final err in result.errors)
          (
            label: 'Dòng ${err.line}',
            preview: err.messages.join('; '),
            valid: false,
          ),
    ];

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
                    // Quay về màn hình trước đó.
                    onTap: () => Navigator.pop(context),
                    child: const Text('‹', style: kBackStyle),
                  ),
                  const SizedBox(width: 22),
                  const Text('Import Excel', style: kPageTitleStyle),
                ],
              ),
            ),

            // --- Nội dung: cuộn được nếu màn hình nhỏ ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpacing20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Đáy tiêu đề -> thẻ file: 35px theo task,
                    // trừ 12px padding dưới của header còn 23px.
                    const SizedBox(height: 23),
                    _SelectedFileCard(
                      fileName: _fileName,
                      onPick: _uploading ? null : _pickAndUpload,
                    ),
                    // Thẻ file -> dòng tiến trình: 17px theo task.
                    const SizedBox(height: 17),
                    if (_uploading) ...[
                      const Text(
                        'Đang đọc file...',
                        style: kWarningTextStyle,
                      ),
                      // Dòng chữ -> thanh tiến trình: 7px theo task.
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          minHeight: kProgressBarHeight,
                          backgroundColor: kProgressTrackBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            kPrimary,
                          ),
                        ),
                      ),
                    ] else if (result != null) ...[
                      const Text(
                        'Đã đọc xong file',
                        style: kWarningTextStyle,
                      ),
                      const SizedBox(height: 7),
                      Container(
                        width: double.infinity,
                        height: kProgressBarHeight,
                        decoration: BoxDecoration(
                          color: kProgressTrackBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: kPrimary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Thanh tiến trình -> tiêu đề "Xem trước": 12px.
                    if (result != null) ...[
                      const SizedBox(height: 12),
                      const Text('Xem trước', style: kHeadingStyle),
                      // Tiêu đề -> dòng xem trước đầu tiên: 5px.
                      const SizedBox(height: 5),

                      // Dong xem truoc, dong cach nhau 10px theo task.
                      ...previewRows.map(
                        (row) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PreviewRow(
                            label: row.label,
                            preview: row.preview,
                            valid: row.valid,
                          ),
                        ),
                      ),
                      // Dòng cuối -> tiêu đề "Lỗi theo dòng": 16px,
                      // trừ 10px padding dưới của dòng cuối còn 6px.
                      const SizedBox(height: 6),
                      if (result.errors.isNotEmpty) ...[
                        const Text('Lỗi theo dòng', style: kHeadingStyle),
                        // Tiêu đề -> hộp lỗi: 5px theo task.
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 13, 16, 11),
                          decoration: BoxDecoration(
                            color: kHardBackground,
                            borderRadius:
                                BorderRadius.circular(kRadiusItem),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0;
                                  i < result.errors.length;
                                  i++) ...[
                                if (i > 0) const SizedBox(height: 4),
                                Text(
                                  result.errors[i].display,
                                  style: kErrorTextStyle,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Hộp lỗi -> dòng tổng kết: 20px theo task.
                        const SizedBox(height: 20),
                      ] else
                        const SizedBox(height: 20),
                      Center(
                        child: Text(
                          '${result.validCount}/'
                          '${result.totalCount} câu hợp lệ',
                          style: kHeadingStyle,
                        ),
                      ),
                      // Dòng tổng kết -> nút xác nhận: 106px theo task.
                      const SizedBox(height: 106),
                      SizedBox(
                        width: double.infinity,
                        height: kButtonHeight,
                        child: ElevatedButton(
                          onPressed: result.validCount == 0 || _confirming
                              ? null
                              : _confirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: kOnPrimary,
                            disabledBackgroundColor:
                                kPrimary.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                kRadiusButton,
                              ),
                            ),
                          ),
                          child: Text(
                            _confirming
                                ? 'Đang lưu...'
                                : 'Xác nhận nhập '
                                    '${result.validCount} câu',
                            style: kButtonTextStyle,
                          ),
                        ),
                      ),
                      // Nút xác nhận -> thanh điều hướng: 20px theo task.
                      const SizedBox(height: 20),
                    ] else if (!_uploading) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Chọn file .xlsx để xem trước nội dung '
                        'và lỗi theo dòng.',
                        style: kWarningTextStyle,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // --- Thanh điều hướng dưới: cao 76px, nền trắng,
      // đường phân cách trên 1px #E9E6F7, nhãn 12px #9A94B8 ---
      // Đích theo task: Trang chủ -> MH-02, Chủ đề -> MH-05,
      // Thi đấu -> MH-17, Xếp hạng -> MH-14, Hồ sơ -> MH-03.
      // Các màn đó chưa làm xong nên onTap hiện chỉ đổi tab đang chọn.
      // Khi các màn đó xong, thay bằng Navigator.pushNamed tương ứng.
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(
            top: BorderSide(color: kInputBorder, width: 1),
          ),
        ),
        height: 76,
        child: Row(
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Trang chủ'),
            _buildNavItem(1, Icons.layers_outlined, 'Chủ đề'),
            _buildNavItem(2, Icons.emoji_events_outlined, 'Thi đấu'),
            _buildNavItem(3, Icons.bar_chart_outlined, 'Xếp hạng'),
            _buildNavItem(4, Icons.person_outline, 'Hồ sơ'),
          ],
        ),
      ),
    );
  }

  /// Một mục ở thanh điều hướng dưới. Lúc mở màn chưa mục nào
  /// được chọn theo task (tất cả xám); bấm vào thì mục đó tím lên.
  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool selected = _selectedIndex == index;
    final Color color = selected ? kPrimary : kNavUnselected;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: kNavLabelStyle.copyWith(
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thẻ file đã chọn 372x104 theo task: nhãn "Đã chọn:", tên file,
/// nút "Chọn file khác" (mo hop chon file .xlsx that).
/// Chua chon file thi hien "Chưa chọn file" + nut "Chọn file".
/// Chỉ dùng ở MH-24 nên để trong file này.
class _SelectedFileCard extends StatelessWidget {
  const _SelectedFileCard({required this.fileName, required this.onPick});

  final String? fileName;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return Container(
      width: double.infinity,
      height: kFileCardHeight,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 10),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasFile ? 'Đã chọn:' : 'Chưa chọn file:',
            style: kLabelStyle,
          ),
          const SizedBox(height: 4),
          Text(
            fileName ?? 'Chưa có file nào được chọn',
            style: kFieldTextStyle.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: 160,
            height: 32,
            child: OutlinedButton(
              onPressed: onPick,
              style: OutlinedButton.styleFrom(
                backgroundColor: kSurface,
                side: const BorderSide(color: kPrimary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kRadiusButton),
                ),
              ),
              child: Text(
                hasFile ? 'Chọn file khác' : 'Chọn file',
                style: kChooseFileTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Một dòng xem trước 372x56 theo task: vòng tròn trạng thái
/// (tick xanh khi hợp lệ, X đỏ khi lỗi), nội dung dòng, nhãn
/// trạng thái ở mép phải. Chỉ dùng ở MH-24 nên để trong file này.
class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.preview,
    required this.valid,
  });

  final String label;
  final String preview;
  final bool valid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: kPreviewRowHeight,
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kInputBorder, width: 1),
        borderRadius: BorderRadius.circular(kRadiusItem),
      ),
      child: Row(
        children: [
          // Vòng tròn trạng thái 24x24.
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: valid ? kEasy : kHard,
              shape: BoxShape.circle,
            ),
            child: Icon(
              valid ? Icons.check : Icons.close,
              size: 14,
              color: kOnPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label — $preview',
              style: kFieldTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            valid ? 'Hợp lệ' : 'Lỗi',
            style: kDifficultyLabelStyle.copyWith(
              color: valid ? kEasy : kHard,
            ),
          ),
        ],
      ),
    );
  }
}
