// Ket noi Firebase Admin SDK (chi bat khi co bien moi truong FIREBASE_SERVICE_ACCOUNT).
//
// Cach dung: dat bien moi truong FIREBASE_SERVICE_ACCOUNT bang mot trong hai dang:
//   - duong dan toi file JSON khoa dich vu, vd: D:\omega-api\serviceAccountKey.json
//   - toan bo noi dung JSON cua khoa (khi host tiem secret qua bien moi truong)
// Neu khong dat bien, hoac thu vien firebase-admin chua duoc cai, API chay
// che do cu: du lieu trong bo nho + token dev. Khong lam hong ai chua co key.
//
// LUU Y: file key KHONG bao gio commit len git (xem api/.gitignore).
// Moi thanh vien tu tao key rieng cua minh tren Firebase console.
const fs = require('fs');
const path = require('path');

let admin = null;
let firestore = null;
let firebaseEnabled = false;

function loadServiceAccount() {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (!raw) return null;
  const value = raw.trim();
  if (value.startsWith('{')) return JSON.parse(value);
  const fullPath = path.resolve(value);
  return JSON.parse(fs.readFileSync(fullPath, 'utf8'));
}

try {
  const serviceAccount = loadServiceAccount();
  if (serviceAccount) {
    const adminLib = require('firebase-admin');
    adminLib.initializeApp({ credential: adminLib.credential.cert(serviceAccount) });
    admin = adminLib;
    firestore = adminLib.firestore();
    firebaseEnabled = true;
    console.log('[firebase] da ket noi project ' + (serviceAccount.project_id || '?'));
  } else {
    console.log('[firebase] chua dat FIREBASE_SERVICE_ACCOUNT — chay che do bo nho + token dev');
  }
} catch (e) {
  console.error('[firebase] khong ket noi duoc (' + e.message + ') — chay che do bo nho + token dev');
}

module.exports = { admin, firestore, firebaseEnabled };
