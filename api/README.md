# Omega Quiz API

Web API cho app Omega Quiz, hiện thực theo hợp đồng `docs/API_CONTRACT.md` (bản v2, UC01–UC28).

## Chạy thử

```
npm install
npm start
```

Server chạy tại `http://localhost:3000/api/`. Kiểm tra nhanh: mở
`http://localhost:3000/api/health` hoặc `GET /api/plans`.

App Flutter trỏ vào API bằng hằng số `baseUrl` trong `lib/core/constants.dart`
(mặc định `http://localhost:3000/api/` — khi chạy máy ảo Android, đổi thành
`http://10.0.2.2:3000/api/` để máy ảo gọi ra máy thật).

## Xác thực khi phát triển

Chưa nối Firebase Auth thật. Mọi request cần header:

```
Authorization: Bearer dev:<uid>
```

Các uid có sẵn trong dữ liệu mẫu: `dev:admin` (Admin nền tảng), `dev:uy`,
`dev:dinh`, `dev:danh`, `dev:thinh`. Tài khoản chưa có thì gọi
`POST /api/auth/login` với token `dev:<uid mới>` kèm body `{name, email}`
để tạo hồ sơ + kích hoạt dùng thử 7 ngày.

Khi server đã nối Firebase (có biến `FIREBASE_SERVICE_ACCOUNT`), API còn
chấp nhận token Firebase Auth thật qua `verifyIdToken()` — song song với
token dev. Xem `huong-dan-noi-firebase.md`.

## Dữ liệu

Firestore là nơi lưu trữ chính. Lớp truy cập dữ liệu nằm ở `src/store.js`
(hàm `repo`: get/has/all/entries/put/del/count — tất cả đều async), gồm
17 collection theo ERD: users, plans, subscriptions, topics, topicMembers,
invitations, questions, exams, examQuestions, attempts, friendships,
battleRooms, contests, contestEntries, reviews, favorites, comments.

- Có khóa dịch vụ (biến `FIREBASE_SERVICE_ACCOUNT`): mọi thao tác đọc/ghi
  đi thẳng xuống Firestore. Lần chạy đầu, collection nào đang trống sẽ
  được nạp dữ liệu mẫu.
- Không có khóa: chạy bằng bộ nhớ + dữ liệu mẫu như bản dev (khởi động lại
  là về trạng thái mẫu) — dùng để test ở máy chưa có khóa.

Gọi `POST /api/dev/reset` để reset về dữ liệu mẫu mà không cần khởi động
lại (nút Reset dữ liệu kiểm thử trong app gọi endpoint này); ở chế độ
Firestore, reset xóa sạch 17 collection rồi nạp lại dữ liệu mẫu.

Dữ liệu mẫu gồm: 2 chủ đề công khai (Toán cao cấp — 72 câu gồm 60 câu ngân
hàng T32; Tiếng Anh — 12 câu), 1 bộ đề "Giữa kỳ — Đạo hàm" (10 câu),
5 gói thuê (giá theo mockup Figma MH-28: 49.000đ / 129.000đ / 449.000đ).

Cách nối Firebase, lấy khóa và kiểm chứng: xem `huong-dan-noi-firebase.md`.

## Cấu trúc

- `src/server.js` — điểm vào, gắn router, xử lý lỗi tập trung đúng khuôn hợp đồng
- `src/store.js` — lớp lưu trữ (Firestore thật / bộ nhớ) + dữ liệu mẫu + reset
- `src/auth.js` — xác thực, kiểm tra hạn mức ở máy chủ, quyền chủ sở hữu
- `src/util.js` — khuôn response, mã lỗi, Fisher–Yates, bảng hạng con vật
- `src/routes/` — auth (UC01–03), topics (UC04–08), questions (UC09–10),
  exams (UC11–12, yêu thích), attempts (UC13–18), social (UC19–24), admin (UC25–28)

## Vòng đời gói thuê và điểm đợt thi (đã hiện thực theo Đợt 2)

- Gói hết hạn → 7 ngày cảnh báo, vẫn full quyền (`lifecycleState: WARNING`
  ở `GET /api/me/subscription`, `warningDaysLeft` đếm ngược đến ngày xóa).
  Qua 7 ngày: chủ đề private của chủ sở hữu bị xóa, chủ đề public chuyển
  chỉ-đọc (`ownerExpired` — chủ sở hữu không sửa được nữa, cộng đồng vẫn
  xem và làm bài). Xử lý lazy trong `src/auth.js`, chạy một lần mỗi đợt.
- Đợt thi hết giờ: lần đầu lấy `GET /api/contests/{id}/results` sẽ xếp
  hạng và cộng điểm rank một lần duy nhất (top 1 +20, hạng 2–3 +10, còn
  lại +2 cho người đã nộp bài), response có thêm `rankDelta` từng người.
- Import Excel: file có dòng lỗi trả HTTP 422 `IMPORT_HAS_ERRORS` kèm
  chi tiết theo dòng trong `data`; `previewToken` vẫn dùng để xác nhận
  lưu các câu hợp lệ.
- Chủ đề private: người ngoài không xem được ngân hàng câu hỏi, danh
  sách bộ đề, không bắt đầu làm bài hay vào đợt thi được (403).

## Điểm cần nhớ khi dùng

- Phát đề không bao giờ chứa `correctOption`/`explanation` (luật cứng của
  hợp đồng) — đã kiểm chứng ở endpoint bắt đầu lượt làm và vào đợt thi.
- Thưởng tốc độ khi chấm: nếu lượt nộp gửi `timeSpentSeconds` cho từng
  câu thì tính đúng công thức Đợt 2 theo từng câu (điểm câu × 0,5 × thời
  gian còn lại / thời gian quy định của câu); không gửi thì lui về tỷ lệ
  tổng thời gian. Hàm `grade()` trong `src/routes/attempts.js`.
- Đối kháng 1-1: API lo tạo phòng/rút câu/chấm/tổng kết điểm rank; app
  đọc trạng thái phòng và tiến trình đối thủ qua `GET /battles/{id}`
  (hợp đồng mục 2.6) — app không đọc Firestore trực tiếp.
