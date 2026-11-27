# PHÂN CHIA CODE GIAO DIỆN (chỉ giao diện, chưa chức năng)

Căn cứ: file Figma "Omega Quiz — UI MVP" do Danh vẽ — đã kiểm tra ngày 22/11/2026: đủ **37 màn hình** (MH-01…MH-33 cộng 4 biến thể trạng thái MH-06b, MH-09b, MH-12b, MH-19b), mỗi màn hình có cả bản wireframe xám và mockup màu, kèm 10 board luồng L1–L10 đã nối mũi tên.
Phạm vi giai đoạn này: dựng đúng bố cục theo Figma + điều hướng chạy được + dữ liệu giả. Chưa nối API/chức năng. Mọi người tuân thủ QUY_TAC_CODE_GIAO_DIEN.md.
Nguyên tắc chia: theo cụm chức năng khớp task chức năng của từng người (sau này tự nối logic phần mình đã dựng); các biến thể "b" đi cùng màn hình gốc; cân bằng số lượng và độ nặng.

## Uy — 8 màn hình + hạ tầng chung
MH-01 Đăng nhập · MH-03 Hồ sơ cá nhân · MH-16 Đối kháng 1-1 · MH-21 Quản lý thành viên · MH-25 Tạo/Sửa bộ đề · MH-26 Cài đặt bộ đề · MH-28 Danh sách gói · MH-29 Gói của tôi.
Hạ tầng chung (không tính vào số màn hình): khung điều hướng (thanh dưới 5 mục + thanh trên), `lib/routes.dart`, hoàn thiện `lib/core/app_theme.dart`, các widget nền dùng chung đầu tiên (nút chính, banner cảnh báo, trạng thái đang tải).

## Danh — 10 màn hình
MH-02 Trang chủ · MH-04 Tìm kiếm · MH-09 Làm bài · MH-09b Hộp thoại nộp bài · MH-10 Kết quả bài làm · MH-11 Xem lại bài · MH-14 Bảng xếp hạng · MH-15 Bạn bè · MH-17 Đợt thi khung giờ · MH-18 Kết quả đợt thi.

## Thịnh — 10 màn hình
MH-05 Chủ đề công khai · MH-06 Chi tiết chủ đề · MH-06b Chi tiết chủ đề (chỉ-đọc) · MH-07 Danh sách bộ đề · MH-08 Chi tiết bộ đề · MH-12 Lịch sử làm bài · MH-12b Lịch sử (rỗng) · MH-13 Ôn tập câu sai · MH-19 Yêu thích · MH-19b Yêu thích (rỗng).

## Đỉnh — 9 màn hình
MH-20 Tạo/Sửa chủ đề · MH-22 Quản lý câu hỏi · MH-23 Soạn/Sửa câu hỏi · MH-24 Import Excel · MH-27 Thống kê chủ đề · MH-30 Admin: Tài khoản · MH-31 Admin: Chi tiết tài khoản · MH-32 Admin: Gói và hạn mức · MH-33 Admin: Thống kê.

## Điều phối
- Widget dùng chung nào xuất hiện trong phần của nhiều người: người gặp đầu tiên tạo vào `lib/widgets/` và báo trong Discord; người sau dùng lại, không tạo bản sao.
- Thứ tự làm: hạ tầng chung (Uy) xong trước để mọi người có khung điều hướng; sau đó mỗi người làm theo thứ tự tầng ưu tiên của cụm mình (màn hình thuộc Tầng 0–1 trước).
- Nghiệm thu: theo checklist ở cuối QUY_TAC_CODE_GIAO_DIEN.md — PR có giải thích 5 dòng + ảnh chụp + video điều hướng; nhóm trưởng kiểm tra đối chiếu Figma.

## Chốt bổ sung ngày 27/11/2026 (nhóm trưởng)
- **MH-15 Bạn bè**: Danh dựng giao diện ban đầu, nhưng phần chức năng T16 (Bạn bè) do **Thịnh** phụ trách — khi nối API và quay video bằng chứng, MH-15 do Thịnh giữ và được quyền sửa.
- **MH-20 Tạo/Sửa chủ đề**: **Đỉnh** phụ trách giao diện + điều hướng; **Thịnh** phụ trách phần nối API của MH-20 (thuộc T17 Chủ đề) nên được quyền sửa file MH-20 ở phần logic/API. Hai người phối hợp khi cần đổi cả giao diện lẫn API.
