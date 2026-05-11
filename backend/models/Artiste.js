const mongoose = require('mongoose');

const artisteSchema = new mongoose.Schema(
  {
    nom: {
      type: String,
      required: [true, 'Le nom est obligatoire'],
      trim: true,
      maxlength: [100, 'Le nom ne peut pas dépasser 100 caractères'],
    },
    genre: {
      type: String,
      trim: true,
      maxlength: [50, 'Le genre ne peut pas dépasser 50 caractères'],
    },
    bio: { type: String, maxlength: [500, 'La bio ne peut pas dépasser 500 caractères'] },
    photoProfil: { type: String, default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Artiste', artisteSchema);
