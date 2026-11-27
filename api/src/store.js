// Lop luu tru cua Web API Omega Quiz — Firestore la noi luu tru chinh.
//
// Hai che do, chon tu dong theo bien moi truong FIREBASE_SERVICE_ACCOUNT:
//   - Co khoa dich vu: moi thao tac doc/ghi di THANG xuong Firestore
//     (qua repo o duoi). Tat server mo lai du lieu van con nguyen.
//     Lan chay dau tien, collection nao dang trong se duoc nap du lieu
//     mau (seed) vao collection do.
//   - Khong co khoa: chay bang bo nho + du lieu mau nhu ban dev cu,
//     restart la ve trang thai ban dau. Dung de test o may chua co key.
//
// Cac route KHONG cham vao Firestore hay Map truc tiep nua — tat ca di
// qua repo (get/has/all/entries/put/del/count, deu la async). Sua mot
// document xong phai goi repo.put de ghi lai (che do Firestore khong
// tu luu thay doi tai cho nhu Map trong bo nho).
//
// Du lieu mau (seed) van xay trong bo nho truoc (seedMemory), roi chi
// duoc day len Firestore khi collection tuong ung dang trong.

const { newId, nowISO } = require('./util');
const { firestore, firebaseEnabled } = require('./firebase');

const COLLECTIONS = [
  'users', 'plans', 'subscriptions', 'topics', 'topicMembers', 'invitations',
  'questions', 'exams', 'examQuestions', 'attempts', 'friendships',
  'battleRooms', 'contests', 'contestEntries', 'reviews', 'favorites', 'comments',
];

// Map trong bo nho: chua du lieu mau + la noi luu tru o che do khong khoa
const db = {};
for (const c of COLLECTIONS) db[c] = new Map();

function seedMemory() {
  for (const c of COLLECTIONS) db[c].clear();
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
  // --- Ngan hang 60 cau Toan cao cap (T32): file NganHangCauHoi_ToanCaoCap.xlsx
  // cua Thinh, Dinh da kiem (du 60 cau, moi muc 20, du goi y + giai thich, khong trung).
  // Nap thang vao du lieu mau vi API chua co CSDL that; khi noi Firestore thi bo khoi nay.
  mk(tToan.id, "Cho ma trận A = [[1, 2], [3, 4]]. Định thức của A bằng bao nhiêu?", ["2", "-2", "10", "-10"], 1, 'easy', "Định thức cấp 2: lấy tích đường chéo chính trừ tích đường chéo phụ.", "det(A) = 1·4 − 2·3 = 4 − 6 = −2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho A = [[2, 1], [0, 3]] và B = [[1, 0], [2, 1]]. Tổng A + B bằng bao nhiêu?", ["[[3, 1], [2, 4]]", "[[3, 0], [2, 3]]", "[[2, 1], [2, 3]]", "[[3, 2], [1, 4]]"], 0, 'medium', "Cộng hai ma trận bằng cách cộng từng phần tử ở cùng vị trí.", "A + B = [[2+1, 1+0], [0+2, 3+1]] = [[3, 1], [2, 4]].").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Ma trận nghịch đảo của A = [[2, 1], [1, 1]] là ma trận nào sau đây?", ["[[1, -1], [-1, 2]]", "[[2, -1], [-1, 1]]", "[[1, 1], [-1, 2]]", "[[-1, 1], [1, -2]]"], 0, 'hard', "Dùng công thức nghịch đảo cấp 2: đổi chỗ a và d, đổi dấu b và c, rồi chia cho định thức.", "det(A) = 2·1 − 1·1 = 1, nên A⁻¹ = [[1, −1], [−1, 2]].").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Giới hạn lim (x → 0) (sin x)/x bằng bao nhiêu?", ["0", "1", "Vô cùng", "Không tồn tại"], 1, 'easy', "Nhớ giới hạn đặc biệt của (sin x)/x khi x tiến về 0.", "Giới hạn đặc biệt: lim (x → 0) (sin x)/x = 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Đạo hàm của hàm số y = x^3 bằng bao nhiêu?", ["3x", "x^2", "3x^2", "3x^3"], 2, 'easy', "Dùng công thức đạo hàm (x^n)' = n·x^(n−1).", "(x^3)' = 3x^2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Giới hạn lim (x → +∞) (2x + 1)/(x + 3) bằng bao nhiêu?", ["0", "1", "2", "Vô cùng"], 2, 'medium', "Chia cả tử và mẫu cho x rồi cho x tiến về +∞.", "Chia tử và mẫu cho x: (2 + 1/x)/(1 + 3/x) → 2/1 = 2 khi x → +∞.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho f(x) = (x^2 + 1)^3. Giá trị f'(1) bằng bao nhiêu?", ["12", "24", "48", "6"], 1, 'hard', "Dùng quy tắc đạo hàm hàm hợp: đạo hàm hàm ngoài nhân với đạo hàm hàm trong.", "f'(x) = 3(x^2+1)^2 · 2x = 6x(x^2+1)^2, nên f'(1) = 6·1·(2)^2 = 24.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Nguyên hàm của hàm số y = x là:", ["x^2 + C", "x^2/2 + C", "2x + C", "1 + C"], 1, 'easy', "Tìm hàm số có đạo hàm bằng x.", "∫x dx = x^2/2 + C, vì (x^2/2)' = x.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Tích phân từ 0 đến π của sin x dx bằng bao nhiêu?", ["0", "1", "2", "-2"], 2, 'medium', "Nguyên hàm của sin x là −cos x, rồi thay cận 0 và π.", "∫₀^π sin x dx = [−cos x]₀^π = −cos π + cos 0 = 1 + 1 = 2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Tích phân từ 0 đến 1 của (3x^2 + 2) dx bằng bao nhiêu?", ["2", "3", "4", "5"], 1, 'hard', "Lấy nguyên hàm từng hạng tử rồi thay cận 0 và 1.", "∫₀¹ (3x^2+2) dx = [x^3 + 2x]₀¹ = (1 + 2) − 0 = 3.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho ma trận A = [[2, 3], [1, 4]]. Định thức của A bằng bao nhiêu?", ["5", "11", "-5", "2"], 0, 'easy', "Áp dụng công thức định thức cấp 2: ad − bc.", "det = 2·4 − 3·1 = 8 − 3 = 5.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho ma trận A = [[5, 2], [3, 1]]. Định thức của A bằng bao nhiêu?", ["1", "-1", "11", "-11"], 1, 'easy', "Lấy tích đường chéo chính trừ tích đường chéo phụ.", "det = 5·1 − 2·3 = 5 − 6 = -1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho ma trận A = [[1, 2], [3, 4]]. Ma trận chuyển vị A^T là ma trận nào sau đây?", ["[[1, 2], [3, 4]]", "[[4, 3], [2, 1]]", "[[1, 3], [2, 4]]", "[[2, 4], [1, 3]]"], 2, 'easy', "Chuyển vị là đổi hàng thành cột.", "Hàng 1 của A thành cột 1 của A^T: A^T = [[1, 3], [2, 4]].").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho ma trận A = [[1, 2], [3, 0]]. Ma trận 2A là ma trận nào sau đây?", ["[[1, 2], [3, 0]]", "[[2, 4], [3, 0]]", "[[2, 2], [6, 0]]", "[[2, 4], [6, 0]]"], 3, 'easy', "Nhân một số với ma trận là nhân số đó với từng phần tử.", "2·[[1, 2], [3, 0]] = [[2, 4], [6, 0]].").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho ma trận A = [[3, 0], [0, 4]]. Định thức của A bằng bao nhiêu?", ["7", "0", "12", "-12"], 2, 'easy', "Ma trận chéo có định thức bằng tích các phần tử trên đường chéo chính.", "det = 3·4 − 0·0 = 12.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Nghiệm của hệ phương trình {x + y = 3; x − y = 1} là:", ["x = 2, y = 1", "x = 1, y = 2", "x = 3, y = 0", "x = 0, y = 3"], 0, 'easy', "Cộng hai phương trình để khử y.", "Cộng hai phương trình: 2x = 4 nên x = 2, thay vào phương trình đầu được y = 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Định thức của ma trận [[1, 2, 0], [0, 1, 1], [2, 0, 1]] bằng bao nhiêu?", ["5", "-3", "3", "-5"], 0, 'medium', "Khai triển định thức theo hàng 1.", "Khai triển theo hàng 1: 1·(1·1 − 1·0) − 2·(0·1 − 1·2) = 1 + 4 = 5.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Định thức của ma trận [[2, 0, 1], [1, 1, 0], [0, 2, 1]] bằng bao nhiêu?", ["2", "4", "6", "-4"], 1, 'medium', "Khai triển theo hàng 1, chú ý dấu của phần bù đại số.", "Khai triển theo hàng 1: 2·(1·1 − 0·2) + 1·(1·2 − 1·0) = 2 + 2 = 4.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Ma trận nghịch đảo của A = [[3, 1], [2, 1]] là ma trận nào sau đây?", ["[[3, -1], [-2, 1]]", "[[1, 1], [2, 3]]", "[[1, -1], [-2, 3]]", "[[-1, 1], [2, -3]]"], 2, 'medium', "Tính định thức trước, rồi dùng công thức nghịch đảo cấp 2.", "det = 3·1 − 1·2 = 1, nên A⁻¹ = [[1, -1], [-2, 3]].").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Hạng của ma trận [[1, 2], [2, 4]] bằng bao nhiêu?", ["0", "1", "2", "3"], 1, 'medium', "Kiểm tra xem các hàng có tỉ lệ với nhau không.", "Hàng 2 gấp đôi hàng 1 nên chỉ có 1 hàng độc lập tuyến tính, hạng bằng 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Theo quy tắc Cramer, nghiệm y của hệ phương trình {2x + 3y = 7; x + y = 3} bằng bao nhiêu?", ["-1", "0", "1", "2"], 2, 'medium', "Tính định thức hệ D và định thức Dy rồi lấy y = Dy/D.", "D = 2·1 − 3·1 = -1; Dy = 2·3 − 7·1 = -1; y = (-1)/(-1) = 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Định thức của ma trận [[1, 1, 1], [1, 2, 3], [1, 3, 6]] bằng bao nhiêu?", ["0", "1", "2", "-1"], 1, 'medium', "Khai triển theo hàng 1 và tính các định thức cấp 2.", "Khai triển theo hàng 1: (12 − 9) − (6 − 3) + (3 − 2) = 3 − 3 + 1 = 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Định thức của ma trận [[a, 1, 0], [0, a, 1], [1, 0, a]] bằng bao nhiêu?", ["a³+1", "a³−1", "a³", "a²+1"], 0, 'hard', "Khai triển theo hàng 1, giữ nguyên a như một số.", "Khai triển theo hàng 1: a·a² − 1·(0·a − 1·1) = a³ + 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Ma trận nghịch đảo của A = [[1, 2], [3, 4]] là ma trận nào sau đây?", ["[[2, -1], [-3/2, 1/2]]", "[[-2, -1], [-3/2, -1/2]]", "[[4, -2], [-3, 1]]", "[[-2, 1], [3/2, -1/2]]"], 3, 'hard', "Tính định thức rồi chia ma trận phụ hợp chuyển vị cho định thức.", "det = 1·4 − 2·3 = -2, nên A⁻¹ = (1/-2)·[[4, -2], [-3, 1]] = [[-2, 1], [3/2, -1/2]].").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Hệ phương trình {x + 2y = 1; 2x + my = 2} có vô số nghiệm khi m bằng bao nhiêu?", ["2", "3", "4", "5"], 2, 'hard', "Hệ có vô số nghiệm khi hai phương trình tỉ lệ với nhau.", "Hai phương trình tỉ lệ khi 1/2 = 2/m, suy ra m = 4.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Hạng của ma trận [[1, 2, 3], [2, 4, 6], [1, 1, 1]] bằng bao nhiêu?", ["1", "2", "3", "0"], 1, 'hard', "Tìm số hàng độc lập tuyến tính tối đa.", "Hàng 2 gấp đôi hàng 1, còn hàng 1 và hàng 3 độc lập nên hạng bằng 2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Định thức của ma trận [[2, 1, 0], [1, 3, 1], [0, 1, 2]] bằng bao nhiêu?", ["6", "10", "12", "8"], 3, 'hard', "Khai triển theo hàng 1, phần tử 0 làm mất một số hạng.", "Khai triển theo hàng 1: 2·(3·2 − 1·1) − 1·(1·2 − 1·0) = 2·5 − 2 = 8.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Giới hạn lim (x → 2) (x^2 − 4)/(x − 2) bằng bao nhiêu?", ["2", "0", "Không tồn tại", "4"], 3, 'easy', "Phân tích tử thành nhân tử rồi rút gọn với mẫu.", "(x²−4)/(x−2) = x+2, nên giới hạn bằng 2+2 = 4.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Đạo hàm của hàm số y = 2x bằng bao nhiêu?", ["2", "x", "2x", "0"], 0, 'easy', "Đạo hàm của hằng số nhân x bằng chính hằng số đó.", "(2x)' = 2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Giới hạn lim (x → 0) (1 − cos x)/x bằng bao nhiêu?", ["1", "0", "1/2", "Không tồn tại"], 1, 'easy', "Nhân tử và mẫu với (1+cos x) rồi dùng giới hạn đặc biệt của sin x/x.", "(1−cos x)/x = sin x·(sin x/x)·1/(1+cos x) → 0·1·(1/2) = 0.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Đạo hàm của hàm số y = sin x bằng bao nhiêu?", ["-cos x", "-sin x", "cos x", "sin x"], 2, 'easy', "Nhớ công thức đạo hàm của các hàm lượng giác cơ bản.", "(sin x)' = cos x.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Đạo hàm của hàm số y = e^x bằng bao nhiêu?", ["x·e^x", "e^(x+1)", "1", "e^x"], 3, 'easy', "Hàm mũ cơ số e có một tính chất đạo hàm đặc biệt.", "(e^x)' = e^x.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Giới hạn lim (x → 0) (e^x − 1)/x bằng bao nhiêu?", ["1", "0", "e", "Không tồn tại"], 0, 'medium', "Đây là giới hạn đặc biệt của hàm mũ, có thể dùng quy tắc L'Hôpital.", "Dùng L'Hôpital: giới hạn bằng lim (x→0) e^x = 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho f(x) = x^2 · e^x. Đạo hàm f'(x) bằng bao nhiêu?", ["e^x(2x+1)", "2x·e^x", "x²·e^x", "e^x(x²+2x)"], 3, 'medium', "Dùng quy tắc đạo hàm của tích.", "f'(x) = 2x·e^x + x²·e^x = e^x(x²+2x).").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho f(x) = ln(x^2 + 1). Giá trị f'(1) bằng bao nhiêu?", ["0", "1/2", "1", "2"], 2, 'medium', "Đạo hàm hàm hợp: đạo hàm của ln u bằng u'/u.", "f'(x) = 2x/(x²+1), nên f'(1) = 2/2 = 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Giới hạn lim (x → 0) (tan x)/x bằng bao nhiêu?", ["0", "1", "2", "Không tồn tại"], 1, 'medium', "Viết tan x = sin x/cos x rồi dùng giới hạn đặc biệt.", "tan x/x = (sin x/x)·(1/cos x) → 1·1 = 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho f(x) = (2x + 1)^2. Giá trị f'(1) bằng bao nhiêu?", ["8", "10", "16", "12"], 3, 'medium', "Dùng quy tắc đạo hàm hàm hợp.", "f'(x) = 2(2x+1)·2 = 8x+4, nên f'(1) = 12.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Hàm số y = x^3 − 3x có điểm tới hạn tại:", ["x = ±1", "x = 0", "x = 1", "x = -1"], 0, 'medium', "Điểm tới hạn là nghiệm của y' = 0.", "y' = 3x² − 3 = 0 ⇔ x² = 1 ⇔ x = ±1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Giới hạn lim (x → +∞) (1 + 1/x)^x bằng bao nhiêu?", ["1", "0", "e", "Vô cùng"], 2, 'hard', "Đây là giới hạn đặc biệt định nghĩa số e.", "Theo giới hạn đặc biệt, lim (x→∞) (1+1/x)^x = e.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho f(x) = x · ln x. Đạo hàm f'(x) bằng bao nhiêu?", ["ln x", "ln x + 1", "1/x", "x"], 1, 'hard', "Dùng quy tắc đạo hàm của tích.", "f'(x) = 1·ln x + x·(1/x) = ln x + 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Hàm số y = x^4 − 2x^2 đạt cực tiểu tại:", ["x = 0", "x = 1", "x = -1", "x = ±1"], 3, 'hard', "Giải y' = 0 rồi xét dấu y'' tại các điểm tới hạn.", "y' = 4x³−4x = 0 ⇔ x = 0, ±1; y'' = 12x²−4, y''(±1) = 8 > 0 nên cực tiểu tại x = ±1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Giới hạn lim (x → 0) (sin 2x)/x bằng bao nhiêu?", ["2", "0", "1", "4"], 0, 'hard', "Đặt t = 2x rồi dùng giới hạn đặc biệt của sin t/t.", "(sin 2x)/x = 2·(sin 2x)/(2x) → 2·1 = 2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Cho f(x) = e^(2x). Giá trị f'(0) bằng bao nhiêu?", ["1", "e", "2", "2e"], 2, 'hard', "Đạo hàm hàm hợp: nhân thêm đạo hàm của 2x.", "f'(x) = 2e^(2x), nên f'(0) = 2·1 = 2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Đạo hàm của hàm số y = √(x^2 + 1) bằng bao nhiêu?", ["1/√(x²+1)", "2x/√(x²+1)", "x²/√(x²+1)", "x/√(x²+1)"], 3, 'hard', "Viết căn thành lũy thừa 1/2 rồi dùng quy tắc đạo hàm hàm hợp.", "y = (x²+1)^(1/2) nên y' = (1/2)(x²+1)^(−1/2)·2x = x/√(x²+1).").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Nguyên hàm của hàm số y = 2 là:", ["2x + C", "x + C", "2 + C", "x² + C"], 0, 'easy', "Nguyên hàm của hằng số a là a·x + C.", "∫2 dx = 2x + C.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Tích phân từ 0 đến 1 của x dx bằng bao nhiêu?", ["1", "1/2", "2", "0"], 1, 'easy', "Lấy nguyên hàm của x rồi thay cận 0 và 1.", "∫₀¹ x dx = [x²/2]₀¹ = 1/2 − 0 = 1/2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Nguyên hàm của hàm số y = cos x là:", ["-sin x + C", "sin x + C", "cos x + C", "-cos x + C"], 1, 'easy', "Nhớ nguyên hàm của các hàm lượng giác cơ bản.", "∫cos x dx = sin x + C, vì (sin x)' = cos x.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Tích phân từ 0 đến 2 của 1 dx bằng bao nhiêu?", ["0", "1", "2", "4"], 2, 'easy', "Tích phân của 1 là độ dài đoạn lấy tích phân.", "∫₀² 1 dx = [x]₀² = 2 − 0 = 2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Nguyên hàm của hàm số y = e^x là:", ["x·e^x + C", "e^(x+1) + C", "1 + C", "e^x + C"], 3, 'easy', "Hàm mũ e^x có nguyên hàm bằng chính nó.", "∫e^x dx = e^x + C, vì (e^x)' = e^x.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Tích phân từ 0 đến 1 của (x + 1) dx bằng bao nhiêu?", ["3/2", "1", "2", "1/2"], 0, 'medium', "Lấy nguyên hàm từng hạng tử rồi thay cận 0 và 1.", "∫₀¹ (x+1) dx = [x²/2 + x]₀¹ = (1/2 + 1) − 0 = 3/2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Nguyên hàm của hàm số y = x · e^x là:", ["(x+1)e^x + C", "x·e^x + C", "e^x + C", "(x−1)e^x + C"], 3, 'medium', "Dùng phương pháp tích phân từng phần với u = x.", "Đặt u = x, dv = e^x dx: ∫x·e^x dx = x·e^x − ∫e^x dx = (x−1)e^x + C.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Tích phân từ 1 đến 2 của (1/x) dx bằng bao nhiêu?", ["ln 2", "1", "2", "0"], 0, 'medium', "Nguyên hàm của 1/x là ln|x|.", "∫₁² (1/x) dx = [ln x]₁² = ln 2 − ln 1 = ln 2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Tích phân từ 0 đến π/2 của cos x dx bằng bao nhiêu?", ["0", "1", "2", "-1"], 1, 'medium', "Nguyên hàm của cos x là sin x, rồi thay cận 0 và π/2.", "∫₀^(π/2) cos x dx = [sin x]₀^(π/2) = 1 − 0 = 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Nguyên hàm của hàm số y = 2x + 1 là:", ["x² + C", "x² + 2x + C", "x² + x + C", "2x² + x + C"], 2, 'medium', "Lấy nguyên hàm từng hạng tử.", "∫(2x+1) dx = x² + x + C.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Tích phân từ 0 đến 1 của x^2 dx bằng bao nhiêu?", ["1/2", "1/3", "1/4", "1"], 1, 'hard', "Dùng công thức nguyên hàm của x^n rồi thay cận.", "∫₀¹ x² dx = [x³/3]₀¹ = 1/3 − 0 = 1/3.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Nguyên hàm của hàm số y = x · sin x là:", ["-x·cos x + sin x + C", "x·cos x + sin x + C", "-x·cos x − sin x + C", "x·sin x + C"], 0, 'hard', "Dùng phương pháp tích phân từng phần với u = x.", "Đặt u = x, dv = sin x dx: ∫x·sin x dx = −x·cos x + ∫cos x dx = −x·cos x + sin x + C.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Tích phân từ 1 đến e của (ln x)/x dx bằng bao nhiêu?", ["1", "e", "1/2", "0"], 2, 'hard', "Đổi biến u = ln x.", "Đặt u = ln x, du = dx/x; khi x = 1 thì u = 0, x = e thì u = 1: ∫₀¹ u du = 1/2.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Diện tích hình phẳng giới hạn bởi y = x^2, y = 0, x = 0 và x = 2 bằng bao nhiêu?", ["4/3", "2", "4", "8/3"], 3, 'hard', "Diện tích bằng tích phân của x² từ 0 đến 2.", "S = ∫₀² x² dx = [x³/3]₀² = 8/3.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Tích phân từ 0 đến 1 của e^x dx bằng bao nhiêu?", ["e", "1", "e+1", "e−1"], 3, 'hard', "Nguyên hàm của e^x là e^x, rồi thay cận 0 và 1.", "∫₀¹ e^x dx = [e^x]₀¹ = e − 1.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';
  mk(tToan.id, "Nguyên hàm của hàm số y = 3x^2 + 2x là:", ["3x³ + 2x² + C", "x³ + 2x² + C", "x³ + x² + C", "3x³ + x² + C"], 2, 'hard', "Lấy nguyên hàm từng hạng tử bằng công thức của x^n.", "∫(3x²+2x) dx = x³ + x² + C.").source = 'NganHangCauHoi_ToanCaoCap.xlsx';

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

// ---------- Lop truy cap du lieu (repo) ----------
const repo = {
  async get(coll, key) {
    if (!firebaseEnabled) return db[coll].get(key);
    const snap = await firestore.collection(coll).doc(String(key)).get();
    return snap.exists ? snap.data() : undefined;
  },
  async has(coll, key) {
    if (!firebaseEnabled) return db[coll].has(key);
    const snap = await firestore.collection(coll).doc(String(key)).get();
    return snap.exists;
  },
  async all(coll) {
    if (!firebaseEnabled) return [...db[coll].values()];
    const snap = await firestore.collection(coll).get();
    return snap.docs.map((d) => d.data());
  },
  async entries(coll) {
    if (!firebaseEnabled) return [...db[coll].entries()];
    const snap = await firestore.collection(coll).get();
    return snap.docs.map((d) => [d.id, d.data()]);
  },
  async put(coll, key, doc) {
    if (!firebaseEnabled) { db[coll].set(key, doc); return doc; }
    await firestore.collection(coll).doc(String(key)).set(doc);
    return doc;
  },
  async del(coll, key) {
    if (!firebaseEnabled) return db[coll].delete(key);
    await firestore.collection(coll).doc(String(key)).delete();
    return true;
  },
  async count(coll) {
    if (!firebaseEnabled) return db[coll].size;
    const snap = await firestore.collection(coll).get();
    return snap.size;
  },
};

// Day du lieu mau cua mot collection len Firestore (theo lo 400, gioi han
// batch cua Firestore la 500)
async function pushSeedCollection(coll) {
  const entries = [...db[coll].entries()];
  for (let i = 0; i < entries.length; i += 400) {
    const batch = firestore.batch();
    for (const [k, v] of entries.slice(i, i + 400)) {
      batch.set(firestore.collection(coll).doc(String(k)), v);
    }
    await batch.commit();
  }
}

// Khoi tao luc server bat dau: xay du lieu mau trong bo nho; o che do
// Firestore thi collection nao dang trong se nhan du lieu mau
async function initStore() {
  seedMemory();
  if (!firebaseEnabled) {
    console.log('[store] che do bo nho (chua co khoa dich vu) — du lieu mau san sang');
    return;
  }
  let seeded = 0;
  for (const c of COLLECTIONS) {
    const snap = await firestore.collection(c).limit(1).get();
    if (snap.empty && db[c].size) { await pushSeedCollection(c); seeded++; }
  }
  console.log(seeded
    ? `[firestore] da nap du lieu mau vao ${seeded} collection dang trong`
    : '[firestore] dung du lieu that dang co tren Firestore');
}

// Reset du lieu kiem thu (nut Reset trong hop dong): che do Firestore thi
// xoa sach 17 collection roi nap lai du lieu mau
async function resetStore() {
  seedMemory();
  if (!firebaseEnabled) return;
  for (const c of COLLECTIONS) {
    const snap = await firestore.collection(c).get();
    for (let i = 0; i < snap.docs.length; i += 400) {
      const batch = firestore.batch();
      snap.docs.slice(i, i + 400).forEach((d) => batch.delete(d.ref));
      await batch.commit();
    }
    await pushSeedCollection(c);
  }
}

module.exports = { repo, initStore, resetStore, COLLECTIONS };
