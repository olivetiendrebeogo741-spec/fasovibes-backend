const videoService = require('../services/videoService');

exports.getAll = async (req, res, next) => {
  try {
    const videos = await videoService.getAll();
    res.status(200).json({ status: 'success', results: videos.length, data: videos });
  } catch (err) {
    next(err);
  }
};

exports.getOne = async (req, res, next) => {
  try {
    const video = await videoService.getById(req.params.id);
    res.status(200).json({ status: 'success', data: video });
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const video = await videoService.create(req.body);
    res.status(201).json({ status: 'success', data: video });
  } catch (err) {
    next(err);
  }
};

exports.like = async (req, res, next) => {
  try {
    const video = await videoService.like(req.params.id);
    res.status(200).json({ status: 'success', data: video });
  } catch (err) {
    next(err);
  }
};

exports.addComment = async (req, res, next) => {
  try {
    const video = await videoService.addComment(req.params.id, {
      auteurId: req.user.id,
      texte: req.body.texte,
    });
    res.status(200).json({ status: 'success', data: video });
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    await videoService.remove(req.params.id);
    res.status(204).send();
  } catch (err) {
    next(err);
  }
};
