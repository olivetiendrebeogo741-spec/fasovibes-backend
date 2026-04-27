const mongoose = require('mongoose');

const musicSchema = new mongoose.Schema({
  titre: { type: String, required: true },
  artisteId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  audioUrl: { type: String, required: true },
  coverImg: { type: String, default: null },
}, { timestamps: true });

module.exports = mongoose.model('Music', musicSchema);
