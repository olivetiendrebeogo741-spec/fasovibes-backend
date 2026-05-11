const Artiste = require('../models/Artiste');
const AppError = require('../utils/AppError');

exports.getAll = async () => Artiste.find().sort({ nom: 1 });

exports.create = async ({ nom, genre, bio, photoProfil }) => {
  if (!nom) throw new AppError('Le nom de l\'artiste est obligatoire.', 400);
  return Artiste.create({ nom, genre, bio, photoProfil });
};

exports.getById = async (id) => {
  const artiste = await Artiste.findById(id);
  if (!artiste) throw new AppError('Artiste introuvable.', 404);
  return artiste;
};

exports.remove = async (id) => {
  const artiste = await Artiste.findByIdAndDelete(id);
  if (!artiste) throw new AppError('Artiste introuvable.', 404);
};
