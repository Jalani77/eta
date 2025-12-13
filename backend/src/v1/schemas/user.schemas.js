import { z } from 'zod';

export const UserUpdateSchema = z.object({
  phoneNumberE164: z.string().min(8).max(20).nullable().optional(),
  goalFinalGrade: z.number().min(0).max(100).optional(),
});
