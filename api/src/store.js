// Kho du lieu trong bo nho, mo phong 17 collection cua Firestore theo ERD.
// Ban chay that se thay lop nay bang Firestore (Firebase Admin SDK);
// cac route chi doc/ghi qua cac Map o day nen khi doi chi sua file nay.
//
// Che do dev: token dang "dev:<uid>" (vd "dev:uy") de test khong can
// Firebase Auth that. Khi co bien moi truong FIREBASE_SERVICE_ACCOUNT
// (duong dan file JSON khoa dich vu) thi auth.js xac thuc token that.

const { newId, nowISO } = require('./util');

const COLLECTIONS = [
  'users', 'plans', 'subscriptions', 'topics', 'topicMembers', 'invitations',
  'questions', 'exams', 'examQuestions', 'attempts', 'friendships',
  'battleRooms', 'contests', 'contestEntries', 'reviews', 'favorites', 'comments',
];

const db = {};
function resetDb() {
  for (const c of COLLECTIONS) db[c] = new Map();
  seed();
}

function seed() {
  // --- Goi thue (gia theo mockup Figma MH-28) ---
  const plans = [
    { id: 'free', name: 'Miễn phí', days: null, price: 0, limits: { maxTopics: 1, maxExamsPerTopic: 2, maxMembersPerTopic: 10, maxQuestionsPerExam: null } },
    { id: 'trial', name: 'Dùng thử', days: 7, price: 0, limits: null }, // null = khong gioi han
    { id: 'p30', name: 'Gói 30 ngày', days: 30, price: 49000, limits: null },
    { id: 'p90', name: 'Gói 90 ngày', days: 90, price: 129000, limits: null },
    { id: 'p365', name: 'Gói 1 năm', days: 365, price: 449000, limits: null },
  ];
  for (const p of plans) db.plans.set(p.id, p);

  // --- Nguoi dung mau (uid = phan sau "dev:") ---
  const users = [
    { uid: 'admin', name: 'Admin Omega', email: 'admin@omega.app', role: 'ADMIN', rankScore: 0, locked: false },
    { uid: 'uy', name: 'Nguyễn Trọng Bảo Uy', email: '0306241504@caothang.edu.vn', role: 'USER', rankScore: 1240, locked: false },
    { uid: 'dinh', name: 'Đặng Ngọc Đỉnh', email: 'dinh@example.com', role: 'USER', rankScore: 1100, locked: false },
    { uid: 'danh', name: 'Ngô Thành Danh', email: 'danh@example.com', role: 'USER', rankScore: 1000, locked: false },
    { uid: 'thinh', name: 'Đỗ Quốc Thịnh', email: 'thinh@example.com', role: 'USER', rankScore: 980, locked: false },
  ];
  for (const u of users) {
    db.users.set(u.uid, { ...u, photoUrl: null, createdAt: nowISO() });
    // Moi tai khoan mau deu dang dung thu, het han sau 7 ngay
    const exp = new Date(Date.now() + 7 * 864e5).toISOString();
    db.subscriptions.set(u.uid, { userId: u.uid, planId: 'trial', startedAt: nowISO(), expiresAt: exp, status: 'ACTIVE' });
  }

  // --- Chu de mau ---
  const tToan = { id: 'topic_toan', ownerId: 'uy', name: 'Toán cao cấp', description: 'Đạo hàm, tích phân, ma trận', visibility: 'PUBLIC', createdAt: nowISO() };
  const tAnh = { id: 'topic_anh', ownerId: 'dinh', name: 'Tiếng Anh', description: 'Ngữ pháp và từ vựng cơ bản', visibility: 'PUBLIC', createdAt: nowISO() };
  db.topics.set(tToan.id, tToan);
  db.topics.set(tAnh.id, tAnh);
  db.topicMembers.set(`${tToan.id}:danh`, { topicId: tToan.id, userId: 'danh', joinedAt: nowISO() });
  db.topicMembers.set(`${tToan.id}:thinh`, { topicId: tToan.id, userId: 'thinh', joinedAt: nowISO() });

  // --- Cau hoi mau: moi chu de 12 cau (4 de / 4 trung binh / 4 kho) ---
  const mk = (topicId, content, options, correctOption, difficulty, hint, explanation) => {
    const q = {
      id: newId('q'), topicId, content, options, correctOption, difficulty,
      timeSeconds: 30, points: 10, hint: hint || null, explanation: explanation || null,
      source: 'Du lieu mau trong store.js',
    };
    db.questions.set(q.id, q);
    return q;
  };
  mk(tToan.id, 'Đạo hàm của f(x) = x² là gì?', ['x', '2x', 'x²', '2'], 1, 'easy', 'Dùng công thức (x^n)\' = n·x^(n-1)', 'f\'(x) = 2x');
  mk(tToan.id, 'Đạo hàm của f(x) = sin(x) là gì?', ['cos(x)', '-cos(x)', 'sin(x)', '-sin(x)'], 0, 'easy', null, '(sin x)\' = cos x');
  mk(tToan.id, 'Số nào là nghiệm của x² − 5x + 6 = 0?', ['x = 1', 'x = 4', 'x = 2', 'x = 5'], 2, 'easy', 'Phân tích thành (x−2)(x−3)', 'Nghiệm x = 2 và x = 3');
  mk(tToan.id, 'log₂(32) bằng bao nhiêu?', ['4', '5', '6', '8'], 1, 'easy', null, '2^5 = 32');
  mk(tToan.id, 'Giới hạn lim (x→0) sin(x)/x bằng?', ['0', '1', '∞', 'Không tồn tại'], 1, 'medium', 'Giới hạn cơ bản của lượng giác', 'lim sin(x)/x = 1 khi x→0');
  mk(tToan.id, 'Tích phân ∫ 2x dx bằng?', ['x² + C', '2x² + C', 'x + C', '2 + C'], 0, 'medium', null, '∫2x dx = x² + C');
  mk(tToan.id, 'Định thức của ma trận [[1,2],[3,4]] bằng?', ['−2', '2', '10', '−10'], 0, 'medium', 'det = a·d − b·c', '1·4 − 2·3 = −2');
  mk(tToan.id, 'Hàm f(x) = e^x có đạo hàm bằng?', ['x·e^x', 'e^x', 'e', 'ln(x)'], 1, 'medium', null, '(e^x)\' = e^x');
  mk(tToan.id, 'Tích phân ∫(0→1) x·e^x dx bằng?', ['1', 'e − 1', 'e', '0'], 0, 'hard', 'Dùng tích phân từng phần', 'Kết quả bằng 1');
  mk(tToan.id, 'Nghiệm tổng quát của y\' = 2y là?', ['y = Ce^x', 'y = Ce^(2x)', 'y = 2Cx', 'y = Cx²'], 1, 'hard', 'Phương trình vi phân tách biến', 'y = Ce^(2x)');
  mk(tToan.id, 'Chuỗi Σ 1/n từ 1 đến ∞ là?', ['Hội tụ về 1', 'Hội tụ về e', 'Phân kỳ', 'Hội tụ về π'], 2, 'hard', 'Chuỗi điều hòa', 'Chuỗi điều hòa phân kỳ');
  mk(tToan.id, 'Ma trận nghịch đảo của [[2,0],[0,2]] là?', ['[[1,0],[0,1]]', '[[0.5,0],[0,0.5]]', '[[2,0],[0,2]]', 'Không tồn tại'], 1, 'hard', null, 'Nhân với 1/2');
  mk(tAnh.id, 'Choose the correct sentence:', ['She go to school.', 'She goes to school.', 'She going to school.', 'She gone to school.'], 1, 'easy', 'Chủ ngữ ngôi thứ ba số ít', 'He/She/It + V-s/es');
  mk(tAnh.id, '"Happy" is a/an:', ['Noun', 'Verb', 'Adjective', 'Adverb'], 2, 'easy', null, 'Happy là tính từ');
  mk(tAnh.id, 'Past tense of "go" is:', ['goed', 'went', 'gone to', 'going'], 1, 'easy', null, 'go → went → gone');
  mk(tAnh.id, 'Which word means "very big"?', ['tiny', 'huge', 'small', 'thin'], 1, 'easy', null, 'huge = rất lớn');
  mk(tAnh.id, 'I have lived here ___ 2020.', ['for', 'since', 'from', 'at'], 1, 'medium', 'Mốc thời gian dùng since', 'since + mốc thời gian');
  mk(tAnh.id, 'The report ___ by the team yesterday.', ['wrote', 'was written', 'is writing', 'has write'], 1, 'medium', 'Câu bị động thì quá khứ', 'was/were + V3');
  mk(tAnh.id, 'If it rains, we ___ at home.', ['would stay', 'will stay', 'stayed', 'stays'], 1, 'medium', 'Câu điều kiện loại 1', 'If + hiện tại, will + V');
  mk(tAnh.id, 'Synonym of "rapid" is:', ['slow', 'quick', 'late', 'weak'], 1, 'medium', null, 'rapid = quick = nhanh');
  mk(tAnh.id, 'Neither the teacher nor the students ___ aware of the change.', ['was', 'were', 'is', 'be'], 1, 'hard', 'Hòa hợp chủ ngữ gần nhất', 'students (số nhiều) → were');
  mk(tAnh.id, 'By this time tomorrow, I ___ my exam.', ['will finish', 'will have finished', 'finish', 'am finishing'], 1, 'hard', 'Tương lai hoàn thành', 'will have + V3');
  mk(tAnh.id, 'The word "ubiquitous" means:', ['rare', 'present everywhere', 'ancient', 'invisible'], 1, 'hard', null, 'ubiquitous = có mặt khắp nơi');
  mk(tAnh.id, 'Had I known, I ___ earlier.', ['would come', 'would have come', 'will come', 'came'], 1, 'hard', 'Đảo ngữ điều kiện loại 3', 'Had I known, I would have come');

  // --- Bo de mau: Giua ky Dao ham (10 cau dau cua Toan) ---
  const exam = {
    id: 'exam_giuaky', topicId: tToan.id, ownerId: 'uy',
    title: 'Giữa kỳ — Đạo hàm', description: 'Bộ đề mẫu', createdAt: nowISO(),
    settings: {
      openAt: null, closeAt: null, durationMinutes: 20, maxAttempts: 3, pin: null,
      shuffleQuestions: true, shuffleOptions: true, allowHelpers: true,
      showAnswerMode: 'AFTER_CLOSE', publishScore: true,
    },
  };
  db.exams.set(exam.id, exam);
  const toanQs = [...db.questions.values()].filter((q) => q.topicId === tToan.id).slice(0, 10);
  toanQs.forEach((q, i) => db.examQuestions.set(`${exam.id}:${q.id}`, { examId: exam.id, questionId: q.id, order: i }));
}

resetDb();
module.exports = { db, resetDb };
