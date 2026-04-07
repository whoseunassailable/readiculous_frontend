const db = require('../config/db');
const logger = require('../config/logger');

// GET /api/genres
exports.getGenres = async (_req, res) => {
    try {
        const [genres] = await db.execute('SELECT genre_id, name FROM genres');
        logger.info({ count: genres.length }, 'getGenres: fetched genres');
        res.json(genres);
    } catch (error) {
        logger.error(error, 'getGenres: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};

// POST /api/genres
exports.createGenre = async (req, res) => {
    const { name } = req.body;

    if (!name) {
        logger.warn('createGenre: name is required');
        return res.status(400).json({ message: 'name is required' });
    }

    try {
        const [result] = await db.execute('INSERT INTO genres (name) VALUES (?)', [name]);
        logger.info({ genre_id: result.insertId, name }, 'createGenre: genre created');
        res.status(201).json({ message: 'Genre created', genre_id: result.insertId, name });
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            logger.warn({ name }, 'createGenre: duplicate genre name');
            return res.status(409).json({ message: 'Genre already exists' });
        }
        logger.error(error, 'createGenre: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};

// DELETE /api/genres/:genre_id
exports.deleteGenre = async (req, res) => {
    const { genre_id } = req.params;
    try {
        const [result] = await db.execute('DELETE FROM genres WHERE genre_id = ?', [genre_id]);

        if (result.affectedRows === 0) {
            logger.warn({ genre_id }, 'deleteGenre: genre not found');
            return res.status(404).json({ message: 'Genre not found' });
        }

        logger.info({ genre_id }, 'deleteGenre: genre deleted');
        res.json({ message: 'Genre deleted successfully' });
    } catch (error) {
        logger.error(error, 'deleteGenre: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};
