// UC04–UC08 chu de, thanh vien, loi moi, tim kiem
const router = require('express').Router();
const { repo } = require('../store');
const { ok, ApiError, newId, nowISO } = require('../util');
const { authMiddleware, checkLimit, requireTopicOwner, assertTopicWritable } = require('../auth');

async function topicView(t) {
  const [members, exams, questions] = await Promise.all([
    repo.all('topicMembers'), repo.all('exams'), repo.all('questions'),
  ]);
  return {
    ...t,
    memberCount: members.filter((m) => m.topicId === t.id).length,
    examCount: exams.filter((e) => e.topicId === t.id).length,
    questionCount: questions.filter((q) => q.topicId === t.id).length,
  };
}

router.get('/topics/public', async (req, res, next) => {
  try {
    const q = (req.query.q || '').toLowerCase();
    const page = Math.max(1, parseInt(req.query.page || '1', 10));
    const limit = Math.min(50, Math.max(1, parseInt(req.query.limit || '20', 10)));
    let list = (await repo.all('topics')).filter((t) => t.visibility === 'PUBLIC');
    if (q) list = list.filter((t) => t.name.toLowerCase().includes(q));
    const total = list.length;
    const items = [];
    for (const t of list.slice((page - 1) * limit, page * limit)) items.push(await topicView(t));
    ok(res, { items, page, limit, total });
  } catch (e) { next(e); }
});

router.use(authMiddleware);

router.get('/topics/mine', async (req, res, next) => {
  try {
    const uid = req.user.uid;
    const memberOf = new Set((await repo.all('topicMembers')).filter((m) => m.userId === uid).map((m) => m.topicId));
    const mine = (await repo.all('topics')).filter((t) => t.ownerId === uid || memberOf.has(t.id));
    const list = [];
    for (const t of mine) list.push({ ...(await topicView(t)), myRole: t.ownerId === uid ? 'OWNER' : 'MEMBER' });
    ok(res, list);
  } catch (e) { next(e); }
});

router.post('/topics', async (req, res, next) => {
  try {
    const { name, description, visibility } = req.body || {};
    if (!name || !name.trim()) throw new ApiError(400, 'VALIDATION_ERROR', 'Thiếu tên chủ đề');
    await checkLimit(req.user.uid, { type: 'topic' });
    const topic = {
      id: newId('topic'), ownerId: req.user.uid, name: name.trim(),
      description: description || '', visibility: visibility === 'PRIVATE' ? 'PRIVATE' : 'PUBLIC',
      createdAt: nowISO(),
    };
    await repo.put('topics', topic.id, topic);
    ok(res, await topicView(topic), 'Đã tạo chủ đề', 201);
  } catch (e) { next(e); }
});

router.get('/topics/:id', async (req, res, next) => {
  try {
    const topic = await repo.get('topics', req.params.id);
    if (!topic) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy chủ đề');
    const isMember = await repo.has('topicMembers', `${topic.id}:${req.user.uid}`);
    if (topic.visibility === 'PRIVATE' && topic.ownerId !== req.user.uid && !isMember) {
      throw new ApiError(403, 'FORBIDDEN', 'Chủ đề riêng tư');
    }
    ok(res, await topicView(topic));
  } catch (e) { next(e); }
});

router.patch('/topics/:id', async (req, res, next) => {
  try {
    const topic = await requireTopicOwner(req, req.params.id);
    assertTopicWritable(topic);
    const { name, description, visibility } = req.body || {};
    if (name !== undefined) topic.name = name;
    if (description !== undefined) topic.description = description;
    if (visibility !== undefined) topic.visibility = visibility === 'PRIVATE' ? 'PRIVATE' : 'PUBLIC';
    await repo.put('topics', topic.id, topic);
    ok(res, await topicView(topic), 'Đã sửa chủ đề');
  } catch (e) { next(e); }
});

router.delete('/topics/:id', async (req, res, next) => {
  try {
    const topicDel = await requireTopicOwner(req, req.params.id);
    assertTopicWritable(topicDel);
    const id = req.params.id;
    await repo.del('topics', id);
    for (const [k, v] of await repo.entries('topicMembers')) if (v.topicId === id) await repo.del('topicMembers', k);
    for (const [k, v] of await repo.entries('invitations')) if (v.topicId === id) await repo.del('invitations', k);
    ok(res, null, 'Đã xóa chủ đề');
  } catch (e) { next(e); }
});

// POST topics/{id}/join — tham gia CHU DE CONG KHAI (chu de rieng tu chi di qua loi moi)
router.post('/topics/:id/join', async (req, res, next) => {
  try {
    const topic = await repo.get('topics', req.params.id);
    if (!topic) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy chủ đề');
    if (topic.ownerId === req.user.uid) {
      ok(res, { topicId: topic.id, myRole: 'OWNER', alreadyMember: true }, 'Bạn là chủ sở hữu chủ đề này');
      return;
    }
    if (topic.visibility === 'PRIVATE') {
      throw new ApiError(403, 'FORBIDDEN', 'Chủ đề riêng tư — chỉ tham gia bằng lời mời');
    }
    const key = `${topic.id}:${req.user.uid}`;
    if (await repo.has('topicMembers', key)) {
      ok(res, { topicId: topic.id, myRole: 'MEMBER', alreadyMember: true }, 'Đã là thành viên của chủ đề');
      return;
    }
    await checkLimit(topic.ownerId, { type: 'member', topicId: topic.id, addCount: 1 });
    await repo.put('topicMembers', key, {
      topicId: topic.id, userId: req.user.uid, joinedAt: nowISO(),
    });
    ok(res, { topicId: topic.id, myRole: 'MEMBER', alreadyMember: false }, 'Đã tham gia chủ đề', 201);
  } catch (e) { next(e); }
});

router.get('/topics/:id/members', async (req, res, next) => {
  try {
    await requireTopicOwner(req, req.params.id);
    const members = (await repo.all('topicMembers')).filter((m) => m.topicId === req.params.id);
    const list = [];
    for (const m of members) {
      const u = await repo.get('users', m.userId);
      list.push({ userId: m.userId, name: u ? u.name : '', email: u ? u.email : '', joinedAt: m.joinedAt });
    }
    ok(res, list);
  } catch (e) { next(e); }
});

router.post('/topics/:id/invitations', async (req, res, next) => {
  try {
    const topic = await requireTopicOwner(req, req.params.id);
    assertTopicWritable(topic);
    const emails = (req.body && req.body.emails) || [];
    if (!Array.isArray(emails) || emails.length === 0) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Cần danh sách emails');
    }
    await checkLimit(req.user.uid, { type: 'member', topicId: topic.id, addCount: emails.length });
    const created = [];
    for (const email of emails) {
      const inv = {
        id: newId('inv'), topicId: topic.id, email: String(email).trim().toLowerCase(),
        status: 'PENDING', createdAt: nowISO(),
      };
      await repo.put('invitations', inv.id, inv);
      created.push(inv);
    }
    ok(res, created, `Đã gửi ${created.length} lời mời`, 201);
  } catch (e) { next(e); }
});

router.delete('/topics/:id/members/:userId', async (req, res, next) => {
  try {
    const topicMem = await requireTopicOwner(req, req.params.id);
    assertTopicWritable(topicMem);
    await repo.del('topicMembers', `${req.params.id}:${req.params.userId}`);
    ok(res, null, 'Đã xóa thành viên');
  } catch (e) { next(e); }
});

router.get('/invitations/mine', async (req, res, next) => {
  try {
    const email = (req.user.email || '').toLowerCase();
    const pending = (await repo.all('invitations')).filter((i) => i.email === email && i.status === 'PENDING');
    const list = [];
    for (const i of pending) {
      const t = await repo.get('topics', i.topicId);
      list.push({ ...i, topicName: t ? t.name : '' });
    }
    ok(res, list);
  } catch (e) { next(e); }
});

router.post('/invitations/:id/accept', async (req, res, next) => {
  try {
    const inv = await repo.get('invitations', req.params.id);
    if (!inv || inv.status !== 'PENDING') throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy lời mời đang chờ');
    if (inv.email !== (req.user.email || '').toLowerCase()) {
      throw new ApiError(403, 'FORBIDDEN', 'Lời mời này không dành cho tài khoản của bạn');
    }
    inv.status = 'ACCEPTED';
    await repo.put('invitations', inv.id, inv);
    await repo.put('topicMembers', `${inv.topicId}:${req.user.uid}`, {
      topicId: inv.topicId, userId: req.user.uid, joinedAt: nowISO(),
    });
    ok(res, { topicId: inv.topicId }, 'Đã tham gia chủ đề');
  } catch (e) { next(e); }
});

router.get('/search', async (req, res, next) => {
  try {
    const q = (req.query.q || '').toLowerCase();
    const foundTopics = (await repo.all('topics')).filter((t) => t.visibility === 'PUBLIC' && t.name.toLowerCase().includes(q));
    const topics = [];
    for (const t of foundTopics) topics.push(await topicView(t));
    const exams = (await repo.all('exams'))
      .filter((e) => e.title.toLowerCase().includes(q))
      .map((e) => ({ id: e.id, topicId: e.topicId, title: e.title }));
    ok(res, { topics, exams });
  } catch (e) { next(e); }
});

module.exports = router;
