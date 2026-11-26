// Diem vao cua Web API Omega Quiz (hop dong docs/API_CONTRACT.md v2)
// Chay: npm install && npm start  ->  http://localhost:3000/api/
const express = require('express');
const cors = require('cors');
const { ApiError } = require('./util');
const { initStore, resetStore } = require('./store');
const { firebaseEnabled } = require('./firebase');

const app = express();
app.use(cors());
app.use(express.json({ limit: '2mb' }));

app.get('/api/health', (req, res) => res.json({ success: true, message: 'OK', data: { status: 'up' } }));

// Nut Reset du lieu kiem thu (hop dong muc 2.10) — dat truoc cac router
// vi cac router phia duoi dung authMiddleware o cap router.
// Che do Firestore: reset ca du lieu tren Firestore roi nap lai du lieu mau.
app.post('/api/dev/reset', async (req, res, next) => {
  try {
    await resetStore();
    res.json({ success: true, message: 'Đã reset dữ liệu kiểm thử về trạng thái ban đầu', data: null });
  } catch (e) { next(e); }
});

// De tuong thich nguoc cho ban app cu tung goi endpoint nay: du lieu gio
// ghi thang xuong Firestore ngay khi thay doi nen khong con buoc dong bo.
app.post('/api/dev/sync', (req, res) => {
  res.json({
    success: true,
    message: firebaseEnabled
      ? 'Dữ liệu đã được ghi thẳng xuống Firestore, không cần đồng bộ nữa'
      : 'Firebase chưa bật — API đang chạy bằng bộ nhớ, không có gì để đồng bộ',
    data: null,
  });
});

app.use('/api', require('./routes/auth'));
app.use('/api', require('./routes/topics'));
app.use('/api', require('./routes/questions'));
app.use('/api', require('./routes/exams'));
app.use('/api', require('./routes/attempts'));
app.use('/api', require('./routes/social'));
app.use('/api', require('./routes/admin'));

app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Endpoint không tồn tại', errorCode: 'NOT_FOUND', data: null });
});

// Xu ly loi tap trung: moi loi deu dung khuon hop dong
app.use((err, req, res, next) => {
  if (err instanceof ApiError) {
    return res.status(err.status).json({ success: false, message: err.message, errorCode: err.errorCode, data: null });
  }
  console.error(err);
  res.status(500).json({ success: false, message: 'Lỗi máy chủ nội bộ', errorCode: 'INTERNAL', data: null });
});

const PORT = process.env.PORT || 3000;

// Khoi tao lop luu tru truoc khi nhan request: che do Firestore thi nap
// du lieu mau vao cac collection dang trong; che do bo nho thi dung ngay
// du lieu mau da xay san.
async function start() {
  await initStore();
  app.listen(PORT, () => console.log(`Omega Quiz API dang chay tai http://localhost:${PORT}/api/`));
}

start();
