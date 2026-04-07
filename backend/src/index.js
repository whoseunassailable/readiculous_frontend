// index.js
require("dotenv").config();
const express = require("express");
const cors = require("cors");
const logger = require("./config/logger");

const app = express();

// -------------------------
// Import route files
// -------------------------
const userRoutes = require("./routes/userRoutes.js");
const genreRoutes = require("./routes/genreRoutes.js");
const userGenreRoutes = require("./routes/userGenreRoutes.js");
const bookRoutes = require("./routes/bookRoutes.js");
const bookGenreRoutes = require("./routes/bookGenreRoutes.js");

// NEW route files (you need to create these)
const libraryRoutes = require("./routes/libraryRoutes.js");
const libraryBookRoutes = require("./routes/libraryBookRoutes.js");
const librarianRoutes = require("./routes/librarianRoutes.js");
const userReadsRoutes = require("./routes/userReadsRoutes.js");
const recommendationRoutes = require("./routes/recommendationRoutes.js");
const trendRoutes = require("./routes/trendRoutes.js");
const mlRoutes = require("./routes/mlRoutes.js");

// -------------------------
// Middleware
// -------------------------
app.use(cors());
app.use(express.json());

// Request logger
app.use((req, _res, next) => {
  const safeBody =
    req.body && Object.keys(req.body).length > 0
      ? { ...req.body, ...(req.body.password && { password: "***" }) }
      : undefined;
  logger.info({ method: req.method, url: req.originalUrl, body: safeBody }, `${req.method} ${req.originalUrl}`);
  next();
});

// -------------------------
// Root route
// -------------------------
app.get("/", (req, res) => {
  res.send("Welcome to the Readiculous Book Recommendation API");
});

// -------------------------
// Mount routes
// -------------------------
app.use("/api/users", userRoutes);
app.use("/api/genres", genreRoutes);
app.use("/api/user-genres", userGenreRoutes);
app.use("/api/books", bookRoutes);
app.use("/api/book-genres", bookGenreRoutes);

app.use("/api/libraries", libraryRoutes);
app.use("/api/library-books", libraryBookRoutes);
app.use("/api/librarians", librarianRoutes);
app.use("/api/reads", userReadsRoutes);
app.use("/api/recommendations", recommendationRoutes);
app.use("/api/trends", trendRoutes);
app.use("/api/ml", mlRoutes);

// -------------------------
// 404 handler
// -------------------------
app.use((req, res) => {
  logger.warn({ method: req.method, url: req.originalUrl }, `[404] No route matched: ${req.method} ${req.originalUrl}`);
  res.status(404).json({ message: "Route not found" });
});

// -------------------------
// Start server
// -------------------------
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
});
