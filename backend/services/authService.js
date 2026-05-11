const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const AppError = require('../utils/AppError');

const JWT_SECRET = process.env.JWT_SECRET || 'fasovibes_secret_key';

const signToken = (id, email) =>
  jwt.sign({ id, email }, JWT_SECRET, { expiresIn: '7d' });

exports.register = async ({ nom, email, motDePasse }) => {
  const existing = await User.findOne({ email });
  if (existing) throw new AppError('Cet email est déjà utilisé.', 400);

  const hash = await bcrypt.hash(motDePasse, 12);
  const user = await User.create({ nom, email, motDePasse: hash });

  return { userId: user._id, nom: user.nom, email: user.email };
};

exports.login = async ({ email, motDePasse }) => {
  const user = await User.findOne({ email }).select('+motDePasse');
  if (!user) throw new AppError('Email ou mot de passe incorrect.', 401);

  const valid = await bcrypt.compare(motDePasse, user.motDePasse);
  if (!valid) throw new AppError('Email ou mot de passe incorrect.', 401);

  const token = signToken(user._id, user.email);

  return {
    token,
    user: { id: user._id, nom: user.nom, email: user.email, photoProfil: user.photoProfil },
  };
};
