const express = require('express');
const router = express.Router();
const Music = require('../models/Music');

/**
 * @openapi
 * /music:
 *   get:
 *     summary: Récupérer tous les morceaux
 *     responses:
 *       200:
 *         description: Liste des morceaux
 */
router.get('/', async (req, res) => {
  try {
    const tracks = await Music.find().sort({ createdAt: -1 });
    res.json(tracks);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @openapi
 * /music:
 *   post:
 *     summary: Uploader un morceau
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               titre:
 *                 type: string
 *               artisteId:
 *                 type: string
 *               audioUrl:
 *                 type: string
 *               coverImg:
 *                 type: string
 *     responses:
 *       201:
 *         description: Morceau créé
 */
router.post('/', async (req, res) => {
  try {
    const track = await Music.create(req.body);
    res.status(201).json(track);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
