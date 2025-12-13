import express from 'express';

import { requireAuthMiddleware } from './middleware.auth.js';
import { User } from '../models/User.js';
import { UserUpdateSchema } from '../schemas/user.schemas.js';
import { usersLimiter } from '../../shared/routeRateLimits.js';

export const usersRouter = express.Router();

usersRouter.use(usersLimiter);

usersRouter.patch('/me', requireAuthMiddleware, async (req, res, next) => {
  try {
    const userId = req.user.id;
    const body = UserUpdateSchema.parse(req.body);

    const user = await User.findById(userId);
    if (!user) return res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Unauthorized' } });

    if (Object.prototype.hasOwnProperty.call(body, 'phoneNumberE164')) {
      user.phoneNumberE164 = body.phoneNumberE164 ?? null;
    }

    if (typeof body.goalFinalGrade === 'number') {
      user.goalFinalGrade = body.goalFinalGrade;
    }

    await user.save();

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
