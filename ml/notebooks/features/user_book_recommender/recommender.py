import os
import re
import pymysql
import pymysql.cursors
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
import joblib
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import LabelEncoder
from sklearn.feature_extraction.text import TfidfVectorizer

# ----- CONFIG -----

MODEL_DIR = os.path.dirname(os.path.abspath(__file__))

DATA_PATH = os.getenv("GOODREADS_CSV")
if not DATA_PATH:
    raise RuntimeError(
        "GOODREADS_CSV environment variable is not set. "
        "Example: export GOODREADS_CSV=/path/to/GoodReads_100k_books.csv"
    )

DB_CONFIG = dict(
    host     = os.getenv("DB_HOST",     "localhost"),
    user     = os.getenv("DB_USER",     "root"),
    password = os.getenv("DB_PASSWORD", "Jraonhvain11#"),
    database = os.getenv("DB_NAME",     "readiculous"),
    charset  = "utf8mb4",
    cursorclass = pymysql.cursors.DictCursor,
)

# Hybrid weight thresholds (content_weight, cf_weight)
# Below MIN_CF: pure content-based (CF has cold-start, not useful yet)
# MIN_CF to MID_CF: lean content, light CF signal
# Above MID_CF: lean CF, content as anchor
MIN_CF  = 5
MID_CF  = 15


# ----- STARTUP: load CSV -----

books_df = pd.read_csv(DATA_PATH)

# Add isbn13 column if the CSV only has isbn (ISBN-10)
def _isbn10_to_isbn13(isbn10):
    clean = re.sub(r"[^0-9Xx]", "", str(isbn10))
    if len(clean) != 10:
        return None
    body = clean[:9]
    if not body.isdigit():
        return None
    prefix = "978" + body
    try:
        total = sum((1 if i % 2 == 0 else 3) * int(d) for i, d in enumerate(prefix))
    except ValueError:
        return None
    check = (10 - (total % 10)) % 10
    return prefix + str(check)

if "isbn13" not in books_df.columns and "isbn" in books_df.columns:
    print("[ML] Converting isbn-10 → isbn-13 for CF matching...", flush=True)
    books_df["isbn13"] = books_df["isbn"].apply(_isbn10_to_isbn13)

# Detect description and ISBN columns
_DESC_COL = next((c for c in ["desc", "description", "Desc", "Description"] if c in books_df.columns), None)
_ISBN_COL = next((c for c in ["isbn13", "ISBN13", "isbn", "ISBN"] if c in books_df.columns), None)


# ----- MODEL LOADING -----

def _load_content_models():
    xgb_model = joblib.load(os.path.join(MODEL_DIR, "xgb_model.pkl"))

    le_author_path = os.path.join(MODEL_DIR, "le_author.pkl")
    le_format_path = os.path.join(MODEL_DIR, "le_format.pkl")

    if not os.path.exists(le_author_path) or not os.path.exists(le_format_path):
        print("[ML] Encoder files missing — bootstrapping from CSV...", flush=True)
        df_tmp = books_df.copy()
        df_tmp["author"]     = df_tmp["author"].fillna("unknown")
        df_tmp["bookformat"] = df_tmp["bookformat"].fillna("unknown").str.lower().str.strip()
        le_a = LabelEncoder().fit(df_tmp["author"])
        le_f = LabelEncoder().fit(df_tmp["bookformat"])
        joblib.dump(le_a, le_author_path)
        joblib.dump(le_f, le_format_path)
        print("[ML] Encoder files saved.", flush=True)

    return xgb_model, joblib.load(le_author_path), joblib.load(le_format_path)


def _load_tfidf():
    tfidf_path = os.path.join(MODEL_DIR, "tfidf_vectorizer.pkl")
    if not os.path.exists(tfidf_path):
        print("[ML] Fitting TF-IDF vectorizer from CSV descriptions...", flush=True)
        if _DESC_COL:
            corpus = books_df[_DESC_COL].fillna("").astype(str)
        else:
            corpus = (
                books_df["title"].fillna("").astype(str) + " " +
                books_df["genre"].fillna("").astype(str)
            )
        vec = TfidfVectorizer(max_features=8000, stop_words="english", ngram_range=(1, 2))
        vec.fit(corpus)
        joblib.dump(vec, tfidf_path)
        print("[ML] TF-IDF vectorizer saved.", flush=True)
    return joblib.load(tfidf_path)


def _load_cf_model():
    cf_path = os.path.join(MODEL_DIR, "cf_model.pkl")
    if not os.path.exists(cf_path):
        print("[ML] CF model not found — CF recommendations unavailable until first retrain.", flush=True)
        return None
    return joblib.load(cf_path)


xgb_model, le_author, le_format = _load_content_models()
tfidf_vec = _load_tfidf()
cf_model  = _load_cf_model()


# ----- HELPERS -----

def _safe_encode(encoder, series):
    known = set(encoder.classes_)
    return np.where(
        series.isin(known),
        encoder.transform(series.where(series.isin(known), encoder.classes_[0])),
        0,
    )


def prepare_numeric_features(df):
    df2 = df.copy()
    df2["log_pages"]        = np.log1p(df2["pages"])
    df2["log_reviews"]      = np.log1p(df2["reviews"])
    df2["log_totalratings"] = np.log1p(df2["totalratings"])
    df2["popularity_score"] = df2["rating"] * df2["log_totalratings"]
    df2["review_ratio"]     = df2["reviews"] / df2["totalratings"].replace(0, np.nan)
    return df2[[
        "log_pages", "log_reviews", "log_totalratings",
        "popularity_score", "review_ratio",
    ]].fillna(0)


def _apply_genre_cap(df, top_n):
    max_per_genre = max(2, top_n // 3)
    result, genre_counts = [], {}
    for _, row in df.iterrows():
        primary = str(row.get("genre", "")).split(",")[0].strip().lower()
        count = genre_counts.get(primary, 0)
        if count < max_per_genre:
            result.append(row)
            genre_counts[primary] = count + 1
    return pd.DataFrame(result) if result else pd.DataFrame(columns=df.columns)


def _build_candidates(df, genres_normalized):
    """Filter to genre-matching books and return (df_clean, cands, idx)."""
    df_clean = df.dropna(subset=["genre"]).reset_index(drop=True)
    df_clean["genre_list"] = df_clean["genre"].str.split(",").apply(
        lambda L: [g.strip().lower() for g in L]
    )
    exploded = df_clean.explode("genre_list")
    cands    = exploded[exploded["genre_list"].isin(genres_normalized)].drop_duplicates("title").copy()
    return df_clean, cands, cands.index


def _xgb_scores(df_clean, idx):
    df_feats = df_clean.copy()
    df_feats["genre"] = df_feats["genre"].fillna("other").str.lower().str.strip()

    feats_num = prepare_numeric_features(df_feats)
    feats_num["author_encoded"] = _safe_encode(le_author, df_feats["author"].fillna("unknown"))
    feats_num["format_encoded"] = _safe_encode(
        le_format, df_feats["bookformat"].fillna("unknown").str.lower().str.strip()
    )
    genre_dummies = pd.get_dummies(df_feats["genre"], prefix="genre")
    feats_full    = pd.concat([feats_num, genre_dummies], axis=1)
    feats_full    = feats_full.reindex(columns=xgb_model.get_booster().feature_names, fill_value=0)
    return xgb_model.predict_proba(feats_full.loc[idx])[:, 1]


def _tfidf_scores(df_clean, idx, genres_normalized):
    if _DESC_COL:
        text_col = df_clean[_DESC_COL].fillna("").astype(str)
    else:
        text_col = (
            df_clean["title"].fillna("").astype(str) + " " +
            df_clean["genre"].fillna("").astype(str)
        )

    # Genre profile = TF-IDF average of top-rated books in the requested genres
    genre_mask     = df_clean["genre_list"].apply(lambda L: bool(genres_normalized.intersection(set(L))))
    genre_books    = df_clean[genre_mask]
    profile_sample = genre_books.nlargest(min(100, len(genre_books)), "rating")
    profile_text   = " ".join(text_col.loc[profile_sample.index].tolist())
    profile_vec    = tfidf_vec.transform([profile_text])

    cand_vecs = tfidf_vec.transform(text_col.loc[idx].tolist())
    return cosine_similarity(cand_vecs, profile_vec).flatten()


def _cf_scores(user_id, cands):
    """
    Score each candidate using the CF model.
    Returns a numpy array of scores in [0, 1] aligned to cands rows.
    Unknown items get the model's global mean (surprise handles this internally).
    """
    if cf_model is None or "isbn13" not in cands.columns:
        return np.zeros(len(cands))

    scores = []
    for isbn13 in cands["isbn13"].tolist():
        if isbn13 is None or (isinstance(isbn13, float) and np.isnan(isbn13)):
            scores.append(0.5)   # unknown item: neutral
        else:
            pred = cf_model.predict(str(user_id), str(isbn13))
            scores.append((pred.est - 1.0) / 4.0)   # normalise [1,5] → [0,1]
    return np.array(scores)


def _get_interaction_count(user_id):
    """Quick MySQL lookup for how many rated/read interactions this user has."""
    try:
        conn = pymysql.connect(**DB_CONFIG)
        with conn.cursor() as cur:
            cur.execute(
                """SELECT COUNT(*) AS cnt FROM user_reads
                   WHERE user_id = %s
                     AND (rating IS NOT NULL OR status = 'read')""",
                (user_id,),
            )
            row = cur.fetchone()
        conn.close()
        return int(row["cnt"]) if row else 0
    except Exception:
        return 0


def _hybrid_weights(interaction_count):
    """Return (content_w, cf_w) based on how much CF signal the user has."""
    if interaction_count < MIN_CF:
        return 1.0, 0.0    # cold-start: content-only
    if interaction_count < MID_CF:
        return 0.7, 0.3    # some history: lean content
    return 0.4, 0.6        # rich history: lean CF


# ----- RECOMMENDATION MODES -----

def _recommend_content(df, genres, top_n):
    """Pure content-based: XGBoost + TF-IDF genre-profile similarity."""
    genres_normalized = {g.lower().strip() for g in genres}
    df_clean, cands, idx = _build_candidates(df, genres_normalized)
    if cands.empty:
        return pd.DataFrame()

    cands["xgb_score"]   = _xgb_scores(df_clean, idx)
    cands["tfidf_sim"]   = _tfidf_scores(df_clean, idx, genres_normalized)
    cands["final_score"] = 0.8 * cands["xgb_score"] + 0.2 * cands["tfidf_sim"]

    top = cands.sort_values("final_score", ascending=False).head(top_n * 3)
    top = _apply_genre_cap(top, top_n).head(top_n)

    out_cols = ["title", "author", "genre", "rating", "xgb_score", "tfidf_sim", "final_score"]
    if _ISBN_COL:
        out_cols = [_ISBN_COL] + out_cols
    return top[[c for c in out_cols if c in top.columns]].reset_index(drop=True)


def _recommend_cf(df, genres, user_id, top_n):
    """Pure CF: candidates filtered by genre, ranked solely by CF predicted rating."""
    if cf_model is None:
        return pd.DataFrame()

    genres_normalized = {g.lower().strip() for g in genres}
    _, cands, _ = _build_candidates(df, genres_normalized)
    if cands.empty:
        return pd.DataFrame()

    cands["cf_score"]    = _cf_scores(user_id, cands)
    cands["final_score"] = cands["cf_score"]

    top = cands.sort_values("final_score", ascending=False).head(top_n * 3)
    top = _apply_genre_cap(top, top_n).head(top_n)

    out_cols = ["title", "author", "genre", "rating", "cf_score", "final_score"]
    if _ISBN_COL:
        out_cols = [_ISBN_COL] + out_cols
    return top[[c for c in out_cols if c in top.columns]].reset_index(drop=True)


def _recommend_hybrid(df, genres, user_id, interaction_count, top_n):
    """
    Weighted blend of content-based and CF scores.
    Weights shift automatically based on how much interaction history the user has.
    """
    genres_normalized = {g.lower().strip() for g in genres}
    df_clean, cands, idx = _build_candidates(df, genres_normalized)
    if cands.empty:
        return pd.DataFrame()

    content_w, cf_w = _hybrid_weights(interaction_count)

    cands["xgb_score"]  = _xgb_scores(df_clean, idx)
    cands["tfidf_sim"]  = _tfidf_scores(df_clean, idx, genres_normalized)
    content_score       = 0.8 * cands["xgb_score"] + 0.2 * cands["tfidf_sim"]

    if cf_w > 0 and cf_model is not None:
        cands["cf_score"] = _cf_scores(user_id, cands)
        cands["final_score"] = content_w * content_score + cf_w * cands["cf_score"]
    else:
        cands["cf_score"]    = 0.0
        cands["final_score"] = content_score

    top = cands.sort_values("final_score", ascending=False).head(top_n * 3)
    top = _apply_genre_cap(top, top_n).head(top_n)

    out_cols = ["title", "author", "genre", "rating",
                "xgb_score", "tfidf_sim", "cf_score", "final_score"]
    if _ISBN_COL:
        out_cols = [_ISBN_COL] + out_cols
    return top[[c for c in out_cols if c in top.columns]].reset_index(drop=True)


# ----- CACHE -----

_rec_cache: dict = {}

def _cache_key(genres, user_id, mode, top_n):
    return (tuple(sorted(g.lower().strip() for g in genres)), str(user_id), mode, top_n)


# ----- FLASK APP -----

app = Flask(__name__)
CORS(app)


@app.route("/recommend", methods=["POST"])
def recommend():
    """
    POST body:
      {
        "genres":  ["Fantasy", "Mystery"],
        "user_id": "abc123",              // optional — enables CF/hybrid
        "top_n":   10                     // optional, default 10
      }

    If user_id is provided and the CF model exists, the mode is chosen
    automatically based on the user's interaction count:
      < 5  interactions  → content-only
      5-14 interactions  → hybrid (70% content / 30% CF)
      15+  interactions  → hybrid (40% content / 60% CF)
    """
    try:
        data    = request.get_json()
        genres  = data.get("genres", [])
        user_id = data.get("user_id")
        top_n   = int(data.get("top_n", 10))

        if not genres:
            return jsonify({"error": "No genres provided"}), 400

        if user_id and cf_model is not None:
            interaction_count = _get_interaction_count(user_id)
            mode = "hybrid"
        else:
            interaction_count = 0
            mode = "content"

        key = _cache_key(genres, user_id, mode, top_n)
        if key not in _rec_cache:
            if mode == "hybrid":
                result_df = _recommend_hybrid(books_df, genres, user_id, interaction_count, top_n)
            else:
                result_df = _recommend_content(books_df, genres, top_n)
            _rec_cache[key] = result_df

        return jsonify(_rec_cache[key].to_dict(orient="records"))

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/compare", methods=["POST"])
def compare():
    """
    Run all three modes and return results side-by-side for evaluation.

    POST body:
      {
        "genres":  ["Fantasy", "Mystery"],
        "user_id": "abc123",
        "top_n":   5
      }
    """
    try:
        data    = request.get_json()
        genres  = data.get("genres", [])
        user_id = data.get("user_id")
        top_n   = int(data.get("top_n", 5))

        if not genres:
            return jsonify({"error": "No genres provided"}), 400

        interaction_count = _get_interaction_count(user_id) if user_id else 0
        content_w, cf_w   = _hybrid_weights(interaction_count)

        content_df = _recommend_content(books_df, genres, top_n)
        cf_df      = _recommend_cf(books_df, genres, user_id, top_n) if user_id else pd.DataFrame()
        hybrid_df  = _recommend_hybrid(books_df, genres, user_id, interaction_count, top_n) if user_id else content_df

        return jsonify({
            "meta": {
                "user_id":           user_id,
                "interaction_count": interaction_count,
                "content_weight":    content_w,
                "cf_weight":         cf_w,
                "cf_available":      cf_model is not None,
            },
            "content": content_df.to_dict(orient="records"),
            "cf":      cf_df.to_dict(orient="records") if not cf_df.empty else [],
            "hybrid":  hybrid_df.to_dict(orient="records"),
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/reload", methods=["POST"])
def reload_models():
    global xgb_model, le_author, le_format, tfidf_vec, cf_model
    try:
        xgb_model, le_author, le_format = _load_content_models()
        tfidf_vec = _load_tfidf()
        cf_model  = _load_cf_model()
        _rec_cache.clear()
        return jsonify({
            "status":       "ok",
            "cf_available": cf_model is not None,
            "message":      "Models reloaded successfully",
        })
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


@app.route("/")
def home():
    return jsonify({
        "service":      "Readiculous ML",
        "cf_available": cf_model is not None,
    })


if __name__ == "__main__":
    app.run(port=6000, debug=True)