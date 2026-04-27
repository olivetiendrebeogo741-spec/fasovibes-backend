const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

const Artiste = mongoose.model('Artiste', new mongoose.Schema({
  nom: String,
  genre: String,
}));

/**
 * @openapi
 * /artistes:
 *   get:
 *     summary: Récupérer la liste des artistes
 *     responses:
 *       200:
 *         description: Liste des artistes
 */
router.get('/', async (req, res) => {
  const artistes = await Artiste.find();
  res.json(artistes);
});

module.exports = router;
