import express from 'express';

import { requireAuthMiddleware } from './middleware.auth.js';
import { ClassModel } from '../models/Class.js';

export const classesRouter = express.Router();

classesRouter.get('/', requireAuthMiddleware, async (req, res, next) => {
  try {
    const userId = req.user.id;
    const classes = await ClassModel.find({ userId }).sort({ createdAt: -1 }).lean();

    return res.json({
      classes: classes.map((c) => ({
        id: c._id.toString(),
        className: c.className,
        categories: c.categories,
        events: c.events,
        grades: c.grades,
        assumedRemainingAverage: c.assumedRemainingAverage,
      })),
    });
  } catch (err) {
    next(err);
  }
});
