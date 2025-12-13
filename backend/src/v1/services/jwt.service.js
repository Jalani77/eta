import jwt from 'jsonwebtoken';

export function signAccessToken({ userId, email }) {
  const secret = process.env.JWT_SECRET;
  if (!secret) throw new Error('Missing JWT_SECRET');

  return jwt.sign({ sub: userId, email }, secret, { expiresIn: '7d' });
}

export function verifyAccessToken(token) {
  const secret = process.env.JWT_SECRET;
  if (!secret) throw new Error('Missing JWT_SECRET');

  return jwt.verify(token, secret);
}
