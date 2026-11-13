# API Contract — Phần mềm kiểm tra trắc nghiệm (Omega)

> BẢN NHÁP v1 — soạn ngày 12/11/2026 để nhóm trưởng duyệt trước hạn T03 (12/11 12:00).
> Cập nhật 13/11/2026 (sau báo cáo buổi 2): bỏ đăng ký và đổi mật khẩu — tài khoản cấp theo email sinh viên, đăng nhập bằng Google.
> Nguồn duy nhất: Phần D (chuẩn API/JSON) của `KE_HOACH_DO_AN_OMEGA_TRAC_NGHIEM.md`,
> cộng các trường settings ở mục B3 và quy tắc chống gian lận ở mục B4.
> Sau khi cả nhóm ký (ghi vào biên bản họp 12/11), bản này ĐÓNG BĂNG:
> muốn đổi phải qua nhóm trưởng, sửa file `docs/API_CONTRACT.md` trên GitHub trước
> rồi mới sửa code, và thông báo trong buổi họp cùng ngày.
> Vị trí cuối cùng trên repo: `docs/API_CONTRACT.md`.

## 1. Quy tắc chung (D1)

- `BASE_URL` là hằng số duy nhất, luôn kết thúc bằng `/`. Endpoint không bắt đầu bằng `/`.
  (Ghi chú: kế hoạch ghi `utils/Constants.kt` — đó là tàn dư Kotlin; dự án dùng Flutter
  nên vị trí đúng là file hằng số Dart, ví dụ `lib/core/constants.dart`.)
- Mọi response đúng **một** khuôn:

```json
{ "success": true, "message": "OK", "data": {} }
```

Khi lỗi: `"success": false`, `"data": null`, `message` là thông điệp người dùng đọc được,
kèm `errorCode` (mục 4).
- Tên field JSON: `camelCase`, tiếng Anh, không viết tắt khó hiểu. Mỗi cấu trúc JSON có một
  model tương ứng trong thư mục `models/` của app Flutter, chuyển đổi bằng `fromJson`/`toJson`.
- ID: chuỗi (`String`) thống nhất toàn hệ thống (Firebase dùng document ID dạng chuỗi) —
  client không tự đổi sang `int`.
- Thời gian: ISO 8601 UTC dạng chuỗi (`2026-11-15T08:30:00Z`); điểm: số thập phân 0–10
  (`score: 8.5`); thời lượng làm bài: giây (`durationSeconds: 742`).
- Phân trang danh sách dài: `?page=1&limit=20`, response `data` kèm `items` + `total`.
- Xác thực: sau đăng nhập, server trả `token` (chuỗi). Mọi request sau đó gửi header
  `Authorization: Bearer <token>`. Token hết hạn → `errorCode: UNAUTHORIZED` →
  client tự đăng xuất về màn hình đăng nhập.

## 2. Bảng endpoint chuẩn v1 (D2) — 28 đầu mối

| # | Method & Endpoint | Việc |
|---|---|---|
| 1 | POST `auth/login` | Đăng nhập bằng Google (email sinh viên đã được Admin cấp) |
| 2 | — | ĐÃ BỎ (13/11/2026): đổi mật khẩu — mật khẩu do Google quản lý |
| 3 | — | ĐÃ BỎ (13/11/2026): đăng ký — tài khoản do Admin cấp theo email trường |
| 4 | GET `account/me` | Hồ sơ + rank + XP của tài khoản hiện tại |
| 5 | GET `admin/users` | Danh sách người dùng (Admin) |
| 6 | GET `admin/users/{id}` | Chi tiết người dùng (Admin) |
| 7 | POST `admin/users/{id}/lock` | Khóa / mở khóa tài khoản (Admin) |
| 8 | GET `topics` | Danh sách chủ đề (mỗi chủ đề = một môn học) |
| 9 | POST `topics` · `topics/update` · `topics/delete` | CRUD chủ đề |
| 10 | GET `questions?topicId=` | Câu hỏi theo chủ đề |
| 11 | POST `questions` · `questions/update` · `questions/delete` | CRUD câu hỏi |
| 12 | POST `questions/import-word` | Import từ file Word (multipart, xem mục 5) |
| 13 | GET `exams` | Danh sách bộ đề (kèm settings) |
| 14 | POST `exams` · `exams/update` · `exams/delete` | CRUD bộ đề + cài đặt (mục B3) |
| 15 | GET `exams/{id}/paper` | Lấy đề để làm — đã xáo trộn theo seed, **không kèm đáp án đúng** |
| 16 | POST `attempts/submit` | Nộp bài |
| 17 | GET `attempts/history?accountId=` | Lịch sử làm bài |
| 18 | GET `attempts/{id}/review` | Xem lại bài (server kiểm tra settings có cho xem chưa) |
| 19 | GET `attempts/wrong?accountId=` | Câu đã làm sai để ôn |
| 20 | GET `friends` | Danh sách bạn bè |
| 21 | POST `friends/request` | Gửi lời mời kết bạn |
| 22 | POST `friends/respond` | Chấp nhận / từ chối lời mời kết bạn |
| 23 | POST `battle-rooms` | Tạo phòng thi đấu (2 người hoặc Lobby) |
| 24 | POST `battle-rooms/{code}/join` | Vào phòng thi đấu bằng mã phòng |
| 25 | GET `battle-rooms/{id}` | Trạng thái / kết quả phòng thi đấu |
| 26 | GET `leaderboard` | Bảng xếp hạng toàn hệ thống |
| 27 | POST `admin/seed-demo` | Nạp lại dữ liệu mẫu demo (phục vụ Reset/test) |
| 28 | POST `ai/draft-questions` *(P2 — chỉ khi qua cổng G2 ngày 20/11)* | AI soạn nháp câu hỏi |

## 3. JSON mẫu đầy đủ

### 3.1. Đăng nhập — POST `auth/login`

Request:

```json
{
  "idToken": "<Google ID token sau khi sinh viên chọn tài khoản email trường>"
}
```

Response thành công:

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "token": "<token>",
    "account": {
      "id": "u01",
      "fullName": "Nguyễn Trọng Bảo Uy",
      "email": "0306241504@caothang.edu.vn",
      "role": "USER"
    }
  }
}
```

Đăng nhập bằng email chưa được Admin cấp:

```json
{ "success": false, "message": "Tài khoản chưa được cấp quyền truy cập. Liên hệ Admin để được thêm email.", "data": null, "errorCode": "ACCOUNT_NOT_PROVISIONED" }
```

### 3.2. Cấp tài khoản (không còn đăng ký)

Theo sửa đổi của giảng viên sau báo cáo buổi 2 (13/11/2026): ứng dụng không có
chức năng đăng ký. Admin thêm sinh viên vào hệ thống theo email trường qua nhóm
đầu mối quản trị người dùng (#5–#7; đầu mối tạo tài khoản `POST admin/users` bổ
sung ở bản hợp đồng 1.1). Sinh viên đăng nhập bằng Google theo mục 3.1; email
chưa được cấp trả `ACCOUNT_NOT_PROVISIONED`. Đầu mối số 2 và số 3 giữ trống để
không đổi số thứ tự của các đầu mối còn lại.

### 3.3. Lấy đề để làm — GET `exams/{id}/paper`

Response (đã xáo trộn câu hỏi/đáp án theo seed; **không có** `correctOption`,
**không có** `explanation` — xem mục 6):

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "paper": {
      "exam": {
        "id": "ex01",
        "title": "Kiểm tra Toán cao cấp — Chương 1",
        "topicId": "t01",
        "durationSeconds": 1800,
        "settings": {
          "shuffleQuestions": true,
          "shuffleOptions": true,
          "showScoreAfterSubmit": "IMMEDIATE",
          "showAnswersAfterSubmit": "AFTER_EXAM_CLOSE",
          "maxAttempts": 1,
          "pin": null,
          "lifelinesEnabled": false,
          "antiCheatEnabled": true,
          "allowReview": true,
          "mode": "EXAM"
        }
      },
      "questions": [
        {
          "id": "q01",
          "content": "Thủ đô của Việt Nam là gì?",
          "options": ["TP. Hồ Chí Minh", "Hà Nội", "Đà Nẵng", "Cần Thơ"],
          "difficulty": "EASY",
          "timeSeconds": 30,
          "points": 1.0,
          "hint": "Nằm ở miền Bắc."
        }
      ]
    }
  }
}
```

Ghi chú: trường `settings` theo đúng mục B3 của kế hoạch (xáo trộn câu/đáp án;
hiện điểm ngay hoặc chỉ hiện "Đã nộp"; hiện đáp án ngay / sau khi hết hạn đề /
không bao giờ; số lần làm tối đa; PIN 4–6 số; bật/tắt trợ giúp, chống thoát màn
hình, xem lại bài; chế độ `EXAM` hoặc `REVIEW`).

### 3.4. Nộp bài — POST `attempts/submit`

Request:

```json
{
  "examId": "ex01",
  "answers": [
    { "questionId": "q01", "selectedOption": 1, "answerTimeMs": 8200 },
    { "questionId": "q02", "selectedOption": 0, "answerTimeMs": 15400 }
  ],
  "durationSeconds": 742,
  "violationCount": 0,
  "clientSeed": "a1b2c3"
}
```

Response (mức công bố theo đúng `settings` của bộ đề; ví dụ dưới đây là trường hợp
hiện điểm ngay):

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "result": {
      "attemptId": "at01",
      "score": 8.5,
      "correctCount": 17,
      "totalCount": 20,
      "durationSeconds": 742,
      "violationCount": 0,
      "status": "SUBMITTED"
    }
  }
}
```

- Điểm mỗi câu = điểm gốc của câu hỏi + điểm thưởng tốc độ. **Công thức điểm tốc độ
  chưa chốt trong bản này — chốt trong tài liệu đặc tả T32 (hạn 13/11) rồi bổ sung
  vào đây trước khi code T16.**
- Hết giờ tự nộp hoặc đủ 5 lần thoát màn hình: `status` là `FORCE_SUBMITTED`,
  `violationCount` ghi vào kết quả để giáo viên thấy (mục B4).
- Nộp bài offline: bài làm vào hàng đợi `PENDING_SYNC` trên máy, có mạng lại thì tự
  gửi request này → trạng thái chuyển `SYNCED`. Không bao giờ mất bài vì rớt mạng.

### 3.5. Xem lại bài — GET `attempts/{id}/review`

- Nếu settings cho phép: trả `review` gồm từng câu, đáp án đã chọn, đáp án đúng
  và `explanation`.
- Nếu chưa tới lúc công bố: response lỗi với `errorCode: REVIEW_LOCKED` và thông điệp
  giải thích đúng lý do (hiển thị nguyên văn trên màn hình kết quả).

### 3.6. Các endpoint còn lại — request/response chính

| # | Request chính | Response `data` chính |
|---|---|---|
| 4 | — | `account` + `rankInfo` (rank động vật, XP, điểm xếp hạng) |
| 5–7 | `locked` (cho #7) | List `user` / `user` + thống kê làm bài / `user` |
| 8–9 | `topic` fields | List `topic` / `topic` |
| 10–11 | `question` fields (nội dung, 4 đáp án, đáp án đúng, mức độ, thời gian, điểm, `hint`, `explanation`) | List `question` / `question` |
| 12 | file `.docx` (multipart) | `importedCount`, `errors[{line, reason}]` |
| 13–14 | `exam` + `settings` (mục B3) | List `exam` (kèm settings) / `exam` |
| 17 | — | List `attempt` |
| 19 | — | List `question` (kèm đáp án đúng + giải thích — chế độ Học/Ôn) |
| 20–22 | `targetUserId` (#21); `friendshipId`, `accept` (#22) | List `friend` / `friendship` (status `PENDING` → `ACCEPTED`/`DECLINED`) |
| 23–25 | `examId`, `mode` (#23: `DUEL` hoặc `LOBBY`); `code` (#24) | `room` (`code`, `status`, danh sách người chơi) / `room` / `room` + kết quả từng người |
| 26 | — | List entry (`rank` động vật, điểm xếp hạng, `xp`) |
| 27 | — | `seeded` counts |
| 28 | `topicName`, `count`, `difficulty` | List `question` draft (chưa lưu — Admin duyệt/sửa từng câu mới lưu) |

Điều kiện đối kháng 2 người: cả hai người chơi đều chưa từng trả lời nhóm câu hỏi đó —
nếu vi phạm, server trả `errorCode: SET_ALREADY_ANSWERED`.

## 4. Mã lỗi chuẩn (D3)

`INVALID_INPUT` (dữ liệu sai/thiếu) · `UNAUTHORIZED` (chưa đăng nhập/token hết hạn) ·
`FORBIDDEN` (không đủ quyền) · `NOT_FOUND` · `DUPLICATE_USERNAME` (tên đăng nhập đã
tồn tại) · `ROOM_FULL` (phòng thi đấu đã đủ người) · `SET_ALREADY_ANSWERED` (người chơi
đã trả lời nhóm câu hỏi này — không đủ điều kiện đối kháng) · `EXAM_CLOSED` (đề đã đóng) ·
`PIN_REQUIRED` / `PIN_WRONG` · `ATTEMPT_LIMIT_REACHED` · `REVIEW_LOCKED` (chưa tới lúc
công bố đáp án) · `NETWORK` (client tự sinh khi không gọi được server) · `SERVER_ERROR`.

## 5. Định dạng file Word nhập câu hỏi (D4)

Mỗi câu chiếm một khối, ngăn cách bằng **một dòng trống**. Dòng đáp án đúng bắt đầu
bằng dấu `*`. Dòng `Gợi ý:` và `Giải thích:` là tùy chọn.

```
Câu 1: Thủ đô của Việt Nam là gì?
A. TP. Hồ Chí Minh
*B. Hà Nội
C. Đà Nẵng
D. Cần Thơ
Gợi ý: Nằm ở miền Bắc.
Giải thích: Hà Nội là thủ đô từ năm 1976.
```

Luật parser: khối không đủ 4 đáp án hoặc không có đúng 1 đáp án `*` → **không import
câu đó**, ghi vào danh sách lỗi kèm số dòng để giáo viên sửa. Import xong luôn qua màn
hình **Xem trước** — giáo viên xác nhận mới lưu. (Hỗ trợ `.docx`; file `.doc` cũ thì
hướng dẫn lưu lại thành `.docx`.)

## 6. Nguyên tắc bảo mật đáp án (D5)

Khi phát đề thi (endpoint #15 `GET exams/{id}/paper`), server **không gửi**
`correctOption` và `explanation` xuống máy học viên. Chấm điểm diễn ra khi nộp bài
(endpoint #16). Nhờ vậy học viên không thể đọc lén đáp án trong dữ liệu mạng/bộ nhớ
máy. Ở chế độ Học/Ôn, đáp án được trả về vì mục đích học tập — phân biệt rõ hai luồng
này là một điểm kỹ thuật đáng thuyết trình.

## 7. Điểm cần chốt trước khi đóng băng (mở — nhóm quyết ở họp 12/11)

1. **Số lượng endpoint: 28 hay 29?** Bảng D2 trong kế hoạch liệt kê 28 đầu mối
   (đánh số 1–28). File phân công (T03) ghi "29 endpoint" — hai tài liệu lệch nhau 1.
   Bản nháp này theo bảng D2 (28). Cần đối chiếu: có endpoint nào bị sót khỏi bảng D2
   không (ví dụ endpoint riêng cho đổi mật khẩu lần đầu, hoặc tách `topics/update`
   thành endpoint riêng)?
2. **Vị trí hằng số BASE_URL:** kế hoạch ghi `utils/Constants.kt` (Kotlin) trong khi
   dự án dùng Flutter/Dart + MVVM (mục F1). Bản nháp này ghi file hằng số Dart.
   Cần chốt tên file/thư mục theo cấu trúc `views/ → viewmodels/ → repositories/ →
   services/ → local/` ở mục F1.
3. **Đánh số trong mục D5 của kế hoạch:** D5 ghi "endpoint 19" (phát đề) và
   "endpoint 20" (nộp bài), nhưng theo bảng D2 thì phát đề là #15 và nộp bài là #16.
   Bản nháp này dùng số đúng theo bảng D2; kế hoạch cần sửa D5 cho khớp.
4. **Công thức điểm tốc độ:** chưa có — chốt trong T32 (SRS, hạn 13/11) rồi bổ sung
   vào mục 3.4 trước khi code T16. Không tự chế công thức trong bản contract này.
5. **Cơ chế tài khoản — ĐÃ CHỐT (13/11/2026):** giảng viên yêu cầu bỏ tự đăng ký
   sau báo cáo buổi 2. Contract này đã sửa theo: đăng nhập bằng Google (#1), bỏ
   đổi mật khẩu (#2) và đăng ký (#3); mục E6 của kế hoạch (không có nút Đăng ký)
   đúng với cơ chế mới.
