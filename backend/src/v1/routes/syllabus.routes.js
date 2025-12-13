import express from 'express';

import { requireAuthMiddleware } from './middleware.auth.js';
import { SyllabusSubmitSchema } from '../schemas/syllabus.schemas.js';
import { parseSyllabusText } from '../services/syllabusParser.service.js';
import { ocrWithGoogleVisionBase64 } from '../services/visionOcr.service.js';
import { scheduleRemindersForClass } from '../services/reminderScheduler.service.js';
import { User } from '../models/User.js';
import { ClassModel } from '../models/Class.js';
import { syllabusLimiter } from '../../shared/routeRateLimits.js';

export const syllabusRouter = express.Router();

syllabusRouter.use(syllabusLimiter);

syllabusRouter.post('/submit', requireAuthMiddleware, async (req, res, next) => {
  try {
    const userId = req.user.id;
    const body = SyllabusSubmitSchema.parse(req.body);

    const syllabusText =
      body.syllabusText ??
      (body.syllabusImageBase64 ? await ocrWithGoogleVisionBase64(body.syllabusImageBase64) : '');

    const parsed = parseSyllabusText(syllabusText);

    const user = await User.findById(userId);
    if (!user) return res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Unauthorized' } });

    if (body.phoneNumberE164) user.phoneNumberE164 = body.phoneNumberE164;

    const classDoc = await ClassModel.create({
      userId,
      className: body.className,
      categories: parsed.categories,
      events: parsed.events,
      assumedRemainingAverage: body.assumedRemainingAverage ?? 85,
    });

    await user.save();

    const agenda = req.ctx?.agenda;
    const schedule = await scheduleRemindersForClass({
      agenda,
      userId,
      classId: classDoc._id.toString(),
      className: classDoc.className,
      phoneNumberE164: user.phoneNumberE164,
      events: classDoc.events,
    });

    return res.status(201).json({
      class: {
        id: classDoc._id.toString(),
        className: classDoc.className,
        categories: classDoc.categories,
        events: classDoc.events,
        assumedRemainingAverage: classDoc.assumedRemainingAverage,
      },
      parseSummary: parsed.raw,
      reminders: schedule,
    });
  } catch (err) {
    next(err);
  }
});
