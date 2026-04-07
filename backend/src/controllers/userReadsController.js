const db = require("../config/db");
const logger = require("../config/logger");

// GET /api/reads/:user_id
exports.getReadsForUser = async (req, res) => {
  const { user_id } = req.params;
  try {
    logger.debug({ user_id }, "getReadsForUser: fetching reads");

    const [rows] = await db.execute(
      `SELECT ur.user_id, ur.book_id, b.title, b.author, b.cover_url,
              ur.status, ur.rating, ur.created_at, ur.updated_at
       FROM user_reads ur
       JOIN books b ON b.book_id = ur.book_id
       WHERE ur.user_id = ?`,
      [user_id],
    );

    logger.info({ user_id, count: rows.length }, "getReadsForUser: fetched reads");
    res.json(rows);
  } catch (err) {
    logger.error(err, "getReadsForUser: unexpected error");
    res.status(500).json({ message: "Internal server error" });
  }
};

// POST /api/reads
exports.upsertRead = async (req, res) => {
  const { user_id, book_id, status = "want_to_read", rating = null } = req.body;

  if (!user_id || !book_id) {
    logger.warn({ user_id, book_id }, "upsertRead: user_id and book_id required");
    return res.status(400).json({ message: "user_id and book_id required" });
  }

  try {
    logger.debug({ user_id, book_id, status, rating }, "upsertRead: saving read status");

    await db.execute(
      `INSERT INTO user_reads (user_id, book_id, status, rating)
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         status = VALUES(status),
         rating = VALUES(rating)`,
      [user_id, book_id, status, rating],
    );

    logger.info({ user_id, book_id, status }, "upsertRead: read status saved");
    res.status(201).json({ message: "Read status saved" });
  } catch (err) {
    logger.error(err, "upsertRead: unexpected error");
    res.status(500).json({ message: "Internal server error" });
  }
};

// DELETE /api/reads/:user_id/:book_id
exports.deleteRead = async (req, res) => {
  const { user_id, book_id } = req.params;
  try {
    const [result] = await db.execute(
      "DELETE FROM user_reads WHERE user_id = ? AND book_id = ?",
      [user_id, book_id],
    );

    if (result.affectedRows === 0) {
      logger.warn({ user_id, book_id }, "deleteRead: read entry not found");
      return res.status(404).json({ message: "Read entry not found" });
    }

    logger.info({ user_id, book_id }, "deleteRead: read entry deleted");
    res.json({ message: "Read entry deleted" });
  } catch (err) {
    logger.error(err, "deleteRead: unexpected error");
    res.status(500).json({ message: "Internal server error" });
  }
};
