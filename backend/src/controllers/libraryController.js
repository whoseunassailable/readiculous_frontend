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
