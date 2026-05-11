require('dotenv').config();
const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');

const connectDB = require('./config/db');
const errorHandler = require('./middleware/errorHandler');

const authRouter = require('./routes/auth');
const artistesRouter = require('./routes/artistes');
const videosRouter = require('./routes/videos');
const musicRouter = require('./routes/music');

const app = express();

app.use(cors());
app.use(express.json());

const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: { title: 'FasoVibes API', version: '2.0.0', description: 'API musicale pour le Burkina Faso' },
    servers: [{ url: 'https://fasovibes-backend.onrender.com' }],
    components: {
      securitySchemes: {
        bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      },
    },
  },
  apis: ['./routes/*.js'],
};
try {
  const swaggerSpec = swaggerJsdoc(swaggerOptions);
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
} catch (err) {
  console.error('Swagger init error (non-bloquant):', err.message);
}

app.get('/', (req, res) => res.json({ status: 'success', message: 'API FasoVibes en ligne' }));

app.use('/auth', authRouter);
app.use('/artistes', artistesRouter);
app.use('/videos', videosRouter);
app.use('/music', musicRouter);

app.use((req, res) => {
  res.status(404).json({ status: 'fail', message: `Route ${req.originalUrl} introuvable.` });
});

app.use(errorHandler);

connectDB().then(() => {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => console.log(`Serveur démarré sur le port ${PORT}`));
});
