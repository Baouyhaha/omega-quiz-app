// Xac thuc nguoi dung tu header Authorization: Bearer <token>.
//
// Hai dang token deu chap nhan:
//   - "dev:<uid>" (vd "dev:uy"): token dev, dung de test o may ca nhan.
//     Chi ton tai khi chay API, khong lien quan toi Firebase Auth.
//   - Token Firebase that (ID token cua Firebase Auth): chi chap nhan khi
//     server da noi Firebase (bien FIREBASE_SERVICE_ACCOUNT). verifyIdToken
//     tra ve uid that cua Firebase Auth — uid nay KHAC uid dev ("uy",
//     "dinh"...), nen lan dang nhap dau tien bang token that se tao ho so
//     moi (xem POST /auth/login). Quyen ADMIN cho tai khoan that phai duoc
//     gan tay tren Firestore console (xem huong-dan-noi-firebase.md).
//
// Moi ham doc du lieu o day deu la async vi du lieu doc qua repo
// (Firestore hoac bo nho — xem store.js).
const { repo } = require('./store');
const { ApiError } = require('./util');
const { auth, firebaseEnabled } = require('./firebase');

async function verifyToken(token) {
  if (token && token.startsWith('dev:')) return token.slice(4);
  if (firebaseEnabled && token) {
    try {
      const decoded = await auth.verifyIdToken(token);
      return decoded.uid;
    } catch (e) {
      return null;
    }
  }
  return null;
}

async function authMiddleware(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) throw new ApiError(401, 'UNAUTHORIZED', 'Thiếu token đăng nhập');
    const uid = await verifyToken(token);
    if (!uid) throw new ApiError(401, 'UNAUTHORIZED', 'Token không hợp lệ');
    const user = await repo.get('users', uid);
    if (!user) throw new ApiError(401, 'UNAUTHORIZED', 'Tài khoản chưa được tạo, hãy gọi auth/login trước');
    if (user.locked) throw new ApiError(403, 'ACCOUNT_LOCKED', 'Tài khoản đã bị khóa');
    req.user = user;
    next();
  } catch (e) {
    next(e);
  }
}

function requireAdmin(req, res, next) {
  if (req.user.role !== 'ADMIN') {
    return next(new ApiError(403, 'FORBIDDEN', 'Chỉ Admin nền tảng mới dùng được chức năng này'));
  }
  next();
}

const WARNING_MS = 7 * 864e5; // 7 ngay canh bao sau khi het han (Dot 2)

// Trang thai vong doi cua goi: ACTIVE (con han) / WARNING (het han chua
// qua 7 ngay - van full quyen) / EXPIRED (qua 7 ngay canh bao)
async function subscriptionState(userId) {
  const sub = await repo.get('subscriptions', userId);
  if (!sub || !sub.expiresAt) return { state: 'ACTIVE', sub };
  const now = Date.now();
  const exp = new Date(sub.expiresAt).getTime();
  if (now <= exp) return { state: 'ACTIVE', sub };
  if (now <= exp + WARNING_MS) return { state: 'WARNING', sub };
  return { state: 'EXPIRED', sub };
}

// Het 7 ngay canh bao: xoa chu de PRIVATE cua chu so huu (kem cau hoi, bo
// de, thanh vien, loi moi), chu de PUBLIC giu lai dang chi-doc. Xu ly lazy
// khi co request dung toi goi cua nguoi dung, chay mot lan moi dot het han.
async function applyExpiryLifecycle(userId) {
  const sub = await repo.get('subscriptions', userId);
  if (!sub || !sub.expiresAt || sub.lifecycleApplied) return;
  if (Date.now() <= new Date(sub.expiresAt).getTime() + WARNING_MS) return;
  sub.lifecycleApplied = true;
  await repo.put('subscriptions', userId, sub);
  const topics = await repo.all('topics');
  for (const topic of topics) {
    if (topic.ownerId !== userId) continue;
    if (topic.visibility === 'PRIVATE') {
      const examIds = new Set((await repo.all('exams')).filter((e) => e.topicId === topic.id).map((e) => e.id));
      await repo.del('topics', topic.id);
      for (const [k, v] of await repo.entries('questions')) if (v.topicId === topic.id) await repo.del('questions', k);
      for (const [k, v] of await repo.entries('exams')) if (v.topicId === topic.id) await repo.del('exams', k);
      for (const [k, v] of await repo.entries('examQuestions')) if (examIds.has(v.examId)) await repo.del('examQuestions', k);
      for (const [k, v] of await repo.entries('topicMembers')) if (v.topicId === topic.id) await repo.del('topicMembers', k);
      for (const [k, v] of await repo.entries('invitations')) if (v.topicId === topic.id) await repo.del('invitations', k);
    } else {
      topic.ownerExpired = true;
      await repo.put('topics', topic.id, topic);
    }
  }
}

// Lay goi dang hieu luc: ACTIVE va WARNING deu dung full quyen cua goi;
// EXPIRED thi ap vong doi roi coi nhu goi mien phi
async function activePlan(userId) {
  const { state, sub } = await subscriptionState(userId);
  if (sub && sub.status === 'ACTIVE' && state !== 'EXPIRED') {
    return { sub, plan: await repo.get('plans', sub.planId), state };
  }
  if (state === 'EXPIRED') await applyExpiryLifecycle(userId);
  return { sub: null, plan: await repo.get('plans', 'free'), state };
}

// Chu de public cua chu so huu da het han goi (qua 7 ngay canh bao) la
// chi-doc: chu so huu khong sua/them duoc nua, cong dong van xem va lam bai
function assertTopicWritable(topic) {
  if (topic.ownerExpired) {
    throw new ApiError(403, 'FORBIDDEN', 'Chủ sở hữu đã hết hạn gói — chủ đề đang ở chế độ chỉ-đọc');
  }
}

// Chu de private: chi chu so huu va thanh vien moi truy cap duoc
async function assertTopicAccess(req, topic) {
  if (topic.visibility !== 'PRIVATE') return;
  const isMember = await repo.has('topicMembers', `${topic.id}:${req.user.uid}`);
  if (topic.ownerId !== req.user.uid && !isMember) {
    throw new ApiError(403, 'FORBIDDEN', 'Chủ đề riêng tư — chỉ chủ sở hữu và thành viên mới truy cập được');
  }
}

// Kiem tra han muc truoc thao tac tao (hop dong API muc 1)
async function checkLimit(userId, kind) {
  const { plan } = await activePlan(userId);
  if (!plan || !plan.limits) return; // goi thue bao: khong gioi han
  const limits = plan.limits;
  if (kind.type === 'topic') {
    const count = (await repo.all('topics')).filter((t) => t.ownerId === userId).length;
    if (count >= limits.maxTopics) {
      throw new ApiError(409, 'LIMIT_EXCEEDED', `Gói miễn phí chỉ tạo tối đa ${limits.maxTopics} chủ đề`);
    }
  }
  if (kind.type === 'exam') {
    const count = (await repo.all('exams')).filter((e) => e.topicId === kind.topicId).length;
    if (count >= limits.maxExamsPerTopic) {
      throw new ApiError(409, 'LIMIT_EXCEEDED', `Gói miễn phí chỉ tạo tối đa ${limits.maxExamsPerTopic} bộ đề mỗi chủ đề`);
    }
  }
  if (kind.type === 'member') {
    const count = (await repo.all('topicMembers')).filter((m) => m.topicId === kind.topicId).length;
    const pending = (await repo.all('invitations')).filter((i) => i.topicId === kind.topicId && i.status === 'PENDING').length;
    if (count + pending + kind.addCount > limits.maxMembersPerTopic) {
      throw new ApiError(409, 'LIMIT_EXCEEDED', `Gói miễn phí tối đa ${limits.maxMembersPerTopic} thành viên mỗi chủ đề`);
    }
  }
}

async function requireTopicOwner(req, topicId) {
  const topic = await repo.get('topics', topicId);
  if (!topic) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy chủ đề');
  if (topic.ownerId !== req.user.uid) {
    throw new ApiError(403, 'FORBIDDEN', 'Chỉ chủ sở hữu chủ đề mới làm được thao tác này');
  }
  return topic;
}

module.exports = { authMiddleware, requireAdmin, activePlan, checkLimit, requireTopicOwner, verifyToken, subscriptionState, applyExpiryLifecycle, assertTopicWritable, assertTopicAccess, WARNING_MS };
