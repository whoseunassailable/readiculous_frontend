import os
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
import joblib
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics.pairwise import cosine_similarity
from collections import Counter

# ----- STARTUP: load everything once -----

MODEL_DIR = os.path.dirname(os.path.abspath(__file__))

def _load_models():
    return (
        joblib.load(os.path.join(MODEL_DIR, "xgb_model.pkl")),
        joblib.load(os.path.join(MODEL_DIR, "svd_transformer.pkl")),
        joblib.load(os.path.join(MODEL_DIR, "svd_logistic_model.pkl")),
    )

DATA_PATH = os.getenv(
    "GOODREADS_CSV",
    "/Users/whoseunassailable/Documents/datasets/GoodReads_100k_books.csv",
)

books_df      = pd.read_csv(DATA_PATH)
xgb_model, svd_model, logreg_model = _load_models()

# ----- RECOMMENDER FUNCTIONS -----

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


def recommend_books(df, genres, top_n=10):
    df_clean = df.dropna(subset=["genre"]).reset_index(drop=True)
    df_clean["genre_list"] = df_clean["genre"].str.split(",").apply(lambda L: [g.strip() for g in L])
    exploded = df_clean.explode("genre_list")
    cands = exploded[exploded["genre_list"].isin(genres)].drop_duplicates("title")
    if cands.empty:
        return pd.DataFrame()

    idx = cands.index
    df_feats = df.copy().reset_index(drop=True)
    df_feats["genre"] = df_feats["genre"].fillna("Other")

    feats_num = prepare_numeric_features(df_feats)
    le_a = LabelEncoder().fit(df_feats["author"])
    feats_num["author_encoded"] = le_a.transform(df_feats["author"])
    le_f = LabelEncoder().fit(df_feats["bookformat"].fillna("Unknown"))
    feats_num["format_encoded"] = le_f.transform(df_feats["bookformat"].fillna("Unknown"))

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

    cands["final_score"] = 0.5 * cands["xgb_proba"] + 0.5 * cands["svd_proba"]
    top = cands.sort_values("final_score", ascending=False).head(top_n)

    output_cols = ["title", "author", "genre", "rating",
                   "xgb_proba", "svd_proba", "sim_score", "final_score"]
    if "isbn" in top.columns:
        output_cols = ["isbn"] + output_cols

    return top[output_cols].reset_index(drop=True)


# ----- FLASK APP -----

app = Flask(__name__)
CORS(app)


@app.route("/recommend", methods=["POST"])
def recommend():
    try:
        data   = request.get_json()
        genres = data.get("genres", [])
        top_n  = data.get("top_n", 10)

        if not genres:
            return jsonify({"error": "No genres provided"}), 400

        results_df = recommend_books(books_df, genres, top_n=top_n)
        return jsonify(results_df.to_dict(orient="records"))

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/suggest", methods=["POST"])
def suggest():
    try:
        data             = request.get_json()
        user_preferences = data.get("user_preferences", [])
        top_m            = data.get("top_m_genres", 5)
        top_n            = data.get("top_n_books", 5)

        all_genres = []
        for user in user_preferences:
            all_genres.extend([g.strip() for g in user["genres"].split(",") if g.strip()])
        top_genres = [g for g, _ in Counter(all_genres).most_common(top_m)]

        results_df = recommend_books(books_df, top_genres, top_n=top_n)
        return jsonify({
            "top_genres":      top_genres,
            "recommendations": results_df.to_dict(orient="records"),
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/reload", methods=["POST"])
def reload_models():
    """
    Hot-reload models from disk after retraining.
    Called by the Node.js backend after POST /api/ml/retrain completes.
    """
    global xgb_model, svd_model, logreg_model
    try:
        xgb_model, svd_model, logreg_model = _load_models()
        return jsonify({"status": "ok", "message": "Models reloaded successfully"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


@app.route("/")
def home():
    return "Readiculous ML service is running."


if __name__ == "__main__":
    app.run(port=6000, debug=True)
