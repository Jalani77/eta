import { z } from 'zod';

export const ClassIdParamSchema = z.object({
  id: z.string().trim().min(1).max(64),
});

export const ClassUpdateSchema = z.object({
  className: z.string().trim().min(1).max(140).optional(),
  assumedRemainingAverage: z.number().min(0).max(100).optional(),
});
