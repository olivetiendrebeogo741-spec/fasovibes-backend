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
      unique: true,
      sparse: true,         // plusieurs null autorisés dans l'index unique
      lowercase: true,
      trim: true,
      validate: {
        validator: (v) => !v || /^\S+@\S+\.\S+$/.test(v),
        message: 'Email invalide',
      },
    },
    telephone: {
      type: String,
      unique: true,
      sparse: true,
      trim: true,
    },
    motDePasse: {
      type: String,
      required: [true, 'Le mot de passe est obligatoire'],
      minlength: [6, 'Le mot de passe doit faire au moins 6 caractères'],
      select: false,
    },
    photoProfil: { type: String, default: null },
  },
  { timestamps: true }
);

// Au moins email ou telephone requis
userSchema.pre('validate', function (next) {
  if (!this.email && !this.telephone) {
    this.invalidate('email', 'Email ou numéro de téléphone requis.');
  }
  next();
});

module.exports = mongoose.model('User', userSchema);
