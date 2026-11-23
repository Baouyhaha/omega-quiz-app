// UC19 ban be, UC20 doi khang 1-1, UC21 dot thi khung gio,
// UC22 bang xep hang, UC24 thong ke chu de
const router = require('express').Router();
const { db } = require('../store');
const { ok, ApiError, newId, fisherYates, animalRank, publicQuestion, nowISO } = require('../util');
const { authMiddleware, requireTopicOwner, assertTopicWritable, assertTopicAccess } = require('../auth');
const { startAttempt, examQuestions } = require('./attempts');

router.use(authMiddleware);

// ---------- Ban be ----------
router.get('/friends', (req, res) => {
  const uid = req.user.uid;
  const friends = [];
  const pending = [];
  for (const f of db.friendships.values()) {
    if (f.status === 'ACCEPTED' && (f.userA === uid || f.userB === uid)) {
      const other = db.users.get(f.userA === uid ? f.userB : f.userA);
      if (other) friends.push({ uid: other.uid, name: other.name, email: other.email, rankScore: other.rankScore });
    }
    if (f.status === 'PENDING' && f.userB === uid) {
      const from = db.users.get(f.userA);
      pending.push({ id: f.id, from: from ? { uid: from.uid, name: from.name, email: from.email } : null });
    }
  }
  ok(res, { friends, pendingRequests: pending });
});

router.post('/friends/requests', (req, res, next) => {
  try {
    const email = String((req.body || {}).email || '').toLowerCase();
    const target = [...db.users.values()].find((u) => (u.email || '').toLowerCase() === email);
    if (!target) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy người dùng với email này');
    if (target.uid === req.user.uid) throw new ApiError(400, 'VALIDATION_ERROR', 'Không thể tự kết bạn');
    const key1 = `${req.user.uid}:${target.uid}`;
    const key2 = `${target.uid}:${req.user.uid}`;
    if (db.friendships.has(key1) || db.friendships.has(key2)) {
      throw new ApiError(409, 'VALIDATION_ERROR', 'Đã có lời mời hoặc đã là bạn bè');
    }
    const f = { id: key1, userA: req.user.uid, userB: target.uid, status: 'PENDING', createdAt: nowISO() };
    db.friendships.set(key1, f);
    ok(res, f, 'Đã gửi lời mời kết bạn', 201);
  } catch (e) { next(e); }
});

router.post('/friends/requests/:id/accept', (req, res, next) => {
  try {
    const f = db.friendships.get(req.params.id);
    if (!f || f.status !== 'PENDING' || f.userB !== req.user.uid) {
      throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy lời mời đang chờ');
    }
    f.status = 'ACCEPTED';
    ok(res, f, 'Đã kết bạn');
  } catch (e) { next(e); }
});

// Huy loi moi da gui hoac tu choi loi moi nhan duoc (chi khi con PENDING)
router.delete('/friends/requests/:id', (req, res, next) => {
  try {
    const f = db.friendships.get(req.params.id);
    if (!f || f.status !== 'PENDING') throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy lời mời đang chờ');
    if (f.userA !== req.user.uid && f.userB !== req.user.uid) {
      throw new ApiError(403, 'FORBIDDEN', 'Không có quyền xử lý lời mời này');
    }
    db.friendships.delete(f.id);
    ok(res, null, f.userA === req.user.uid ? 'Đã hủy lời mời kết bạn' : 'Đã từ chối lời mời kết bạn');
  } catch (e) { next(e); }
});

router.delete('/friends/:userId', (req, res) => {
  db.friendships.delete(`${req.user.uid}:${req.params.userId}`);
  db.friendships.delete(`${req.params.userId}:${req.user.uid}`);
  ok(res, null, 'Đã hủy kết bạn');
});

// ---------- Doi khang 1-1 ----------
const battleView = (r) => ({
  id: r.id, code: r.code, topicId: r.topicId, hostId: r.hostId, guestId: r.guestId,
  status: r.status, questionCount: r.questionIds.length,
  ready: r.ready, results: r.results || null, createdAt: r.createdAt,
});

router.post('/battles', (req, res, next) => {
  try {
    const { topicId, questionCount } = req.body || {};
    const topic = db.topics.get(topicId);
    if (!topic) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy chủ đề');
    const n = Math.min(50, Math.max(1, Number(questionCount) || 10));
    const pool = [...db.questions.values()].filter((q) => q.topicId === topicId).map((q) => q.id);
    if (pool.length < n) throw new ApiError(400, 'VALIDATION_ERROR', `Chủ đề chỉ có ${pool.length} câu, không đủ ${n} câu`);
    const { roomCode } = require('../util');
    const room = {
      id: newId('battle'), code: roomCode(), topicId, hostId: req.user.uid, guestId: null,
      status: 'WAITING', questionIds: fisherYates(pool).slice(0, n),
      ready: {}, results: null, createdAt: nowISO(),
    };
    db.battleRooms.set(room.id, room);
    ok(res, battleView(room), 'Đã tạo phòng đối kháng', 201);
  } catch (e) { next(e); }
});

router.post('/battles/:id/join', (req, res, next) => {
  try {
    // :id chap nhan ca id phong lan ma phong (app nhap ma phong)
    const room = db.battleRooms.get(req.params.id) ||
      [...db.battleRooms.values()].find((r) => r.code === req.params.id.toUpperCase());
    if (!room) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy phòng');
    if (room.hostId === req.user.uid) throw new ApiError(400, 'VALIDATION_ERROR', 'Bạn là chủ phòng');
    if (room.guestId && room.guestId !== req.user.uid) throw new ApiError(409, 'VALIDATION_ERROR', 'Phòng đã đủ 2 người');
    room.guestId = req.user.uid;
    ok(res, battleView(room), 'Đã vào phòng');
  } catch (e) { next(e); }
});

router.post('/battles/:id/ready', (req, res, next) => {
  try {
    const room = db.battleRooms.get(req.params.id);
    if (!room) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy phòng');
    if (room.hostId !== req.user.uid && room.guestId !== req.user.uid) {
      throw new ApiError(403, 'FORBIDDEN', 'Bạn không ở trong phòng này');
    }
    room.ready[req.user.uid] = true;
    let questions = null;
    if (room.ready[room.hostId] && room.guestId && room.ready[room.guestId]) {
      room.status = 'IN_PROGRESS';
      const attempt = startAttempt(req.user, null, room.questionIds, { topicId: room.topicId, battleId: room.id });
      room.attemptByUser = room.attemptByUser || {};
      room.attemptByUser[req.user.uid] = attempt.id;
      questions = attempt.questionIds.map((id) => publicQuestion(db.questions.get(id)));
    }
    ok(res, { ...battleView(room), questions }, 'Đã sẵn sàng');
  } catch (e) { next(e); }
});

router.post('/battles/:id/submit', (req, res, next) => {
  try {
    const room = db.battleRooms.get(req.params.id);
    if (!room) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy phòng');
    const { answers, durationSeconds } = req.body || {};
    if (!Array.isArray(answers)) throw new ApiError(400, 'VALIDATION_ERROR', 'Thiếu answers');
    let correct = 0;
    for (const qid of room.questionIds) {
      const q = db.questions.get(qid);
      const a = answers.find((x) => x.questionId === qid);
      if (q && a && a.selectedOption === q.correctOption) correct++;
    }
    room.submissions = room.submissions || {};
    room.submissions[req.user.uid] = { correct, durationSeconds: durationSeconds || 0, at: nowISO() };
    if (room.submissions[room.hostId] && room.guestId && room.submissions[room.guestId]) {
      room.status = 'FINISHED';
      const h = room.submissions[room.hostId];
      const g = room.submissions[room.guestId];
      let winner = null;
      if (h.correct !== g.correct) winner = h.correct > g.correct ? room.hostId : room.guestId;
      else if (h.durationSeconds !== g.durationSeconds) winner = h.durationSeconds < g.durationSeconds ? room.hostId : room.guestId;
      const deltas = {};
      for (const uid of [room.hostId, room.guestId]) {
        deltas[uid] = winner === null ? 0 : winner === uid ? 15 : -10;
        const u = db.users.get(uid);
        if (u) u.rankScore = Math.max(0, u.rankScore + deltas[uid]);
      }
      room.results = { winner, deltas, submissions: room.submissions };
    }
    ok(res, battleView(room), room.status === 'FINISHED' ? 'Trận đấu đã kết thúc' : 'Đã ghi nhận bài nộp, chờ đối thủ');
  } catch (e) { next(e); }
});

// ---------- Dot thi khung gio ----------
const contestView = (c) => {
  const now = new Date();
  const status = now < new Date(c.openAt) ? 'UPCOMING' : now <= new Date(c.closeAt) ? 'OPEN' : 'CLOSED';
  return { ...c, status, enteredCount: [...db.contestEntries.values()].filter((e) => e.contestId === c.id).length };
};

router.post('/topics/:id/contests', (req, res, next) => {
  try {
    const topic = requireTopicOwner(req, req.params.id);
    assertTopicWritable(topic);
    const b = req.body || {};
    if (!b.title || !b.openAt || !b.closeAt || !b.source) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Thiếu title/openAt/closeAt/source');
    }
    let questionIds = [];
    if (b.source.type === 'RANDOM_TOPIC') {
      const n = b.source.questionCount || 20;
      const pool = [...db.questions.values()].filter((q) => q.topicId === topic.id).map((q) => q.id);
      if (pool.length < n) throw new ApiError(400, 'VALIDATION_ERROR', `Chủ đề chỉ có ${pool.length} câu, không đủ ${n} câu`);
      questionIds = fisherYates(pool).slice(0, n);
    } else if (b.source.type === 'EXAM') {
      const exam = db.exams.get(b.source.examId);
      if (!exam || exam.topicId !== topic.id) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy bộ đề trong chủ đề');
      questionIds = examQuestions(exam.id).map((q) => q.id);
    } else {
      throw new ApiError(400, 'VALIDATION_ERROR', 'source.type phải là RANDOM_TOPIC hoặc EXAM');
    }
    const contest = {
      id: newId('contest'), topicId: topic.id, ownerId: req.user.uid, title: b.title,
      openAt: b.openAt, closeAt: b.closeAt, source: b.source, questionIds, createdAt: nowISO(),
    };
    db.contests.set(contest.id, contest);
    ok(res, contestView(contest), 'Đã mở đợt thi', 201);
  } catch (e) { next(e); }
});

router.get('/contests', (req, res) => {
  ok(res, [...db.contests.values()].map(contestView));
});

router.post('/contests/:id/enter', (req, res, next) => {
  try {
    const contest = db.contests.get(req.params.id);
    if (!contest) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy đợt thi');
    const now = new Date();
    if (now < new Date(contest.openAt) || now > new Date(contest.closeAt)) {
      throw new ApiError(409, 'CONTEST_NOT_OPEN', 'Đợt thi không trong khung giờ mở');
    }
    const contestTopic = db.topics.get(contest.topicId);
    if (contestTopic) assertTopicAccess(req, contestTopic);
    const key = `${contest.id}:${req.user.uid}`;
    if (db.contestEntries.has(key)) throw new ApiError(409, 'ALREADY_ENTERED', 'Mỗi tài khoản chỉ được thi 1 lượt trong đợt');
    if (contest.source.type === 'EXAM') {
      const done = [...db.attempts.values()].some(
        (a) => a.examId === contest.source.examId && a.userId === req.user.uid && a.status !== 'IN_PROGRESS');
      if (done) throw new ApiError(409, 'ALREADY_ATTEMPTED', 'Bạn đã làm bộ đề của đợt thi này rồi');
    }
    db.contestEntries.set(key, { contestId: contest.id, userId: req.user.uid, enteredAt: nowISO() });
    const fakeExam = contest.source.type === 'EXAM' ? db.exams.get(contest.source.examId) : null;
    const attempt = startAttempt(req.user, fakeExam, contest.questionIds, { contestId: contest.id, topicId: contest.topicId });
    ok(res, {
      attemptId: attempt.id,
      questions: attempt.questionIds.map((id) => publicQuestion(db.questions.get(id))),
    }, 'Đã vào đợt thi', 201);
  } catch (e) { next(e); }
});

// Xep hang dot thi + cong diem rank mot lan duy nhat khi dot da dong:
// top 1 +20, hang 2-3 +10, con lai +2 (chi tinh nguoi da nop bai) — Dot 2 muc 5
function finalizeContest(contest) {
  const rows = [...db.contestEntries.values()]
    .filter((e) => e.contestId === contest.id)
    .map((e) => {
      const a = [...db.attempts.values()].find(
        (x) => x.contestId === contest.id && x.userId === e.userId && x.status !== 'IN_PROGRESS');
      const u = db.users.get(e.userId);
      return {
        userId: e.userId, name: u ? u.name : '',
        correctCount: a ? a.correctCount : 0,
        durationSeconds: a ? a.durationSeconds : null,
        score: a ? a.score : null,
        submitted: !!a,
      };
    })
    .sort((x, y) => y.correctCount - x.correctCount || (x.durationSeconds ?? 1e9) - (y.durationSeconds ?? 1e9));
  if (!contest.pointsAwarded) {
    contest.pointsAwarded = true;
    contest.awardedDeltas = {};
    rows.forEach((r, i) => {
      const delta = !r.submitted ? 0 : i === 0 ? 20 : i <= 2 ? 10 : 2;
      contest.awardedDeltas[r.userId] = delta;
      const u = db.users.get(r.userId);
      if (u && delta) u.rankScore = Math.max(0, u.rankScore + delta);
    });
  }
  return rows.map((r, i) => ({
    rank: i + 1, userId: r.userId, name: r.name, correctCount: r.correctCount,
    durationSeconds: r.durationSeconds, score: r.score,
    rankDelta: contest.awardedDeltas ? contest.awardedDeltas[r.userId] || 0 : 0,
  }));
}

router.get('/contests/:id/results', (req, res, next) => {
  try {
    const contest = db.contests.get(req.params.id);
    if (!contest) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy đợt thi');
    if (new Date() <= new Date(contest.closeAt)) {
      throw new ApiError(409, 'CONTEST_NOT_OPEN', 'Kết quả chỉ có sau khi hết giờ thi');
    }
    ok(res, finalizeContest(contest));
  } catch (e) { next(e); }
});

// ---------- Xep hang + thong ke chu de ----------
router.get('/leaderboard', (req, res) => {
  const list = [...db.users.values()]
    .filter((u) => u.role === 'USER')
    .sort((a, b) => b.rankScore - a.rankScore)
    .map((u, i) => ({ rank: i + 1, uid: u.uid, name: u.name, rankScore: u.rankScore, animalRank: animalRank(u.rankScore) }));
  ok(res, list);
});

router.get('/topics/:id/stats', (req, res, next) => {
  try {
    requireTopicOwner(req, req.params.id);
    const examIds = new Set([...db.exams.values()].filter((e) => e.topicId === req.params.id).map((e) => e.id));
    const attempts = [...db.attempts.values()].filter((a) => examIds.has(a.examId) && a.status !== 'IN_PROGRESS');
    const avgPercent = attempts.length
      ? Math.round((attempts.reduce((s, a) => s + (a.percent || 0), 0) / attempts.length) * 10) / 10
      : null;
    const perQuestion = {};
    for (const a of attempts) {
      for (const ans of a.answers || []) {
        const q = db.questions.get(ans.questionId);
        if (!q) continue;
        perQuestion[q.id] = perQuestion[q.id] || { questionId: q.id, content: q.content, total: 0, correct: 0 };
        perQuestion[q.id].total++;
        if (ans.selectedOption === q.correctOption) perQuestion[q.id].correct++;
      }
    }
    ok(res, {
      totalAttempts: attempts.length,
      averagePercent: avgPercent,
      perQuestion: Object.values(perQuestion).map((p) => ({ ...p, correctRate: p.total ? Math.round((p.correct / p.total) * 1000) / 10 : 0 })),
    });
  } catch (e) { next(e); }
});

module.exports = router;
module.exports.finalizeContest = finalizeContest;
