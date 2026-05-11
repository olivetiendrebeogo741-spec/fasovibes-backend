const mongoose = require('mongoose');

const connectDB = async () => {
  const uri = process.env.MONGO_URI;

  if (!uri) {
    console.error('MONGO_URI manquant dans les variables d\'environnement.');
    process.exit(1);
  }

  try {
    await mongoose.connect(uri);
    console.log('MongoDB connecté');
  } catch (err) {
    if (err.message.includes('bad auth') || err.message.includes('authentication failed')) {
      console.error('Erreur MongoDB — Authentification échouée.');
      console.error('Vérifie que ton mot de passe ne contient pas de caractères spéciaux non encodés (@, :, /, ?, #, &).');
      console.error('Encode-les avec encodeURIComponent() ou remplace-les dans l\'URI.');
    } else {
      console.error('Erreur connexion MongoDB:', err.message);
    }
    process.exit(1);
  }
};

module.exports = connectDB;
