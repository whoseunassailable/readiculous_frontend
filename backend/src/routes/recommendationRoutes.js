const express = require("express");
const router = express.Router();
const ctrl = require("../controllers/recommendationController");

// User recommendations
router.post("/users/:user_id/generate", ctrl.generateUserRecommendations);
router.get("/users/:user_id", ctrl.getUserRecommendations);
router.post("/users", ctrl.createUserRecommendation);
router.delete("/users/:recommendation_id", ctrl.deleteUserRecommendation);

// Library recommendations
router.post("/libraries/:library_id/generate", ctrl.generateLibraryRecommendations);
router.get("/libraries/:library_id", ctrl.getLibraryRecommendations);
router.post("/libraries", ctrl.createLibraryRecommendation);
router.patch("/libraries/:recommendation_id", ctrl.updateLibraryRecommendationState);
router.delete("/libraries/:recommendation_id", ctrl.deleteLibraryRecommendation);

module.exports = router;
