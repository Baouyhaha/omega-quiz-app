# Hướng dẫn Git cho nhóm Omega

Repo: https://github.com/Baouyhaha/omega-quiz-app

Nhánh chính: `main` (nhóm trưởng quản lý, không ai push thẳng lên main).
Nhánh cá nhân: `uy` (Uy), `dinh` (Đỉnh), `danh` (Danh), `thinh` (Thịnh).
Mỗi người chỉ làm việc trên nhánh của mình.

## 1. Thiết lập lần đầu (làm ở T01)

Cài Git, sau đó cấu hình tên và email (dùng email sinh viên):

```
git config --global user.name "Ho Ten"
git config --global user.email "MSSV@caothang.edu.vn"
```

Tải repo về máy:

```
git clone https://github.com/Baouyhaha/omega-quiz-app.git
cd omega-quiz-app
git checkout <nhanh-ca-nhan>
```

Ví dụ: `git checkout dinh`

## 2. Quy trình mỗi ngày

Trước khi code, lấy bản mới nhất của main về nhánh của mình:

```
git checkout <nhanh-ca-nhan>
git pull origin main
```

Code xong thì lưu và đẩy lên nhánh cá nhân:

```
git add .
git commit -m "Mo ta ngan gon viec vua lam"
git push origin <nhanh-ca-nhan>
```

Quy định commit:

- Tối thiểu 3 commit/tuần/người (theo phiếu chấm điểm của giảng viên).
- Nội dung commit viết ngắn, đúng việc vừa làm, ví dụ: "Lam man hinh dang nhap", "Sua loi dem thoi gian lam bai".
- Không commit các file cấu hình bí mật: `google-services.json`, `firebase_options.dart`, `.env` (đã chặn trong .gitignore, nếu git báo các file này thì dừng lại và hỏi nhóm trưởng).

## 3. Gửi code lên main (Pull Request)

Khi một chức năng chạy được và đã tự test:

1. Push nhánh cá nhân lên GitHub.
2. Mở Pull Request từ nhánh cá nhân vào `main`, tiêu đề ghi mã task (ví dụ: "T09 — Đăng nhập").
3. Task code phải kèm video tự test ngắn (30 giây – 2 phút) trong phần mô tả PR.
4. Nhóm trưởng kiểm tra và merge. Người làm không tự merge PR của mình.

## 4. Khi bị xung đột (conflict)

- Nguyên nhân thường gặp: hai người sửa cùng một file. Cách phòng: pull main trước khi code, không sửa file của task người khác khi chưa báo nhóm.
- Nếu push bị từ chối: chạy `git pull origin <nhanh-ca-nhan>` rồi push lại.
- Nếu pull báo conflict: mở file bị đánh dấu, giữ lại phần đúng theo thỏa thuận với người sửa cùng file, xóa các dấu `<<<<<<<`, `=======`, `>>>>>>>`, sau đó `git add .` và `git commit` để hoàn tất. Kẹt quá 15 phút thì chụp màn hình gửi nhóm, không tự xóa code của người khác.

## 5. Lỗi thường gặp

- Gõ sai tên nhánh khi push: kiểm tra nhánh hiện tại bằng `git branch` (nhánh đang dùng có dấu *).
- Quên pull trước khi code: code trên nền cũ dễ sinh conflict; pull main vào buổi sáng trước khi bắt đầu.
- Commit nhầm file lạ: dùng `git status` xem danh sách file sắp commit trước khi `git add .`.
