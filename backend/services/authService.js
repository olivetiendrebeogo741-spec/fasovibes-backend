const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const AppError = require('../utils/AppError');

const JWT_SECRET = process.env.JWT_SECRET || 'fasovibes_secret_key';

const signToken = (id) =>
  jwt.sign({ id }, JWT_SECRET, { expiresIn: '7d' });

const isEmail = (str) => str.includes('@');

// Build the search/create field from the identifier (email or phone)
const identifierField = (identifier) =>
  isEmail(identifier)
    ? { email: identifier.toLowerCase().trim() }
    : { telephone: identifier.trim() };

exports.register = async ({ nom, identifier, motDePasse }) => {
  if (!identifier) throw new AppError('Email ou numéro de téléphone requis.', 400);

  const field = identifierField(identifier);
  const existing = await User.findOne(field);
  if (existing) {
    throw new AppError(
      isEmail(identifier)
        ? 'Cet email est déjà utilisé.'
        : 'Ce numéro est déjà utilisé.',
      400
    );
  }

  const hash = await bcrypt.hash(motDePasse, 12);
  const user = await User.create({ nom, motDePasse: hash, ...field });

  return {
    userId: user._id,
    nom: user.nom,
    email: user.email || null,
    telephone: user.telephone || null,
  };
};

exports.updateProfile = async (userId, { nom, bio, genre }) => {
  const updates = {};
  if (nom && nom.trim()) updates.nom = nom.trim();
  if (bio !== undefined) updates.bio = bio?.trim() || null;
  if (genre !== undefined) updates.genre = genre?.trim() || null;

  const user = await User.findByIdAndUpdate(userId, updates, { new: true });
  if (!user) throw new AppError('Utilisateur introuvable.', 404);
  return { id: user._id, nom: user.nom, bio: user.bio, genre: user.genre };
};

exports.login = async ({ identifier, motDePasse }) => {
  if (!identifier) throw new AppError('Email ou numéro de téléphone requis.', 400);

  const field = identifierField(identifier);
  const user = await User.findOne(field).select('+motDePasse');
  if (!user) throw new AppError('Identifiant ou mot de passe incorrect.', 401);

  const valid = await bcrypt.compare(motDePasse, user.motDePasse);
  if (!valid) throw new AppError('Identifiant ou mot de passe incorrect.', 401);

  const token = signToken(user._id);

  return {
    token,
    user: {
      id: user._id,
      nom: user.nom,
      email: user.email || null,
      telephone: user.telephone || null,
      photoProfil: user.photoProfil,
    },
  };
};
