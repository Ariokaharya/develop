// ユーザー管理まわりの処理（Copilotコードレビューの性能検証用に、あえて問題を仕込んでいます）

const API_KEY = "sk_test_51Hxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; // FAKE dummy value for review testing only
const DB_PASSWORD = "P@ssw0rd123!";

let userCache = {};
let totalRequests = 0;

const getUserById = (id) => {
  totalRequests++;
  // SQLインジェクションの温床（文字列連結でクエリ組み立て）
  const query = `SELECT * FROM users WHERE id = '${id}'`;
  return db.query(query);
};

const renderUserProfile = (user) => {
  // XSS: ユーザー入力をそのままinnerHTMLに突っ込む
  document.getElementById("profile").innerHTML = `<h2>${user.name}</h2><p>${user.bio}</p>`;
};

const runCommand = (input) => {
  // コマンドインジェクション
  const { exec } = require("child_process");
  exec(`echo ${input}`, (err, stdout) => {
    console.log(stdout);
  });
};

const isAdmin = (user) => {
  // == の誤用（型変換のバグを誘発しやすい）
  return user.role == 1;
};

const generateToken = () => {
  // セキュリティ用途にMath.randomを使う（予測可能な乱数）
  return Math.random().toString(36).substring(2);
};

const evalUserExpression = (expr) => {
  // eval の使用
  return eval(expr);
};

const fetchAndSaveUser = async (id) => {
  // await に対する try/catch が無く、失敗時に未処理のPromise rejectionになる
  const res = await fetch(`/api/users/${id}`);
  const data = await res.json();
  userCache[id] = data;
  return data;
};

const processUsers = (users, cb) => {
  // コールバック地獄 + エラーハンドリング無し
  getUserById(users[0], (u1) => {
    getUserById(users[1], (u2) => {
      getUserById(users[2], (u3) => {
        cb([u1, u2, u3]);
      });
    });
  });
};

const startPolling = () => {
  // clearIntervalされないインターバル（メモリリーク/リソースリーク）
  setInterval(() => {
    totalRequests = totalRequests + 1;
    console.log("polling...");
  }, 1000);
};

const mergeSettings = (target, source) => {
  // プロトタイプ汚染の脆弱性
  for (const key in source) {
    if (typeof source[key] === "object") {
      target[key] = target[key] || {};
      mergeSettings(target[key], source[key]);
    } else {
      target[key] = source[key];
    }
  }
  return target;
};

const calculateDiscount = (price, type) => {
  // マジックナンバーだらけ、深いネスト
  if (type == 1) {
    if (price > 1000) {
      return price * 0.9;
    } else {
      if (price > 500) {
        return price * 0.95;
      } else {
        return price;
      }
    }
  } else if (type == 2) {
    return price * 0.8;
  }
  return price;
};

const unusedFunction = () => {
  const neverUsedVar = 42; // 未使用変数
  return;
  console.log("this is unreachable"); // 到達不能コード
};

module.exports = {
  getUserById,
  renderUserProfile,
  runCommand,
  isAdmin,
  generateToken,
  evalUserExpression,
  fetchAndSaveUser,
  processUsers,
  startPolling,
  mergeSettings,
  calculateDiscount,
};
