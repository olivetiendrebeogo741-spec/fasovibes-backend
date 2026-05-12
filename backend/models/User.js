const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    nom: {
      type: String,
      required: [true, 'Le nom est obligatoire'],
      trim: true,
      maxlength: [50, 'Le nom ne peut pas dépasser 50 caractères'],
    },
    email: {
      type: String,
      lowercase: true,
      trim: true,
      default: null,
      validate: {
        validator: (v) => !v || /^\S+@\S+\.\S+$/.test(v),
        message: 'Email invalide',
      },
    },
    telephone: {
      type: String,
      trim: true,
      default: null,
    },
    motDePasse: {
      type: String,
      required: [true, 'Le mot de passe est obligatoire'],
      minlength: [6, 'Le mot de passe doit faire au moins 6 caractères'],
      select: false,
    },
    photoProfil: { type: String, default: null },
  },
  { timestamps: true, autoIndex: false }
);

module.exports = mongoose.model('User', userSchema);
