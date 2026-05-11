const express = require('express');
const router = express.Router();
const musicController = require('../controllers/musicController');
const authenticate = require('../middleware/authenticate');

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
router.post('/', authenticate, musicController.create);

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

module.exports = router;
