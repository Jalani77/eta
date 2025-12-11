import crypto from 'crypto';

function pbkdf2Async(password, salt, iterations, keylen, digest) {
  return new Promise((resolve, reject) => {
    crypto.pbkdf2(password, salt, iterations, keylen, digest, (err, derivedKey) => {
      if (err) reject(err);
      else resolve(derivedKey);
    });
  });
}

export async function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const iterations = 210_000;
  const keylen = 32;
  const digest = 'sha256';

  const derivedKey = await pbkdf2Async(password, salt, iterations, keylen, digest);
  return `pbkdf2$${digest}$${iterations}$${salt}$${derivedKey.toString('hex')}`;
}

export async function verifyPassword(password, stored) {
  const [alg, digest, iterationsStr, salt, hashHex] = stored.split('$');
  if (alg !== 'pbkdf2') return false;

  const iterations = Number(iterationsStr);
  const keylen = Buffer.from(hashHex, 'hex').length;
  const derivedKey = await pbkdf2Async(password, salt, iterations, keylen, digest);

  const a = Buffer.from(hashHex, 'hex');
  const b = Buffer.from(derivedKey);
  if (a.length !== b.length) return false;
  return crypto.timingSafeEqual(a, b);
}
