const db = require("../config/db");
const logger = require("../config/logger");

// GET /api/libraries
exports.getAllLibraries = async (_req, res) => {
  try {
    const [rows] = await db.execute(
      "SELECT library_id, name, location, created_at, updated_at FROM libraries",
    );
    logger.info({ count: rows.length }, "getAllLibraries: fetched libraries");
    res.json(rows);
  } catch (err) {
    logger.error(err, "getAllLibraries: unexpected error");
    res.status(500).json({ message: "Internal server error" });
  }
};

// POST /api/libraries
exports.createLibrary = async (req, res) => {
  const { name, location } = req.body;

  if (!name) {
    logger.warn("createLibrary: name is required");
    return res.status(400).json({ message: "name is required" });
  }

  try {
    const [result] = await db.execute(
      "INSERT INTO libraries (name, location) VALUES (?, ?)",
      [name, location || null],
    );

    logger.info({ library_id: result.insertId, name, location }, "createLibrary: library created");
    res.status(201).json({
      message: "Library created",
      library_id: result.insertId,
      name,
      location: location || null,
    });
  } catch (err) {
    logger.error(err, "createLibrary: unexpected error");
    res.status(500).json({ message: "Internal server error" });
  }
};

// GET /api/libraries/:library_id/activity
exports.getLibraryReaderActivity = async (req, res) => {
  const { library_id } = req.params;

  try {
    const [rows] = await db.execute(
      `SELECT
         b.book_id,
         b.title,
         b.author,
         GROUP_CONCAT(
           DISTINCT CONCAT(u.first_name, ' ', u.last_name)
           ORDER BY u.first_name, u.last_name
           SEPARATOR ' • '
         ) AS reader_names,
         SUM(CASE WHEN ur.status = 'reading' THEN 1 ELSE 0 END) AS reading_count,
         SUM(CASE WHEN ur.status = 'want_to_read' THEN 1 ELSE 0 END) AS want_to_read_count,
         SUM(CASE WHEN ur.status = 'read' THEN 1 ELSE 0 END) AS read_count,
         COUNT(*) AS total_reader_events
       FROM user_libraries ul
       JOIN user_reads ur ON ur.user_id = ul.user_id
       JOIN users u ON u.user_id = ul.user_id
       JOIN books b ON b.book_id = ur.book_id
       WHERE ul.library_id = ?
       GROUP BY b.book_id, b.title, b.author
       ORDER BY reading_count DESC, want_to_read_count DESC, read_count DESC, b.title ASC`,
      [library_id],
    );

    logger.info(
      { library_id, count: rows.length },
      "getLibraryReaderActivity: fetched reader activity",
    );
    res.json(rows);
  } catch (err) {
    logger.error(err, "getLibraryReaderActivity: unexpected error");
    res.status(500).json({ message: "Internal server error" });
  }
};
