"""
retrain.py — Readiculous model retraining pipeline

Pulls live signals from MySQL, merges with the Kaggle baseline,
retrains XGBoost (content-based) and SVD (collaborative filtering),
and overwrites the .pkl files in place.

Called by the Node.js backend via:
  POST /api/ml/retrain

Outputs a single JSON line to stdout on completion:
  {"status": "ok", "records": 12345, "xgb_accuracy": 0.87, "cf_rmse": 0.91, "message": "..."}
  {"status": "error", "message": "..."}

Usage (standalone):
  python retrain.py
  GOODREADS_CSV=/path/to/file.csv DB_HOST=localhost python retrain.py
"""

import os
import sys
import json
import time
import warnings
import numpy as np
import pandas as pd
import pymysql
import joblib

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score
import xgboost as xgb

from surprise import Dataset, Reader, SVD as SurpriseSVD
from surprise.model_selection import train_test_split as surprise_split
from surprise import accuracy as surprise_accuracy

warnings.filterwarnings("ignore")

# ──────────────────────────────────────────────
# Config — all overridable via env vars
# ──────────────────────────────────────────────

DB_CONFIG = {
    "host":     os.getenv("DB_HOST",     "localhost"),
    "user":     os.getenv("DB_USER",     "root"),
    "password": os.getenv("DB_PASSWORD", "Jraonhvain11#"),
    "database": os.getenv("DB_NAME",     "readiculous"),
    "charset":  "utf8mb4",
}

KAGGLE_CSV       = os.getenv("GOODREADS_CSV", "/Users/whoseunassailable/Documents/datasets/GoodReads_100k_books.csv")
MODEL_DIR        = os.path.dirname(os.path.abspath(__file__))
MIN_NEW_ROWS     = int(os.getenv("MIN_NEW_ROWS", "100"))    # skip XGBoost retrain if fewer signals
MIN_CF_ROWS      = int(os.getenv("MIN_CF_ROWS",  "10"))     # skip CF retrain if fewer interactions


def out(payload: dict):
    """Write a single JSON result line to stdout and exit."""
    print(json.dumps(payload), flush=True)


# ──────────────────────────────────────────────
# 1a. Pull quality signals for XGBoost
# ──────────────────────────────────────────────

def pull_mysql_signals():
    """
    Returns a DataFrame with columns:
      isbn13, avg_user_rating, rating_count, library_signal
    """
    conn = pymysql.connect(**DB_CONFIG)
    try:
        user_ratings = pd.read_sql(
            """
            SELECT b.isbn13,
                   AVG(ur.rating)   AS avg_user_rating,
                   COUNT(ur.rating) AS rating_count
            FROM user_reads ur
            JOIN books b ON b.book_id = ur.book_id
            WHERE ur.rating IS NOT NULL
              AND b.isbn13   IS NOT NULL
            GROUP BY b.isbn13
            """,
            conn,
        )

        library_signals = pd.read_sql(
            """
            SELECT b.isbn13,
                   MAX(CASE
                       WHEN lr.state IN ('STOCKED','ORDERED') THEN  1
                       WHEN lr.state = 'IGNORED'              THEN -1
                       ELSE 0
                   END) AS library_signal
            FROM library_recommendations lr
            JOIN books b ON b.book_id = lr.book_id
            WHERE lr.state != 'NEW'
              AND b.isbn13 IS NOT NULL
            GROUP BY b.isbn13
            """,
            conn,
        )
    finally:
        conn.close()

    if user_ratings.empty and library_signals.empty:
        return pd.DataFrame()

    signals = pd.merge(user_ratings, library_signals, on="isbn13", how="outer")
    signals["avg_user_rating"] = signals["avg_user_rating"].fillna(0)
    signals["rating_count"]    = signals["rating_count"].fillna(0)
    signals["library_signal"]  = signals["library_signal"].fillna(0)
    return signals


# ──────────────────────────────────────────────
# 1b. Pull user interactions for CF
# ──────────────────────────────────────────────

def pull_user_interactions():
    """
    Returns a DataFrame with columns: user_id, isbn13, effective_rating.

    effective_rating:
      - Explicit rating if present (1-5 tinyint)
      - Implicit fallback from status if no rating:
          read         → 3.5  (finished, probably liked it)
          reading      → 3.0  (in progress, neutral positive)
          want_to_read → 2.5  (expressed interest, weaker signal)
    """
    conn = pymysql.connect(**DB_CONFIG)
    try:
        df = pd.read_sql(
            """
            SELECT
                ur.user_id,
                b.isbn13,
                COALESCE(
                    ur.rating,
                    CASE ur.status
                        WHEN 'read'         THEN 3.5
                        WHEN 'reading'      THEN 3.0
                        WHEN 'want_to_read' THEN 2.5
                    END
                ) AS effective_rating
            FROM user_reads ur
            JOIN books b ON b.book_id = ur.book_id
            WHERE b.isbn13 IS NOT NULL
            """,
            conn,
        )
    finally:
        conn.close()

    df = df.dropna(subset=["effective_rating"])
    df["effective_rating"] = df["effective_rating"].astype(float).clip(1.0, 5.0)
    return df


# ──────────────────────────────────────────────
# 2. Merge signals into the Kaggle baseline
# ──────────────────────────────────────────────

def build_training_data(signals: pd.DataFrame):
    cols = ["author", "bookformat", "genre", "isbn", "pages", "rating", "reviews", "title", "totalratings"]
    df = pd.read_csv(KAGGLE_CSV, encoding="utf-8")
    df = df[[c for c in cols if c in df.columns]]
    df = df.dropna(subset=["rating", "genre", "author"]).reset_index(drop=True)

    if "isbn" in df.columns:
        df = df.rename(columns={"isbn": "isbn13"})

    if signals.empty or "isbn13" not in df.columns:
        return df, np.ones(len(df), dtype="float32")

    merged = df.merge(signals, on="isbn13", how="left")
    merged["avg_user_rating"] = merged["avg_user_rating"].fillna(0)
    merged["library_signal"]  = merged["library_signal"].fillna(0)

    has_user_rating = merged["avg_user_rating"] > 0
    merged.loc[has_user_rating, "rating"] = (
        0.7 * merged.loc[has_user_rating, "rating"] +
        0.3 * merged.loc[has_user_rating, "avg_user_rating"]
    )

    weights = np.ones(len(merged), dtype="float32")
    weights[merged["library_signal"] == 1]  = 3.0
    weights[merged["library_signal"] == -1] = 0.5

    df_out = merged.drop(columns=["avg_user_rating", "rating_count", "library_signal"], errors="ignore")
    return df_out, weights


# ──────────────────────────────────────────────
# 3. Feature engineering
# ──────────────────────────────────────────────

def engineer_features(df: pd.DataFrame):
    df = df.copy()
    df["pages"]        = df["pages"].fillna(0).astype("int32")
    df["reviews"]      = df["reviews"].fillna(0).astype("int32")
    df["totalratings"] = df["totalratings"].fillna(0).astype("int32")
    df["bookformat"]   = df["bookformat"].fillna("unknown").str.lower().str.strip()
    df["genre"]        = df["genre"].fillna("other").str.lower().str.strip()

    df["log_pages"]        = np.log1p(df["pages"]).astype("float32")
    df["log_reviews"]      = np.log1p(df["reviews"]).astype("float32")
    df["log_totalratings"] = np.log1p(df["totalratings"]).astype("float32")
    df["popularity_score"] = df["rating"] * df["log_totalratings"]
    df["review_ratio"]     = (df["reviews"] / df["totalratings"].replace(0, np.nan)).fillna(0)

    le_a = LabelEncoder().fit(df["author"])
    le_f = LabelEncoder().fit(df["bookformat"])
    df["author_encoded"] = le_a.transform(df["author"])
    df["format_encoded"] = le_f.transform(df["bookformat"])

    genre_dummies = pd.get_dummies(df["genre"], prefix="genre")

    feature_cols = [
        "log_pages", "log_reviews", "log_totalratings",
        "popularity_score", "review_ratio",
        "author_encoded", "format_encoded",
    ]
    features = pd.concat([df[feature_cols], genre_dummies], axis=1)
    target   = (df["rating"] >= 4.0).astype("int8")

    return features, target, le_a, le_f


# ──────────────────────────────────────────────
# 4a. Train XGBoost (content-based ranker)
# ──────────────────────────────────────────────

def train_xgb(features: pd.DataFrame, target: pd.Series, weights: np.ndarray):
    X_train, X_test, y_train, y_test, w_train, _ = train_test_split(
        features, target, weights, test_size=0.2, random_state=42, stratify=target
    )

    model = xgb.XGBClassifier(
        n_estimators=200,
        max_depth=6,
        learning_rate=0.1,
        use_label_encoder=False,
        eval_metric="logloss",
        random_state=42,
        verbosity=0,
    )
    model.fit(X_train, y_train, sample_weight=w_train)
    acc = accuracy_score(y_test, model.predict(X_test))
    return model, float(acc)


# ──────────────────────────────────────────────
# 4b. Train SVD (collaborative filtering)
# ──────────────────────────────────────────────

def train_cf(interactions: pd.DataFrame):
    """
    Train surprise SVD on user-book interactions.
    Returns (model, rmse) or (None, None) if data is insufficient.
    """
    reader  = Reader(rating_scale=(1.0, 5.0))
    dataset = Dataset.load_from_df(
        interactions[["user_id", "isbn13", "effective_rating"]],
        reader,
    )

    trainset, testset = surprise_split(dataset, test_size=0.2, random_state=42)

    # n_factors=50: reasonable for a mid-size catalogue; adjust after measuring RMSE
    model = SurpriseSVD(n_factors=50, n_epochs=25, lr_all=0.005, reg_all=0.02, random_state=42)
    model.fit(trainset)

    predictions = model.test(testset)
    rmse = surprise_accuracy.rmse(predictions, verbose=False)
    return model, float(rmse)


# ──────────────────────────────────────────────
# 5. Save models
# ──────────────────────────────────────────────

def save_xgb(xgb_model, le_a, le_f):
    joblib.dump(xgb_model, os.path.join(MODEL_DIR, "xgb_model.pkl"))
    joblib.dump(le_a,      os.path.join(MODEL_DIR, "le_author.pkl"))
    joblib.dump(le_f,      os.path.join(MODEL_DIR, "le_format.pkl"))


def save_cf(cf_model):
    joblib.dump(cf_model, os.path.join(MODEL_DIR, "cf_model.pkl"))


# ──────────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────────

def main():
    t0 = time.time()
    result = {}

    try:
        # ── Content-based (XGBoost) ───────────────
        signals          = pull_mysql_signals()
        new_signal_count = len(signals)

        if new_signal_count < MIN_NEW_ROWS:
            result["xgb_status"]  = "skipped"
            result["xgb_message"] = f"Only {new_signal_count} signals (min {MIN_NEW_ROWS})"
        else:
            df, weights            = build_training_data(signals)
            features, target, le_a, le_f = engineer_features(df)
            xgb_model, xgb_acc    = train_xgb(features, target, weights)
            save_xgb(xgb_model, le_a, le_f)
            result["xgb_status"]   = "ok"
            result["xgb_records"]  = len(df)
            result["xgb_accuracy"] = round(xgb_acc, 4)

        # ── Collaborative filtering (SVD) ─────────
        interactions      = pull_user_interactions()
        cf_interaction_count = len(interactions)

        if cf_interaction_count < MIN_CF_ROWS:
            result["cf_status"]  = "skipped"
            result["cf_message"] = f"Only {cf_interaction_count} interactions (min {MIN_CF_ROWS})"
        else:
            cf_model, cf_rmse = train_cf(interactions)
            save_cf(cf_model)
            result["cf_status"]        = "ok"
            result["cf_interactions"]  = cf_interaction_count
            result["cf_unique_users"]  = int(interactions["user_id"].nunique())
            result["cf_unique_books"]  = int(interactions["isbn13"].nunique())
            result["cf_rmse"]          = round(cf_rmse, 4)

        elapsed         = round(time.time() - t0, 1)
        result["status"]    = "ok"
        result["elapsed_s"] = elapsed
        result["message"]   = (
            f"Retrain complete in {elapsed}s. "
            f"XGBoost: {result.get('xgb_status', 'skipped')} "
            f"(acc={result.get('xgb_accuracy', 'n/a')}). "
            f"CF: {result.get('cf_status', 'skipped')} "
            f"(rmse={result.get('cf_rmse', 'n/a')})."
        )
        out(result)

    except Exception as e:
        out({"status": "error", "message": str(e)})
        sys.exit(1)


if __name__ == "__main__":
    main()