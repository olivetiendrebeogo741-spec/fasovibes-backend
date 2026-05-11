const jwt = require('jsonwebtoken');
const AppError = require('../utils/AppError');

module.exports = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new AppError('Vous devez être connecté pour accéder à cette ressource.', 401));
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fasovibes_secret_key');
    req.user = decoded;
    next();
  } catch (err) {
    next(new AppError('Token invalide ou expiré.', 401));
  }
};
