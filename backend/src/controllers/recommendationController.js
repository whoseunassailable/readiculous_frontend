const db = require("../config/db");
const logger = require("../config/logger");
const mlService = require("../services/mlService");
const googleBooksService = require("../services/googleBooksService");

// ==========================
// USER RECOMMENDATIONS
// ==========================

// GET /api/recommendations/users/:user_id
exports.getUserRecommendations = async (req, res) => {
  const { user_id } = req.params;
  try {
    logger.debug({ user_id }, "getUserRecommendations: fetching");

    const [rows] = await db.execute(
      `SELECT
         ur.recommendation_id,
         ur.user_id,
         ur.book_id,
         b.title,
         b.author,
         b.cover_url,
         ur.score,
         ur.reason,
         ur.created_at,
         ur.updated_at
       FROM user_recommendations ur
       JOIN books b ON b.book_id = ur.book_id
       WHERE ur.user_id = ?
       ORDER BY ur.score DESC, ur.created_at DESC`,
      [user_id],
    );

    logger.info({ user_id, count: rows.length }, "getUserRecommendations: fetched");
    return res.json(rows);
  } catch (error) {
    logger.error(error, "getUserRecommendations: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// POST /api/recommendations/users
exports.createUserRecommendation = async (req, res) => {
  const { user_id, book_id, score = null, reason = null } = req.body;

  if (!user_id || !book_id) {
    logger.warn({ user_id, book_id }, "createUserRecommendation: user_id and book_id required");
    return res.status(400).json({ message: "user_id and book_id are required" });
  }

  try {
    const [result] = await db.execute(
      `INSERT INTO user_recommendations (user_id, book_id, score, reason) VALUES (?, ?, ?, ?)`,
      [user_id, book_id, score, reason],
    );

    logger.info({ user_id, book_id, recommendation_id: result.insertId }, "createUserRecommendation: created");
    return res.status(201).json({ message: "User recommendation created", recommendation_id: result.insertId });
  } catch (error) {
    logger.error(error, "createUserRecommendation: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// DELETE /api/recommendations/users/:recommendation_id
exports.deleteUserRecommendation = async (req, res) => {
  const { recommendation_id } = req.params;
  try {
    const [result] = await db.execute(
      "DELETE FROM user_recommendations WHERE recommendation_id = ?",
      [recommendation_id],
    );

    if (result.affectedRows === 0) {
      logger.warn({ recommendation_id }, "deleteUserRecommendation: not found");
      return res.status(404).json({ message: "Recommendation not found" });
    }

    logger.info({ recommendation_id }, "deleteUserRecommendation: deleted");
    return res.json({ message: "User recommendation deleted" });
  } catch (error) {
    logger.error(error, "deleteUserRecommendation: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// =============================
// LIBRARY RECOMMENDATIONS
// =============================

// GET /api/recommendations/libraries/:library_id
exports.getLibraryRecommendations = async (req, res) => {
  const { library_id } = req.params;
  try {
    logger.debug({ library_id }, "getLibraryRecommendations: fetching");

    const [rows] = await db.execute(
      `SELECT
         lr.recommendation_id,
         lr.library_id,
         lr.book_id,
         b.title,
         b.author,
         b.cover_url,
         lr.demand_score,
         lr.demand_level,
         lr.reason,
         lr.state,
         lr.created_at,
         lr.updated_at
       FROM library_recommendations lr
       JOIN books b ON b.book_id = lr.book_id
       WHERE lr.library_id = ?
       ORDER BY lr.demand_score DESC, lr.created_at DESC`,
      [library_id],
    );

    logger.info({ library_id, count: rows.length }, "getLibraryRecommendations: fetched");
    return res.json(rows);
  } catch (error) {
    logger.error(error, "getLibraryRecommendations: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// POST /api/recommendations/libraries
exports.createLibraryRecommendation = async (req, res) => {
  const {
    library_id,
    book_id,
    demand_score = 0.0,
    demand_level = null,
    reason = null,
    state = "NEW",
  } = req.body;

  if (!library_id || !book_id) {
    logger.warn({ library_id, book_id }, "createLibraryRecommendation: library_id and book_id required");
    return res.status(400).json({ message: "library_id and book_id are required" });
  }

  try {
    const [result] = await db.execute(
      `INSERT INTO library_recommendations (library_id, book_id, demand_score, demand_level, reason, state)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [library_id, book_id, demand_score, demand_level, reason, state],
    );

    logger.info({ library_id, book_id, recommendation_id: result.insertId }, "createLibraryRecommendation: created");
    return res.status(201).json({ message: "Library recommendation created", recommendation_id: result.insertId });
  } catch (error) {
    logger.error(error, "createLibraryRecommendation: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// PATCH /api/recommendations/libraries/:recommendation_id
exports.updateLibraryRecommendationState = async (req, res) => {
  const { recommendation_id } = req.params;
  const { state } = req.body;

  const validStates = new Set(["NEW", "ORDERED", "STOCKED", "IGNORED"]);
  if (!state || !validStates.has(state)) {
    logger.warn({ recommendation_id, state }, "updateLibraryRecommendationState: invalid state");
    return res.status(400).json({ message: "state must be one of: NEW, ORDERED, STOCKED, IGNORED" });
  }

  try {
    const [result] = await db.execute(
      "UPDATE library_recommendations SET state = ? WHERE recommendation_id = ?",
      [state, recommendation_id],
    );

    if (result.affectedRows === 0) {
      logger.warn({ recommendation_id }, "updateLibraryRecommendationState: not found");
      return res.status(404).json({ message: "Recommendation not found" });
    }

    logger.info({ recommendation_id, state }, "updateLibraryRecommendationState: state updated");

    // Feed librarian signal back into genre_trends (non-blocking — don't fail the request if this errors)
    applyFeedbackSignal(recommendation_id, state).catch((err) =>
      logger.error(err, "updateLibraryRecommendationState: feedback signal failed silently"),
    );

    return res.json({ message: "Recommendation state updated", recommendation_id, state });
  } catch (error) {
    logger.error(error, "updateLibraryRecommendationState: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

/**
 * Translate a librarian state action into a genre trend delta and persist it.
 *
 * Signal mapping:
 *   STOCKED  → +0.5  (book confirmed as stocked — strong positive signal)
 *   ORDERED  → +0.3  (book ordered — positive signal)
 *   IGNORED  → -0.3  (librarian explicitly rejected this — negative signal)
 *   NEW      →  0    (no signal — state reset, skip)
 */
async function applyFeedbackSignal(recommendation_id, state) {
  const delta = { STOCKED: 0.5, ORDERED: 0.3, IGNORED: -0.3, NEW: 0 }[state];
  if (!delta) return;

  // Get the library and book for this recommendation
  const [rows] = await db.execute(
    "SELECT library_id, book_id FROM library_recommendations WHERE recommendation_id = ?",
    [recommendation_id],
  );
  if (rows.length === 0) return;

  const { library_id, book_id } = rows[0];

  // Get all genres for this book
  const [genreRows] = await db.execute(
    "SELECT genre_id FROM book_genres WHERE book_id = ?",
    [book_id],
  );
  if (genreRows.length === 0) return;

  // Upsert genre_trends: add delta to existing score (floor at 0)
  for (const { genre_id } of genreRows) {
    await db.execute(
      `INSERT INTO genre_trends (library_id, genre_id, score, captured_at)
       VALUES (?, ?, GREATEST(0, ?), NOW())
       ON DUPLICATE KEY UPDATE
         score       = GREATEST(0, score + ?),
         captured_at = NOW()`,
      [library_id, genre_id, delta, delta],
    );
  }

  logger.info({ recommendation_id, state, delta, library_id, book_id }, "applyFeedbackSignal: genre trends updated");
}

// DELETE /api/recommendations/libraries/:recommendation_id
exports.deleteLibraryRecommendation = async (req, res) => {
  const { recommendation_id } = req.params;
  try {
    const [result] = await db.execute(
      "DELETE FROM library_recommendations WHERE recommendation_id = ?",
      [recommendation_id],
    );

    if (result.affectedRows === 0) {
      logger.warn({ recommendation_id }, "deleteLibraryRecommendation: not found");
      return res.status(404).json({ message: "Recommendation not found" });
    }

    logger.info({ recommendation_id }, "deleteLibraryRecommendation: deleted");
    return res.json({ message: "Library recommendation deleted" });
  } catch (error) {
    logger.error(error, "deleteLibraryRecommendation: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// =============================================
// ML-GENERATED RECOMMENDATIONS
// =============================================

/**
 * Derive a demand level label from the ML final_score.
 */
function demandLevel(score) {
  if (score >= 0.7) return "HIGH";
  if (score >= 0.4) return "MEDIUM";
  return "LOW";
}

/**
 * Ensure a book exists in the MySQL books table.
 * If not found by isbn13, fetch from Google Books API and create it.
 * Returns the book_id, or null if the book cannot be resolved.
 */
async function resolveBook(isbn) {
  if (!isbn) return null;

  const [rows] = await db.execute(
    "SELECT book_id FROM books WHERE isbn13 = ?",
    [String(isbn)],
  );

  if (rows.length > 0) return rows[0].book_id;

  const bookData = await googleBooksService.fetchBookByIsbn(String(isbn));
  if (!bookData) return null;

  const [result] = await db.execute(
    `INSERT INTO books (title, author, description, cover_url, isbn13)
     VALUES (?, ?, ?, ?, ?)`,
    [bookData.title, bookData.author, bookData.description, bookData.cover_url, bookData.isbn13],
  );

  logger.info({ isbn, book_id: result.insertId }, "resolveBook: created new book from Google Books");
  return result.insertId;
}

/**
 * Compute weighted genre scores for a set of users.
 *
 * Each user's genre preferences are weighted by:
 *   - Activity  : log(1 + read_count)  — users who read more carry more signal
 *   - Recency   : exp(-days_since_last_read / 180)  — recent reads decay slowly over ~6 months
 *   - Rating    : avg rating across their reads (defaults to 1 if no ratings yet)
 *
 * Returns a sorted array of { genre, score } objects.
 */
async function computeWeightedGenres(userIds, topM) {
  const placeholders = userIds.map(() => "?").join(",");

  // Activity and recency stats per user from their reading history
  const [readStats] = await db.execute(
    `SELECT
       user_id,
       COUNT(*)                                        AS read_count,
       DATEDIFF(NOW(), MAX(updated_at))                AS days_since_last_read,
       COALESCE(AVG(NULLIF(rating, 0)), 3)             AS avg_rating
     FROM user_reads
     WHERE user_id IN (${placeholders})
     GROUP BY user_id`,
    userIds,
  );

  // Build a weight map keyed by user_id
  const weightByUser = {};
  for (const row of readStats) {
    const activityWeight = Math.log1p(Number(row.read_count));
    const recencyWeight  = Math.exp(-Number(row.days_since_last_read) / 180);
    const ratingWeight   = Number(row.avg_rating) / 5;
    weightByUser[row.user_id] = activityWeight * recencyWeight * ratingWeight;
  }

  // Genre preferences per user
  const [genreRows] = await db.execute(
    `SELECT ug.user_id, g.name AS genre
     FROM user_genres ug
     JOIN genres g ON g.genre_id = ug.genre_id
     WHERE ug.user_id IN (${placeholders})`,
    userIds,
  );

  // Accumulate weighted scores per genre
  const genreScores = {};
  for (const row of genreRows) {
    const weight = weightByUser[row.user_id] ?? 1; // fallback: new users with no reads get weight 1
    genreScores[row.genre] = (genreScores[row.genre] ?? 0) + weight;
  }

  return Object.entries(genreScores)
    .sort(([, a], [, b]) => b - a)
    .slice(0, topM)
    .map(([genre, score]) => ({ genre, score }));
}

// POST /api/recommendations/libraries/:library_id/generate
exports.generateLibraryRecommendations = async (req, res) => {
  const { library_id } = req.params;
  const { top_m_genres = 5, top_n_books = 10 } = req.body;

  try {
    // 1. Get library location
    const [libraries] = await db.execute(
      "SELECT library_id, name, location FROM libraries WHERE library_id = ?",
      [library_id],
    );
    if (libraries.length === 0) {
      return res.status(404).json({ message: "Library not found" });
    }
    const library = libraries[0];

    // 2. Find users explicitly associated with this library.
    // Fallback to the older location-based behavior so existing demo data still works.
    let [users] = await db.execute(
      `SELECT DISTINCT user_id
       FROM user_libraries
       WHERE library_id = ?`,
      [library_id],
    );

    if (users.length === 0) {
      [users] = await db.execute(
        "SELECT user_id FROM users WHERE LOWER(?) LIKE CONCAT('%', LOWER(location), '%')",
        [library.location || ""],
      );
    }

    if (users.length === 0) {
      // Cold start: new library with no local users — fall back to globally popular genres
      logger.info({ library_id }, "generateLibraryRecommendations: no local users — using global user pool");
      [users] = await db.execute(
        "SELECT DISTINCT user_id FROM user_genres LIMIT 200",
      );
      if (users.length === 0) {
        logger.warn({ library_id }, "generateLibraryRecommendations: no users in system at all");
        return res.status(400).json({ message: "No users found in the system yet" });
      }
    }

    const userIds = users.map((u) => u.user_id);

    // 3. Compute weighted genre scores (activity + recency + rating)
    const weightedGenres = await computeWeightedGenres(userIds, top_m_genres);

    if (weightedGenres.length === 0) {
      return res.status(400).json({ message: "No genre preferences found for local users" });
    }

    // 3b. Boost genre scores with this library's accumulated trend signal
    const [trendRows] = await db.execute(
      `SELECT g.name AS genre, gt.score AS trend_score
       FROM genre_trends gt
       JOIN genres g ON g.genre_id = gt.genre_id
       WHERE gt.library_id = ?`,
      [library_id],
    );
    if (trendRows.length > 0) {
      const trendMap = Object.fromEntries(trendRows.map((r) => [r.genre, Number(r.trend_score)]));
      for (const g of weightedGenres) {
        if (trendMap[g.genre] != null) {
          g.score += trendMap[g.genre];
        }
      }
      weightedGenres.sort((a, b) => b.score - a.score);
    }

    const topGenreNames = weightedGenres.map((g) => g.genre);
    logger.info({ library_id, topGenreNames }, "generateLibraryRecommendations: weighted genres computed");

    // 4. Call Flask /recommend with the weighted top genres
    const recommendations = await mlService.getRecommendationsForUser(topGenreNames, top_n_books);

    // 5. Resolve each book and save to library_recommendations
    const saved = [];
    for (const rec of recommendations) {
      const book_id = await resolveBook(rec.isbn13 ?? rec.isbn);
      if (!book_id) {
        logger.warn({ title: rec.title }, "generateLibraryRecommendations: could not resolve book, skipping");
        continue;
      }

      const score = rec.final_score ?? 0;
      const [result] = await db.execute(
        `INSERT INTO library_recommendations (library_id, book_id, demand_score, demand_level, reason, state)
         VALUES (?, ?, ?, ?, ?, 'NEW')
         ON DUPLICATE KEY UPDATE demand_score = VALUES(demand_score), demand_level = VALUES(demand_level), state = 'NEW'`,
        [library_id, book_id, score, demandLevel(score), `Top genres: ${topGenreNames.join(", ")}`],
      );

      saved.push({ recommendation_id: result.insertId || null, book_id, title: rec.title, demand_score: score });
    }

    logger.info({ library_id, saved: saved.length }, "generateLibraryRecommendations: done");
    return res.status(201).json({
      message: `${saved.length} recommendations generated`,
      top_genres: weightedGenres,
      recommendations: saved,
    });
  } catch (error) {
    logger.error(error, "generateLibraryRecommendations: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// POST /api/recommendations/users/:user_id/generate
exports.generateUserRecommendations = async (req, res) => {
  const { user_id } = req.params;
  const { top_n = 10 } = req.body;

  try {
    // 1. Get user's genre preferences
    const [genreRows] = await db.execute(
      `SELECT g.name AS genre
       FROM user_genres ug
       JOIN genres g ON g.genre_id = ug.genre_id
       WHERE ug.user_id = ?`,
      [user_id],
    );

    if (genreRows.length === 0) {
      return res.status(400).json({ message: "User has no genre preferences set" });
    }

    const genres = genreRows.map((r) => r.genre);

    // 2. Call Flask ML service
    logger.info({ user_id, genres }, "generateUserRecommendations: calling ML");
    const recommendations = await mlService.getRecommendationsForUser(genres, top_n);

    // 3. Resolve each book and save to user_recommendations
    const saved = [];
    for (const rec of recommendations) {
      const book_id = await resolveBook(rec.isbn13 ?? rec.isbn);
      if (!book_id) {
        logger.warn({ title: rec.title }, "generateUserRecommendations: could not resolve book, skipping");
        continue;
      }

      const score = rec.final_score ?? 0;
      const [result] = await db.execute(
        `INSERT INTO user_recommendations (user_id, book_id, score, reason)
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE score = VALUES(score)`,
        [user_id, book_id, score, `Genres: ${genres.join(", ")}`],
      );

      saved.push({ recommendation_id: result.insertId || null, book_id, title: rec.title, score });
    }

    logger.info({ user_id, saved: saved.length }, "generateUserRecommendations: done");
    return res.status(201).json({
      message: `${saved.length} recommendations generated`,
      recommendations: saved,
    });
  } catch (error) {
    logger.error(error, "generateUserRecommendations: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};
