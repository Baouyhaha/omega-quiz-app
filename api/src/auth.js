// Xac thuc nguoi dung tu header Authorization: Bearer <token>.
//
// Che do hien tai (phat trien): token dang "dev:<uid>", vi du "dev:uy".
// Khi noi Firebase that: cai firebase-admin, nap khoa dich vu qua bien
// FIREBASE_SERVICE_ACCOUNT, roi thay ham verifyToken() bang
// admin.auth().verifyIdToken(token) va lay uid tu ket qua.
const { db } = require('./store');
const { ApiError } = require('./util');

async function verifyToken(token) {
  if (token && token.startsWith('dev:')) return token.slice(4);
  // ponytail: chua noi Firebase Admin — token that se bi tu choi cho den
  // khi verifyIdToken duoc nap vao day.
  return null;
}

async function authMiddleware(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) throw new ApiError(401, 'UNAUTHORIZED', 'Thiếu token đăng nhập');
    const uid = await verifyToken(token);
    if (!uid) throw new ApiError(401, 'UNAUTHORIZED', 'Token không hợp lệ');
    const user = db.users.get(uid);
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
function subscriptionState(userId) {
  const sub = db.subscriptions.get(userId);
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
function applyExpiryLifecycle(userId) {
  const sub = db.subscriptions.get(userId);
  if (!sub || !sub.expiresAt || sub.lifecycleApplied) return;
  if (Date.now() <= new Date(sub.expiresAt).getTime() + WARNING_MS) return;
  sub.lifecycleApplied = true;
  for (const topic of [...db.topics.values()]) {
    if (topic.ownerId !== userId) continue;
    if (topic.visibility === 'PRIVATE') {
      const examIds = new Set([...db.exams.values()].filter((e) => e.topicId === topic.id).map((e) => e.id));
      db.topics.delete(topic.id);
      for (const [k, v] of [...db.questions]) if (v.topicId === topic.id) db.questions.delete(k);
      for (const [k, v] of [...db.exams]) if (v.topicId === topic.id) db.exams.delete(k);
      for (const [k, v] of [...db.examQuestions]) if (examIds.has(v.examId)) db.examQuestions.delete(k);
      for (const [k, v] of [...db.topicMembers]) if (v.topicId === topic.id) db.topicMembers.delete(k);
      for (const [k, v] of [...db.invitations]) if (v.topicId === topic.id) db.invitations.delete(k);
    } else {
      topic.ownerExpired = true;
    }
  }
}

// Lay goi dang hieu luc: ACTIVE va WARNING deu dung full quyen cua goi;
// EXPIRED thi ap vong doi roi coi nhu goi mien phi
function activePlan(userId) {
  const { state, sub } = subscriptionState(userId);
  if (sub && sub.status === 'ACTIVE' && state !== 'EXPIRED') {
    return { sub, plan: db.plans.get(sub.planId), state };
  }
  if (state === 'EXPIRED') applyExpiryLifecycle(userId);
  return { sub: null, plan: db.plans.get('free'), state };
}

// Chu de public cua chu so huu da het han goi (qua 7 ngay canh bao) la
// chi-doc: chu so huu khong sua/them duoc nua, cong dong van xem va lam bai
function assertTopicWritable(topic) {
  if (topic.ownerExpired) {
    throw new ApiError(403, 'FORBIDDEN', 'Chủ sở hữu đã hết hạn gói — chủ đề đang ở chế độ chỉ-đọc');
  }
}

// Chu de private: chi chu so huu va thanh vien moi truy cap duoc
function assertTopicAccess(req, topic) {
  if (topic.visibility !== 'PRIVATE') return;
  const isMember = db.topicMembers.has(`${topic.id}:${req.user.uid}`);
  if (topic.ownerId !== req.user.uid && !isMember) {
    throw new ApiError(403, 'FORBIDDEN', 'Chủ đề riêng tư — chỉ chủ sở hữu và thành viên mới truy cập được');
  }
}

// Kiem tra han muc truoc thao tac tao (hop dong API muc 1)
function checkLimit(userId, kind) {
  const { plan } = activePlan(userId);
  if (!plan || !plan.limits) return; // goi thue bao: khong gioi han
  const limits = plan.limits;
  if (kind.type === 'topic') {
    const count = [...db.topics.values()].filter((t) => t.ownerId === userId).length;
    if (count >= limits.maxTopics) {
      throw new ApiError(409, 'LIMIT_EXCEEDED', `Gói miễn phí chỉ tạo tối đa ${limits.maxTopics} chủ đề`);
    }
  }
  if (kind.type === 'exam') {
    const count = [...db.exams.values()].filter((e) => e.topicId === kind.topicId).length;
    if (count >= limits.maxExamsPerTopic) {
      throw new ApiError(409, 'LIMIT_EXCEEDED', `Gói miễn phí chỉ tạo tối đa ${limits.maxExamsPerTopic} bộ đề mỗi chủ đề`);
    }
  }
  if (kind.type === 'member') {
    const count = [...db.topicMembers.values()].filter((m) => m.topicId === kind.topicId).length;
    const pending = [...db.invitations.values()].filter((i) => i.topicId === kind.topicId && i.status === 'PENDING').length;
    if (count + pending + kind.addCount > limits.maxMembersPerTopic) {
      throw new ApiError(409, 'LIMIT_EXCEEDED', `Gói miễn phí tối đa ${limits.maxMembersPerTopic} thành viên mỗi chủ đề`);
    }
  }
}

function requireTopicOwner(req, topicId) {
  const topic = db.topics.get(topicId);
  if (!topic) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy chủ đề');
  if (topic.ownerId !== req.user.uid) {
    throw new ApiError(403, 'FORBIDDEN', 'Chỉ chủ sở hữu chủ đề mới làm được thao tác này');
  }
  return topic;
}

module.exports = { authMiddleware, requireAdmin, activePlan, checkLimit, requireTopicOwner, verifyToken, subscriptionState, applyExpiryLifecycle, assertTopicWritable, assertTopicAccess, WARNING_MS };
