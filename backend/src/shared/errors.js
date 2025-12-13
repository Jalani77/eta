export function notFound(_req, res) {
  res.status(404).json({ error: { code: 'NOT_FOUND', message: 'Route not found' } });
}

// eslint-disable-next-line no-unused-vars
export function errorHandler(err, _req, res, _next) {
  const status = Number(err?.statusCode ?? 500);
  const code = err?.code ?? 'INTERNAL_ERROR';
  const message = err?.message ?? 'Unexpected error';

  res.status(status).json({ error: { code, message } });
}
