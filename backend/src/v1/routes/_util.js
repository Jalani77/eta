export function requireAuth(req) {
  const userId = req.user?.id;
  if (!userId) {
    const err = new Error('Unauthorized');
    err.statusCode = 401;
    err.code = 'UNAUTHORIZED';
    throw err;
  }
  return userId;
}

export function parseBearerToken(req) {
  const h = req.headers.authorization;
  if (!h) return null;
  const m = h.match(/^Bearer\s+(.+)$/i);
  return m ? m[1] : null;
}
