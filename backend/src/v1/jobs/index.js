import { sendReminderSms } from '../services/twilio.service.js';

export function defineJobs(agenda) {
  agenda.define('sendReminderSms', async (job) => {
    const { toE164, className, title, dueAt } = job.attrs.data ?? {};
    if (!toE164) return;

    const body = `Yiri reminder: ${className} — ${title} is due ${new Date(dueAt).toLocaleDateString()}.`;
    await sendReminderSms({ toE164, body });
  });
}
