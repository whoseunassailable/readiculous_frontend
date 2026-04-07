const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');

router.get('/', bookController.getBooks);
router.get('/:book_id', bookController.getBook);
router.post('/', bookController.createBook);
router.put('/:book_id', bookController.updateBook);
router.delete('/:book_id', bookController.deleteBook);

module.exports = router;
