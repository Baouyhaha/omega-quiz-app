// UC11 bo de, UC12 cai dat bo de, UC23 yeu thich
const router = require('express').Router();
const { db } = require('../store');
const { ok, ApiError, newId, fisherYates, nowISO } = require('../util');
const { authMiddleware, checkLimit, requireTopicOwner, assertTopicWritable, assertTopicAccess } = require('../auth');

const examView = (e) => ({
  ...e,
  questionCount: [...db.examQuestions.values()].filter((x) => x.examId === e.id).length,
});

router.use(authMiddleware);

router.get('/topics/:id/exams', (req, res, next) => {
  try {
    const topicOfList = db.topics.get(req.params.id);
    if (!topicOfList) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy chủ đề');
    assertTopicAccess(req, topicOfList);
    ok(res, [...db.exams.values()].filter((e) => e.topicId === req.params.id).map(examView));
  } catch (e) { next(e); }
});

router.post('/topics/:id/exams', (req, res, next) => {
  try {
    const topic = requireTopicOwner(req, req.params.id);
    assertTopicWritable(topic);
    const b = req.body || {};
    if (!b.title) throw new ApiError(400, 'VALIDATION_ERROR', 'Thiếu tên bộ đề');
    checkLimit(req.user.uid, { type: 'exam', topicId: topic.id });
    let questionIds = [];
    if (b.mode === 'RANDOM') {
      const counts = b.counts || { easy: 8, medium: 7, hard: 5 };
      const pool = [...db.questions.values()].filter((q) => q.topicId === topic.id);
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
    db.exams.set(exam.id, exam);
    questionIds.forEach((qid, i) => db.examQuestions.set(`${exam.id}:${qid}`, { examId: exam.id, questionId: qid, order: i }));
    ok(res, examView(exam), 'Đã tạo bộ đề', 201);
  } catch (e) { next(e); }
});

router.get('/exams/:id', (req, res, next) => {
  try {
    const exam = db.exams.get(req.params.id);
    if (!exam) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy bộ đề');
    ok(res, examView(exam));
  } catch (e) { next(e); }
});

router.patch('/exams/:id', (req, res, next) => {
  try {
    const exam = db.exams.get(req.params.id);
    if (!exam) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy bộ đề');
    assertTopicWritable(requireTopicOwner(req, exam.topicId));
    const { title, description } = req.body || {};
    if (title !== undefined) exam.title = title;
    if (description !== undefined) exam.description = description;
    ok(res, examView(exam), 'Đã sửa bộ đề');
  } catch (e) { next(e); }
});

router.patch('/exams/:id/settings', (req, res, next) => {
  try {
    const exam = db.exams.get(req.params.id);
    if (!exam) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy bộ đề');
    assertTopicWritable(requireTopicOwner(req, exam.topicId));
    Object.assign(exam.settings, req.body || {});
    ok(res, examView(exam), 'Đã lưu cài đặt');
  } catch (e) { next(e); }
});

router.post('/exams/:id/favorite', (req, res, next) => {
  try {
    if (!db.exams.get(req.params.id)) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy bộ đề');
    db.favorites.set(`${req.user.uid}:${req.params.id}`, { userId: req.user.uid, examId: req.params.id, createdAt: nowISO() });
    ok(res, null, 'Đã thêm vào yêu thích');
  } catch (e) { next(e); }
});

router.delete('/exams/:id/favorite', (req, res) => {
  db.favorites.delete(`${req.user.uid}:${req.params.id}`);
  ok(res, null, 'Đã bỏ yêu thích');
});

router.get('/favorites', (req, res) => {
  const list = [...db.favorites.values()]
    .filter((f) => f.userId === req.user.uid)
    .map((f) => db.exams.get(f.examId))
    .filter(Boolean)
    .map(examView);
  ok(res, list);
});

module.exports = router;
