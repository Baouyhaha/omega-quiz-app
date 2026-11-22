// UC01 dang nhap, UC03 ho so, UC02 goi thue
const router = require('express').Router();
const { db } = require('../store');
const { ok, ApiError, animalRank, nowISO } = require('../util');
const { authMiddleware, activePlan, verifyToken, subscriptionState, WARNING_MS } = require('../auth');

function profileOf(user) {
  const { sub, plan } = activePlan(user.uid);
  const myAttempts = [...db.attempts.values()].filter((a) => a.userId === user.uid && a.status !== 'IN_PROGRESS');
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
    let user = db.users.get(uid);
    if (!user) {
      const { name, email, photoUrl } = req.body || {};
      user = {
        uid, name: name || 'Người dùng', email: email || '', photoUrl: photoUrl || null,
        role: 'USER', rankScore: 1000, locked: false, createdAt: nowISO(),
      };
      db.users.set(uid, user);
      const exp = new Date(Date.now() + 7 * 864e5).toISOString();
      db.subscriptions.set(uid, { userId: uid, planId: 'trial', startedAt: nowISO(), expiresAt: exp, status: 'ACTIVE' });
    }
    if (user.locked) throw new ApiError(403, 'ACCOUNT_LOCKED', 'Tài khoản đã bị khóa');
    ok(res, profileOf(user), 'Đăng nhập thành công');
  } catch (e) { next(e); }
});

router.get('/me', authMiddleware, (req, res) => ok(res, profileOf(req.user)));

router.patch('/me', authMiddleware, (req, res) => {
  const { name, photoUrl } = req.body || {};
  if (name !== undefined) req.user.name = name;
  if (photoUrl !== undefined) req.user.photoUrl = photoUrl;
  ok(res, profileOf(req.user), 'Đã cập nhật hồ sơ');
});

router.get('/plans', (req, res) => ok(res, [...db.plans.values()]));

router.get('/me/subscription', authMiddleware, (req, res) => {
  const { sub, plan } = activePlan(req.user.uid);
  const { state } = subscriptionState(req.user.uid);
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
});

router.post('/me/subscription/mock-pay', authMiddleware, (req, res, next) => {
  try {
    const { planId } = req.body || {};
    const plan = db.plans.get(planId);
    if (!plan || planId === 'free') throw new ApiError(400, 'VALIDATION_ERROR', 'Gói không hợp lệ');
    const cur = db.subscriptions.get(req.user.uid);
    const base = cur && cur.expiresAt && new Date(cur.expiresAt) > new Date() && cur.planId === planId
      ? new Date(cur.expiresAt)
      : new Date();
    const exp = plan.days ? new Date(base.getTime() + plan.days * 864e5).toISOString() : null;
    db.subscriptions.set(req.user.uid, {
      userId: req.user.uid, planId, startedAt: nowISO(), expiresAt: exp, status: 'ACTIVE',
    });
    ok(res, profileOf(req.user).subscription, `Đã kích hoạt ${plan.name} (thanh toán mô phỏng)`);
  } catch (e) { next(e); }
});

module.exports = router;
