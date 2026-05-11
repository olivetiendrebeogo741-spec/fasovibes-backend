const express = require('express');
const router = express.Router();
const artisteController = require('../controllers/artisteController');
const authenticate = require('../middleware/authenticate');

/**
 * @openapi
 * /artistes:
 *   get:
 *     summary: Récupérer la liste des artistes
 *     responses:
 *       200:
 *         description: Liste des artistes
 */
router.get('/', artisteController.getAll);

/**
 * @openapi
 * /artistes/{id}:
 *   get:
 *     summary: Récupérer un artiste par ID
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Artiste trouvé
 *       404:
 *         description: Artiste introuvable
 */
router.get('/:id', artisteController.getOne);

/**
 * @openapi
 * /artistes:
 *   post:
 *     summary: Créer un artiste (authentification requise)
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [nom]
 *             properties:
 *               nom:
 *                 type: string
 *               genre:
 *                 type: string
 *               bio:
 *                 type: string
 *               photoProfil:
 *                 type: string
 *     responses:
 *       201:
 *         description: Artiste créé
 */
router.post('/', authenticate, artisteController.create);

/**
 * @openapi
 * /artistes/{id}:
 *   delete:
 *     summary: Supprimer un artiste (authentification requise)
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
 *         description: Artiste supprimé
 */
router.delete('/:id', authenticate, artisteController.remove);

module.exports = router;
