const { spawn } = require("child_process");
const path = require("path");
const axios = require("axios");
const logger = require("../config/logger");

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || "http://localhost:6000";

const RETRAIN_SCRIPT = path.resolve(
  process.env.RETRAIN_SCRIPT_PATH ||
  path.join(__dirname, "../../../../readiculous_ml/notebooks/features/user_book_recommender/retrain.py"),
);

const PYTHON_BIN = process.env.PYTHON_BIN || "python3";

function getRequiredEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`${name} environment variable is required`);
  }
  return value;
}

// POST /api/ml/retrain
exports.triggerRetrain = (req, res) => {
  logger.info({ script: RETRAIN_SCRIPT }, "triggerRetrain: starting");

  let env;
  try {
    env = {
      ...process.env,
      DB_HOST: getRequiredEnv("DB_HOST"),
      DB_USER: getRequiredEnv("DB_USER"),
      DB_PASSWORD: getRequiredEnv("DB_PASSWORD"),
      DB_NAME: getRequiredEnv("DB_NAME"),
      GOODREADS_CSV: getRequiredEnv("GOODREADS_CSV"),
      MIN_NEW_ROWS: process.env.MIN_NEW_ROWS || "10",
      MIN_CF_ROWS: process.env.MIN_CF_ROWS || "10",
    };
  } catch (error) {
    logger.warn({ error: error.message }, "triggerRetrain: missing required environment");
    return res.status(500).json({ message: error.message });
  }

  const child = spawn(PYTHON_BIN, [RETRAIN_SCRIPT], { env });

  let stdout = "";
  let stderr = "";

  child.stdout.on("data", (data) => { stdout += data.toString(); });
  child.stderr.on("data", (data) => { stderr += data.toString(); });

  child.on("close", (code) => {
    // retrain.py always writes a single JSON line to stdout
    let result = {};
    try {
      result = JSON.parse(stdout.trim().split("\n").pop());
    } catch {
      result = { status: "error", message: "Failed to parse script output", raw: stdout };
    }

    if (stderr) {
      logger.warn({ stderr }, "triggerRetrain: script wrote to stderr");
    }

    if (code !== 0 || result.status === "error") {
      logger.error({ code, result }, "triggerRetrain: script failed");
      return res.status(500).json({ message: "Retraining failed", ...result });
    }

    logger.info(result, "triggerRetrain: complete");

    // Hot-reload models in Flask so it picks up the new .pkl files immediately
    axios.post(`${ML_SERVICE_URL}/reload`)
      .then(() => logger.info("triggerRetrain: Flask models reloaded"))
      .catch((err) => logger.warn({ err: err.message }, "triggerRetrain: Flask reload failed (non-fatal)"));

    return res.json({ message: "Retraining complete", ...result });
  });

  child.on("error", (err) => {
    logger.error(err, "triggerRetrain: failed to spawn process");
    res.status(500).json({ message: "Failed to start retraining process", error: err.message });
  });
};
