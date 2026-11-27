# Hướng dẫn nối Firebase (Firestore) cho Omega Quiz API

Tài liệu này dành cho cả nhóm. Đọc kỹ phần **Quy tắc khóa** trước khi làm.

## 1. Mô hình lưu trữ hiện tại

- App Flutter **chỉ gọi Web API**, không bao giờ đọc/ghi Firestore trực tiếp.
- API là nơi xử lý và quyết định (hạn mức gói, giấu đáp án, chấm điểm, điểm rank).
- Firestore là nơi **lưu trữ lâu dài duy nhất**: toàn bộ 17 collection
  (users, plans, subscriptions, topics, topicMembers, invitations, questions,
  exams, examQuestions, attempts, friendships, battleRooms, contests,
  contestEntries, reviews, favorites, comments).
- Mọi thao tác dữ liệu trong code đi qua `repo` ở `src/store.js`
  (get / has / all / entries / put / del / count — tất cả đều là async).
  Sửa một document xong **phải gọi `repo.put`** để ghi lại; không còn
  cơ chế tự đồng bộ như bản cũ.

## 2. Hai chế độ chạy

| | Có khóa dịch vụ | Không có khóa |
|---|---|---|
| Điều kiện | Đặt biến môi trường `FIREBASE_SERVICE_ACCOUNT` | Không đặt biến này |
| Dữ liệu ở đâu | Firestore thật, tắt server mở lại còn nguyên | Bộ nhớ của server, restart là về dữ liệu mẫu |
| Dùng khi nào | Máy chạy API chính / máy demo báo cáo | Máy dev chỉ test giao diện, test luồng |

Chế độ được chọn **tự động** lúc server khởi động, không phải sửa code.

## 3. Chạy API với Firestore thật

Điều kiện tiên quyết (làm 1 lần trên Firebase console của project
`Omega-Quiz`): vào **Build → Firestore Database** — nếu chưa có database
thì bấm **Create database** để tạo. Chưa tạo database thì API không nạp
được dữ liệu (xem mục 5).

Các bước trên máy chạy API (mỗi lệnh một dòng):

```
cd api
```

```
npm install
```

Windows PowerShell:

```
$env:FIREBASE_SERVICE_ACCOUNT="C:\duong-dan\toi\file-khoa.json"
```

```
npm start
```

macOS/Linux:

```
FIREBASE_SERVICE_ACCOUNT=/duong-dan/toi/file-khoa.json npm start
```

Biến môi trường nhận **đường dẫn tới file khóa** hoặc **nội dung JSON của
khóa**. File khóa cất **ngoài thư mục repo**.

## 4. Kiểm chứng đã nối thật hay chưa

Nhìn 2 dòng log đầu tiên khi server khởi động:

- Đúng: `[firebase] da ket noi project omega-quiz-a392d` và tiếp theo là
  `[firestore] da nap du lieu mau vao N collection dang trong` (lần đầu)
  hoặc `[firestore] dung du lieu that dang co tren Firestore` (các lần sau).
- Sai: dòng `[firebase] chua dat FIREBASE_SERVICE_ACCOUNT` nghĩa là server
  đang chạy bằng bộ nhớ — kiểm tra lại biến môi trường.
- Nếu báo không kết nối được / lỗi nạp dữ liệu: kiểm tra Firestore Database
  đã được tạo trong console chưa (mục 3) và file khóa có đúng project không.

Kiểm chứng thêm: tạo 1 chủ đề bằng app/API, tắt server, mở lại, gọi
`GET /api/topics/mine` — chủ đề vẫn còn thì dữ liệu đã nằm trên Firestore.

## 5. Quy tắc khóa dịch vụ (BẮT BUỘC)

- Khóa dịch vụ là chìa khóa tổng của toàn bộ dữ liệu. **Tuyệt đối không
  commit lên GitHub** (repo đã chặn sẵn trong `.gitignore`), không gửi
  qua kênh chat công khai, không để trong thư mục repo.
- **Chỉ máy nào chạy API mới cần giữ khóa** (hiện tại: máy demo của nhóm
  trưởng + máy của Đỉnh). Không phải ai cũng tạo một bản khóa riêng.
- Người giữ khóa chính của project: nhóm trưởng (Uy).
- Lộ khóa thì vào console thu hồi khóa cũ và tạo khóa mới ngay.

## 6. Dữ liệu mẫu (seed)

- Dữ liệu mẫu nằm trong `src/store.js` (hàm `seedMemory`), gồm 60 câu ngân
  hàng Toán của T32 gắn cứng trong seed.
- Ở chế độ Firestore: seed **chỉ** được nạp vào collection đang **trống**.
  Collection đã có dữ liệu thật thì seed không đụng vào.
- Muốn quay về trạng thái mẫu: gọi `POST /api/dev/reset` (ở chế độ
  Firestore thao tác này **xóa sạch dữ liệu thật** trong 17 collection —
  cân nhắc trước khi bấm).

## 7. Việc trên Firebase console (làm 1 lần)

1. Tạo Firestore Database (mục 3) nếu chưa có.
2. Đặt Firestore Rules chặn truy cập trực tiếp từ client, vì app chỉ đi
   qua API còn API dùng khóa dịch vụ (khóa dịch vụ bỏ qua rules):

   ```
   rules_version = '2';
   service cloud.firestore {
     match /{document=**} {
       allow read, write: if false;
     }
   }
   ```

3. Gán quyền Admin nền tảng cho một tài khoản đăng nhập thật (khi dùng
   token Firebase Auth): trong collection `users`, tìm document của tài
   khoản đó và sửa trường `role` thành `ADMIN`.
