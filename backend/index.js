const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');
require('dotenv').config();

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
  },
  apis: ['./routes/*.js'],
};
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerJsdoc(swaggerOptions)));

app.use('/auth', authRouter);
app.use('/artistes', artistesRouter);
app.use('/videos', videosRouter);
app.use('/music', musicRouter);

app.get('/', (req, res) => res.send('🚀 API FasoVibes Live!'));

mongoose.connect(process.env.MONGO_URI).then(() => console.log('✅ MongoDB connecté'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Serveur sur port ${PORT}`));
