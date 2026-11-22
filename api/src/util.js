// Tien ich dung chung: khuon response, loi, xao tron, hang con vat, cham diem.
class ApiError extends Error {
  constructor(status, errorCode, message) {
    super(message);
    this.status = status;
    this.errorCode = errorCode;
  }
}

const ok = (res, data, message = 'OK', status = 200) =>
  res.status(status).json({ success: true, message, data });

// Xao tron Fisher-Yates (hop dong API muc 3)
function fisherYates(arr) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

// Bang hang con vat theo diem xep hang (rankScore)
function animalRank(score) {
  if (score >= 2000) return 'Cá Voi Xanh';
  if (score >= 1800) return 'Voi';
  if (score >= 1650) return 'Sư Tử';
  if (score >= 1500) return 'Hổ';
  if (score >= 1350) return 'Gấu';
  if (score >= 1200) return 'Ngựa';
  if (score >= 1100) return 'Heo';
  if (score >= 1000) return 'Chó';
  if (score >= 900) return 'Mèo';
  return 'Chuột';
}

let seq = 1000;
const newId = (prefix) => `${prefix}_${++seq}`;
const nowISO = () => new Date().toISOString();
const roomCode = () =>
  Array.from({ length: 6 }, () => 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'[Math.floor(Math.random() * 31)]).join('');

// Bo dap an dung + giai thich truoc khi phat cau hoi cho app (luat cung hop dong)
function publicQuestion(q) {
  return {
    id: q.id,
    topicId: q.topicId,
    content: q.content,
    options: q.options,
    difficulty: q.difficulty,
    timeSeconds: q.timeSeconds,
    points: q.points,
    hint: q.hint,
  };
}

module.exports = { ApiError, ok, fisherYates, animalRank, newId, nowISO, roomCode, publicQuestion };
