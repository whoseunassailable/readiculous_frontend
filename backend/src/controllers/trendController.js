const db = require("../config/db");
const logger = require("../config/logger");

// GET /api/trends/libraries/:library_id?days=7
exports.getLibraryGenreTrends = async (req, res) => {
  const { library_id } = req.params;
  const days = Number(req.query.days || 7);

  try {
    logger.debug({ library_id, days }, "getLibraryGenreTrends: fetching trends");

    const [rows] = await db.execute(
      `SELECT
         gt.library_id,
         gt.genre_id,
         g.name AS genre_name,
         gt.score,
         gt.captured_at
       FROM genre_trends gt
       JOIN genres g ON g.genre_id = gt.genre_id
       WHERE gt.library_id = ?
         AND gt.captured_at >= (NOW() - INTERVAL ? DAY)
       ORDER BY gt.captured_at DESC, gt.score DESC`,
      [library_id, days],
    );

    logger.info({ library_id, days, count: rows.length }, "getLibraryGenreTrends: fetched trends");
    return res.json(rows);
  } catch (error) {
    logger.error(error, "getLibraryGenreTrends: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// GET /api/trends/top?library_id=1&days=7&limit=10
exports.getTopTrends = async (req, res) => {
  const library_id = req.query.library_id ? Number(req.query.library_id) : null;
  const days = Number(req.query.days || 7);
  const limit = Number(req.query.limit || 10);

  try {
    logger.debug({ library_id, days, limit }, "getTopTrends: fetching top trends");

    let sql = `
      SELECT
        gt.genre_id,
        g.name AS genre_name,
        ${library_id ? "gt.library_id," : ""}
        AVG(gt.score) AS avg_score,
        MAX(gt.captured_at) AS last_captured_at
      FROM genre_trends gt
      JOIN genres g ON g.genre_id = gt.genre_id
      WHERE gt.captured_at >= (NOW() - INTERVAL ? DAY)
    `;

    const params = [days];

    if (library_id) {
      sql += " AND gt.library_id = ? ";
      params.push(library_id);
    }

    sql += `
      GROUP BY ${library_id ? "gt.library_id, " : ""}gt.genre_id
      ORDER BY avg_score DESC
      LIMIT ?
    `;

    params.push(limit);

    const [rows] = await db.execute(sql, params);
    logger.info({ library_id, days, limit, count: rows.length }, "getTopTrends: fetched top trends");
    return res.json(rows);
  } catch (error) {
    logger.error(error, "getTopTrends: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// POST /api/trends
exports.upsertTrend = async (req, res) => {
  const { library_id, genre_id, score, captured_at } = req.body;

  if (!library_id || !genre_id || score === undefined) {
    logger.warn({ library_id, genre_id, score }, "upsertTrend: library_id, genre_id, and score required");
    return res.status(400).json({ message: "library_id, genre_id, and score are required" });
  }

  try {
    const cap = captured_at || new Date();
    logger.debug({ library_id, genre_id, score, cap }, "upsertTrend: saving trend");

    await db.execute(
      `INSERT INTO genre_trends (library_id, genre_id, score, captured_at)
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE score = VALUES(score)`,
      [library_id, genre_id, score, cap],
    );

    logger.info({ library_id, genre_id, score }, "upsertTrend: trend saved");
    return res.status(201).json({ message: "Trend saved" });
  } catch (error) {
    logger.error(error, "upsertTrend: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};
