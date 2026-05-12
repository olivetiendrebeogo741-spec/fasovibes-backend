const multer = require('multer');
const path = require('path');
const fs = require('fs');

['audio', 'video', 'covers'].forEach((d) => fs.mkdirSync(`uploads/${d}`, { recursive: true }));

const makeStorage = (folder) =>
  multer.diskStorage({
    destination: `uploads/${folder}/`,
    filename: (req, file, cb) => {
      const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
      cb(null, unique + path.extname(file.originalname));
    },
  });

exports.uploadAudio = multer({ storage: makeStorage('audio') });
exports.uploadVideo = multer({ storage: makeStorage('video') });

exports.uploadMusicFiles = multer({
  storage: multer.diskStorage({
    destination: (req, file, cb) => {
      cb(null, `uploads/${file.fieldname === 'cover' ? 'covers' : 'audio'}/`);
    },
    filename: (req, file, cb) => {
      const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
      cb(null, unique + path.extname(file.originalname));
    },
  }),
}).fields([
  { name: 'audio', maxCount: 1 },
  { name: 'cover', maxCount: 1 },
]);
