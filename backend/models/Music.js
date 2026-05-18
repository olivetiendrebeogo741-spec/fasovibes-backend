const mongoose = require('mongoose');

const musicSchema = new mongoose.Schema(
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
    audioUrl: {
      type: String,
      required: [true, "L'URL audio est obligatoire"],
    },
    coverImg: { type: String, default: null },
    streams: { type: Number, default: 0 },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Music', musicSchema);
