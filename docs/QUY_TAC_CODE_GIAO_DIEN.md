# QUY TẮC CODE GIAO DIỆN (chỉ giao diện, chưa chức năng)

Giai đoạn này mỗi thành viên hiện thực phần giao diện được chia bằng Flutter: bố cục đúng Figma, điều hướng chạy được giữa các màn hình, dữ liệu hiển thị là DỮ LIỆU GIẢ. Chưa nối API, chưa xử lý logic thật. Mục tiêu kép: (1) giao diện xong nhanh để ghép luồng; (2) **mọi thành viên phải hiểu rõ code giao diện của chính mình** — khi giảng viên hỏi, mỗi người tự trình bày được phần mình làm.

## 1. Cấu trúc bắt buộc
1. Mỗi màn hình là **một file riêng**: `lib/views/<maMH>_<ten>_screen.dart` (ví dụ `mh09_lam_bai_screen.dart`). Không gộp nhiều màn hình vào một file.
2. Đầu mỗi file màn hình bắt buộc có khối chú thích theo mẫu cố định:
   - Mã MH + tên màn hình (khớp DANH_SACH_MAN_HINH_DOT4.md)
   - Thuộc luồng nào (L1–L10 trong LUONG_HOAT_DONG_APP.md)
   - Vào màn hình này từ đâu, thao tác nào đưa tới
   - Từ màn hình này đi tiếp tới những màn hình nào
   - Dữ liệu giả đang dùng nằm ở đâu
   - Chức năng thật sẽ nối ở task nào (ghi "để giai đoạn chức năng")
3. Điều hướng khai báo tập trung trong `lib/routes.dart`, route name theo mã MH (ví dụ `/mh09`). Màn hình không tự ý đặt tên route riêng.

## 2. Thành phần dùng chung — không copy-paste
1. Màu sắc, font, bo góc, khoảng cách: chỉ lấy từ `lib/core/app_theme.dart` và hằng số chung. Cấm tự gõ mã màu trong từng màn hình (4 màu đáp án A/B/C/D cũng đã có hằng số).
2. Khối giao diện nào xuất hiện từ 2 màn hình trở lên thì tách thành **widget dùng chung** trong `lib/widgets/`, một widget một file, tên file `<ten>_widget.dart`. Danh sách widget chung dự kiến: nút chính, thẻ chủ đề, thẻ bộ đề, ô đáp án, thanh tiến trình làm bài, đồng hồ đếm ngược, hộp xác nhận nộp bài, banner cảnh báo hết hạn, trạng thái rỗng, trạng thái đang tải, mục bị khóa (disabled) cho chức năng đã lọc.
3. Tên widget trong code phải trùng tên gọi trong Figma/tài liệu luồng (ví dụ AnswerOptionCard, ProgressHeader) để đối chiếu 1-1 giữa bản vẽ và code.
4. Khối nào dài trên ~50 dòng hoặc lặp lại trong cùng màn hình thì tách thành widget con có tên rõ nghĩa — không để cây widget lồng nhau vô danh quá sâu.

## 3. Dữ liệu giả
1. Dữ liệu giả đặt trong file `<maMH>_<ten>_mock.dart` cùng thư mục views hoặc ngay đầu file màn hình, luôn ghi chú `// MOCK:` ở dòng đầu khối dữ liệu.
2. Mỗi màn hình phải **tự chạy độc lập được bằng dữ liệu giả**, không chờ màn hình của người khác làm xong.
3. Dữ liệu giả phải giống dữ liệu thật về hình thức (đủ dài, có trường hợp rỗng/dài bất thường) để lộ lỗi bố cục sớm.

## 4. Quy tắc HIỂU code của mình (bắt buộc)
1. Chỉ nộp code do mình hiểu: nếu dùng đoạn code có sẵn hoặc được hỗ trợ viết, phải đọc lại và tự sửa được tên biến/cấu trúc theo quy ước trước khi nộp.
2. Mỗi pull request (PR) kèm **bản giải thích 5 dòng** của chính người làm: màn hình gồm những khối nào; khối nào là widget dùng chung; bấm vào đâu thì đi tới màn hình nào; dữ liệu giả lấy ở đâu; phần nào đang chờ nối chức năng.
3. Review chéo: người review đọc code mà không chỉ được "màn hình này có những khối nào, dữ liệu giả ở đâu, điều hướng đi đâu" thì PR bị trả lại để bổ sung chú thích/đặt lại tên.
4. Kiểm tra hiểu bài ngẫu nhiên trong giờ Discord 15:00–18:00: nhóm trưởng có thể hỏi bất kỳ ai về một màn hình của chính họ (khối nào vẽ phần nào, vì sao tách widget đó) — trả lời được mới tính là hoàn thành.
5. Ảnh chụp màn hình thật (máy ảo hoặc điện thoại) + video ngắn bấm chuyển qua các màn hình của mình đính kèm PR làm bằng chứng.

## 5. Checklist tự kiểm trước khi nộp
- [ ] File đúng tên, đúng thư mục, có đủ khối chú thích đầu file.
- [ ] Không có mã màu/kích thước tự gõ ngoài theme và hằng số.
- [ ] Khối lặp đã tách widget dùng chung, tên khớp Figma.
- [ ] Chạy độc lập bằng dữ liệu giả, điều hướng tới/lui đúng luồng.
- [ ] Màn hình giống Figma (tỷ lệ, thứ tự khối, trạng thái disabled nếu có).
- [ ] PR có bản giải thích 5 dòng + ảnh chụp + video điều hướng.

## 6. Chốt bổ sung ngày 27/11/2026 — quy tắc giai đoạn nối API và gộp code (nhóm trưởng)
1. Phần code giao diện/chức năng **đã merge vào main thì giữ nguyên**, không ai phải viết lại cho khớp toàn bộ quy tắc ở mục 1–5 (các mục đó áp cho giai đoạn dựng giao diện).
2. **File mới viết từ 27/11/2026** vẫn phải: có khối chú thích đầu file theo mẫu ở mục 1; màu/kích thước lấy từ `app_theme.dart`, không gõ thêm mã màu trực tiếp trong file.
3. Khi gộp code vào app chính, **mọi màn hình phải đăng ký vào `lib/routes.dart` của main** và điều hướng qua route đã đăng ký; trong giai đoạn làm riêng trên nhánh cá nhân thì điều hướng trực tiếp tạm chấp nhận.
4. ViewModel theo khung MVVM rút gọn của repo là khuyến khích cho màn hình mới; **không bắt buộc hồi tố** với code đã merge (model + service theo chức năng như hiện tại vẫn được chấp nhận).

## Mục 8. Icon rank — chuẩn thống nhất (chốt 28/11/2026)

1. File icon rank để ở `assets/icons/rank/`, tên dạng `rank_<tên không dấu>.png` (bộ icon T12: chuot, meo, cho, heo, ngua, gau, ho, sutu, voi, cavoi). Không đặt file icon rank ở thư mục khác.
2. Màn hình lấy icon qua hàm `iconRank(animal)` trong `lib/utils/rank_helper.dart` — KHÔNG ghi đường dẫn file cứng trong từng màn hình. Cần thêm/sửa ánh xạ con vật → file thì sửa ở rank_helper.dart.
3. Kiểu hiển thị rank thống nhất: "Hạng <icon>" + điểm (chốt 27/11/2026), không ghi tên con vật dạng chữ cạnh icon.
