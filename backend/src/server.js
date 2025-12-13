import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';

import { connectMongo } from './shared/mongo.js';
import { createAgenda } from './shared/agenda.js';
import { attachRequestContext } from './shared/requestContext.js';
import { errorHandler, notFound } from './shared/errors.js';
import { loadEnv } from './shared/env.js';

import { authRouter } from './v1/routes/auth.routes.js';
import { syllabusRouter } from './v1/routes/syllabus.routes.js';
import { gradesRouter } from './v1/routes/grades.routes.js';
import { classesRouter } from './v1/routes/classes.routes.js';
import { usersRouter } from './v1/routes/users.routes.js';

dotenv.config();

const env = loadEnv();

const app = express();

app.disable('x-powered-by');
app.use(helmet());
app.use(
  cors({
    origin: env.CORS_ORIGIN === '*'
      ? '*'
      : env.CORS_ORIGIN.split(',').map((s) => s.trim()).filter(Boolean),
    // If you need cookies/credentials, set explicit origins (not '*').
    credentials: env.CORS_ORIGIN !== '*',
  })
);
app.use(express.json({ limit: '8mb' }));
app.use(morgan('dev'));
app.use(
  rateLimit({
    windowMs: 60_000,
    max: 120,
    standardHeaders: true,
    legacyHeaders: false,
  })
);

app.get('/health', (_req, res) =>
  res.json({
    ok: true,
    service: 'yiri-backend',
    env: process.env.NODE_ENV ?? 'development',
  })
);

const port = Number(env.PORT ?? 3001);

async function main() {
  await connectMongo(env.MONGODB_URI);
  const agenda = await createAgenda(env.MONGODB_URI);

  app.use(attachRequestContext({ agenda }));

  app.use('/api/v1/auth', authRouter);
  app.use('/api/v1/users', usersRouter);
  app.use('/api/v1/syllabus', syllabusRouter);
  app.use('/api/v1/grades', gradesRouter);
  app.use('/api/v1/classes', classesRouter);

  app.use(notFound);
  app.use(errorHandler);

  app.listen(port, () => {
    // eslint-disable-next-line no-console
    console.log(`Yiri backend listening on :${port}`);
  });
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('Fatal startup error:', err);
  process.exit(1);
});
