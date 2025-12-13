export function isValid(d) {
  return d instanceof Date && !Number.isNaN(d.getTime());
}

export function addHours(date, hours) {
  const d = new Date(date.getTime());
  d.setHours(d.getHours() + hours);
  return d;
}
