const AppError = require('../utils/AppError');

const handleCastErrorDB = (err) =>
  new AppError(`Valeur invalide pour le champ "${err.path}": ${err.value}`, 400);

const handleDuplicateFieldsDB = (err) => {
  const field = Object.keys(err.keyValue)[0];
  return new AppError(`La valeur du champ "${field}" existe déjà.`, 400);
};

const handleValidationErrorDB = (err) => {
  const messages = Object.values(err.errors).map((e) => e.message);
  return new AppError(`Données invalides: ${messages.join('. ')}`, 400);
};

const handleJWTError = () =>
  new AppError('Token invalide. Veuillez vous reconnecter.', 401);

const handleJWTExpiredError = () =>
  new AppError('Token expiré. Veuillez vous reconnecter.', 401);

const sendErrorDev = (err, res) => {
  res.status(err.statusCode).json({
    status: err.status,
    message: err.message,
    stack: err.stack,
    error: err,
  });
};

const sendErrorProd = (err, res) => {
  if (err.isOperational) {
    res.status(err.statusCode).json({ status: err.status, message: err.message });
  } else {
    console.error('ERREUR INTERNE:', err);
    res.status(500).json({ status: 'error', message: 'Une erreur interne est survenue.' });
  }
};

module.exports = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';

  if (process.env.NODE_ENV === 'development') {
    sendErrorDev(err, res);
  } else {
    let error = { ...err, message: err.message };
    if (err.name === 'CastError') error = handleCastErrorDB(error);
    if (err.code === 11000) error = handleDuplicateFieldsDB(error);
    if (err.name === 'ValidationError') error = handleValidationErrorDB(error);
    if (err.name === 'JsonWebTokenError') error = handleJWTError();
    if (err.name === 'TokenExpiredError') error = handleJWTExpiredError();
    sendErrorProd(error, res);
  }
};
