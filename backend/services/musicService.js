const Music = require('../models/Music');
const AppError = require('../utils/AppError');

exports.getAll = async () => Music.find().sort({ createdAt: -1 }).populate('artisteId', 'nom photoProfil');

exports.create = async ({ titre, artisteId, audioUrl, coverImg }) => {
  if (!titre || !artisteId || !audioUrl) {
    throw new AppError('titre, artisteId et audioUrl sont obligatoires.', 400);
  }
  return Music.create({ titre, artisteId, audioUrl, coverImg });
};

exports.getById = async (id) => {
  const track = await Music.findById(id).populate('artisteId', 'nom');
  if (!track) throw new AppError('Morceau introuvable.', 404);
  return track;
};

exports.remove = async (id) => {
  const track = await Music.findByIdAndDelete(id);
  if (!track) throw new AppError('Morceau introuvable.', 404);
};

exports.stream = async (id) => {
  const track = await Music.findByIdAndUpdate(
    id,
    { $inc: { streams: 1 } },
    { new: true }
  );
  if (!track) throw new AppError('Morceau introuvable.', 404);
  return track;
};
