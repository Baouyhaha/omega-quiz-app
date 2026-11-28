# API Contract — Phần mềm kiểm tra trắc nghiệm (Omega)

> **BẢN v2 — viết lại ngày 20/11/2026 theo mô hình mới sau họp buổi 3** (thay thế toàn bộ v1.1).
> Mô hình áp dụng: 4 vai trò (Người dùng / Người dùng thuê bao / Chủ sở hữu chủ đề / Admin nền tảng),
> 28 use case UC01–UC28, ERD 17 thực thể. Mọi thay đổi hợp đồng phải qua nhóm trưởng,
> sửa file này trên GitHub trước rồi mới sửa code.

## 1. Quy tắc chung

- `BASE_URL` là hằng số duy nhất trong `lib/core/constants.dart`, luôn kết thúc bằng `/`. Endpoint không bắt đầu bằng `/`.
- Xác thực: app đăng nhập bằng Firebase Auth (Google) và gửi kèm mọi request header
  `Authorization: Bearer <Firebase ID token>`. API xác thực token, lấy `uid` làm định danh người dùng.
- Mọi response đúng một khuôn:

```json
{ "success": true, "message": "OK", "data": {} }
```

Khi lỗi: `"success": false`, `"data": null`, `message` là thông điệp người dùng đọc được, kèm `errorCode` (mục 4).
- Tên field JSON: `camelCase`, tiếng Anh. ID: chuỗi (`String`) toàn hệ thống. Thời gian: ISO 8601 UTC.
- **Luật cứng khi phát đề: response phát câu hỏi KHÔNG chứa `correctOption` và `explanation`.** Chấm điểm chỉ diễn ra ở máy chủ.
- **Kiểm tra hạn mức ở máy chủ** trước mọi thao tác tạo (chủ đề, bộ đề, thành viên): vượt hạn mức thì trả lỗi `LIMIT_EXCEEDED`.
- Kiểm tra quyền theo phạm vi: thao tác quản lý trong một chủ đề chỉ dành cho chủ sở hữu của chủ đề đó; endpoint `/admin/...` chỉ dành cho Admin nền tảng.

## 2. Danh mục endpoint

### 2.1 Tài khoản và hồ sơ (UC01, UC03)
| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `auth/login` | Gửi ID token; tạo hồ sơ lần đầu (users + gói dùng thử 7 ngày), trả hồ sơ + trạng thái gói |
| GET | `me` | Hồ sơ của tôi: tên, ảnh, rankScore, hạng con vật, điểm trung bình, gói hiện tại, `attemptCount` (số lượt đã làm), `friendCount` (số bạn bè), `battleWins` (số trận đối kháng thắng) |
| PATCH | `me` | Cập nhật tên hiển thị, ảnh đại diện |

### 2.2 Chủ đề và thành viên (UC04–UC08)
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `topics/public` | Danh sách chủ đề công khai (phân trang, tìm kiếm theo tên) |
| GET | `topics/mine` | Chủ đề tôi sở hữu + chủ đề tôi là thành viên |
| POST | `topics` | Tạo chủ đề (kiểm tra hạn mức maxTopics) |
| GET | `topics/{id}` | Chi tiết chủ đề |
| PATCH | `topics/{id}` | Sửa chủ đề (chỉ chủ sở hữu); gồm visibility public/private |
| DELETE | `topics/{id}` | Xóa chủ đề (chỉ chủ sở hữu) |
| GET | `topics/{id}/members` | Danh sách thành viên (chủ sở hữu xem) |
| POST | `topics/{id}/invitations` | Mời thành viên: body `{ "emails": [...] }` (kiểm tra hạn mức maxMembersPerTopic) |
| DELETE | `topics/{id}/members/{userId}` | Xóa thành viên (chỉ chủ sở hữu) |
| GET | `invitations/mine` | Lời mời đang chờ của tôi (hiện ở trang chủ) |
| POST | `invitations/{id}/accept` | Chấp nhận lời mời → ghi topic_members |
| POST | `topics/{id}/join` | Tham gia **chủ đề công khai** (chủ đề riêng tư chỉ vào bằng lời mời → 403): kiểm tra hạn mức thành viên theo gói của chủ sở hữu; đã là thành viên thì trả `alreadyMember: true` |
| GET | `search?q=` | Tìm chủ đề và bộ đề theo từ khóa |

### 2.3 Câu hỏi và import Excel (UC09, UC10)
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `topics/{id}/questions` | Danh sách câu hỏi của chủ đề (lọc theo difficulty) |
| POST | `topics/{id}/questions` | Thêm câu hỏi thủ công |
| PATCH | `questions/{id}` | Sửa câu hỏi |
| DELETE | `questions/{id}` | Xóa câu hỏi |
| POST | `topics/{id}/questions/import` | Upload file .xlsx (multipart) → trả danh sách xem trước + lỗi theo dòng + `previewToken` |
| POST | `topics/{id}/questions/import/confirm` | Body `{ "previewToken": "..." }` → lưu các câu hợp lệ |
| GET | `topics/{id}/questions/export` | Xuất ngân hàng câu hỏi ra file .xlsx |

Định dạng file Excel: chuẩn 13 cột (id, cau_hoi, dap_an_a..d, dap_an_dung, muc_do, thoi_gian_giay, diem, goi_y, giai_thich, nguon) — file mẫu MAU_IMPORT_CAU_HOI.xlsx tại Doc/06_DuLieu.

### 2.4 Bộ đề và cài đặt (UC11, UC12)
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `topics/{id}/exams` | Danh sách bộ đề trong chủ đề |
| POST | `topics/{id}/exams` | Tạo bộ đề: `{ "mode": "MANUAL", "questionIds": [...] }` hoặc `{ "mode": "RANDOM", "counts": { "easy": 8, "medium": 7, "hard": 5 } }` (kiểm tra hạn mức maxExamsPerTopic) |
| GET | `exams/{id}` | Chi tiết bộ đề + cài đặt hiển thị cho người làm |
| PATCH | `exams/{id}` | Sửa thông tin bộ đề |
| PATCH | `exams/{id}/settings` | Cài đặt: openAt/closeAt, durationMinutes, maxAttempts, pin, shuffleQuestions, shuffleOptions, allowHelpers, showAnswerMode (IMMEDIATELY / AFTER_CLOSE / NEVER), publishScore |
| DELETE | `exams/{id}` | Xóa bộ đề (chỉ chủ sở hữu; xóa kèm liên kết câu hỏi, lượt làm và yêu thích của bộ đề; đợt thi đã chốt câu riêng nên không bị ảnh hưởng) |

### 2.5 Làm bài, trợ giúp, kết quả (UC13–UC18)
| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `exams/{id}/attempts` | Bắt đầu lượt làm: kiểm tra khung giờ, PIN (body `{ "pin": "..." }` nếu có), số lần làm → trả `attemptId` + danh sách câu hỏi (không đáp án) |
| POST | `attempts/{id}/helpers` | Dùng quyền trợ giúp: `{ "type": "FIFTY_FIFTY" \| "LIGHT_HINT" \| "VIEW_EXPLANATION" \| "CHANGE_QUESTION" \| "EXTRA_TIME" \| "SAFE_SHIELD", "questionId": "..." }`. Giới hạn mỗi lượt làm (REQ-F31): 50:50 ×1, Gợi Ý Nhẹ ×2 (câu đã xem gợi ý trừ 20% điểm), Soi Giải Thích ×1, Đổi Câu ×1, Thêm Giờ ×2 (+15 giây/lần), Khiên ×1 — hết lượt trả 400 `HELPER_LIMIT_REACHED`; bộ đề tắt trợ giúp (`allowHelpers: false`) trả 403 `HELPERS_DISABLED` |
| POST | `attempts/{id}/violations` | Báo một lần thoát app giữa chừng → trả số lần vi phạm; đủ 5 lần máy chủ tự nộp bài |
| POST | `attempts/{id}/submit` | Nộp bài: `{ "answers": [{ "questionId": "...", "selectedOption": 0, "timeSpentSeconds": 12 }], "durationSeconds": 742 }` → máy chủ chấm (điểm gốc + thưởng tốc độ), trả kết quả. `timeSpentSeconds` là tùy chọn: thời gian làm từng câu, dùng để tính thưởng tốc độ theo từng câu đúng công thức Đợt 2; không gửi thì tính theo tỷ lệ tổng thời gian |
| GET | `attempts/mine` | Lịch sử làm bài của tôi (mỗi lượt có `durationSeconds` — thời gian làm bài, `score`, `percent`, `submittedAt`) |
| GET | `attempts/{id}/review` | Xem lại bài: đáp án đúng + giải thích (chỉ khi cài đặt bộ đề cho phép) |
| GET | `reviews/wrong` | Danh sách câu tôi từng làm sai (ôn tập) — trả kèm đáp án đúng + giải thích |
| DELETE | `reviews/wrong/{questionId}` | Gỡ 1 câu khỏi danh sách câu sai của tôi (ôn tập trả lời đúng tại MH-13 hoặc bấm "Đã nhớ") — gỡ vĩnh viễn; gọi lại khi câu đã gỡ vẫn trả 200 với `removed: false` |

### 2.6 Bạn bè, đối kháng, đợt thi (UC19–UC21)
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `friends` | Danh sách bạn bè + lời mời kết bạn đang chờ |
| POST | `friends/requests` | Gửi lời mời kết bạn: `{ "email": "..." }` |
| POST | `friends/requests/{id}/accept` | Chấp nhận lời mời kết bạn |
| DELETE | `friends/requests/{id}` | Hủy lời mời đã gửi / từ chối lời mời nhận được (chỉ khi đang chờ) |
| DELETE | `friends/{userId}` | Hủy kết bạn |
| POST | `battles` | Tạo phòng đối kháng 1-1: `{ "topicId": "...", "questionCount": 10 }` — **máy chủ rút ngẫu nhiên câu hỏi từ kho của chủ đề** và chốt vào phòng |
| POST | `battles/{id}/join` | Vào phòng bằng mã phòng |
| POST | `battles/{id}/ready` | Sẵn sàng; cả hai sẵn sàng → phòng bắt đầu |
| POST | `battles/{id}/submit` | Nộp bài trong trận → khi cả hai đã nộp, máy chủ tổng kết và cộng/trừ rankScore (+15/0/−10). `results.submissions[uid].details` có chi tiết từng câu (câu hỏi, đáp án đã chọn, đáp án đúng) — chỉ trả khi trận đã kết thúc |
| POST | `battles/{id}/forfeit` | Bỏ trận giữa chừng (chỉ khi trận đang diễn ra): người bỏ cuộc tính thua −10, đối thủ thắng mặc định +15; `results.forfeitedBy` ghi người bỏ cuộc |
| GET | `battles/{id}` | Xem trạng thái phòng (app gọi lặp lại): người chơi + sẵn sàng + tiến độ đối thủ; trận đang diễn ra thì trả kèm câu hỏi (không đáp án) và tạo lượt làm nếu chưa có |
| POST | `battles/{id}/progress` | Báo tiến độ của mình: `{ "answeredCount": 5 }` để đối thủ thấy đã làm mấy câu |

Trạng thái phòng đối kháng (WAITING / IN_PROGRESS / FINISHED) và tiến trình đối thủ đồng bộ thời gian thực qua Firestore `battle_rooms` — app nghe trực tiếp collection này sau khi phòng được tạo qua API.

| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `topics/{id}/contests` | Chủ sở hữu mở đợt đối kháng nhiều người: `{ "title": "...", "openAt": "...", "closeAt": "...", "source": { "type": "RANDOM_TOPIC", "questionCount": 20 } }` hoặc `{ "source": { "type": "EXAM", "examId": "..." } }` |
| GET | `contests` | Danh sách đợt thi (đang mở / sắp mở / đã kết thúc) |
| POST | `contests/{id}/enter` | Vào thi trong khung giờ (mỗi tài khoản 1 lượt; nguồn EXAM thì phải chưa từng làm bộ đề đó) → trả attempt như 2.5 |
| GET | `contests/{id}/results` | Bảng xếp hạng của đợt (chỉ có sau khi hết giờ): xếp theo số câu đúng, hòa xét thời gian làm bài |

### 2.7 Xếp hạng, yêu thích, thống kê chủ đề (UC22–UC24)
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `leaderboard` | Bảng xếp hạng toàn hệ thống theo rankScore |
| POST | `exams/{id}/favorite` | Đánh dấu yêu thích bộ đề |
| DELETE | `exams/{id}/favorite` | Bỏ yêu thích |
| GET | `favorites` | Danh sách bộ đề tôi yêu thích |
| GET | `topics/{id}/stats` | Thống kê chủ đề cho chủ sở hữu: lượt làm, điểm trung bình, tỉ lệ đúng theo câu |

### 2.8 Gói thuê (UC02)
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `plans` | Danh sách gói: miễn phí (hạn mức), dùng thử 7 ngày, 30 / 90 / 365 ngày |
| GET | `me/subscription` | Gói hiện tại của tôi: loại gói, ngày hết hạn, số ngày cảnh báo còn lại |
| POST | `me/subscription/mock-pay` | Thanh toán mô phỏng: `{ "planId": "..." }` → kích hoạt/gia hạn gói |

### 2.9 Admin nền tảng (UC25–UC28)
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `admin/users` | Danh sách tài khoản toàn hệ thống (tìm/lọc) |
| GET | `admin/users/{id}` | Chi tiết tài khoản |
| POST | `admin/users/{id}/lock` / `unlock` | Khóa / mở khóa tài khoản |
| POST | `admin/users/{id}/subscription` | Gán hoặc gia hạn gói thủ công: `{ "planId": "..." }` |
| GET | `admin/plans` / PUT | `admin/plans/{id}` | Xem / sửa cấu hình gói và hạn mức |
| GET | `admin/stats` | Thống kê toàn hệ thống |
| GET | `admin/stats/exams` | Thống kê theo bộ đề: số lượt làm đã nộp, điểm % trung bình/cao nhất/thấp nhất |
| GET | `admin/stats/topics` | Thống kê theo chủ đề: số lượt làm đã nộp, điểm % trung bình, tỉ lệ câu đúng |
| GET | `admin/stats/violations` | Tài khoản có vi phạm gian lận: tổng số vi phạm, số lượt bị tự nộp bài, chi tiết từng lượt |

### 2.10 Kiểm thử (không thuộc use case nghiệp vụ)
| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `dev/reset` | **Nút Reset dữ liệu kiểm thử**: xóa dữ liệu test (chủ đề/bộ đề/lượt làm của tài khoản test) về trạng thái ban đầu. Bắt buộc cập nhật endpoint này mỗi khi thêm chức năng mới có dữ liệu riêng. |

## 3. Cách rút câu hỏi ngẫu nhiên (đối kháng và đợt thi)
Máy chủ thực hiện: lấy danh sách id câu hỏi của chủ đề → xáo trộn Fisher–Yates → lấy N id đầu → chốt danh sách vào `battle_rooms.questionIds` / `contests.questionIds`. Mọi người trong cùng trận/đợt làm cùng một danh sách câu.

## 4. Mã lỗi chính
`UNAUTHORIZED` (401) · `FORBIDDEN` (403) · `ACCOUNT_LOCKED` (403) · `NOT_FOUND` (404) ·
`LIMIT_EXCEEDED` (409, kèm hạn mức nào bị vượt trong message) · `EXAM_NOT_OPEN` (409) · `EXAM_CLOSED` (409) ·
`PIN_REQUIRED` (400) / `PIN_INVALID` (400) · `MAX_ATTEMPTS_REACHED` (409) · `ALREADY_ATTEMPTED` (409, đợt thi dùng bộ đề đã làm) ·
`CONTEST_NOT_OPEN` (409) · `ALREADY_ENTERED` (409) · `IMPORT_HAS_ERRORS` (422, chi tiết lỗi theo dòng trong data) · `VALIDATION_ERROR` (400).
