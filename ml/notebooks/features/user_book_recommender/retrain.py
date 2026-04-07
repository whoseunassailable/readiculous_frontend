"""
retrain.py — Readiculous model retraining pipeline

Pulls live signals from MySQL, merges with the Kaggle baseline,
retrains XGBoost + SVD, and overwrites the .pkl files in place.

Called by the Node.js backend via:
  POST /api/ml/retrain

Outputs a single JSON line to stdout on completion:
  {"status": "ok", "records": 12345, "xgb_accuracy": 0.87, "message": "..."}
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
from sklearn.decomposition import TruncatedSVD
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
import xgboost as xgb

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

KAGGLE_CSV   = os.getenv("GOODREADS_CSV", "/Users/whoseunassailable/Documents/datasets/GoodReads_100k_books.csv")
MODEL_DIR    = os.path.dirname(os.path.abspath(__file__))
MIN_NEW_ROWS = int(os.getenv("MIN_NEW_ROWS", "10"))   # skip retraining if fewer new signals than this


def out(payload: dict):
    """Write a single JSON result line to stdout and exit."""
    print(json.dumps(payload), flush=True)


# ──────────────────────────────────────────────
# 1. Pull signals from MySQL
# ──────────────────────────────────────────────

def pull_mysql_signals():
    """
    Returns a DataFrame with columns:
      isbn13, avg_user_rating, rating_count, library_signal

    library_signal:
       +1  = book was STOCKED or ORDERED by a librarian (positive)
       -1  = book was IGNORED by a librarian (negative)
        0  = no librarian signal
    """
    conn = pymysql.connect(**DB_CONFIG)
    try:
        # User ratings aggregated per book
        user_ratings = pd.read_sql(
            """
            SELECT
                b.isbn13,
                AVG(ur.rating)  AS avg_user_rating,
                COUNT(ur.rating) AS rating_count
            FROM user_reads ur
            JOIN books b ON b.book_id = ur.book_id
            WHERE ur.rating IS NOT NULL
              AND b.isbn13  IS NOT NULL
            GROUP BY b.isbn13
            """,
            conn,
        )

        # Librarian signals
        library_signals = pd.read_sql(
            """
            SELECT
                b.isbn13,
                MAX(CASE
                    WHEN lr.state IN ('STOCKED', 'ORDERED') THEN  1
                    WHEN lr.state = 'IGNORED'               THEN -1
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
    signals["avg_user_rating"]  = signals["avg_user_rating"].fillna(0)
    signals["rating_count"]     = signals["rating_count"].fillna(0)
    signals["library_signal"]   = signals["library_signal"].fillna(0)
    return signals


# ──────────────────────────────────────────────
# 2. Merge signals into the Kaggle baseline
# ──────────────────────────────────────────────

def build_training_data(signals: pd.DataFrame):
    """
    Load the Kaggle CSV and overlay live MySQL signals.

    For books present in MySQL:
      - Blend the Kaggle avg rating with the user rating (weighted 70/30)
      - Boost or penalise rows based on library_signal by duplicating them
        (STOCKED/ORDERED → 3× copies, IGNORED → 1 copy with rating capped at 2.5)

    Returns a DataFrame ready for feature engineering + training.
    """
    cols = ["author", "bookformat", "genre", "isbn", "pages", "rating", "reviews", "title", "totalratings"]
    df = pd.read_csv(KAGGLE_CSV, encoding="utf-8")
    df = df[[c for c in cols if c in df.columns]]
    df = df.dropna(subset=["rating", "genre", "author"]).reset_index(drop=True)

    # Normalise isbn column name to isbn13
    if "isbn" in df.columns:
        df = df.rename(columns={"isbn": "isbn13"})

    if signals.empty or "isbn13" not in df.columns:
        return df

    # Merge signals
    merged = df.merge(signals, on="isbn13", how="left")
    merged["avg_user_rating"] = merged["avg_user_rating"].fillna(0)
    merged["library_signal"]  = merged["library_signal"].fillna(0)

    # Blend rating: 70% Kaggle + 30% user rating (only where user data exists)
    has_user_rating = merged["avg_user_rating"] > 0
    merged.loc[has_user_rating, "rating"] = (
        0.7 * merged.loc[has_user_rating, "rating"] +
        0.3 * merged.loc[has_user_rating, "avg_user_rating"]
    )

    # Positive library signal → duplicate rows (amplify this book's influence)
    positive = merged[merged["library_signal"] == 1]
    if not positive.empty:
        merged = pd.concat([merged] + [positive] * 2, ignore_index=True)

    # Negative library signal → cap rating at 2.5 (push below quality threshold)
    neg_mask = merged["library_signal"] == -1
    merged.loc[neg_mask, "rating"] = merged.loc[neg_mask, "rating"].clip(upper=2.5)

    return merged.drop(columns=["avg_user_rating", "rating_count", "library_signal"], errors="ignore")


# ──────────────────────────────────────────────
# 3. Feature engineering (mirrors the notebook)
# ──────────────────────────────────────────────

def engineer_features(df: pd.DataFrame):
    df = df.copy()
    df["pages"]        = df["pages"].fillna(0).astype("int32")
    df["reviews"]      = df["reviews"].fillna(0).astype("int32")
    df["totalratings"] = df["totalratings"].fillna(0).astype("int32")
    df["bookformat"]   = df["bookformat"].fillna("Unknown")
    df["genre"]        = df["genre"].fillna("Other")

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

    return features, target


# ──────────────────────────────────────────────
# 4. Train XGBoost + SVD + LogisticRegression
# ──────────────────────────────────────────────

def train(features: pd.DataFrame, target: pd.Series):
    X_train, X_test, y_train, y_test = train_test_split(
        features, target, test_size=0.2, random_state=42, stratify=target
    )

    # XGBoost
    xgb_model = xgb.XGBClassifier(
        n_estimators=200,
        max_depth=6,
        learning_rate=0.1,
        use_label_encoder=False,
        eval_metric="logloss",
        random_state=42,
        verbosity=0,
    )
    xgb_model.fit(X_train, y_train)
    xgb_acc = accuracy_score(y_test, xgb_model.predict(X_test))

    # SVD + Logistic Regression
    svd = TruncatedSVD(n_components=20, random_state=42)
    X_train_svd = svd.fit_transform(X_train)
    X_test_svd  = svd.transform(X_test)

    logreg = LogisticRegression(max_iter=1000, random_state=42)
    logreg.fit(X_train_svd, y_train)

    return xgb_model, svd, logreg, float(xgb_acc)


# ──────────────────────────────────────────────
# 5. Save models
# ──────────────────────────────────────────────

def save_models(xgb_model, svd, logreg):
    joblib.dump(xgb_model, os.path.join(MODEL_DIR, "xgb_model.pkl"))
    joblib.dump(svd,       os.path.join(MODEL_DIR, "svd_transformer.pkl"))
    joblib.dump(logreg,    os.path.join(MODEL_DIR, "svd_logistic_model.pkl"))


# ──────────────────────────────────────────────
# Entry point
# ──────────────────────────────────────────────

def main():
    t0 = time.time()

    try:
        # 1. Pull live signals
        signals = pull_mysql_signals()
        new_signal_count = len(signals)

        if new_signal_count < MIN_NEW_ROWS:
            out({
                "status":  "skipped",
                "records": new_signal_count,
                "message": f"Only {new_signal_count} new signals — minimum is {MIN_NEW_ROWS}. Retraining skipped.",
            })
            return

        # 2. Build training data
        df = build_training_data(signals)

        # 3. Feature engineering
        features, target = engineer_features(df)

        # 4. Train
        xgb_model, svd, logreg, xgb_acc = train(features, target)

        # 5. Save
        save_models(xgb_model, svd, logreg)

        elapsed = round(time.time() - t0, 1)
        out({
            "status":       "ok",
            "records":      len(df),
            "new_signals":  new_signal_count,
            "xgb_accuracy": round(xgb_acc, 4),
            "elapsed_s":    elapsed,
            "message":      f"Retrained on {len(df)} records ({new_signal_count} live signals) in {elapsed}s. XGBoost accuracy: {round(xgb_acc * 100, 1)}%",
        })

    except Exception as e:
        out({"status": "error", "message": str(e)})
        sys.exit(1)


if __name__ == "__main__":
    main()
