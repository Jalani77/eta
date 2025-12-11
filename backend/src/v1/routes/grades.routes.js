import express from 'express';

import { requireAuthMiddleware } from './middleware.auth.js';
import { GradesUpdateSchema } from '../schemas/grades.schemas.js';
import { ClassModel } from '../models/Class.js';

export const gradesRouter = express.Router();

gradesRouter.post('/update', requireAuthMiddleware, async (req, res, next) => {
  try {
    const userId = req.user.id;
    const body = GradesUpdateSchema.parse(req.body);

    const cls = await ClassModel.findOne({ _id: body.classId, userId });
    if (!cls) return res.status(404).json({ error: { code: 'CLASS_NOT_FOUND', message: 'Class not found' } });

    for (const g of body.grades) {
      cls.grades.push({
        eventTitle: g.eventTitle,
        category: g.category,
        scoreEarned: g.scoreEarned,
        scorePossible: g.scorePossible,
      });
    }

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
