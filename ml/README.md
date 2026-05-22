# Readiculous

> Because what's sitting on library shelves should actually be worth reading.

---

## The Problem

Libraries across the country shelf books that nobody reads. The same titles collect dust for decades while readers walk out empty-handed because the books they actually want aren't there. This isn't just a bad experience — it's wasted shelf space, wasted paper, and a missed opportunity to bring people back to one of the best places to spend time.

If you've ever walked into a library in Chicago — Chinatown, Joe and Rika, or anywhere else — you've probably felt this. You go in with a mood, maybe something heavy and introspective on a grey day, maybe something light on a sunny one, and the library just... doesn't have it. What it does have is a wall of books nobody has touched since 2003.

---

## The Solution — Readiculous

Readiculous is a community-driven book recommendation platform that bridges the gap between what readers actually want and what libraries decide to stock.

Here's how it works:

1. **Readers** create an account, log the books they read, and set their genre preferences.
2. **The ML model** aggregates reading preferences from all users in a given area, identifies the top genres and the highest-quality books within those genres, and generates recommendations.
3. **Librarians** receive those recommendations ranked by community interest. They decide what to order, stock, or ignore. The result: shelves that reflect what the actual local reader base wants to read.

No more guessing. No more decade-old inventory that nobody touches.

---

## Architecture

Readiculous is split across three layers:

```
┌──────────────────────────────────┐
│         Flutter App              │  Mobile client for readers & librarians
└──────────────┬───────────────────┘
               │ REST API
┌──────────────▼───────────────────┐
│     Node.js + MySQL Backend      │  User, book, library, and recommendation data
└──────────────┬───────────────────┘
               │ Internal call
┌──────────────▼───────────────────┐
│    Python Flask ML Service       │  Hybrid recommendation engine
│    (this repository)             │  XGBoost + SVD + Cosine Similarity
└──────────────────────────────────┘
```

- **Frontend**: Flutter (iOS + Android)
- **Backend**: Node.js, MySQL
- **ML Service**: Python, Flask, scikit-learn, XGBoost

---

## ML Model

The recommendation engine lives in `notebooks/features/user_book_recommender/good_reads_books_100k.ipynb` and is served via `recommender.py`.

It uses a hybrid approach combining content-based ranking and collaborative filtering:

| Model                     | Role                                                                                |
| ------------------------- | ----------------------------------------------------------------------------------- |
| XGBoost                   | Scores books from metadata and popularity features such as rating, reviews, genre, format, and author |
| TF-IDF + Cosine Similarity | Builds a genre-profile text representation from book descriptions and measures content similarity |
| Surprise SVD             | Learns user-book interaction patterns for collaborative filtering when enough user history exists |

In production, the `/recommend` endpoint blends those signals dynamically:

- Cold start users: content-only recommendations
- Users with some history: hybrid recommendations weighted toward content
- Users with richer history: hybrid recommendations weighted toward collaborative filtering

The dataset is sourced from Kaggle — 100k GoodReads books with ratings, genres, review counts, and metadata.

### Two Recommendation Flows

**For individual readers** (`/recommend`):

- Input: list of genre preferences
- Output: top-N books ranked by final score

**For libraries** (`/suggest`):

- Input: reading preferences from all users in the library's area
- Output: top trending genres + top-N books per genre — what the librarian should consider ordering

## Evaluation

Model evaluation is handled in `notebooks/features/user_book_recommender/retrain.py`.

- The XGBoost ranker is trained with an 80/20 train-test split and reports classification accuracy on the held-out set.
- The collaborative filtering model uses Surprise SVD with its own 80/20 split over user-book interactions and reports RMSE on held-out predictions.
- The `/compare` endpoint in `recommender.py` returns content-only, collaborative-filtering-only, and hybrid results side by side so recommendation quality can be inspected during testing.

The retraining pipeline writes these metrics to stdout as structured JSON, including fields such as `xgb_accuracy`, `cf_rmse`, `cf_unique_users`, and `cf_unique_books`.

---

## API Reference

### User & Auth

| Endpoint                      | Method | Description                         |
| ----------------------------- | ------ | ----------------------------------- |
| `/api/users/`                 | GET    | Get all users                       |
| `/api/users/create`           | POST   | Create user                         |
| `/api/users/login`            | POST   | Login                               |
| `/api/users/preferences`      | GET    | All users with genre preferences    |
| `/api/users/:user_id/library` | GET    | Get user's library (librarian only) |
| `/api/users/:user_id`         | DELETE | Delete user                         |

### Books

| Endpoint              | Method | Description                            |
| --------------------- | ------ | -------------------------------------- |
| `/api/books/`         | GET    | All books (includes cover_url, isbn13) |
| `/api/books/:book_id` | GET    | Single book                            |
| `/api/books/`         | POST   | Create book                            |
| `/api/books/:book_id` | PUT    | Update book                            |
| `/api/books/:book_id` | DELETE | Delete book                            |

### Genres

| Endpoint                | Method | Description  |
| ----------------------- | ------ | ------------ |
| `/api/genres/`          | GET    | All genres   |
| `/api/genres/`          | POST   | Create genre |
| `/api/genres/:genre_id` | DELETE | Delete genre |

### Book–Genre Assignments

| Endpoint                              | Method | Description             |
| ------------------------------------- | ------ | ----------------------- |
| `/api/book-genres/`                   | POST   | Assign genres to a book |
| `/api/book-genres/:book_id`           | GET    | Get genres for a book   |
| `/api/book-genres/:book_id/:genre_id` | DELETE | Remove genre from book  |

### User Genre Preferences

| Endpoint                              | Method | Description                        |
| ------------------------------------- | ------ | ---------------------------------- |
| `/api/user-genres/`                   | POST   | Add genres to user preferences     |
| `/api/user-genres/:user_id`           | GET    | Get user's genre preferences       |
| `/api/user-genres/:user_id/:genre_id` | DELETE | Remove genre from user preferences |

### Libraries

| Endpoint                         | Method | Description                  |
| -------------------------------- | ------ | ---------------------------- |
| `/api/libraries/`                | GET    | All libraries                |
| `/api/libraries/`                | POST   | Create library               |
| `/api/library-books/:library_id` | GET    | Books in a library           |
| `/api/library-books/`            | POST   | Add or update book inventory |

### Librarians

| Endpoint                               | Method | Description                  |
| -------------------------------------- | ------ | ---------------------------- |
| `/api/librarians/assign`               | POST   | Assign librarian (sets role) |
| `/api/librarians/:library_id`          | GET    | Get librarians for a library |
| `/api/librarians/:user_id/:library_id` | DELETE | Unassign librarian           |

### Reading Lists

| Endpoint                       | Method | Description               |
| ------------------------------ | ------ | ------------------------- |
| `/api/reads/:user_id`          | GET    | Get user's reading list   |
| `/api/reads/`                  | POST   | Add or update read status |
| `/api/reads/:user_id/:book_id` | DELETE | Remove from reading list  |

### Recommendations

| Endpoint                                            | Method | Description                                      |
| --------------------------------------------------- | ------ | ------------------------------------------------ |
| `/api/recommendations/users/:user_id`               | GET    | User recommendations                             |
| `/api/recommendations/users`                        | POST   | Create user recommendation                       |
| `/api/recommendations/users/:recommendation_id`     | DELETE | Delete user recommendation                       |
| `/api/recommendations/libraries/:library_id`        | GET    | Library recommendations                          |
| `/api/recommendations/libraries`                    | POST   | Create library recommendation                    |
| `/api/recommendations/libraries/:recommendation_id` | PATCH  | Update state (NEW / ORDERED / STOCKED / IGNORED) |
| `/api/recommendations/libraries/:recommendation_id` | DELETE | Delete library recommendation                    |

### Trends

| Endpoint                            | Method | Description                         |
| ----------------------------------- | ------ | ----------------------------------- |
| `/api/trends/libraries/:library_id` | GET    | Genre trends for a specific library |
| `/api/trends/top`                   | GET    | Top trends globally or per library  |
| `/api/trends/`                      | POST   | Upsert trend score                  |

---

## Repository Structure

```
readiculous_ml/
├── notebooks/
│   └── features/
│       └── user_book_recommender/
│           ├── good_reads_books_100k.ipynb   # Model training notebook
│           ├── recommender.py                # Flask ML microservice
│           ├── xgb_model.pkl                 # Trained XGBoost model
│           ├── svd_transformer.pkl           # Trained SVD transformer
│           ├── svd_logistic_model.pkl        # Logistic regression on SVD space
│           ├── kmeans_model.pkl              # KMeans (experimental)
│           └── knn_model.pkl                 # KNN (experimental)
├── data_loader.ipynb                         # Dataset loading & preprocessing
├── helper_functions/                         # Shared utilities
└── README.md
```

---

## Running the ML Service

```bash
# Install dependencies
pip install flask flask-cors pandas numpy scikit-learn xgboost joblib

# Start the service
python notebooks/features/user_book_recommender/recommender.py
# Runs on http://localhost:6000
```

## Deployment

This repository is the Python Flask ML microservice in the broader Readiculous stack.

- The service loads trained artifacts from `notebooks/features/user_book_recommender/*.pkl` at startup.
- It expects environment variables for the GoodReads dataset path and the shared MySQL database: `GOODREADS_CSV`, `DB_HOST`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME`.
- The Node.js backend calls this service internally for recommendation generation and model retraining.
- A `/reload` endpoint is available to refresh model artifacts in memory after retraining without restarting the process.

### Endpoints

**POST `/recommend`** — book recommendations for a reader

```json
{
  "genres": ["Romance", "Mystery"],
  "top_n": 10
}
```

**POST `/suggest`** — library stocking suggestions based on community preferences

```json
{
  "user_preferences": [
    { "user_id": 1, "genres": "Fiction, Mystery" },
    { "user_id": 2, "genres": "Romance, Thriller" }
  ],
  "top_m_genres": 5,
  "top_n_books": 10
}
```

---

## License

MIT. See [LICENSE](LICENSE).
