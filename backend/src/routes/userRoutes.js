const express = require("express");
const router = express.Router();
const userController = require("../controllers/userController");

router.post("/create", userController.createUser);
router.post("/login", userController.loginUser);
router.get("/preferences", userController.getUserPreferences);
router.get("/", userController.getAllUsers);
router.patch("/:user_id/role", userController.setUserRole);
router.get("/:user_id/library", userController.getUserLibrary);
router.post("/:user_id/library", userController.upsertUserLibrary);
router.delete("/:user_id/library", userController.removeUserLibrary);
router.delete("/:user_id", userController.deleteUser);

module.exports = router;
