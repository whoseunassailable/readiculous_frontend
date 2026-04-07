const express = require("express");
const router = express.Router();
const controller = require("../controllers/libraryBookController");

// GET /api/library-books/:library_id
router.get("/:library_id", controller.getBooksForLibrary);

// POST /api/library-books
router.post("/", controller.upsertLibraryBook); // add/update inventory

module.exports = router;
