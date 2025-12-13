import express from 'express';

import { usersLimiter } from '../../shared/routeRateLimits.js';

export const metaRouter = express.Router();

metaRouter.use(usersLimiter);

metaRouter.get('/', (_req, res) => {
  const twilioConfigured = Boolean(
    process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN && process.env.TWILIO_FROM_NUMBER
  );
  const ocrConfigured = Boolean(process.env.GOOGLE_VISION_API_KEY);

  res.json({
    service: 'yiri-backend',
    twilioConfigured,
    ocrConfigured,
  });
});
