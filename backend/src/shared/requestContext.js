export function attachRequestContext({ agenda }) {
  return function requestContext(req, _res, next) {
    req.ctx = { agenda };
    next();
  };
}
