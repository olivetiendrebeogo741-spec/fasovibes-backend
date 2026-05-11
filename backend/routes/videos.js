const express = require('express');
const router = express.Router();
const videoController = require('../controllers/videoController');
const authenticate = require('../middleware/authenticate');

/**
 * @openapi
 * /videos:
 *   get:
 *     summary: Récupérer le feed de vidéos
 *     responses:
 *       200:
 *         description: Liste des vidéos
 */
router.get('/', videoController.getAll);

/**
 * @openapi
 * /videos/{id}:
 *   get:
 *     summary: Récupérer une vidéo par ID
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Vidéo trouvée
 *       404:
 *         description: Vidéo introuvable
 */
router.get('/:id', videoController.getOne);

/**
 * @openapi
 * /videos:
 *   post:
 *     summary: Uploader une vidéo (authentification requise)
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [titre, artisteId, videoUrl]
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
router.post('/', authenticate, videoController.create);

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
router.patch('/:id/like', videoController.like);

/**
 * @openapi
 * /videos/{id}/commentaires:
 *   post:
 *     summary: Commenter une vidéo (authentification requise)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [texte]
 *             properties:
 *               texte:
 *                 type: string
 *     responses:
 *       200:
 *         description: Commentaire ajouté
 */
router.post('/:id/commentaires', authenticate, videoController.addComment);

/**
 * @openapi
 * /videos/{id}:
 *   delete:
 *     summary: Supprimer une vidéo (authentification requise)
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
 *         description: Vidéo supprimée
 */
router.delete('/:id', authenticate, videoController.remove);

module.exports = router;
