const db = require('../config/db');
const logger = require('../config/logger');

// GET /api/books
exports.getBooks = async (_req, res) => {
    try {
        const [books] = await db.execute('SELECT book_id, title, author, description, cover_url, isbn13, created_at, updated_at FROM books');
        logger.info({ count: books.length }, 'getBooks: fetched books');
        res.json(books);
    } catch (error) {
        logger.error(error, 'getBooks: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};

// GET /api/books/:book_id
exports.getBook = async (req, res) => {
    const { book_id } = req.params;
    try {
        const [rows] = await db.execute(
            'SELECT book_id, title, author, description, cover_url, isbn13, created_at, updated_at FROM books WHERE book_id = ?',
            [book_id]
        );

        if (rows.length === 0) {
            logger.warn({ book_id }, 'getBook: book not found');
            return res.status(404).json({ message: 'Book not found' });
        }

        logger.info({ book_id }, 'getBook: fetched book');
        res.json(rows[0]);
    } catch (error) {
        logger.error(error, 'getBook: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};

// POST /api/books
exports.createBook = async (req, res) => {
    const { title, author, description, cover_url, isbn13 } = req.body;

    if (!title) {
        logger.warn({ title }, 'createBook: title is required');
        return res.status(400).json({ message: 'Title is required' });
    }

    try {
        const [result] = await db.execute(
            'INSERT INTO books (title, author, description, cover_url, isbn13) VALUES (?, ?, ?, ?, ?)',
            [title, author || null, description || null, cover_url || null, isbn13 || null]
        );

        logger.info({ book_id: result.insertId, title, author }, 'createBook: book created');
        res.status(201).json({ message: 'Book created', book_id: result.insertId });
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            logger.warn({ isbn13 }, 'createBook: duplicate isbn13');
            return res.status(409).json({ message: 'A book with this ISBN already exists' });
        }
        logger.error(error, 'createBook: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};

// PUT /api/books/:book_id
exports.updateBook = async (req, res) => {
    const { book_id } = req.params;
    const { title, author, description, cover_url, isbn13 } = req.body;

    try {
        logger.debug({ book_id }, 'updateBook: updating book');

        const [result] = await db.execute(
            'UPDATE books SET title = ?, author = ?, description = ?, cover_url = ?, isbn13 = ? WHERE book_id = ?',
            [title, author || null, description || null, cover_url || null, isbn13 || null, book_id]
        );

        if (result.affectedRows === 0) {
            logger.warn({ book_id }, 'updateBook: book not found');
            return res.status(404).json({ message: 'Book not found' });
        }

        logger.info({ book_id }, 'updateBook: book updated');
        res.json({ message: 'Book updated successfully' });
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            logger.warn({ isbn13 }, 'updateBook: duplicate isbn13');
            return res.status(409).json({ message: 'A book with this ISBN already exists' });
        }
        logger.error(error, 'updateBook: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};

// DELETE /api/books/:book_id
exports.deleteBook = async (req, res) => {
    const { book_id } = req.params;
    try {
        const [result] = await db.execute('DELETE FROM books WHERE book_id = ?', [book_id]);

        if (result.affectedRows === 0) {
            logger.warn({ book_id }, 'deleteBook: book not found');
            return res.status(404).json({ message: 'Book not found' });
        }

        logger.info({ book_id }, 'deleteBook: book deleted');
        res.json({ message: 'Book deleted successfully' });
    } catch (error) {
        logger.error(error, 'deleteBook: unexpected error');
        res.status(500).json({ message: 'Internal server error' });
    }
};
