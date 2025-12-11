import { z } from 'zod';

export const SyllabusSubmitSchema = z.object({
  className: z.string().min(1).max(140),
  syllabusText: z.string().min(1).max(200000),
  phoneNumberE164: z.string().min(8).max(20).optional(),
  assumedRemainingAverage: z.number().min(0).max(100).optional(),
});
