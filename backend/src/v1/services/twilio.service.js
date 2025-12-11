import twilio from 'twilio';

export function createTwilioClient() {
  const sid = process.env.TWILIO_ACCOUNT_SID;
  const token = process.env.TWILIO_AUTH_TOKEN;
  if (!sid || !token) return null;
  return twilio(sid, token);
}

export async function sendReminderSms({ toE164, body }) {
  const client = createTwilioClient();
  const from = process.env.TWILIO_FROM_NUMBER;

  if (!client) {
    // In dev, allow running without Twilio credentials.
    // eslint-disable-next-line no-console
    console.log('[twilio:disabled] would send to', toE164, 'body:', body);
    return { disabled: true };
  }

  if (!from) throw new Error('Missing TWILIO_FROM_NUMBER');

  const result = await client.messages.create({
    from,
    to: toE164,
    body,
  });

  return { sid: result.sid };
}
