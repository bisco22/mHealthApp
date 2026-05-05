const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const sqlite3 = require('sqlite3').verbose();

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-me';
const DATA_DIR = path.join(__dirname, 'data');
const DB_PATH = path.join(DATA_DIR, 'users.db');
const WORDS_DB_PATH = path.join(DATA_DIR, 'words.db');

app.use(cors());
app.use(express.json());

fs.mkdirSync(DATA_DIR, { recursive: true });

const db = new sqlite3.Database(DB_PATH);
const wordsDb = new sqlite3.Database(WORDS_DB_PATH);

function run(dbInstance, sql, params = []) {
  return new Promise((resolve, reject) => {
    dbInstance.run(sql, params, function (error) {
      if (error) {
        reject(error);
        return;
      }
      resolve(this);
    });
  });
}

function get(dbInstance, sql, params = []) {
  return new Promise((resolve, reject) => {
    dbInstance.get(sql, params, (error, row) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(row);
    });
  });
}

function all(dbInstance, sql, params = []) {
  return new Promise((resolve, reject) => {
    dbInstance.all(sql, params, (error, rows) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(rows);
    });
  });
}

function hashPassword(password, salt = crypto.randomBytes(16).toString('hex')) {
  return new Promise((resolve, reject) => {
    crypto.scrypt(password, salt, 64, (error, derivedKey) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(`${salt}:${derivedKey.toString('hex')}`);
    });
  });
}

function verifyPassword(password, storedHash) {
  return new Promise((resolve, reject) => {
    const [salt, key] = String(storedHash || '').split(':');
    if (!salt || !key) {
      resolve(false);
      return;
    }

    crypto.scrypt(password, salt, 64, (error, derivedKey) => {
      if (error) {
        reject(error);
        return;
      }

      const storedKeyBuffer = Buffer.from(key, 'hex');
      const derivedKeyBuffer = Buffer.from(derivedKey);

      if (storedKeyBuffer.length !== derivedKeyBuffer.length) {
        resolve(false);
        return;
      }

      resolve(crypto.timingSafeEqual(storedKeyBuffer, derivedKeyBuffer));
    });
  });
}

async function initDb() {
  await run(db, `
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      username_key TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  `);

  const existingDemoUser = await get(db,
    'SELECT id FROM users WHERE username_key = ?',
    ['alessandro']
  );

  if (!existingDemoUser) {
    const passwordHash = await hashPassword('adminAdmin1234');
    await run(db,
      'INSERT INTO users (username, username_key, password_hash) VALUES (?, ?, ?)',
      ['Alessandro', 'alessandro', passwordHash]
    );
  }
}

app.get('/users', async (_, res) => {
    try {
    const users = await all(db, 'SELECT id, username FROM users');
    res.json(users);
  } catch(error){
  res.status(500).json({ message: 'errore interno del server' });
  }
});

app.get('/health', async (_, res) => {
  try {
    await get(db, 'SELECT 1 as ok');
    res.json({ ok: true, service: 'login-demo-local-api-sqlite', db: 'sqlite' });
  } catch (error) {
    res.status(500).json({ ok: false, message: 'database non disponibile' });
  }
});

app.post('/auth/register', async (req, res) => {
  try {
    const { username, password } = req.body || {};

    if (!username || !password) {
      return res.status(400).json({ message: 'username e password obbligatori' });
    }

    const normalizedUsername = String(username).trim();
    const usernameKey = normalizedUsername.toLowerCase();

    if (normalizedUsername.length < 3 || String(password).length < 6) {
      return res.status(400).json({ message: 'username/password non validi' });
    }

    const existingUser = await get(db,
      'SELECT id FROM users WHERE username_key = ?',
      [usernameKey]
    );

    if (existingUser) {
      return res.status(409).json({ message: 'username già registrato' });
    }

    const passwordHash = await hashPassword(String(password));

    await run(db,
      'INSERT INTO users (username, username_key, password_hash) VALUES (?, ?, ?)',
      [normalizedUsername, usernameKey, passwordHash]
    );

    return res.status(201).json({ message: 'utente creato' });
  } catch (error) {
    console.error('Errore register:', error);
    return res.status(500).json({ message: 'errore interno del server' });
  }
});

app.post('/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body || {};
    const usernameKey = String(username || '').trim().toLowerCase();

    const user = await get(db,
      'SELECT username, password_hash FROM users WHERE username_key = ?',
      [usernameKey]
    );

    if (!user) {
      return res.status(401).json({ message: 'credenziali non valide' });
    }

    const passwordMatches = await verifyPassword(
      String(password || ''),
      user.password_hash
    );

    if (!passwordMatches) {
      return res.status(401).json({ message: 'credenziali non valide' });
    }

    const token = jwt.sign({ sub: user.username }, JWT_SECRET, { expiresIn: '1h' });
    return res.json({ token, username: user.username });
  } catch (error) {
    console.error('Errore login:', error);
    return res.status(500).json({ message: 'errore interno del server' });
  }
});

app.get('/me', (req, res) => {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.substring(7) : null;

  if (!token) {
    return res.status(401).json({ message: 'token mancante' });
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    return res.json({ username: payload.sub });
  } catch (error) {
    return res.status(401).json({ message: 'token non valido' });
  }
});

app.get('/words/random', async (req, res) => {
  try {
    const row = await get(wordsDb, 'SELECT word FROM words ORDER BY RANDOM() LIMIT 1');
    if (!row) {
      return res.status(404).json({ message: 'nessuna parola trovata' });
    }
    res.json(row);
  } catch (error) {
    console.error('Errore /words/random:', error);
    res.status(500).json({ message: 'errore interno del server' });
  }
});

app.get('/words/:word', async (req, res) => {
  try {
    const wordParam = String(req.params.word || '').toLowerCase();
    const row = await get(wordsDb, 'SELECT word FROM words WHERE word = ?', [wordParam]);
    if (!row) {
      return res.status(404).json({ message: 'parola non trovata' });
    }
    res.json(row);
  } catch (error) {
    console.error('Errore /words/:word:', error);
    res.status(500).json({ message: 'errore interno del server' });
  }
});

async function initWordsDb() {
  await run(wordsDb, `
    CREATE TABLE IF NOT EXISTS words (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      word TEXT NOT NULL UNIQUE
    )
  `);

  const countRow = await get(wordsDb, 'SELECT COUNT(*) as count FROM words');
  if (countRow.count === 0) {
    console.log('Database parole vuoto. Inizio popolamento da words.jsonl...');
    const jsonlPath = path.join(DATA_DIR, 'words.jsonl');
    if (fs.existsSync(jsonlPath)) {
      try {
        const content = fs.readFileSync(jsonlPath, 'utf8');
        const lines = content.split('\n').filter(line => line.trim());

        await run(wordsDb, 'BEGIN TRANSACTION');
        for (const line of lines) {
          try {
            const data = JSON.parse(line);
            const word = data.word || data.text;
            if (word && word.length === 5) {
              await run(wordsDb, 'INSERT OR IGNORE INTO words (word) VALUES (?)', [word.toLowerCase()]);
            }
          } catch (e) { }
        }
        await run(wordsDb, 'COMMIT');
        const finalCount = await get(wordsDb, 'SELECT COUNT(*) as count FROM words');
        console.log(`Popolamento completato! Caricate ${finalCount.count} parole.`);
      } catch (error) {
        await run(wordsDb, 'ROLLBACK');
        console.error('Errore durante il caricamento delle parole:', error);
      }
    } else {
      console.warn('ATTENZIONE: words.jsonl non trovato.');
    }
  }
}

async function start() {
  try {
    await initDb();
    await initWordsDb();
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Local API SQLite in ascolto su http://0.0.0.0:${PORT}`);
    });
  } catch (error) {
    console.error('Impossibile inizializzare i database:', error);
    process.exit(1);
  }
}

start();
