const db = require("../config/db");
const logger = require("../config/logger");

// GET /api/library-books/:library_id
exports.getBooksForLibrary = async (req, res) => {
  const { library_id } = req.params;

  try {
    logger.debug({ library_id }, "getBooksForLibrary: fetching books");

    const [rows] = await db.execute(
      `SELECT lb.library_id, lb.book_id, b.title, b.author,
              lb.copies_total, lb.copies_available, lb.low_stock_threshold, lb.is_deleted
       FROM library_books lb
       JOIN books b ON b.book_id = lb.book_id
       WHERE lb.library_id = ? AND lb.is_deleted = 0`,
      [library_id],
    );

    logger.info({ library_id, count: rows.length }, "getBooksForLibrary: fetched books");
    res.json(rows);
  } catch (err) {
    logger.error(err, "getBooksForLibrary: unexpected error");
    res.status(500).json({ message: "Internal server error" });
  }
};

// POST /api/library-books
exports.upsertLibraryBook = async (req, res) => {
  const {
    library_id,
    book_id,
    copies_total = 1,
    copies_available = 1,
    low_stock_threshold = 1,
    is_deleted = 0,
  } = req.body;

  if (!library_id || !book_id) {
    logger.warn({ library_id, book_id }, "upsertLibraryBook: library_id and book_id required");
    return res.status(400).json({ message: "library_id and book_id required" });
  }

  try {
    logger.debug({ library_id, book_id, copies_total, copies_available }, "upsertLibraryBook: upserting");

    await db.execute(
      `INSERT INTO library_books
       (library_id, book_id, copies_total, copies_available, low_stock_threshold, is_deleted)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         copies_total = VALUES(copies_total),
         copies_available = VALUES(copies_available),
         low_stock_threshold = VALUES(low_stock_threshold),
         is_deleted = VALUES(is_deleted)`,
      [library_id, book_id, copies_total, copies_available, low_stock_threshold, is_deleted],
    );

    logger.info({ library_id, book_id }, "upsertLibraryBook: library book saved");
    res.status(201).json({ message: "Library book saved" });
  } catch (err) {
    logger.error(err, "upsertLibraryBook: unexpected error");
    res.status(500).json({ message: "Internal server error" });
  }
};
