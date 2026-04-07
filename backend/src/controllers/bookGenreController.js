const db = require('../config/db');
const logger = require('../config/logger');

// POST /api/book-genres
exports.assignGenresToBook = async (req, res) => {
    const { book_id, genre_ids } = req.body;

    if (!book_id || !Array.isArray(genre_ids) || genre_ids.length === 0) {
        logger.warn({ book_id, genre_ids }, 'assignGenresToBook: book_id and genre_ids array required');
        return res.status(400).json({ message: 'book_id and genre_ids array are required' });
    }

    try {
        const values = genre_ids.map(genre_id => [book_id, genre_id]);
        await db.query('INSERT IGNORE INTO book_genres (book_id, genre_id) VALUES ?', [values]);

        logger.info({ book_id, count: genre_ids.length }, 'assignGenresToBook: genres assigned to book');
        res.status(201).json({ message: 'Genres assigned to book' });
    } catch (error) {
        logger.error(error, 'assignGenresToBook: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};

// GET /api/book-genres/:book_id
exports.getGenresForBook = async (req, res) => {
    const { book_id } = req.params;
    try {
        logger.debug({ book_id }, 'getGenresForBook: fetching genres');

        const [rows] = await db.execute(
            `SELECT g.genre_id, g.name
             FROM book_genres bg
             JOIN genres g ON g.genre_id = bg.genre_id
             WHERE bg.book_id = ?`,
            [book_id]
        );

        logger.info({ book_id, count: rows.length }, 'getGenresForBook: fetched genres');
        res.json(rows);
    } catch (error) {
        logger.error(error, 'getGenresForBook: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};

// DELETE /api/book-genres/:book_id/:genre_id
exports.removeGenreFromBook = async (req, res) => {
    const { book_id, genre_id } = req.params;
    try {
        const [result] = await db.execute(
            'DELETE FROM book_genres WHERE book_id = ? AND genre_id = ?',
            [book_id, genre_id]
        );

        if (result.affectedRows === 0) {
            logger.warn({ book_id, genre_id }, 'removeGenreFromBook: assignment not found');
            return res.status(404).json({ message: 'Book-genre assignment not found' });
        }

        logger.info({ book_id, genre_id }, 'removeGenreFromBook: genre removed from book');
        res.json({ message: 'Genre removed from book' });
    } catch (error) {
        logger.error(error, 'removeGenreFromBook: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};
