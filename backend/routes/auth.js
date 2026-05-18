const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

/**
 * @openapi
 * /auth/register:
 *   post:
 *     summary: Créer un nouveau compte
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [nom, email, motDePasse]
 *             properties:
 *               nom:
 *                 type: string
 *               email:
 *                 type: string
 *               motDePasse:
 *                 type: string
 *     responses:
 *       201:
 *         description: Compte créé
 *       400:
 *         description: Email déjà utilisé ou données invalides
 */
router.post('/register', authController.register);

/**
 * @openapi
 * /auth/login:
 *   post:
 *     summary: Se connecter
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, motDePasse]
 *             properties:
 *               email:
 *                 type: string
 *               motDePasse:
 *                 type: string
 *     responses:
 *       200:
 *         description: Connexion réussie avec token JWT
 *       401:
 *         description: Identifiants incorrects
 */
router.post('/login', authController.login);

/**
 * @openapi
 * /auth/me:
 *   patch:
 *     summary: Mettre à jour le profil (authentification requise)
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               nom:
 *                 type: string
 *               bio:
 *                 type: string
 *               genre:
 *                 type: string
 *     responses:
 *       200:
 *         description: Profil mis à jour
 */
const authenticate = require('../middleware/authenticate');
router.patch('/me', authenticate, authController.updateProfile);

module.exports = router;
