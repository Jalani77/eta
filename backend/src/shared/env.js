function required(name) {
  const v = process.env[name];
  if (!v || v.trim().length === 0) {
    const err = new Error(`Missing required env var: ${name}`);
    err.code = 'ENV_MISSING';
    err.statusCode = 500;
    throw err;
  }
  return v;
}

function optional(name, fallback = undefined) {
  const v = process.env[name];
  if (!v || v.trim().length === 0) return fallback;
  return v;
}

export function loadEnv() {
  // Required for core operation
  const MONGODB_URI = required('MONGODB_URI');
  const JWT_SECRET = required('JWT_SECRET');

  // Optional/with defaults
  const PORT = Number(optional('PORT', '3001'));
  const CORS_ORIGIN = optional('CORS_ORIGIN', '*');

  return { MONGODB_URI, JWT_SECRET, PORT, CORS_ORIGIN };
}
