// UC01 dang nhap, UC03 ho so, UC02 goi thue
const router = require('express').Router();
const { repo } = require('../store');
const { ok, ApiError, animalRank, nowISO } = require('../util');
const { authMiddleware, activePlan, verifyToken, subscriptionState, WARNING_MS } = require('../auth');

async function profileOf(user) {
  const { sub, plan } = await activePlan(user.uid);
  const myAttempts = (await repo.all('attempts')).filter((a) => a.userId === user.uid && a.status !== 'IN_PROGRESS');
  const avg = myAttempts.length
    ? Math.round((myAttempts.reduce((s, a) => s + (a.percent || 0), 0) / myAttempts.length) * 10) / 10
    : null;
  return {
    uid: user.uid,
    name: user.name,
    email: user.email,
    photoUrl: user.photoUrl,
    role: user.role,
    rankScore: user.rankScore,
    animalRank: animalRank(user.rankScore),
    averagePercent: avg,
    subscription: sub
      ? { planId: sub.planId, planName: plan ? plan.name : sub.planId, expiresAt: sub.expiresAt, status: sub.status }
      : { planId: 'free', planName: 'Miễn phí', expiresAt: null, status: 'ACTIVE' },
  };
}

// POST auth/login — tao ho so lan dau + kich hoat dung thu 7 ngay
router.post('/auth/login', async (req, res, next) => {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    const uid = token ? await verifyToken(token) : null;
    if (!uid) throw new ApiError(401, 'UNAUTHORIZED', 'Token không hợp lệ');
    let user = await repo.get('users', uid);
    if (!user) {
      const { name, email, photoUrl } = req.body || {};
      user = {
        uid, name: name || 'Người dùng', email: email || '', photoUrl: photoUrl || null,
        role: 'USER', rankScore: 1000, locked: false, createdAt: nowISO(),
      };
      await repo.put('users', uid, user);
      const exp = new Date(Date.now() + 7 * 864e5).toISOString();
      await repo.put('subscriptions', uid, { userId: uid, planId: 'trial', startedAt: nowISO(), expiresAt: exp, status: 'ACTIVE' });
    }
    if (user.locked) throw new ApiError(403, 'ACCOUNT_LOCKED', 'Tài khoản đã bị khóa');
    ok(res, await profileOf(user), 'Đăng nhập thành công');
  } catch (e) { next(e); }
});

router.get('/me', authMiddleware, async (req, res, next) => {
  try { ok(res, await profileOf(req.user)); } catch (e) { next(e); }
});

router.patch('/me', authMiddleware, async (req, res, next) => {
  try {
    const { name, photoUrl } = req.body || {};
    if (name !== undefined) req.user.name = name;
    if (photoUrl !== undefined) req.user.photoUrl = photoUrl;
    await repo.put('users', req.user.uid, req.user);
    ok(res, await profileOf(req.user), 'Đã cập nhật hồ sơ');
  } catch (e) { next(e); }
});

router.get('/plans', async (req, res, next) => {
  try { ok(res, await repo.all('plans')); } catch (e) { next(e); }
});

router.get('/me/subscription', authMiddleware, async (req, res, next) => {
  try {
    const { sub, plan } = await activePlan(req.user.uid);
    const { state } = await subscriptionState(req.user.uid);
    const daysLeft = sub && sub.expiresAt
      ? Math.max(0, Math.ceil((new Date(sub.expiresAt) - new Date()) / 864e5))
      : null;
    // Trong giai doan WARNING: dem nguoc den ngay xoa du lieu (het han + 7 ngay)
    const warningDaysLeft = state === 'WARNING' && sub && sub.expiresAt
      ? Math.max(0, Math.ceil((new Date(sub.expiresAt).getTime() + WARNING_MS - Date.now()) / 864e5))
      : (daysLeft !== null && daysLeft <= 7 ? daysLeft : null);
    ok(res, {
      planId: plan ? plan.id : 'free',
      planName: plan ? plan.name : 'Miễn phí',
      limits: plan ? plan.limits : null,
      expiresAt: sub ? sub.expiresAt : null,
      daysLeft,
      lifecycleState: state,
      warningDaysLeft,
    });
  } catch (e) { next(e); }
});

router.post('/me/subscription/mock-pay', authMiddleware, async (req, res, next) => {
  try {
    const { planId } = req.body || {};
    const plan = await repo.get('plans', planId);
    if (!plan || planId === 'free') throw new ApiError(400, 'VALIDATION_ERROR', 'Gói không hợp lệ');
    const cur = await repo.get('subscriptions', req.user.uid);
    const base = cur && cur.expiresAt && new Date(cur.expiresAt) > new Date() && cur.planId === planId
      ? new Date(cur.expiresAt)
      : new Date();
    const exp = plan.days ? new Date(base.getTime() + plan.days * 864e5).toISOString() : null;
    await repo.put('subscriptions', req.user.uid, {
      userId: req.user.uid, planId, startedAt: nowISO(), expiresAt: exp, status: 'ACTIVE',
    });
    ok(res, (await profileOf(req.user)).subscription, `Đã kích hoạt ${plan.name} (thanh toán mô phỏng)`);
  } catch (e) { next(e); }
});

module.exports = router;
