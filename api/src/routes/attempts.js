// UC13 lam bai, UC14 tro giup, UC15 chong gian lan (gop trong luong lam bai),
// UC16 ket qua, UC17 lich su, UC18 on tap cau sai
const router = require('express').Router();
const { repo } = require('../store');
const { ok, ApiError, newId, fisherYates, publicQuestion, nowISO } = require('../util');
const { authMiddleware, assertTopicAccess } = require('../auth');

router.use(authMiddleware);

async function examQuestions(examId) {
  const links = (await repo.all('examQuestions'))
    .filter((x) => x.examId === examId)
    .sort((a, b) => a.order - b.order);
  const qs = [];
  for (const x of links) {
    const q = await repo.get('questions', x.questionId);
    if (q) qs.push(q);
  }
  return qs;
}

async function startAttempt(user, exam, questionIds, extra = {}) {
  const attempt = {
    id: newId('att'), userId: user.uid, examId: exam ? exam.id : null,
    topicId: exam ? exam.topicId : extra.topicId,
    contestId: extra.contestId || null, battleId: extra.battleId || null,
    questionIds, status: 'IN_PROGRESS', startedAt: nowISO(),
    violations: 0, helpersUsed: [], hintedQuestions: [], shield: false, extraSeconds: 0,
    answers: null, score: null, correctCount: null, percent: null, durationSeconds: null,
  };
  await repo.put('attempts', attempt.id, attempt);
  return attempt;
}

async function presentQuestions(attempt, shuffle) {
  let qs = [];
  for (const id of attempt.questionIds) {
    const q = await repo.get('questions', id);
    if (q) qs.push(q);
  }
  if (shuffle) qs = fisherYates(qs);
  return qs.map(publicQuestion);
}

router.post('/exams/:id/attempts', async (req, res, next) => {
  try {
    const exam = await repo.get('exams', req.params.id);
    if (!exam) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy bộ đề');
    const examTopic = await repo.get('topics', exam.topicId);
    if (examTopic) await assertTopicAccess(req, examTopic);
    const s = exam.settings;
    const now = new Date();
    if (s.openAt && now < new Date(s.openAt)) throw new ApiError(409, 'EXAM_NOT_OPEN', 'Bộ đề chưa mở');
    if (s.closeAt && now > new Date(s.closeAt)) throw new ApiError(409, 'EXAM_CLOSED', 'Bộ đề đã đóng');
    if (s.pin) {
      const pin = (req.body || {}).pin;
      if (!pin) throw new ApiError(400, 'PIN_REQUIRED', 'Bộ đề yêu cầu mã PIN');
      if (String(pin) !== String(s.pin)) throw new ApiError(400, 'PIN_INVALID', 'Mã PIN không đúng');
    }
    const done = (await repo.all('attempts')).filter(
      (a) => a.examId === exam.id && a.userId === req.user.uid && a.status !== 'IN_PROGRESS');
    if (s.maxAttempts && done.length >= s.maxAttempts) {
      throw new ApiError(409, 'MAX_ATTEMPTS_REACHED', 'Đã hết số lần làm bộ đề này');
    }
    const ids = (await examQuestions(exam.id)).map((q) => q.id);
    const attempt = await startAttempt(req.user, exam, ids);
    ok(res, {
      attemptId: attempt.id,
      durationMinutes: s.durationMinutes,
      questions: await presentQuestions(attempt, s.shuffleQuestions),
    }, 'Bắt đầu lượt làm', 201);
  } catch (e) { next(e); }
});

router.post('/attempts/:id/helpers', async (req, res, next) => {
  try {
    const attempt = await repo.get('attempts', req.params.id);
    if (!attempt || attempt.userId !== req.user.uid) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy lượt làm');
    if (attempt.status !== 'IN_PROGRESS') throw new ApiError(409, 'VALIDATION_ERROR', 'Lượt làm đã kết thúc');
    const { type, questionId } = req.body || {};
    const q = await repo.get('questions', questionId);
    if (!q) throw new ApiError(400, 'VALIDATION_ERROR', 'Thiếu hoặc sai questionId');
    attempt.helpersUsed.push({ type, questionId, at: nowISO() });
    await repo.put('attempts', attempt.id, attempt);
    let data = { type };
    if (type === 'FIFTY_FIFTY') {
      const wrong = [0, 1, 2, 3].filter((i) => i !== q.correctOption);
      data = { ...data, hiddenOptions: fisherYates(wrong).slice(0, 2) };
    } else if (type === 'LIGHT_HINT') {
      attempt.hintedQuestions.push(questionId);
      data = { ...data, hint: q.hint, scoreMultiplier: 0.8 };
    } else if (type === 'VIEW_EXPLANATION') {
      data = { ...data, explanation: q.explanation };
    } else if (type === 'CHANGE_QUESTION') {
      const pool = (await repo.all('questions')).filter(
        (x) => x.topicId === q.topicId && !attempt.questionIds.includes(x.id));
      if (!pool.length) throw new ApiError(400, 'VALIDATION_ERROR', 'Kho không còn câu thay thế');
      const replacement = fisherYates(pool)[0];
      attempt.questionIds = attempt.questionIds.map((id) => (id === questionId ? replacement.id : id));
      data = { ...data, newQuestion: publicQuestion(replacement) };
    } else if (type === 'EXTRA_TIME') {
      attempt.extraSeconds += 15;
      data = { ...data, extraSeconds: attempt.extraSeconds };
    } else if (type === 'SAFE_SHIELD') {
      attempt.shield = true;
      data = { ...data, shield: true };
    } else {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Loại trợ giúp không hợp lệ');
    }
    await repo.put('attempts', attempt.id, attempt);
    ok(res, data, 'Đã dùng quyền trợ giúp');
  } catch (e) { next(e); }
});

router.post('/attempts/:id/violations', async (req, res, next) => {
  try {
    const attempt = await repo.get('attempts', req.params.id);
    if (!attempt || attempt.userId !== req.user.uid) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy lượt làm');
    attempt.violations += 1;
    const forceSubmitted = attempt.violations >= 5;
    if (forceSubmitted && attempt.status === 'IN_PROGRESS') attempt.status = 'FORCE_SUBMITTED';
    await repo.put('attempts', attempt.id, attempt);
    ok(res, { violations: attempt.violations, forceSubmitted });
  } catch (e) { next(e); }
});

// Cham diem: diem goc theo cau + thuong toc do (cong thuc Dot 2 muc 5):
// moi cau dung duoc cong them = diem cau (da nhan he so goi y neu co)
//   x 0,5 x (thoi gian con lai cua cau / thoi gian quy dinh cua cau).
// App gui thoi gian tung cau qua answers[].timeSpentSeconds; neu luot nop
// khong gui thi lui ve cach tinh theo ty le tong thoi gian (ban cu).
async function grade(attempt, answers, durationSeconds) {
  let score = 0;
  let baseScore = 0;
  let bonus = 0;
  let correct = 0;
  let shieldUsed = false;
  const detail = [];
  const perQuestion = answers.every((a) => typeof a.timeSpentSeconds === 'number');
  const qById = new Map();
  for (const id of attempt.questionIds) qById.set(id, await repo.get('questions', id));
  const allotted = attempt.questionIds.reduce((s, id) => s + (qById.get(id)?.timeSeconds || 30), 0);
  const totalRatio = allotted > 0 ? Math.max(0, 1 - (durationSeconds || allotted) / allotted) : 0;
  for (const qid of attempt.questionIds) {
    const q = qById.get(qid);
    if (!q) continue;
    const a = answers.find((x) => x.questionId === qid);
    const selected = a ? a.selectedOption : null;
    let isCorrect = selected === q.correctOption;
    if (!isCorrect && attempt.shield && !shieldUsed && selected !== null) {
      isCorrect = true; // Khien An Toan: 1 cau sai dau tien khong tinh sai
      shieldUsed = true;
    }
    let pts = 0;
    if (isCorrect) {
      correct++;
      pts = q.points * (attempt.hintedQuestions.includes(qid) ? 0.8 : 1);
      baseScore += pts;
      if (perQuestion) {
        const remaining = Math.max(0, (q.timeSeconds || 30) - a.timeSpentSeconds);
        bonus += pts * 0.5 * (remaining / (q.timeSeconds || 30));
      }
    }
    detail.push({ questionId: qid, selectedOption: selected, correctOption: q.correctOption, isCorrect, points: pts });
  }
  if (!perQuestion) bonus = baseScore * 0.5 * totalRatio;
  bonus = Math.round(bonus * 10) / 10;
  score = Math.round((baseScore + bonus) * 10) / 10;
  return { score, baseScore, bonus, correct, detail, total: attempt.questionIds.length };
}

router.post('/attempts/:id/submit', async (req, res, next) => {
  try {
    const attempt = await repo.get('attempts', req.params.id);
    if (!attempt || attempt.userId !== req.user.uid) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy lượt làm');
    if (attempt.status === 'SUBMITTED') throw new ApiError(409, 'VALIDATION_ERROR', 'Lượt làm đã nộp rồi');
    const { answers, durationSeconds } = req.body || {};
    if (!Array.isArray(answers)) throw new ApiError(400, 'VALIDATION_ERROR', 'Thiếu answers');
    const g = await grade(attempt, answers, durationSeconds);
    attempt.answers = answers;
    attempt.durationSeconds = durationSeconds || null;
    attempt.score = g.score;
    attempt.correctCount = g.correct;
    attempt.percent = g.total ? Math.round((g.correct / g.total) * 1000) / 10 : 0;
    if (attempt.status === 'IN_PROGRESS') attempt.status = 'SUBMITTED';
    attempt.submittedAt = nowISO();
    await repo.put('attempts', attempt.id, attempt);
    // Luu cac cau sai vao reviews de on tap (UC18)
    for (const d of g.detail) {
      if (!d.isCorrect) {
        await repo.put('reviews', `${attempt.userId}:${d.questionId}`, {
          userId: attempt.userId, questionId: d.questionId, lastWrongAt: nowISO(),
        });
      } else {
        await repo.del('reviews', `${attempt.userId}:${d.questionId}`);
      }
    }
    const exam = attempt.examId ? await repo.get('exams', attempt.examId) : null;
    const publish = !exam || exam.settings.publishScore;
    ok(res, {
      attemptId: attempt.id,
      status: attempt.status,
      correctCount: g.correct,
      totalQuestions: g.total,
      percent: attempt.percent,
      score: publish ? g.score : null,
      baseScore: publish ? g.baseScore : null,
      speedBonus: publish ? g.bonus : null,
    }, 'Đã nộp bài');
  } catch (e) { next(e); }
});

router.get('/attempts/mine', async (req, res, next) => {
  try {
    const mine = (await repo.all('attempts'))
      .filter((a) => a.userId === req.user.uid && a.status !== 'IN_PROGRESS')
      .sort((a, b) => (b.submittedAt || '').localeCompare(a.submittedAt || ''));
    const list = [];
    for (const a of mine) {
      const exam = a.examId ? await repo.get('exams', a.examId) : null;
      list.push({
        id: a.id, examId: a.examId, contestId: a.contestId, battleId: a.battleId,
        examTitle: exam ? exam.title : null,
        status: a.status, score: a.score, correctCount: a.correctCount,
        totalQuestions: a.questionIds.length, percent: a.percent,
        durationSeconds: a.durationSeconds, submittedAt: a.submittedAt || null,
      });
    }
    ok(res, list);
  } catch (e) { next(e); }
});

router.get('/attempts/:id/review', async (req, res, next) => {
  try {
    const attempt = await repo.get('attempts', req.params.id);
    if (!attempt || attempt.userId !== req.user.uid) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy lượt làm');
    const exam = attempt.examId ? await repo.get('exams', attempt.examId) : null;
    const mode = exam ? exam.settings.showAnswerMode : 'IMMEDIATELY';
    const closed = !exam || !exam.settings.closeAt || new Date() > new Date(exam.settings.closeAt);
    if (mode === 'NEVER' || (mode === 'AFTER_CLOSE' && !closed)) {
      throw new ApiError(403, 'FORBIDDEN', 'Bộ đề không cho xem đáp án vào lúc này');
    }
    const detail = [];
    for (const qid of attempt.questionIds) {
      const q = await repo.get('questions', qid);
      const a = (attempt.answers || []).find((x) => x.questionId === qid);
      detail.push({
        questionId: qid, content: q.content, options: q.options,
        selectedOption: a ? a.selectedOption : null,
        correctOption: q.correctOption, explanation: q.explanation,
      });
    }
    ok(res, { attemptId: attempt.id, questions: detail });
  } catch (e) { next(e); }
});

router.get('/reviews/wrong', async (req, res, next) => {
  try {
    const mine = (await repo.all('reviews')).filter((r) => r.userId === req.user.uid);
    const list = [];
    for (const r of mine) {
      const q = await repo.get('questions', r.questionId);
      if (q) list.push({ ...q });
    }
    ok(res, list);
  } catch (e) { next(e); }
});

module.exports = router;
module.exports.startAttempt = startAttempt;
module.exports.examQuestions = examQuestions;
