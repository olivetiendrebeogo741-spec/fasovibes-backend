const express = require('express');
const router = express.Router();
const musicController = require('../controllers/musicController');
const authenticate = require('../middleware/authenticate');
const { uploadMusicFiles } = require('../middleware/upload');

/**
 * @openapi
 * /music:
 *   get:
 *     summary: Récupérer tous les morceaux
 *     responses:
 *       200:
 *         description: Liste des morceaux
 */
router.get('/', musicController.getAll);

/**
 * @openapi
 * /music/{id}:
 *   get:
 *     summary: Récupérer un morceau par ID
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Morceau trouvé
 *       404:
 *         description: Morceau introuvable
 */
router.get('/:id', musicController.getOne);

/**
 * @openapi
 * /music:
 *   post:
 *     summary: Ajouter un morceau (authentification requise)
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [titre, artisteId, audioUrl]
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
router.post('/', authenticate, uploadMusicFiles, musicController.create);

/**
 * @openapi
 * /music/{id}:
 *   delete:
 *     summary: Supprimer un morceau (authentification requise)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       204:
 *         description: Morceau supprimé
 */
router.delete('/:id', authenticate, musicController.remove);

/**
 * @openapi
 * /music/{id}/stream:
 *   post:
 *     summary: Incrémenter le compteur d'écoutes d'un morceau
 *     tags:
 *       - Music
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID du morceau
 *     responses:
 *       200:
 *         description: Compteur incrémenté avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 data:
 *                   type: object
 *                   properties:
 *                     streams:
 *                       type: integer
 *                       example: 42
 *       404:
 *         description: Morceau introuvable
 */
router.post('/:id/stream', musicController.stream);

module.exports = router;
