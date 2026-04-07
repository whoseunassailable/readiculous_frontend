const express = require("express");
const router = express.Router();
const controller = require("../controllers/librarianController");

router.post("/assign", controller.assignLibrarian);
router.get("/:library_id", controller.getLibrariansForLibrary);
router.delete("/:user_id/:library_id", controller.unassignLibrarian);

module.exports = router;
