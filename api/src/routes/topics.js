// UC04–UC08 chu de, thanh vien, loi moi, tim kiem
const router = require('express').Router();
const { db } = require('../store');
const { ok, ApiError, newId, nowISO } = require('../util');
const { authMiddleware, checkLimit, requireTopicOwner, assertTopicWritable } = require('../auth');

const topicView = (t) => ({
  ...t,
  memberCount: [...db.topicMembers.values()].filter((m) => m.topicId === t.id).length,
  examCount: [...db.exams.values()].filter((e) => e.topicId === t.id).length,
  questionCount: [...db.questions.values()].filter((q) => q.topicId === t.id).length,
});

router.get('/topics/public', (req, res) => {
  const q = (req.query.q || '').toLowerCase();
  const page = Math.max(1, parseInt(req.query.page || '1', 10));
  const limit = Math.min(50, Math.max(1, parseInt(req.query.limit || '20', 10)));
  let list = [...db.topics.values()].filter((t) => t.visibility === 'PUBLIC');
  if (q) list = list.filter((t) => t.name.toLowerCase().includes(q));
  const total = list.length;
  list = list.slice((page - 1) * limit, page * limit).map(topicView);
  ok(res, { items: list, page, limit, total });
});

router.use(authMiddleware);

router.get('/topics/mine', (req, res) => {
  const uid = req.user.uid;
  const memberOf = new Set([...db.topicMembers.values()].filter((m) => m.userId === uid).map((m) => m.topicId));
  const list = [...db.topics.values()]
    .filter((t) => t.ownerId === uid || memberOf.has(t.id))
    .map((t) => ({ ...topicView(t), myRole: t.ownerId === uid ? 'OWNER' : 'MEMBER' }));
  ok(res, list);
});

router.post('/topics', (req, res, next) => {
  try {
    const { name, description, visibility } = req.body || {};
    if (!name || !name.trim()) throw new ApiError(400, 'VALIDATION_ERROR', 'Thiếu tên chủ đề');
    checkLimit(req.user.uid, { type: 'topic' });
    const topic = {
      id: newId('topic'), ownerId: req.user.uid, name: name.trim(),
      description: description || '', visibility: visibility === 'PRIVATE' ? 'PRIVATE' : 'PUBLIC',
      createdAt: nowISO(),
    };
    db.topics.set(topic.id, topic);
    ok(res, topicView(topic), 'Đã tạo chủ đề', 201);
  } catch (e) { next(e); }
});

router.get('/topics/:id', (req, res, next) => {
  try {
    const topic = db.topics.get(req.params.id);
    if (!topic) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy chủ đề');
    const isMember = db.topicMembers.has(`${topic.id}:${req.user.uid}`);
    if (topic.visibility === 'PRIVATE' && topic.ownerId !== req.user.uid && !isMember) {
      throw new ApiError(403, 'FORBIDDEN', 'Chủ đề riêng tư');
    }
    ok(res, topicView(topic));
  } catch (e) { next(e); }
});

router.patch('/topics/:id', (req, res, next) => {
  try {
    const topic = requireTopicOwner(req, req.params.id);
    assertTopicWritable(topic);
    const { name, description, visibility } = req.body || {};
    if (name !== undefined) topic.name = name;
    if (description !== undefined) topic.description = description;
    if (visibility !== undefined) topic.visibility = visibility === 'PRIVATE' ? 'PRIVATE' : 'PUBLIC';
    ok(res, topicView(topic), 'Đã sửa chủ đề');
  } catch (e) { next(e); }
});

router.delete('/topics/:id', (req, res, next) => {
  try {
    const topicDel = requireTopicOwner(req, req.params.id);
    assertTopicWritable(topicDel);
    const id = req.params.id;
    db.topics.delete(id);
    for (const [k, v] of [...db.topicMembers]) if (v.topicId === id) db.topicMembers.delete(k);
    for (const [k, v] of [...db.invitations]) if (v.topicId === id) db.invitations.delete(k);
    ok(res, null, 'Đã xóa chủ đề');
  } catch (e) { next(e); }
});

router.get('/topics/:id/members', (req, res, next) => {
  try {
    requireTopicOwner(req, req.params.id);
    const members = [...db.topicMembers.values()]
      .filter((m) => m.topicId === req.params.id)
      .map((m) => {
        const u = db.users.get(m.userId);
        return { userId: m.userId, name: u ? u.name : '', email: u ? u.email : '', joinedAt: m.joinedAt };
      });
    ok(res, members);
  } catch (e) { next(e); }
});

router.post('/topics/:id/invitations', (req, res, next) => {
  try {
    const topic = requireTopicOwner(req, req.params.id);
    assertTopicWritable(topic);
    const emails = (req.body && req.body.emails) || [];
    if (!Array.isArray(emails) || emails.length === 0) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Cần danh sách emails');
    }
    checkLimit(req.user.uid, { type: 'member', topicId: topic.id, addCount: emails.length });
    const created = [];
    for (const email of emails) {
      const inv = {
        id: newId('inv'), topicId: topic.id, email: String(email).trim().toLowerCase(),
        status: 'PENDING', createdAt: nowISO(),
      };
      db.invitations.set(inv.id, inv);
      created.push(inv);
    }
    ok(res, created, `Đã gửi ${created.length} lời mời`, 201);
  } catch (e) { next(e); }
});

router.delete('/topics/:id/members/:userId', (req, res, next) => {
  try {
    const topicMem = requireTopicOwner(req, req.params.id);
    assertTopicWritable(topicMem);
    db.topicMembers.delete(`${req.params.id}:${req.params.userId}`);
    ok(res, null, 'Đã xóa thành viên');
  } catch (e) { next(e); }
});

router.get('/invitations/mine', (req, res) => {
  const email = (req.user.email || '').toLowerCase();
  const list = [...db.invitations.values()]
    .filter((i) => i.email === email && i.status === 'PENDING')
    .map((i) => ({ ...i, topicName: (db.topics.get(i.topicId) || {}).name || '' }));
  ok(res, list);
});

router.post('/invitations/:id/accept', (req, res, next) => {
  try {
    const inv = db.invitations.get(req.params.id);
    if (!inv || inv.status !== 'PENDING') throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy lời mời đang chờ');
    if (inv.email !== (req.user.email || '').toLowerCase()) {
      throw new ApiError(403, 'FORBIDDEN', 'Lời mời này không dành cho tài khoản của bạn');
    }
    inv.status = 'ACCEPTED';
    db.topicMembers.set(`${inv.topicId}:${req.user.uid}`, {
      topicId: inv.topicId, userId: req.user.uid, joinedAt: nowISO(),
    });
    ok(res, { topicId: inv.topicId }, 'Đã tham gia chủ đề');
  } catch (e) { next(e); }
});

router.get('/search', (req, res) => {
  const q = (req.query.q || '').toLowerCase();
  const topics = [...db.topics.values()]
    .filter((t) => t.visibility === 'PUBLIC' && t.name.toLowerCase().includes(q))
    .map(topicView);
  const exams = [...db.exams.values()]
    .filter((e) => e.title.toLowerCase().includes(q))
    .map((e) => ({ id: e.id, topicId: e.topicId, title: e.title }));
  ok(res, { topics, exams });
});

module.exports = router;
