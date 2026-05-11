const mongoose = require('mongoose');

const commentaireSchema = new mongoose.Schema({
  auteurId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  texte: {
    type: String,
    required: [true, 'Le texte du commentaire est obligatoire'],
    maxlength: [500, 'Le commentaire ne peut pas dépasser 500 caractères'],
  },
  date: { type: Date, default: Date.now },
});

const videoSchema = new mongoose.Schema(
  {
    titre: {
      type: String,
      required: [true, 'Le titre est obligatoire'],
      trim: true,
      maxlength: [100, 'Le titre ne peut pas dépasser 100 caractères'],
    },
    artisteId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, "L'artiste est obligatoire"],
    },
    videoUrl: {
      type: String,
      required: [true, "L'URL vidéo est obligatoire"],
    },
    likes: { type: Number, default: 0, min: 0 },
    commentaires: [commentaireSchema],
  },
  { timestamps: true }
);

module.exports = mongoose.model('Video', videoSchema);
