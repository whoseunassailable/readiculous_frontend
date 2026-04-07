const express = require("express");
const router = express.Router();
const controller = require("../controllers/userReadsController");

router.get("/:user_id", controller.getReadsForUser);
router.post("/", controller.upsertRead);
router.delete("/:user_id/:book_id", controller.deleteRead);

module.exports = router;
