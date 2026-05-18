const musicService = require('../services/musicService');

exports.getAll = async (req, res, next) => {
  try {
    const tracks = await musicService.getAll();
    res.status(200).json({ status: 'success', results: tracks.length, data: tracks });
  } catch (err) {
    next(err);
  }
};

exports.getOne = async (req, res, next) => {
  try {
    const track = await musicService.getById(req.params.id);
    res.status(200).json({ status: 'success', data: track });
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const baseUrl = process.env.BASE_URL || 'https://fasovibes-backend.onrender.com';
    const audioFile = req.files?.['audio']?.[0];
    const coverFile = req.files?.['cover']?.[0];
    const audioUrl = audioFile
      ? `${baseUrl}/uploads/audio/${audioFile.filename}`
      : req.body.audioUrl;
    const coverImg = coverFile
      ? `${baseUrl}/uploads/covers/${coverFile.filename}`
      : req.body.coverImg;
    const track = await musicService.create({ ...req.body, audioUrl, coverImg });
    res.status(201).json({ status: 'success', data: track });
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    await musicService.remove(req.params.id);
    res.status(204).send();
  } catch (err) {
    next(err);
  }
};

exports.stream = async (req, res, next) => {
  try {
    const track = await musicService.stream(req.params.id);
    res.status(200).json({ status: 'success', data: { streams: track.streams } });
  } catch (err) {
    next(err);
  }
};
