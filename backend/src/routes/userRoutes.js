const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");

router.post("/create", userController.createUser);
router.post("/login", userController.loginUser);
router.get("/preferences", userController.getUserPreferences);
router.get("/", userController.getAllUsers);
router.get("/:user_id/library", userController.getUserLibrary);
router.delete("/:user_id", userController.deleteUser);

module.exports = router;
