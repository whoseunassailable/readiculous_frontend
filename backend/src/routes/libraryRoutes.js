const express = require("express");
const router = express.Router();
const libraryController = require("../controllers/libraryController");

router.get("/", libraryController.getAllLibraries);
router.post("/", libraryController.createLibrary);

module.exports = router;
