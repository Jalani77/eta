import { z } from 'zod';

export const SyllabusSubmitSchema = z
  .object({
    className: z.string().trim().min(1).max(140),
    syllabusText: z.string().trim().min(1).max(200000).optional(),
    // Base64 (no data URL prefix required). Intended for optional OCR via Google Vision.
    syllabusImageBase64: z.string().min(100).max(12_000_000).optional(),
    phoneNumberE164: z.string().trim().min(8).max(20).optional(),
    assumedRemainingAverage: z.number().min(0).max(100).optional(),
  })
  .refine((v) => Boolean(v.syllabusText) || Boolean(v.syllabusImageBase64), {
    message: 'Provide syllabusText or syllabusImageBase64',
  });
