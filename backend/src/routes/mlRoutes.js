const express = require("express");
const router = express.Router();
const ctrl = require("../controllers/mlController");

// POST /api/ml/retrain
// Triggers the Python retraining pipeline.
// Can be called manually or on a schedule.
router.post("/retrain", ctrl.triggerRetrain);

module.exports = router;
