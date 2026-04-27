const express = require('express');
const router = express.Router();
const Video = require('../models/Video');

/**
 * @openapi
 * /videos:
 *   get:
 *     summary: Récupérer le feed de vidéos
 *     responses:
 *       200:
 *         description: Liste des vidéos
 */
router.get('/', async (req, res) => {
  try {
    const videos = await Video.find().sort({ createdAt: -1 });
    res.json(videos);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @openapi
 * /videos:
 *   post:
 *     summary: Uploader une vidéo
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
 *               videoUrl:
 *                 type: string
 *     responses:
 *       201:
 *         description: Vidéo créée
 */
router.post('/', async (req, res) => {
  try {
    const video = await Video.create(req.body);
    res.status(201).json(video);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

/**
 * @openapi
 * /videos/{id}/like:
 *   patch:
 *     summary: Liker une vidéo
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Like ajouté
 */
router.patch('/:id/like', async (req, res) => {
  try {
    const video = await Video.findByIdAndUpdate(
      req.params.id,
      { $inc: { likes: 1 } },
      { new: true }
    );
    res.json(video);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
