const express = require('express');
const router = express.Router();
const controller = require('../controllers/bookGenreController');

router.post('/', controller.assignGenresToBook);
router.get('/:book_id', controller.getGenresForBook);
router.delete('/:book_id/:genre_id', controller.removeGenreFromBook);

module.exports = router;
