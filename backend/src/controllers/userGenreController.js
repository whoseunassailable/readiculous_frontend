const db = require('../config/db');
const logger = require('../config/logger');

// Add genres to a user's preferences
exports.addUserGenres = async (req, res) => {
    const { user_id, genre_ids } = req.body;

    if (!user_id || !Array.isArray(genre_ids) || genre_ids.length === 0) {
        logger.warn({ user_id, genre_ids }, 'addUserGenres: user_id and genre_ids array required');
        return res.status(400).json({ message: 'user_id and genre_ids array are required' });
    }

    try {
        const values = genre_ids.map(genre_id => [user_id, genre_id]);
        await db.query('INSERT IGNORE INTO user_genres (user_id, genre_id) VALUES ?', [values]);

        logger.info({ user_id, count: genre_ids.length }, 'addUserGenres: genres added to user preferences');
        res.status(201).json({ message: 'Genres added to user preferences' });
    } catch (error) {
        logger.error(error, 'addUserGenres: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};

// Remove a genre from a user's preferences
exports.removeUserGenre = async (req, res) => {
    const { user_id, genre_id } = req.params;

    try {
        logger.debug({ user_id, genre_id }, 'removeUserGenre: removing genre preference');

        const [result] = await db.execute(
            'DELETE FROM user_genres WHERE user_id = ? AND genre_id = ?',
            [user_id, genre_id]
        );

        if (result.affectedRows === 0) {
            logger.warn({ user_id, genre_id }, 'removeUserGenre: preference not found');
            return res.status(404).json({ message: 'Preference not found' });
        }

        logger.info({ user_id, genre_id }, 'removeUserGenre: genre preference removed');
        res.json({ message: 'Genre preference removed' });
    } catch (error) {
        logger.error(error, 'removeUserGenre: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};

// Get all genres preferred by a user
exports.getUserGenres = async (req, res) => {
    const { user_id } = req.params;

    try {
        logger.debug({ user_id }, 'getUserGenres: fetching genres for user');

        const [rows] = await db.execute(
            `SELECT g.genre_id, g.name
             FROM user_genres ug
             JOIN genres g ON ug.genre_id = g.genre_id
             WHERE ug.user_id = ?`,
            [user_id]
        );

        logger.info({ user_id, count: rows.length }, 'getUserGenres: fetched user genres');
        res.json(rows);
    } catch (error) {
        logger.error(error, 'getUserGenres: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};
