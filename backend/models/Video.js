const mongoose = require('mongoose');

const commentaireSchema = new mongoose.Schema({
  auteurId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  texte: { type: String, required: true },
  date: { type: Date, default: Date.now },
});

const videoSchema = new mongoose.Schema({
  titre: { type: String, required: true },
  artisteId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  videoUrl: { type: String, required: true },
  likes: { type: Number, default: 0 },
  commentaires: [commentaireSchema],
}, { timestamps: true });

module.exports = mongoose.model('Video', videoSchema);
