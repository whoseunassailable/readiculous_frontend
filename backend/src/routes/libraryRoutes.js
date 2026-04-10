const express = require("express");
const router = express.Router();
const libraryController = require("../controllers/libraryController");

router.get("/", libraryController.getAllLibraries);
router.get("/:library_id/activity", libraryController.getLibraryReaderActivity);
router.post("/", libraryController.createLibrary);

module.exports = router;
