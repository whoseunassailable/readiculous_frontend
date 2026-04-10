const axios = require("axios");
const logger = require("../config/logger");

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || "http://localhost:6000";

/**
 * Get book recommendations for a single reader based on their genre preferences.
 * Calls Flask POST /recommend
 *
 * @param {string[]} genres  - e.g. ["Fiction", "Mystery"]
 * @param {number}   topN    - how many books to return
 * @returns {Promise<Array>} - array of book objects from the ML model
 */
exports.getRecommendationsForUser = async (genres, userId, topN = 10) => {
  logger.debug({ genres, userId, topN }, "mlService: calling /recommend");
  const response = await axios.post(`${ML_SERVICE_URL}/recommend`, {
    genres,
    user_id: userId,
    top_n: topN,
  });
  return response.data;
};

/**
 * Get library stocking suggestions based on aggregated community genre preferences.
 * Calls Flask POST /suggest
 *
 * @param {Array<{user_id, genres: string}>} userPreferences
 * @param {number} topMGenres - how many top genres to surface
 * @param {number} topNBooks  - how many books to recommend
 * @returns {Promise<{top_genres: string[], recommendations: Array}>}
 */
exports.getSuggestionsForLibrary = async (userPreferences, topMGenres = 5, topNBooks = 10) => {
  logger.debug({ userCount: userPreferences.length, topMGenres, topNBooks }, "mlService: calling /suggest");
  const response = await axios.post(`${ML_SERVICE_URL}/suggest`, {
    user_preferences: userPreferences,
    top_m_genres: topMGenres,
    top_n_books: topNBooks,
  });
  return response.data;
};
