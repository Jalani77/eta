import express from 'express';

import { requireAuthMiddleware } from './middleware.auth.js';
import { ClassModel } from '../models/Class.js';
import { ClassIdParamSchema, ClassUpdateSchema, EventsUpsertSchema } from '../schemas/classes.schemas.js';
import { classesLimiter } from '../../shared/routeRateLimits.js';

export const classesRouter = express.Router();

classesRouter.use(classesLimiter);

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

classesRouter.get('/:id', requireAuthMiddleware, async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { id } = ClassIdParamSchema.parse(req.params);

    const cls = await ClassModel.findOne({ _id: id, userId }).lean();
    if (!cls) return res.status(404).json({ error: { code: 'CLASS_NOT_FOUND', message: 'Class not found' } });

    return res.json({
      class: {
        id: cls._id.toString(),
        className: cls.className,
        categories: cls.categories,
        events: cls.events,
        grades: cls.grades,
        assumedRemainingAverage: cls.assumedRemainingAverage,
      },
    });
  } catch (err) {
    next(err);
  }
});

classesRouter.patch('/:id', requireAuthMiddleware, async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { id } = ClassIdParamSchema.parse(req.params);
    const body = ClassUpdateSchema.parse(req.body);

    const cls = await ClassModel.findOne({ _id: id, userId });
    if (!cls) return res.status(404).json({ error: { code: 'CLASS_NOT_FOUND', message: 'Class not found' } });

    if (typeof body.className === 'string') cls.className = body.className;
    if (typeof body.assumedRemainingAverage === 'number') cls.assumedRemainingAverage = body.assumedRemainingAverage;

    await cls.save();

    return res.json({
      class: {
        id: cls._id.toString(),
        className: cls.className,
        categories: cls.categories,
        events: cls.events,
        grades: cls.grades,
        assumedRemainingAverage: cls.assumedRemainingAverage,
      },
    });
  } catch (err) {
    next(err);
  }
});

classesRouter.delete('/:id', requireAuthMiddleware, async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { id } = ClassIdParamSchema.parse(req.params);

    const resDel = await ClassModel.deleteOne({ _id: id, userId });
    if (resDel.deletedCount === 0) {
      return res.status(404).json({ error: { code: 'CLASS_NOT_FOUND', message: 'Class not found' } });
    }

    return res.status(204).send();
  } catch (err) {
    next(err);
  }
});

classesRouter.patch('/:id/events', requireAuthMiddleware, async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { id } = ClassIdParamSchema.parse(req.params);
    const body = EventsUpsertSchema.parse(req.body);

    const cls = await ClassModel.findOne({ _id: id, userId });
    if (!cls) return res.status(404).json({ error: { code: 'CLASS_NOT_FOUND', message: 'Class not found' } });

    const toKey = (t, d) => `${String(t).trim().toLowerCase()}|${new Date(d).toISOString()}`;
    const incoming = new Map();
    for (const e of body.events) {
      const dt = new Date(e.dueAt);
      if (Number.isNaN(dt.getTime())) {
        return res.status(400).json({ error: { code: 'INVALID_DATE', message: 'Invalid dueAt' } });
      }
      incoming.set(toKey(e.title, dt), { ...e, dueAt: dt });
    }

    cls.events = (cls.events ?? []).map((existing) => {
      const key = toKey(existing.title, existing.dueAt);
      const upd = incoming.get(key);
      if (!upd) return existing;

      existing.category = Object.prototype.hasOwnProperty.call(upd, 'category') ? (upd.category ?? null) : existing.category;
      existing.pointsPossible = Object.prototype.hasOwnProperty.call(upd, 'pointsPossible') ? (upd.pointsPossible ?? null) : existing.pointsPossible;
      return existing;
    });

    await cls.save();

    return res.json({
      class: {
        id: cls._id.toString(),
        className: cls.className,
        categories: cls.categories,
        events: cls.events,
        grades: cls.grades,
        assumedRemainingAverage: cls.assumedRemainingAverage,
      },
    });
  } catch (err) {
    next(err);
  }
});
