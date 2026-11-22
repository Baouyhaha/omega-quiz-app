// UC09 cau hoi, UC10 import/export Excel (chuan 13 cot)
const router = require('express').Router();
const multer = require('multer');
const XLSX = require('xlsx');
const { db } = require('../store');
const { ok, ApiError, newId } = require('../util');
const { authMiddleware, requireTopicOwner, assertTopicWritable, assertTopicAccess } = require('../auth');

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });
const previews = new Map(); // previewToken -> { topicId, rows }

const DIFF_IN = { 'dễ': 'easy', 'de': 'easy', 'easy': 'easy', 'trung bình': 'medium', 'trung binh': 'medium', 'medium': 'medium', 'khó': 'hard', 'kho': 'hard', 'hard': 'hard' };
const DIFF_OUT = { easy: 'Dễ', medium: 'Trung bình', hard: 'Khó' };

function validateRow(r) {
  const errs = [];
  if (!r.content) errs.push('thiếu câu hỏi');
  if (!Array.isArray(r.options) || r.options.some((o) => !o)) errs.push('thiếu đáp án A-D');
  if (![0, 1, 2, 3].includes(r.correctOption)) errs.push('đáp án đúng phải là A/B/C/D');
  if (!r.difficulty) errs.push('mức độ phải là Dễ/Trung bình/Khó');
  return errs;
}

function toQuestion(topicId, r) {
  return {
    id: r.id && db.questions.has(r.id) ? r.id : newId('q'),
    topicId,
    content: r.content,
    options: r.options,
    correctOption: r.correctOption,
    difficulty: r.difficulty,
    timeSeconds: r.timeSeconds || 30,
    points: r.points || 10,
    hint: r.hint || null,
    explanation: r.explanation || null,
    source: r.source || null,
  };
}

router.use(authMiddleware);

router.get('/topics/:id/questions', (req, res, next) => {
  try {
    const topic = db.topics.get(req.params.id);
    if (!topic) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy chủ đề');
    assertTopicAccess(req, topic);
    let list = [...db.questions.values()].filter((q) => q.topicId === topic.id);
    if (req.query.difficulty) list = list.filter((q) => q.difficulty === req.query.difficulty);
    // Chu so huu thay ca dap an dung; nguoi khac chi thay cau hoi khong dap an
    const isOwner = topic.ownerId === req.user.uid;
    ok(res, isOwner ? list : list.map(({ correctOption, explanation, ...rest }) => rest));
  } catch (e) { next(e); }
});

router.post('/topics/:id/questions', (req, res, next) => {
  try {
    assertTopicWritable(requireTopicOwner(req, req.params.id));
    const b = req.body || {};
    const row = {
      content: b.content, options: b.options, correctOption: b.correctOption,
      difficulty: DIFF_IN[String(b.difficulty || '').toLowerCase()] || b.difficulty,
      timeSeconds: b.timeSeconds, points: b.points, hint: b.hint, explanation: b.explanation, source: b.source,
    };
    const errs = validateRow(row);
    if (errs.length) throw new ApiError(400, 'VALIDATION_ERROR', errs.join('; '));
    const q = toQuestion(req.params.id, row);
    db.questions.set(q.id, q);
    ok(res, q, 'Đã thêm câu hỏi', 201);
  } catch (e) { next(e); }
});

router.patch('/questions/:id', (req, res, next) => {
  try {
    const q = db.questions.get(req.params.id);
    if (!q) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy câu hỏi');
    assertTopicWritable(requireTopicOwner(req, q.topicId));
    Object.assign(q, req.body || {});
    ok(res, q, 'Đã sửa câu hỏi');
  } catch (e) { next(e); }
});

router.delete('/questions/:id', (req, res, next) => {
  try {
    const q = db.questions.get(req.params.id);
    if (!q) throw new ApiError(404, 'NOT_FOUND', 'Không tìm thấy câu hỏi');
    assertTopicWritable(requireTopicOwner(req, q.topicId));
    db.questions.delete(q.id);
    ok(res, null, 'Đã xóa câu hỏi');
  } catch (e) { next(e); }
});

// Import buoc 1: doc file, tra xem truoc + loi theo dong + previewToken
router.post('/topics/:id/questions/import', upload.single('file'), (req, res, next) => {
  try {
    assertTopicWritable(requireTopicOwner(req, req.params.id));
    if (!req.file) throw new ApiError(400, 'VALIDATION_ERROR', 'Thiếu file .xlsx');
    const wb = XLSX.read(req.file.buffer, { type: 'buffer' });
    const ws = wb.Sheets[wb.SheetNames[0]];
    const rows = XLSX.utils.sheet_to_json(ws, { defval: '' });
    const parsed = [];
    const errors = [];
    rows.forEach((r, i) => {
      const line = i + 2; // dong 1 la tieu de
      const correctLetter = String(r.dap_an_dung || '').trim().toUpperCase();
      const row = {
        id: String(r.id || '').trim() || null,
        content: String(r.cau_hoi || '').trim(),
        options: [r.dap_an_a, r.dap_an_b, r.dap_an_c, r.dap_an_d].map((x) => String(x || '').trim()),
        correctOption: ['A', 'B', 'C', 'D'].indexOf(correctLetter),
        difficulty: DIFF_IN[String(r.muc_do || '').trim().toLowerCase()] || null,
        timeSeconds: Number(r.thoi_gian_giay) || 30,
        points: Number(r.diem) || 10,
        hint: String(r.goi_y || '').trim() || null,
        explanation: String(r.giai_thich || '').trim() || null,
        source: String(r.nguon || '').trim() || null,
      };
      const errs = validateRow(row);
      if (errs.length) errors.push({ line, errors: errs });
      else parsed.push(row);
    });
    const previewToken = newId('preview');
    previews.set(previewToken, { topicId: req.params.id, rows: parsed, createdAt: Date.now() });
    const data = { previewToken, validCount: parsed.length, errorCount: errors.length, errors, preview: parsed.slice(0, 5) };
    if (errors.length) {
      // Hop dong muc 4: file co loi thi tra 422 IMPORT_HAS_ERRORS, chi tiet
      // theo dong nam trong data; previewToken van dung duoc de xac nhan
      // luu cac cau hop le
      return res.status(422).json({ success: false, message: 'File có dòng lỗi, xem chi tiết trong data', errorCode: 'IMPORT_HAS_ERRORS', data });
    }
    ok(res, data, 'File hợp lệ');
  } catch (e) { next(e); }
});

// Import buoc 2: xac nhan luu cac cau hop le
router.post('/topics/:id/questions/import/confirm', (req, res, next) => {
  try {
    assertTopicWritable(requireTopicOwner(req, req.params.id));
    const p = previews.get((req.body || {}).previewToken);
    if (!p || p.topicId !== req.params.id) throw new ApiError(404, 'NOT_FOUND', 'previewToken không hợp lệ hoặc đã hết hạn');
    let saved = 0;
    for (const r of p.rows) {
      const q = toQuestion(req.params.id, r);
      db.questions.set(q.id, q);
      saved++;
    }
    previews.delete(req.body.previewToken);
    ok(res, { saved }, `Đã lưu ${saved} câu hỏi`);
  } catch (e) { next(e); }
});

router.get('/topics/:id/questions/export', (req, res, next) => {
  try {
    requireTopicOwner(req, req.params.id);
    const rows = [...db.questions.values()]
      .filter((q) => q.topicId === req.params.id)
      .map((q) => ({
        id: q.id, cau_hoi: q.content,
        dap_an_a: q.options[0], dap_an_b: q.options[1], dap_an_c: q.options[2], dap_an_d: q.options[3],
        dap_an_dung: 'ABCD'[q.correctOption], muc_do: DIFF_OUT[q.difficulty],
        thoi_gian_giay: q.timeSeconds, diem: q.points,
        goi_y: q.hint || '', giai_thich: q.explanation || '', nguon: q.source || '',
      }));
    const ws = XLSX.utils.json_to_sheet(rows);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'CauHoi');
    const buf = XLSX.write(wb, { type: 'buffer', bookType: 'xlsx' });
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename="ngan_hang_cau_hoi.xlsx"');
    res.send(buf);
  } catch (e) { next(e); }
});

module.exports = router;
