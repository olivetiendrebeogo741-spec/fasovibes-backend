const artisteService = require('../services/artisteService');

exports.getAll = async (req, res, next) => {
  try {
    const artistes = await artisteService.getAll();
    res.status(200).json({ status: 'success', results: artistes.length, data: artistes });
  } catch (err) {
    next(err);
  }
};

exports.getOne = async (req, res, next) => {
  try {
    const artiste = await artisteService.getById(req.params.id);
    res.status(200).json({ status: 'success', data: artiste });
  } catch (err) {
    next(err);
  }
};

exports.create = async (req, res, next) => {
  try {
    const artiste = await artisteService.create(req.body);
    res.status(201).json({ status: 'success', data: artiste });
  } catch (err) {
    next(err);
  }
};

exports.remove = async (req, res, next) => {
  try {
    await artisteService.remove(req.params.id);
    res.status(204).send();
  } catch (err) {
    next(err);
  }
};
