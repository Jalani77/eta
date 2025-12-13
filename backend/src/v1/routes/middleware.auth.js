import { verifyAccessToken } from '../services/jwt.service.js';
import { parseBearerToken } from './_util.js';

export function authMiddleware(req, _res, next) {
  try {
    const token = parseBearerToken(req);
    if (!token) {
      req.user = null;
      return next();
    }

    const payload = verifyAccessToken(token);
    req.user = {
      id: payload.sub,
      email: payload.email,
    };

    return next();
  } catch (_err) {
    req.user = null;
    return next();
  }
}

export function requireAuthMiddleware(req, res, next) {
  authMiddleware(req, res, () => {
    if (!req.user?.id) {
      return res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Unauthorized' } });
    }
    return next();
  });
}
