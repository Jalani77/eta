// NOTE: This is a pragmatic "text-first" parser to get Yiri usable immediately.
// It extracts:
// - Category weights like "Homework 20%" or "Quizzes: 15%"
// - Events like "2026-02-15 Exam 1" or "Feb 15, 2026: Assignment 3"
// You can later replace/augment this with Google Vision OCR for images.

const MONTHS = {
  jan: 0,
  january: 0,
  feb: 1,
  february: 1,
  mar: 2,
  march: 2,
  apr: 3,
  april: 3,
  may: 4,
  jun: 5,
  june: 5,
  jul: 6,
  july: 6,
  aug: 7,
  august: 7,
  sep: 8,
  sept: 8,
  september: 8,
  oct: 9,
  october: 9,
  nov: 10,
  november: 10,
  dec: 11,
  december: 11,
};

function tryParseIsoDate(line) {
  const m = line.match(/\b(20\d{2})-(\d{2})-(\d{2})\b/);
  if (!m) return null;
  const y = Number(m[1]);
  const mo = Number(m[2]) - 1;
  const d = Number(m[3]);
  const dt = new Date(Date.UTC(y, mo, d, 12, 0, 0));
  return Number.isNaN(dt.getTime()) ? null : dt;
}

function tryParseMonthDate(line) {
  const m = line.match(/\b([A-Za-z]{3,9})\s+(\d{1,2})(?:,\s*)?(20\d{2})\b/);
  if (!m) return null;
  const monthKey = m[1].toLowerCase();
  const mo = MONTHS[monthKey];
  if (mo === undefined) return null;
  const d = Number(m[2]);
  const y = Number(m[3]);
  const dt = new Date(Date.UTC(y, mo, d, 12, 0, 0));
  return Number.isNaN(dt.getTime()) ? null : dt;
}

function parseWeights(text) {
  const categories = [];
  const lines = text.split(/\r?\n/).map((l) => l.trim()).filter(Boolean);

  for (const line of lines) {
    // Examples:
    // "Homework 20%"
    // "Quizzes: 15%"
    // "Midterm - 25%"
    const m = line.match(/^([A-Za-z][A-Za-z0-9 &/()._-]{1,60})\s*[:\-–—]\s*(\d{1,3})(?:\s*)%\b|^([A-Za-z][A-Za-z0-9 &/()._-]{1,60})\s+(\d{1,3})(?:\s*)%\b/);
    if (!m) continue;

    const name = (m[1] ?? m[3] ?? '').trim();
    const weight = Number(m[2] ?? m[4]);

    if (!name || !Number.isFinite(weight)) continue;
    if (weight <= 0 || weight > 100) continue;

    categories.push({ name, weight });
  }

  // De-dupe by name (keep first)
  const seen = new Set();
  return categories.filter((c) => {
    const key = c.name.toLowerCase();
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

function parseEvents(text) {
  const events = [];
  const lines = text.split(/\r?\n/).map((l) => l.trim()).filter(Boolean);

  for (const line of lines) {
    const dueAt = tryParseIsoDate(line) ?? tryParseMonthDate(line);
    if (!dueAt) continue;

    // Title = line stripped of the date
    const title = line
      .replace(/\b(20\d{2})-(\d{2})-(\d{2})\b/, '')
      .replace(/\b([A-Za-z]{3,9})\s+(\d{1,2})(?:,\s*)?(20\d{2})\b/, '')
      .replace(/^[:\-–—\s]+/, '')
      .trim();

    events.push({
      title: title || 'Event',
      dueAt,
    });
  }

  // Sort chronologically
  events.sort((a, b) => new Date(a.dueAt).getTime() - new Date(b.dueAt).getTime());
  return events;
}

export function parseSyllabusText(syllabusText) {
  const categories = parseWeights(syllabusText);
  const events = parseEvents(syllabusText);

  return {
    categories,
    events,
    raw: { detectedCategoryCount: categories.length, detectedEventCount: events.length },
  };
}
