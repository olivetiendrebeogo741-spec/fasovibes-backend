const authService = require('../services/authService');

exports.register = async (req, res, next) => {
  try {
    const data = await authService.register(req.body);
    res.status(201).json({ status: 'success', message: 'Compte créé avec succès.', data });
  } catch (err) {
    next(err);
  }
};

exports.login = async (req, res, next) => {
  try {
    const data = await authService.login(req.body);
    res.status(200).json({ status: 'success', data });
  } catch (err) {
    next(err);
  }
};
