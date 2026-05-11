const Video = require('../models/Video');
const AppError = require('../utils/AppError');

exports.getAll = async () => Video.find().sort({ createdAt: -1 }).populate('artisteId', 'nom');

exports.create = async ({ titre, artisteId, videoUrl }) => {
  if (!titre || !artisteId || !videoUrl) {
    throw new AppError('titre, artisteId et videoUrl sont obligatoires.', 400);
  }
  return Video.create({ titre, artisteId, videoUrl });
};

exports.getById = async (id) => {
  const video = await Video.findById(id).populate('artisteId', 'nom');
  if (!video) throw new AppError('Vidéo introuvable.', 404);
  return video;
};

exports.like = async (id) => {
  const video = await Video.findByIdAndUpdate(id, { $inc: { likes: 1 } }, { new: true });
  if (!video) throw new AppError('Vidéo introuvable.', 404);
  return video;
};

exports.addComment = async (videoId, { auteurId, texte }) => {
  if (!texte) throw new AppError('Le texte du commentaire est obligatoire.', 400);
  const video = await Video.findByIdAndUpdate(
    videoId,
    { $push: { commentaires: { auteurId, texte } } },
    { new: true, runValidators: true }
  );
  if (!video) throw new AppError('Vidéo introuvable.', 404);
  return video;
};

exports.remove = async (id) => {
  const video = await Video.findByIdAndDelete(id);
  if (!video) throw new AppError('Vidéo introuvable.', 404);
};
