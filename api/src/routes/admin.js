// UC25–UC28 admin nen tang + nut Reset du lieu kiem thu (muc 2.10 hop dong)
const router = require('express').Router();
const { db } = require('../store');
const { ok, ApiError, animalRank, nowISO } = require('../util');
const { authMiddleware, requireAdmin } = require('../auth');

router.use(authMiddleware, requireAdmin);

router.get('/admin/users', (req, res) => {
  const q = (req.query.q || '').toLowerCase();
  let list = [...db.users.values()];
  if (q) list = list.filter((u) => u.name.toLowerCase().includes(q) || (u.email || '').toLowerCase().includes(q));
  ok(res, list.map((u) => ({
    uid: u.uid, name: u.name, email: u.email, role: u.role,
    rankScore: u.rankScore, animalRank: animalRank(u.rankScore), locked: u.locked,
  })));
});

router.get('/admin/users/:id', (req, res, next) => {
  try {
    const u = db.users.get(req.params.id);
    if (!u) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy tài khoản');
    const sub = db.subscriptions.get(u.uid);
    ok(res, { ...u, subscription: sub || null });
  } catch (e) { next(e); }
});

router.post('/admin/users/:id/lock', (req, res, next) => {
  try {
    const u = db.users.get(req.params.id);
    if (!u) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy tài khoản');
    u.locked = true;
    ok(res, null, 'Đã khóa tài khoản');
  } catch (e) { next(e); }
});

router.post('/admin/users/:id/unlock', (req, res, next) => {
  try {
    const u = db.users.get(req.params.id);
    if (!u) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy tài khoản');
    u.locked = false;
    ok(res, null, 'Đã mở khóa tài khoản');
  } catch (e) { next(e); }
});

router.post('/admin/users/:id/subscription', (req, res, next) => {
  try {
    const u = db.users.get(req.params.id);
    if (!u) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy tài khoản');
    const plan = db.plans.get((req.body || {}).planId);
    if (!plan) throw new ApiError(400, 'VALIDATION_ERROR', 'Gói không hợp lệ');
    const exp = plan.days ? new Date(Date.now() + plan.days * 864e5).toISOString() : null;
    db.subscriptions.set(u.uid, { userId: u.uid, planId: plan.id, startedAt: nowISO(), expiresAt: exp, status: 'ACTIVE' });
    ok(res, null, `Đã gán ${plan.name} cho tài khoản`);
  } catch (e) { next(e); }
});

router.get('/admin/plans', (req, res) => ok(res, [...db.plans.values()]));

router.put('/admin/plans/:id', (req, res, next) => {
  try {
    const plan = db.plans.get(req.params.id);
    if (!plan) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy gói');
    Object.assign(plan, req.body || {});
    ok(res, plan, 'Đã cập nhật gói');
  } catch (e) { next(e); }
});

router.get('/admin/stats', (req, res) => {
  ok(res, {
    totalUsers: db.users.size,
    totalTopics: db.topics.size,
    totalQuestions: db.questions.size,
    totalExams: db.exams.size,
    totalAttempts: [...db.attempts.values()].filter((a) => a.status !== 'IN_PROGRESS').length,
    totalBattles: db.battleRooms.size,
    totalContests: db.contests.size,
  });
});

module.exports = router;
