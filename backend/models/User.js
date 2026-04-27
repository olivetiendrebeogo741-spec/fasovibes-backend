const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  nom: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  motDePasse: { type: String, required: true },
  photoProfil: { type: String, default: null },
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
