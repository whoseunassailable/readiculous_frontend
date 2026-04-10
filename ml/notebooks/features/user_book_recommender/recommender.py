import os
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
import joblib
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import LabelEncoder

# ----- STARTUP: load everything once -----

MODEL_DIR = os.path.dirname(os.path.abspath(__file__))

DATA_PATH = os.getenv("GOODREADS_CSV")
if not DATA_PATH:
    raise RuntimeError(
        "GOODREADS_CSV environment variable is not set. "
        "Set it to the absolute path of your GoodReads CSV file before starting the service. "
        "Example: export GOODREADS_CSV=/path/to/GoodReads_100k_books.csv"
    )

books_df = pd.read_csv(DATA_PATH)


def _load_models():
    xgb_model   = joblib.load(os.path.join(MODEL_DIR, "xgb_model.pkl"))
    svd_model   = joblib.load(os.path.join(MODEL_DIR, "svd_transformer.pkl"))
    logreg_model = joblib.load(os.path.join(MODEL_DIR, "svd_logistic_model.pkl"))

    le_author_path = os.path.join(MODEL_DIR, "le_author.pkl")
    le_format_path = os.path.join(MODEL_DIR, "le_format.pkl")

    # Bootstrap encoder files from the CSV if they were never saved
    if not os.path.exists(le_author_path) or not os.path.exists(le_format_path):
        print("[ML] Encoder files missing — bootstrapping from CSV data...", flush=True)
        df_tmp = books_df.copy()
        df_tmp["author"]     = df_tmp["author"].fillna("unknown")
        df_tmp["bookformat"] = df_tmp["bookformat"].fillna("unknown").str.lower().str.strip()
        le_a = LabelEncoder().fit(df_tmp["author"])
        le_f = LabelEncoder().fit(df_tmp["bookformat"])
        joblib.dump(le_a, le_author_path)
        joblib.dump(le_f, le_format_path)
        print("[ML] Encoder files saved.", flush=True)

    le_author = joblib.load(le_author_path)
    le_format = joblib.load(le_format_path)
    return xgb_model, svd_model, logreg_model, le_author, le_format


xgb_model, svd_model, logreg_model, le_author, le_format = _load_models()

# Detect the ISBN column once at startup so recommend_books can use it reliably.
# Common names in the wild: isbn, ISBN, isbn13, ISBN13, isbn10, ISBN10
_ISBN_CANDIDATES = ["isbn13", "ISBN13", "isbn", "ISBN", "isbn10", "ISBN10"]
ISBN_COL = next((c for c in _ISBN_CANDIDATES if c in books_df.columns), None)

# ----- RECOMMENDER FUNCTIONS -----

def _safe_encode(encoder, series):
    """Encode a Series with a fitted LabelEncoder; map unseen values to 0."""
    known = set(encoder.classes_)
    return np.where(series.isin(known), encoder.transform(series.where(series.isin(known), encoder.classes_[0])), 0)


def prepare_numeric_features(df):
    df2 = df.copy()
    df2["log_pages"]        = np.log1p(df2["pages"])
    df2["log_reviews"]      = np.log1p(df2["reviews"])
    df2["log_totalratings"] = np.log1p(df2["totalratings"])
    df2["popularity_score"] = df2["rating"] * df2["log_totalratings"]
    df2["review_ratio"]     = df2["reviews"] / df2["totalratings"].replace(0, np.nan)
    return df2[[
        "log_pages", "log_reviews", "log_totalratings",
        "popularity_score", "review_ratio"
    ]].fillna(0)


def _apply_genre_cap(df, top_n):
    """Prevent one genre from dominating: cap books per primary genre at top_n // 3 (min 2)."""
    max_per_genre = max(2, top_n // 3)
    result = []
    genre_counts: dict = {}
    for _, row in df.iterrows():
        primary = str(row.get("genre", "")).split(",")[0].strip().lower()
        count = genre_counts.get(primary, 0)
        if count < max_per_genre:
            result.append(row)
            genre_counts[primary] = count + 1
    return pd.DataFrame(result) if result else pd.DataFrame(columns=df.columns)


def recommend_books(df, genres, top_n=10):
    genres_normalized = {g.lower().strip() for g in genres}

    df_clean = df.dropna(subset=["genre"]).reset_index(drop=True)
    df_clean["genre_list"] = df_clean["genre"].str.split(",").apply(
        lambda L: [g.strip().lower() for g in L]
    )
    exploded = df_clean.explode("genre_list")
    cands = exploded[exploded["genre_list"].isin(genres_normalized)].drop_duplicates("title")
    if cands.empty:
        return pd.DataFrame()

    idx = cands.index
    df_feats = df.copy().reset_index(drop=True)
    df_feats["genre"] = df_feats["genre"].fillna("other").str.lower().str.strip()

    feats_num = prepare_numeric_features(df_feats)
    # Use encoders trained during retraining — do not re-fit here
    feats_num["author_encoded"] = _safe_encode(le_author, df_feats["author"])
    feats_num["format_encoded"] = _safe_encode(le_format, df_feats["bookformat"].fillna("unknown").str.lower().str.strip())

    genre_dummies = pd.get_dummies(df_feats["genre"], prefix="genre")
    feats_full = pd.concat([feats_num, genre_dummies], axis=1)

    # Use module-level models (loaded once at startup)
    feat_names = xgb_model.get_booster().feature_names
    feats_full = feats_full.reindex(columns=feat_names, fill_value=0)

    cands = cands.copy()
    cands["xgb_proba"] = xgb_model.predict_proba(feats_full.loc[idx])[:, 1]

    latent_all  = svd_model.transform(feats_full)
    latent_cand = latent_all[idx]
    cands["svd_proba"] = logreg_model.predict_proba(latent_cand)[:, 1]

    user_vec = latent_cand.mean(axis=0).reshape(1, -1)
    cands["sim_score"] = cosine_similarity(latent_cand, user_vec).flatten()

    # 40% XGBoost + 40% SVD logistic + 20% cosine similarity to genre centroid
    cands["final_score"] = (
        0.4 * cands["xgb_proba"] +
        0.4 * cands["svd_proba"] +
        0.2 * cands["sim_score"]
    )
    # Over-fetch then apply genre cap so no single genre dominates the results
    top = cands.sort_values("final_score", ascending=False).head(top_n * 3)
    top = _apply_genre_cap(top, top_n)
    top = top.head(top_n)

    output_cols = ["title", "author", "genre", "rating",
                   "xgb_proba", "svd_proba", "sim_score", "final_score"]
    if ISBN_COL is not None:
        output_cols = [ISBN_COL] + output_cols

    return top[output_cols].reset_index(drop=True)


# ----- FLASK APP -----

app = Flask(__name__)
CORS(app)

# Cache keyed on (sorted-genres-tuple, top_n). Cleared on model reload.
_rec_cache: dict = {}


def _cached_recommend(genres, top_n):
    key = (tuple(sorted(g.lower().strip() for g in genres)), top_n)
    if key not in _rec_cache:
        _rec_cache[key] = recommend_books(books_df, genres, top_n)
    return _rec_cache[key]


@app.route("/recommend", methods=["POST"])
def recommend():
    try:
        data   = request.get_json()
        genres = data.get("genres", [])
        top_n  = data.get("top_n", 10)

        if not genres:
            return jsonify({"error": "No genres provided"}), 400

        results_df = _cached_recommend(genres, top_n)
        return jsonify(results_df.to_dict(orient="records"))

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/reload", methods=["POST"])
def reload_models():
    """
    Hot-reload models from disk after retraining.
    Called by the Node.js backend after POST /api/ml/retrain completes.
    """
    global xgb_model, svd_model, logreg_model, le_author, le_format
    try:
        xgb_model, svd_model, logreg_model, le_author, le_format = _load_models()
        _rec_cache.clear()
        return jsonify({"status": "ok", "message": "Models reloaded successfully"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


@app.route("/")
def home():
    return "Readiculous ML service is running."


if __name__ == "__main__":
    app.run(port=6000, debug=True)
