export function isValidE164(phone) {
  if (phone == null) return true;
  if (typeof phone !== 'string') return false;
  const v = phone.trim();
  if (v.length === 0) return true;
  // E.164: +[1-9][0-9]{1,14}
  return /^\+[1-9]\d{1,14}$/.test(v);
}
