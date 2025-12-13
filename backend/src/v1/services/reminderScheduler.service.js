import { addHours, isValid } from './time.util.js';

function normalizeToDate(v) {
  const d = v instanceof Date ? v : new Date(v);
  return isValid(d) ? d : null;
}

export async function scheduleRemindersForClass({
  agenda,
  userId,
  classId,
  className,
  phoneNumberE164,
  events,
}) {
  if (!agenda) throw new Error('Missing agenda');
  if (!phoneNumberE164) return { scheduled: 0, skipped: events?.length ?? 0 };

  let scheduled = 0;
  let skipped = 0;

  for (const ev of events ?? []) {
    const dueAt = normalizeToDate(ev.dueAt);
    if (!dueAt) {
      skipped += 1;
      continue;
    }

    const sendAt = addHours(dueAt, -24);
    if (!isValid(sendAt) || sendAt.getTime() < Date.now() + 10_000) {
      // If it's already too soon/past, skip.
      skipped += 1;
      continue;
    }

    const data = {
      userId,
      classId,
      toE164: phoneNumberE164,
      className,
      title: ev.title,
      dueAt: dueAt.toISOString(),
    };

    // Prevent duplicates on re-submit by ensuring uniqueness per (classId, to, title, dueAt).
    const job = agenda.create('sendReminderSms', data);
    job.unique({
      name: 'sendReminderSms',
      'data.classId': classId,
      'data.toE164': phoneNumberE164,
      'data.title': ev.title,
      'data.dueAt': data.dueAt,
    });
    job.schedule(sendAt);
    await job.save();

    scheduled += 1;
  }

  return { scheduled, skipped };
}
