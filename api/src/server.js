// Diem vao cua Web API Omega Quiz (hop dong docs/API_CONTRACT.md v2)
// Chay: npm install && npm start  ->  http://localhost:3000/api/
const express = require('express');
const cors = require('cors');
const { ApiError } = require('./util');
const { resetDb, initDb, flushDb } = require('./store');
const { firebaseEnabled } = require('./firebase');

const app = express();
app.use(cors());
app.use(express.json({ limit: '2mb' }));

app.get('/api/health', (req, res) => res.json({ success: true, message: 'OK', data: { status: 'up' } }));

// Nut Reset du lieu kiem thu (hop dong muc 2.10) — dat truoc cac router
// vi cac router phia duoi dung authMiddleware o cap router.
// Khi co Firebase: reset ca du lieu tren Firestore roi moi nap lai du lieu mau.
app.post('/api/dev/reset', async (req, res, next) => {
  try {
    await resetDb();
    res.json({ success: true, message: 'Đã reset dữ liệu kiểm thử về trạng thái ban đầu', data: null });
  } catch (e) { next(e); }
});

// Day toan bo du lieu trong bo nho len Firestore (chi co tac dung khi
// Firebase da bat). Dung khi muon chac du lieu tren console la moi nhat
// thay vi doi vong dong bo 30 giay.
app.post('/api/dev/sync', async (req, res, next) => {
  try {
    if (!firebaseEnabled) {
      return res.json({ success: true, message: 'Firebase chưa bật — API đang chạy bằng bộ nhớ, không có gì để đồng bộ', data: null });
    }
    await flushDb();
    res.json({ success: true, message: 'Đã đồng bộ dữ liệu lên Firestore', data: null });
  } catch (e) { next(e); }
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

// Nap du lieu Firestore vao bo nho truoc khi nhan request. Neu khong co
// Firebase thi initDb() khong lam gi va server chay nhu cu.
async function start() {
  await initDb();
  app.listen(PORT, () => console.log(`Omega Quiz API dang chay tai http://localhost:${PORT}/api/`));
  if (firebaseEnabled) {
    // Dong bo dinh ky: bat cac thay doi sua tai cho (PATCH, doi trang thai)
    // ma lop Map khong tu day len Firestore duoc.
    setInterval(() => {
      flushDb().catch((e) => console.error('[firestore] dong bo dinh ky loi:', e.message));
    }, 30 * 1000);
    const shutdown = async () => {
      try { await flushDb(); } catch (e) { /* bo qua loi khi tat */ }
      process.exit(0);
    };
    process.on('SIGINT', shutdown);
    process.on('SIGTERM', shutdown);
  }
}

start();
