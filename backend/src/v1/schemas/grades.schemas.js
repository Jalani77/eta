import { z } from 'zod';

export const GradesUpdateSchema = z.object({
  classId: z.string().trim().min(1).max(64),
  grades: z
    .array(
      z.object({
        eventTitle: z.string().trim().min(1).max(200),
        category: z.string().trim().min(1).max(80),
        scoreEarned: z.number().min(0),
        scorePossible: z.number().positive().max(1_000_000),
      })
    )
    .min(1),
});
