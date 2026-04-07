const express = require('express');
const router = express.Router();
const genreController = require('../controllers/genreController');

router.get('/', genreController.getGenres);
router.post('/', genreController.createGenre);
router.delete('/:genre_id', genreController.deleteGenre);

module.exports = router;
