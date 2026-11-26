// UC25–UC28 admin nen tang + nut Reset du lieu kiem thu (muc 2.10 hop dong)
const router = require('express').Router();
const { repo } = require('../store');
const { ok, ApiError, animalRank, nowISO } = require('../util');
const { authMiddleware, requireAdmin } = require('../auth');

router.use(authMiddleware, requireAdmin);

router.get('/admin/users', async (req, res, next) => {
  try {
    const q = (req.query.q || '').toLowerCase();
    let list = await repo.all('users');
    if (q) list = list.filter((u) => u.name.toLowerCase().includes(q) || (u.email || '').toLowerCase().includes(q));
    ok(res, list.map((u) => ({
      uid: u.uid, name: u.name, email: u.email, role: u.role,
      rankScore: u.rankScore, animalRank: animalRank(u.rankScore), locked: u.locked,
    })));
  } catch (e) { next(e); }
});

router.get('/admin/users/:id', async (req, res, next) => {
  try {
    const u = await repo.get('users', req.params.id);
    if (!u) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy tài khoản');
    const sub = await repo.get('subscriptions', u.uid);
    ok(res, { ...u, subscription: sub || null });
  } catch (e) { next(e); }
});

router.post('/admin/users/:id/lock', async (req, res, next) => {
  try {
    const u = await repo.get('users', req.params.id);
    if (!u) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy tài khoản');
    u.locked = true;
    await repo.put('users', u.uid, u);
    ok(res, null, 'Đã khóa tài khoản');
  } catch (e) { next(e); }
});

router.post('/admin/users/:id/unlock', async (req, res, next) => {
  try {
    const u = await repo.get('users', req.params.id);
    if (!u) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy tài khoản');
    u.locked = false;
    await repo.put('users', u.uid, u);
    ok(res, null, 'Đã mở khóa tài khoản');
  } catch (e) { next(e); }
});

router.post('/admin/users/:id/subscription', async (req, res, next) => {
  try {
    const u = await repo.get('users', req.params.id);
    if (!u) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy tài khoản');
    const plan = await repo.get('plans', (req.body || {}).planId);
    if (!plan) throw new ApiError(400, 'VALIDATION_ERROR', 'Gói không hợp lệ');
    const exp = plan.days ? new Date(Date.now() + plan.days * 864e5).toISOString() : null;
    await repo.put('subscriptions', u.uid, { userId: u.uid, planId: plan.id, startedAt: nowISO(), expiresAt: exp, status: 'ACTIVE' });
    ok(res, null, `Đã gán ${plan.name} cho tài khoản`);
  } catch (e) { next(e); }
});

router.get('/admin/plans', async (req, res, next) => {
  try { ok(res, await repo.all('plans')); } catch (e) { next(e); }
});

router.put('/admin/plans/:id', async (req, res, next) => {
  try {
    const plan = await repo.get('plans', req.params.id);
    if (!plan) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy gói');
    Object.assign(plan, req.body || {});
    await repo.put('plans', plan.id, plan);
    ok(res, plan, 'Đã cập nhật gói');
  } catch (e) { next(e); }
});

router.get('/admin/stats', async (req, res, next) => {
  try {
    const attempts = await repo.all('attempts');
    ok(res, {
      totalUsers: await repo.count('users'),
      totalTopics: await repo.count('topics'),
      totalQuestions: await repo.count('questions'),
      totalExams: await repo.count('exams'),
      totalAttempts: attempts.filter((a) => a.status !== 'IN_PROGRESS').length,
      totalBattles: await repo.count('battleRooms'),
      totalContests: await repo.count('contests'),
    });
  } catch (e) { next(e); }
});

// Thong ke theo bo de (MH-33): so luot lam da nop, diem % TB/cao nhat/thap nhat
router.get('/admin/stats/exams', async (req, res, next) => {
  try {
    const done = (await repo.all('attempts')).filter((a) => a.examId && a.status !== 'IN_PROGRESS');
    const list = [];
    for (const e of await repo.all('exams')) {
      const mine = done.filter((a) => a.examId === e.id);
      const pcts = mine.map((a) => a.percent || 0);
      const topic = await repo.get('topics', e.topicId);
      list.push({
        examId: e.id, title: e.title, topicId: e.topicId, topicName: topic ? topic.name : null,
        attempts: mine.length,
        averagePercent: pcts.length ? Math.round(pcts.reduce((s, x) => s + x, 0) / pcts.length * 10) / 10 : null,
        highestPercent: pcts.length ? Math.max(...pcts) : null,
        lowestPercent: pcts.length ? Math.min(...pcts) : null,
      });
    }
    ok(res, list);
  } catch (e) { next(e); }
});

// Thong ke theo chu de (MH-33): so luot lam da nop, diem % TB, ti le cau dung
router.get('/admin/stats/topics', async (req, res, next) => {
  try {
    const done = (await repo.all('attempts')).filter((a) => a.topicId && a.status !== 'IN_PROGRESS');
    const list = (await repo.all('topics')).map((t) => {
      const mine = done.filter((a) => a.topicId === t.id);
      const pcts = mine.map((a) => a.percent || 0);
      const totalQ = mine.reduce((s, a) => s + (a.questionIds ? a.questionIds.length : 0), 0);
      const totalRight = mine.reduce((s, a) => s + (a.correctCount || 0), 0);
      return {
        topicId: t.id, name: t.name, attempts: mine.length,
        averagePercent: pcts.length ? Math.round(pcts.reduce((s, x) => s + x, 0) / pcts.length * 10) / 10 : null,
        correctRatio: totalQ ? Math.round(totalRight / totalQ * 1000) / 1000 : null,
      };
    });
    ok(res, list);
  } catch (e) { next(e); }
});

// Tai khoan co vi pham gian lan (MH-33): tong hop tu truong violations cua
// cac luot lam; forceSubmitted = bi tu nop bai khi du 5 lan vi pham
router.get('/admin/stats/violations', async (req, res, next) => {
  try {
    const flagged = (await repo.all('attempts')).filter((a) => (a.violations || 0) > 0);
    const byUser = new Map();
    for (const a of flagged) {
      if (!byUser.has(a.userId)) byUser.set(a.userId, []);
      byUser.get(a.userId).push({
        attemptId: a.id, examId: a.examId, topicId: a.topicId,
        violations: a.violations, status: a.status,
      });
    }
    const list = [];
    for (const [uid, atts] of byUser.entries()) {
      const u = await repo.get('users', uid);
      list.push({
        uid, name: u ? u.name : uid, email: u ? u.email : null,
        totalViolations: atts.reduce((s, x) => s + x.violations, 0),
        forceSubmittedCount: atts.filter((x) => x.status === 'FORCE_SUBMITTED').length,
        attempts: atts,
      });
    }
    list.sort((x, y) => y.totalViolations - x.totalViolations);
    ok(res, list);
  } catch (e) { next(e); }
});

module.exports = router;
