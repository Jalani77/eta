import { z } from 'zod';

export const ClassIdParamSchema = z.object({
  id: z.string().trim().min(1).max(64),
});

export const ClassUpdateSchema = z.object({
  className: z.string().trim().min(1).max(140).optional(),
  assumedRemainingAverage: z.number().min(0).max(100).optional(),
});

export const EventsUpsertSchema = z.object({
  events: z
    .array(
      z.object({
        title: z.string().trim().min(1).max(240),
        dueAt: z.string().trim().min(4).max(64), // ISO string
        category: z.string().trim().min(1).max(80).nullable().optional(),
        pointsPossible: z.number().positive().max(1_000_000).nullable().optional(),
      })
    )
    .min(1)
    .max(500),
});
