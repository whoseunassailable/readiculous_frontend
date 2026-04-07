const express = require("express");
const router = express.Router();

const trendController = require("../controllers/trendController");

// GET /api/trends/libraries/:library_id?days=7
router.get("/libraries/:library_id", trendController.getLibraryGenreTrends);

// GET /api/trends/top?library_id=1&days=7&limit=10
router.get("/top", trendController.getTopTrends);

// POST /api/trends
router.post("/", trendController.upsertTrend);

module.exports = router;
