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

Khi nối Firebase: cài `firebase-admin`, thay hàm `verifyToken()` trong
`src/auth.js` bằng `verifyIdToken()` — các route không phải sửa.

## Dữ liệu

Dữ liệu nằm trong bộ nhớ (`src/store.js`), mô phỏng 17 collection của
Firestore theo ERD: users, plans, subscriptions, topics, topic_members,
invitations, questions, exams, exam_questions, attempts, friendships,
battle_rooms, contests, contest_entries, reviews, favorites, comments.
Khởi động lại server là dữ liệu về trạng thái mẫu ban đầu; gọi
`POST /api/dev/reset` để reset mà không cần khởi động lại (nút Reset dữ
liệu kiểm thử trong app gọi endpoint này).

Dữ liệu mẫu gồm: 2 chủ đề công khai (Toán cao cấp, Tiếng Anh — mỗi chủ đề
12 câu), 1 bộ đề "Giữa kỳ — Đạo hàm" (10 câu), 5 gói thuê (giá theo
mockup Figma MH-28: 49.000đ / 129.000đ / 449.000đ).

Khi chuyển sang Firestore thật, chỉ thay `src/store.js` bằng lớp đọc/ghi
Firestore giữ nguyên giao diện Map; các route giữ nguyên.

## Cấu trúc

- `src/server.js` — điểm vào, gắn router, xử lý lỗi tập trung đúng khuôn hợp đồng
- `src/store.js` — kho dữ liệu trong bộ nhớ + dữ liệu mẫu + reset
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
- Đối kháng 1-1: API lo tạo phòng/rút câu/chấm/tổng kết điểm rank; tiến
  trình đối thủ thời gian thực app nghe qua Firestore `battle_rooms`
  khi nối Firebase (hợp đồng mục 2.6).
