function notFoundHandler(_req, _res, next) {
  const error = new Error("Route not found");
  error.statusCode = 404;
  next(error);
}

function errorHandler(err, _req, res, _next) {
  const statusCode = err.statusCode || 500;

  res.status(statusCode).json({
    message: err.message || "Unexpected server error",
    details: err.details || null,
  });
}

module.exports = {
  notFoundHandler,
  errorHandler,
};
