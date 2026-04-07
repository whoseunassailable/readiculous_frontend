const axios = require("axios");
const logger = require("../config/logger");

const GOOGLE_BOOKS_URL = "https://www.googleapis.com/books/v1/volumes";

/**
 * Fetch book metadata from Google Books API by ISBN.
 * Returns null if the book is not found or the API call fails.
 *
 * Set GOOGLE_BOOKS_API_KEY in your .env to avoid rate limiting.
 *
 * @param {string} isbn - isbn13 string
 * @returns {Promise<{title, author, description, cover_url, isbn13} | null>}
 */
exports.fetchBookByIsbn = async (isbn) => {
  try {
    const params = { q: `isbn:${isbn}` };
    if (process.env.GOOGLE_BOOKS_API_KEY) {
      params.key = process.env.GOOGLE_BOOKS_API_KEY;
    }

    logger.debug({ isbn }, "googleBooksService: fetching book");
    const response = await axios.get(GOOGLE_BOOKS_URL, { params });

    const items = response.data.items;
    if (!items || items.length === 0) {
      logger.warn({ isbn }, "googleBooksService: no results found");
      return null;
    }

    const info = items[0].volumeInfo;
    return {
      title:       info.title || "Unknown Title",
      author:      info.authors ? info.authors.join(", ") : "Unknown Author",
      description: info.description || null,
      cover_url:   info.imageLinks?.thumbnail?.replace("http://", "https://") || null,
      isbn13:      isbn,
    };
  } catch (err) {
    logger.error({ isbn, err: err.message }, "googleBooksService: API call failed");
    return null;
  }
};
