const db = require("../config/db");
const logger = require("../config/logger");

// POST /api/librarians/assign
exports.assignLibrarian = async (req, res) => {
  const { user_id, library_id, verified = 0 } = req.body;

  if (!user_id || !library_id) {
    logger.warn({ user_id, library_id }, "assignLibrarian: user_id and library_id required");
    return res.status(400).json({ message: "user_id and library_id required" });
  }

  try {
    logger.debug({ user_id, library_id, verified }, "assignLibrarian: assigning librarian");

    await db.execute(
      `INSERT INTO librarians (user_id, library_id, verified)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE verified = VALUES(verified)`,
      [user_id, library_id, verified],
    );

    await db.execute("UPDATE users SET role='librarian' WHERE user_id = ?", [user_id]);

    logger.info({ user_id, library_id }, "assignLibrarian: librarian assigned and role updated");
    res.status(201).json({ message: "Librarian assigned" });
  } catch (err) {
    logger.error(err, "assignLibrarian: unexpected error");
    res.status(500).json({ message: "Internal server error" });
  }
};

// GET /api/librarians/:library_id
exports.getLibrariansForLibrary = async (req, res) => {
  const { library_id } = req.params;
  try {
    logger.debug({ library_id }, "getLibrariansForLibrary: fetching librarians");

    const [rows] = await db.execute(
      `SELECT l.user_id, u.first_name, u.last_name, u.email, l.verified, l.created_at
       FROM librarians l
       JOIN users u ON u.user_id = l.user_id
       WHERE l.library_id = ?`,
      [library_id],
    );

    logger.info({ library_id, count: rows.length }, "getLibrariansForLibrary: fetched");
    res.json(rows);
  } catch (err) {
    logger.error(err, "getLibrariansForLibrary: unexpected error");
    res.status(500).json({ message: "Internal server error" });
  }
};

// DELETE /api/librarians/:user_id/:library_id
exports.unassignLibrarian = async (req, res) => {
  const { user_id, library_id } = req.params;
  try {
    const [result] = await db.execute(
      "DELETE FROM librarians WHERE user_id = ? AND library_id = ?",
      [user_id, library_id],
    );

    if (result.affectedRows === 0) {
      logger.warn({ user_id, library_id }, "unassignLibrarian: assignment not found");
      return res.status(404).json({ message: "Librarian assignment not found" });
    }

    // Revert role back to 'user' if no other library assignments exist
    const [remaining] = await db.execute(
      "SELECT 1 FROM librarians WHERE user_id = ? LIMIT 1",
      [user_id],
    );

    if (remaining.length === 0) {
      await db.execute("UPDATE users SET role='user' WHERE user_id = ?", [user_id]);
      logger.info({ user_id }, "unassignLibrarian: no remaining assignments, role reverted to user");
    }

    logger.info({ user_id, library_id }, "unassignLibrarian: librarian unassigned");
    res.json({ message: "Librarian unassigned" });
  } catch (err) {
    logger.error(err, "unassignLibrarian: unexpected error");
    res.status(500).json({ message: "Internal server error" });
  }
};
