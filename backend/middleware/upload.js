const multer = require('multer');
const path = require('path');

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
