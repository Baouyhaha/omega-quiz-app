# T14 — Hướng dẫn cấu hình Firebase cho đăng nhập Google

Code đăng nhập đã xong (MH-01 + AuthService + Session + ApiClient đọc token thật).
Để chạy đăng nhập Google THẬT trên một máy, cần làm 4 việc cấu hình dưới đây.
Máy nào chưa cấu hình vẫn chạy app bình thường ở chế độ token dev
(nút "Vào bằng tài khoản dev (kiểm thử)" ở MH-01).

Chuẩn áp dụng: tài liệu chính thức FlutterFire (firebase.google.com/docs/flutter/setup)
và Firebase Auth (firebase.google.com/docs/auth/android/google-signin).

## 1. Bật Google trong Firebase console
- Vào console.firebase.google.com, chọn project **Omega-Quiz**.
- Build → Authentication → Sign-in method → **Google** → Enable → Save.

## 2. Đăng ký app Android + lấy SHA-1
- Project settings → Your apps → Add app → Android.
- Android package name: **com.example.omega_quiz** (đúng applicationId trong android/app/build.gradle.kts).
- Lấy SHA-1 của máy đang chạy debug: mở terminal trong thư mục android của project, chạy:
  - `./gradlew signingReport` (Windows: `gradlew.bat signingReport`)
  - Copy dòng SHA-1 của biến thể debug, dán vào form đăng ký app.
- Tải file **google-services.json** về, đặt vào thư mục **android/app/** của project.
  File này đã bị chặn trong .gitignore — không commit lên GitHub, mỗi máy tự giữ một bản.

## 3. Thêm plugin google-services vào Gradle (chỉ sửa 2 chỗ)
- File `android/settings.gradle.kts`, trong khối plugins thêm 1 dòng:
  `id("com.google.gms.google-services") version "4.4.2" apply false`
- File `android/app/build.gradle.kts`, trong khối plugins thêm 1 dòng:
  `id("com.google.gms.google-services")`
- Hai sửa đổi này CHƯA áp sẵn trong repo: máy nào chưa có google-services.json
  mà áp plugin sẽ lỗi build ngay, nên chỉ áp khi đã làm xong mục 2.

## 4. Chạy API ở chế độ Firebase thật
- API phải chạy với biến môi trường FIREBASE_SERVICE_ACCOUNT trỏ tới file khóa
  dịch vụ (xem api/huong-dan-noi-firebase.md). Có khóa thì API mới verify được
  ID token thật; không có khóa, API chỉ nhận token dev.
- App chạy máy ảo: baseUrl trong lib/core/constants.dart để http://10.0.2.2:3000/api/.

## Kiểm thử 3 trường hợp (theo mô hình hiện hành)
1. Đăng nhập lần đầu bằng một tài khoản Google chưa từng vào app:
   API tự tạo hồ sơ, tự kích hoạt dùng thử 7 ngày, vào thẳng khung điều hướng.
2. Đăng nhập lại bằng tài khoản cũ: vào thẳng, dữ liệu cũ còn nguyên.
3. Bấm đăng nhập rồi hủy ở màn chọn tài khoản Google:
   app ở lại MH-01, hiện dòng "Đã hủy đăng nhập", không văng lỗi.

Lưu ý: ID token hết hạn sau khoảng 1 giờ; nếu app để lâu rồi gọi API bị 401
thì đăng xuất và đăng nhập lại (bản hoàn thiện sau này sẽ tự làm mới token).
