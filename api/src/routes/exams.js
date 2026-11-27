// UC11 bo de, UC12 cai dat bo de, UC23 yeu thich
const router = require('express').Router();
const { repo } = require('../store');
const { ok, ApiError, newId, fisherYates, nowISO } = require('../util');
const { authMiddleware, checkLimit, requireTopicOwner, assertTopicWritable, assertTopicAccess } = require('../auth');

async function examView(e) {
  const links = await repo.all('examQuestions');
  return { ...e, questionCount: links.filter((x) => x.examId === e.id).length };
}

router.use(authMiddleware);

router.get('/topics/:id/exams', async (req, res, next) => {
  try {
    const topicOfList = await repo.get('topics', req.params.id);
    if (!topicOfList) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy chủ đề');
    await assertTopicAccess(req, topicOfList);
    const list = [];
    for (const e of (await repo.all('exams')).filter((x) => x.topicId === req.params.id)) list.push(await examView(e));
    ok(res, list);
  } catch (e) { next(e); }
});

router.post('/topics/:id/exams', async (req, res, next) => {
  try {
    const topic = await requireTopicOwner(req, req.params.id);
    assertTopicWritable(topic);
    const b = req.body || {};
    if (!b.title) throw new ApiError(400, 'VALIDATION_ERROR', 'Thiếu tên bộ đề');
    await checkLimit(req.user.uid, { type: 'exam', topicId: topic.id });
    let questionIds = [];
    if (b.mode === 'RANDOM') {
      const counts = b.counts || { easy: 8, medium: 7, hard: 5 };
      const pool = (await repo.all('questions')).filter((q) => q.topicId === topic.id);
      for (const [diff, n] of Object.entries(counts)) {
        const ofDiff = fisherYates(pool.filter((q) => q.difficulty === diff).map((q) => q.id));
        if (ofDiff.length < n) {
          throw new ApiError(400, 'VALIDATION_ERROR', `Kho chỉ có ${ofDiff.length} câu mức ${diff}, không đủ ${n} câu`);
        }
        questionIds.push(...ofDiff.slice(0, n));
      }
    } else {
      questionIds = b.questionIds || [];
      if (!questionIds.length) throw new ApiError(400, 'VALIDATION_ERROR', 'Cần chọn ít nhất 1 câu hỏi');
    }
    const exam = {
      id: newId('exam'), topicId: topic.id, ownerId: req.user.uid,
      title: b.title, description: b.description || '', createdAt: nowISO(),
      settings: {
        openAt: null, closeAt: null, durationMinutes: 20, maxAttempts: 1, pin: null,
        shuffleQuestions: true, shuffleOptions: true, allowHelpers: true,
        showAnswerMode: 'AFTER_CLOSE', publishScore: true,
      },
    };
    await repo.put('exams', exam.id, exam);
    for (let i = 0; i < questionIds.length; i++) {
      await repo.put('examQuestions', `${exam.id}:${questionIds[i]}`, { examId: exam.id, questionId: questionIds[i], order: i });
    }
    ok(res, await examView(exam), 'Đã tạo bộ đề', 201);
  } catch (e) { next(e); }
});

router.get('/exams/:id', async (req, res, next) => {
  try {
    const exam = await repo.get('exams', req.params.id);
    if (!exam) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy bộ đề');
    ok(res, await examView(exam));
  } catch (e) { next(e); }
});

router.patch('/exams/:id', async (req, res, next) => {
  try {
    const exam = await repo.get('exams', req.params.id);
    if (!exam) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy bộ đề');
    assertTopicWritable(await requireTopicOwner(req, exam.topicId));
    const { title, description } = req.body || {};
    if (title !== undefined) exam.title = title;
    if (description !== undefined) exam.description = description;
    await repo.put('exams', exam.id, exam);
    ok(res, await examView(exam), 'Đã sửa bộ đề');
  } catch (e) { next(e); }
});

router.patch('/exams/:id/settings', async (req, res, next) => {
  try {
    const exam = await repo.get('exams', req.params.id);
    if (!exam) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy bộ đề');
    assertTopicWritable(await requireTopicOwner(req, exam.topicId));
    Object.assign(exam.settings, req.body || {});
    await repo.put('exams', exam.id, exam);
    ok(res, await examView(exam), 'Đã lưu cài đặt');
  } catch (e) { next(e); }
});

router.post('/exams/:id/favorite', async (req, res, next) => {
  try {
    if (!(await repo.get('exams', req.params.id))) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy bộ đề');
    await repo.put('favorites', `${req.user.uid}:${req.params.id}`, { userId: req.user.uid, examId: req.params.id, createdAt: nowISO() });
    ok(res, null, 'Đã thêm vào yêu thích');
  } catch (e) { next(e); }
});

router.delete('/exams/:id/favorite', async (req, res, next) => {
  try {
    await repo.del('favorites', `${req.user.uid}:${req.params.id}`);
    ok(res, null, 'Đã bỏ yêu thích');
  } catch (e) { next(e); }
});

router.get('/favorites', async (req, res, next) => {
  try {
    const favs = (await repo.all('favorites')).filter((f) => f.userId === req.user.uid);
    const list = [];
    for (const f of favs) {
      const e = await repo.get('exams', f.examId);
      if (e) list.push(await examView(e));
    }
    ok(res, list);
  } catch (e) { next(e); }
});

module.exports = router;
