import express from 'express';
import { z } from 'zod';

import { User } from '../models/User.js';
import { RegisterSchema, LoginSchema } from '../schemas/auth.schemas.js';
import { hashPassword, verifyPassword } from '../services/password.service.js';
import { signAccessToken, verifyAccessToken } from '../services/jwt.service.js';
import { parseBearerToken } from './_util.js';

export const authRouter = express.Router();

authRouter.post('/register', async (req, res, next) => {
  try {
    const body = RegisterSchema.parse(req.body);

    const existing = await User.findOne({ email: body.email.toLowerCase() });
    if (existing) {
      return res.status(409).json({ error: { code: 'EMAIL_IN_USE', message: 'Email already registered' } });
    }

    const passwordHash = await hashPassword(body.password);
    const user = await User.create({
      email: body.email.toLowerCase(),
      passwordHash,
    });

    const token = signAccessToken({ userId: user._id.toString(), email: user.email });
    return res.status(201).json({ token, user: { id: user._id.toString(), email: user.email } });
  } catch (err) {
    next(err);
  }
});

authRouter.post('/login', async (req, res, next) => {
  try {
    const body = LoginSchema.parse(req.body);

    const user = await User.findOne({ email: body.email.toLowerCase() });
    if (!user) {
      return res.status(401).json({ error: { code: 'INVALID_CREDENTIALS', message: 'Invalid credentials' } });
    }

    const ok = await verifyPassword(body.password, user.passwordHash);
    if (!ok) {
      return res.status(401).json({ error: { code: 'INVALID_CREDENTIALS', message: 'Invalid credentials' } });
    }

    const token = signAccessToken({ userId: user._id.toString(), email: user.email });
    return res.json({ token, user: { id: user._id.toString(), email: user.email } });
  } catch (err) {
    next(err);
  }
});

authRouter.get('/me', async (req, res, next) => {
  try {
    const token = parseBearerToken(req);
    if (!token) return res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Missing token' } });

    const payload = verifyAccessToken(token);
    const userId = z.string().parse(payload.sub);

    const user = await User.findById(userId).lean();
    if (!user) return res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Invalid token' } });

    return res.json({
      user: {
        id: user._id.toString(),
        email: user.email,
        phoneNumberE164: user.phoneNumberE164,
        goalFinalGrade: user.goalFinalGrade,
      },
    });
  } catch (err) {
    next(err);
  }
});
