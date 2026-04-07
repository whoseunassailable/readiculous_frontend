const express = require('express');
const router = express.Router();
const controller = require('../controllers/userGenreController');

router.post('/', controller.addUserGenres);
router.get('/:user_id', controller.getUserGenres);
router.delete('/:user_id/:genre_id', controller.removeUserGenre);

module.exports = router;
