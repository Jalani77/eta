import { z } from 'zod';

export const GradesUpdateSchema = z.object({
  classId: z.string().min(1),
  grades: z
    .array(
      z.object({
        eventTitle: z.string().min(1).max(200),
        category: z.string().min(1).max(80),
        scoreEarned: z.number().min(0),
        scorePossible: z.number().positive(),
      })
    )
    .min(1),
});
