# Readiculous Project Workflow and Architecture

This document describes the full Readiculous pipeline from Flutter UI to Node.js backend, MySQL database, and Python ML services. The diagrams use Mermaid and are intended to render in GitHub, VS Code Markdown preview, and other Mermaid-enabled viewers.

## Source Map

| Area | Main files |
| --- | --- |
| Flutter bootstrap | `frontend/lib/main.dart`, `frontend/lib/main_dev.dart`, `frontend/lib/main_prod.dart`, `frontend/lib/app_bootstrap.dart` |
| Frontend routing/session | `frontend/lib/core/routing/routing.dart`, `frontend/lib/core/session/*` |
| Frontend feature modules | `frontend/lib/core/features/*` |
| Frontend API clients | `frontend/lib/core/network/dio_client.dart`, `frontend/lib/core/network/clients/*` |
| Backend entrypoint | `backend/src/index.js` |
| Backend route/controller layer | `backend/src/routes/*`, `backend/src/controllers/*` |
| Backend services | `backend/src/services/mlService.js`, `backend/src/services/googleBooksService.js` |
| Database config/schema | `backend/src/config/db.js`, `database/schema.sql`, `backend/src/utils/readiculous.sql` |
| Demo/catalog seeding | `backend/scripts/seed_demo_data.js`, `backend/scripts/seed_books_catalog.js`, `backend/scripts/import_books_from_csv.py` |
| ML service | `ml/notebooks/features/user_book_recommender/recommender.py` |
| ML retraining | `ml/notebooks/features/user_book_recommender/retrain.py` |
| ML notebooks/artifacts | `ml/notebooks/features/user_book_recommender/good_reads_books_100k.ipynb`, `*.pkl` |

Note: the checked-in SQL files are older than the effective backend schema. They define the initial user/book/genre tables, while the current controllers and seed scripts also depend on `book_id`, inventory, librarian, read-history, recommendation, and trend tables. The ERD below documents the effective schema implied by the active backend code.

## System Context

```mermaid
flowchart LR
  Reader[Reader] --> Flutter[Flutter App]
  Librarian[Librarian] --> Flutter

  Flutter -->|REST JSON via Dio/Retrofit| Node[Node.js Express API<br/>port 5000]
  Node -->|mysql2 pool| MySQL[(MySQL<br/>readiculous)]
  Node -->|POST /recommend<br/>POST /suggest<br/>POST /reload| ML[Python Flask ML Service<br/>port 6000]
  ML -->|read user_reads<br/>for CF count/training| MySQL
  ML -->|load CSV| CSV[(GoodReads 100k CSV)]
  ML -->|load/save joblib| Artifacts[(Model artifacts<br/>xgb, encoders, tfidf, cf)]
  Node -->|lookup missing ISBN metadata| GoogleBooks[Google Books API]
```

## Runtime Startup

```mermaid
sequenceDiagram
  participant App as Flutter app
  participant Env as AppEnv
  participant Prefs as SharedPreferences
  participant API as Node API
  participant ML as Flask ML

  App->>Env: bootstrap(dev or prod)
  Env-->>App: apiBaseUrl and mlBaseUrl
  App->>Prefs: load session keys
  App->>API: optional silent login with cached credentials
  API-->>App: user_id, role
  App->>API: warm libraries/current user/current library cache
  API-->>App: cached data
  Note over API,ML: root npm start runs backend and ML together
```

## Frontend Feature-First Architecture

The Flutter app is organized by feature under `frontend/lib/core/features`. Shared cross-cutting code lives in `core/config`, `core/routing`, `core/session`, `core/network`, `core/cache`, `core/theme`, `core/utils`, and `core/widgets`.

```mermaid
flowchart TB
  subgraph App["Flutter application"]
    Bootstrap["app_bootstrap.dart<br/>ProviderContainer, splash, cache warmup"]
    Router["routing.dart<br/>go_router auth redirects"]
    Session["session/*<br/>Riverpod session state"]
    Network["network/*<br/>Dio + Retrofit clients"]
    Cache["cache/*<br/>SharedPreferences cache"]
  end

  subgraph Features["core/features"]
    Auth["authentication<br/>data/domain/presentation"]
    Home["home<br/>data/domain/presentation"]
    LibraryDB["library_database<br/>presentation/providers"]
    MyBooks["my_books<br/>reading list"]
    Suggested["suggested_books<br/>user/library recs"]
    Inventory["library_inventory<br/>librarian stock management"]
    Trends["genre_trends<br/>trend display"]
    Preferences["genre_preferences<br/>preference editing"]
    Association["library_association<br/>reader/library link"]
    Settings["settings<br/>profile/logout"]
  end

  Bootstrap --> Session
  Bootstrap --> Router
  Bootstrap --> Cache
  Router --> Features
  Features --> Network
  Features --> Session
  Features --> Cache
  Network --> NodeAPI["Node API /api"]
```

### Feature Layer Pattern

```mermaid
flowchart LR
  Page["Presentation page/widget"] --> Provider["Riverpod provider/controller"]
  Provider --> UseCase["Domain use case/repository interface<br/>(where present)"]
  UseCase --> RepoImpl["Data repository implementation"]
  Provider --> Client["Retrofit/Dio API client"]
  RepoImpl --> Client
  Client --> Backend["Express REST API"]
```

Examples:

| Feature | UI | State/API path |
| --- | --- | --- |
| Login/register | `authentication/presentation/pages/*` | `LoginController -> AuthRepositoryImpl -> AuthRemoteDataSource -> /users/login` |
| Session restore | `app_bootstrap.dart` | `SessionBootstrap -> AuthRemoteDataSource -> /users/login` |
| Library lookup | `home` | `userLibraryProvider -> HomeRepositoryImpl -> /users/:user_id/library` |
| My books | `my_books` | `myBooksProvider -> ReadsApiClient -> /reads` |
| User recommendations | `suggested_books` | `UserRecommendationsController -> /recommendations/users/:user_id/generate` |
| Library recommendations | `suggested_books` | `LibraryRecommendationsController -> /recommendations/libraries/:library_id` |
| Inventory | `library_inventory` | `LibraryInventoryNotifier -> /library-books` |
| Trends | `genre_trends` | `GenreTrendsNotifier -> /trends/top?library_id=...` |

## Backend Architecture

`backend/src/index.js` creates the Express app, applies CORS and JSON middleware, logs requests, and mounts domain route modules under `/api`.

```mermaid
flowchart TB
  Express["Express app<br/>backend/src/index.js"] --> Middleware["cors, express.json, request logger"]

  Middleware --> Routes["Route modules<br/>backend/src/routes"]
  Routes --> Controllers["Controllers<br/>backend/src/controllers"]
  Controllers --> DBPool["mysql2/promise pool<br/>backend/src/config/db.js"]
  Controllers --> MLService["mlService.js<br/>Axios to Flask"]
  Controllers --> GoogleBooks["googleBooksService.js<br/>ISBN metadata"]
  DBPool --> MySQL[(MySQL)]
  MLService --> Flask["Flask ML service"]
  GoogleBooks --> External["Google Books API"]
```

### Backend Domain Endpoints

| Domain | Route prefix | Responsibility |
| --- | --- | --- |
| Users/auth | `/api/users` | create/login/delete users, role updates, user-library association, preference aggregation |
| Genres | `/api/genres` | genre CRUD |
| User genres | `/api/user-genres` | reader genre preferences |
| Books | `/api/books` | book CRUD |
| Book genres | `/api/book-genres` | book-to-genre links |
| Libraries | `/api/libraries` | library list/create and reader activity |
| Library inventory | `/api/library-books` | library book stock records |
| Librarians | `/api/librarians` | librarian assignment and verification |
| Reads | `/api/reads` | user reading list/status/rating |
| Recommendations | `/api/recommendations` | saved and generated user/library recommendations |
| Trends | `/api/trends` | genre trend persistence and reporting |
| ML operations | `/api/ml` | retrain trigger and model reload orchestration |

## Database Model

```mermaid
erDiagram
  USERS {
    varchar user_id PK
    varchar first_name
    varchar last_name
    enum role
    date date_of_birth
    varchar location
    varchar email UK
    varchar phone
    varchar password
    timestamp created_at
  }

  LIBRARIES {
    bigint library_id PK
    varchar name
    varchar location
    varchar phone
    varchar website
    varchar county
    varchar state
    varchar zip
    varchar address
    boolean is_public
    timestamp created_at
    timestamp updated_at
  }

  GENRES {
    int genre_id PK
    varchar name UK
  }

  BOOKS {
    int book_id PK
    varchar isbn13 UK
    text title
    text author
    text description
    varchar cover_url
    timestamp created_at
    timestamp updated_at
  }

  USER_LIBRARIES {
    varchar user_id PK FK
    bigint library_id FK
    timestamp created_at
    timestamp updated_at
  }

  LIBRARIANS {
    varchar user_id FK
    bigint library_id FK
    boolean verified
    timestamp created_at
  }

  USER_GENRES {
    varchar user_id FK
    int genre_id FK
  }

  BOOK_GENRES {
    int book_id FK
    int genre_id FK
  }

  LIBRARY_BOOKS {
    bigint library_id FK
    int book_id FK
    int copies_total
    int copies_available
    int low_stock_threshold
    boolean is_deleted
  }

  USER_READS {
    varchar user_id FK
    int book_id FK
    enum status
    float rating
    timestamp created_at
    timestamp updated_at
  }

  USER_RECOMMENDATIONS {
    int recommendation_id PK
    varchar user_id FK
    int book_id FK
    float score
    text reason
    timestamp created_at
    timestamp updated_at
  }

  LIBRARY_RECOMMENDATIONS {
    int recommendation_id PK
    bigint library_id FK
    int book_id FK
    float demand_score
    enum demand_level
    text reason
    enum state
    timestamp created_at
    timestamp updated_at
  }

  GENRE_TRENDS {
    bigint library_id FK
    int genre_id FK
    float score
    timestamp captured_at
  }

  USERS ||--o| USER_LIBRARIES : "reader belongs to"
  LIBRARIES ||--o{ USER_LIBRARIES : "has readers"
  USERS ||--o{ LIBRARIANS : "may manage"
  LIBRARIES ||--o{ LIBRARIANS : "has librarians"
  USERS ||--o{ USER_GENRES : "prefers"
  GENRES ||--o{ USER_GENRES : "selected by"
  BOOKS ||--o{ BOOK_GENRES : "classified as"
  GENRES ||--o{ BOOK_GENRES : "classifies"
  LIBRARIES ||--o{ LIBRARY_BOOKS : "stocks"
  BOOKS ||--o{ LIBRARY_BOOKS : "stocked in"
  USERS ||--o{ USER_READS : "logs"
  BOOKS ||--o{ USER_READS : "read event"
  USERS ||--o{ USER_RECOMMENDATIONS : "receives"
  BOOKS ||--o{ USER_RECOMMENDATIONS : "recommended"
  LIBRARIES ||--o{ LIBRARY_RECOMMENDATIONS : "receives"
  BOOKS ||--o{ LIBRARY_RECOMMENDATIONS : "recommended"
  LIBRARIES ||--o{ GENRE_TRENDS : "tracks"
  GENRES ||--o{ GENRE_TRENDS : "trend score"
```

### Database Creation and Seeding

```mermaid
flowchart TB
  SQL["database/schema.sql<br/>backend/src/utils/readiculous.sql"] --> BaseTables["Initial tables:<br/>libraries, users, genres,<br/>user_genres, user_libraries,<br/>books, book_genres, ratings"]
  SeedDemo["backend/scripts/seed_demo_data.js"] --> EffectiveTables["Effective app tables:<br/>librarians, library_books,<br/>user_reads, user_recommendations,<br/>library_recommendations, genre_trends"]
  SeedCatalog["backend/scripts/seed_books_catalog.js"] --> Books["Seed books + book_genres"]
  SeedCatalog --> Inventory["Seed library_books inventory"]
  ImportCSV["backend/scripts/import_books_from_csv.py"] --> Books
  BaseTables --> MySQL[(MySQL readiculous)]
  EffectiveTables --> MySQL
  Books --> MySQL
  Inventory --> MySQL
```

## Use Case View

```mermaid
flowchart LR
  Reader((Reader))
  Librarian((Librarian))

  Reader --> Login([Login or register])
  Reader --> ChooseLibrary([Choose home library])
  Reader --> SetPrefs([Set genre preferences])
  Reader --> BrowseCatalog([Browse library catalog])
  Reader --> LogReads([Log reading status and rating])
  Reader --> GetUserRecs([Generate personal recommendations])

  Librarian --> Login
  Librarian --> ManageInventory([Manage inventory])
  Librarian --> ViewActivity([View reader activity])
  Librarian --> ViewTrends([View genre trends])
  Librarian --> GenerateLibraryRecs([Generate library recommendations])
  Librarian --> UpdateState([Mark recommendations NEW, ORDERED, STOCKED, IGNORED])

  LogReads --> Signals[(User read/rating signals)]
  SetPrefs --> Signals
  UpdateState --> Feedback[(Librarian feedback signals)]
  Signals --> ML([ML recommendation engine])
  Feedback --> ML
```

## Reader Activity Flow

```mermaid
flowchart TD
  A([Open app]) --> B{Saved session?}
  B -- no --> C[Login or register]
  B -- yes --> D[Restore session]
  C --> E[Save session in SharedPreferences]
  D --> F{Reader has genre prefs?}
  E --> F
  F -- no --> G[Preferred genre onboarding]
  G --> H[POST /api/user-genres]
  H --> I[Mark has_genre_prefs=true]
  F -- yes --> J[Home page]
  I --> J
  J --> K[Browse library catalog]
  K --> L[Add/update reading status]
  L --> M[POST /api/reads]
  M --> N[(user_reads)]
  J --> O[Generate recommendations]
  O --> P[POST /api/recommendations/users/:user_id/generate]
  P --> Q[Backend calls Flask /recommend]
  Q --> R[(user_recommendations)]
  R --> S[User recommendation UI]
```

## Librarian Activity Flow

```mermaid
flowchart TD
  A([Librarian logs in]) --> B[Get associated library]
  B --> C[Dashboard/home]
  C --> D[View inventory]
  D --> E[GET /api/library-books/:library_id]
  C --> F[View reader activity]
  F --> G[GET /api/libraries/:library_id/activity]
  C --> H[View trends]
  H --> I[GET /api/trends/top?library_id=...]
  C --> J[Generate library recommendations]
  J --> K[POST /api/recommendations/libraries/:library_id/generate]
  K --> L[Compute weighted genres from members]
  L --> M[Boost with genre_trends]
  M --> N[Call Flask /recommend]
  N --> O[(library_recommendations)]
  O --> P[Recommendation list]
  P --> Q[Set state ORDERED/STOCKED/IGNORED]
  Q --> R[PATCH /api/recommendations/libraries/:recommendation_id]
  R --> S[Apply trend feedback delta]
  S --> T[(genre_trends)]
```

## User Recommendation Sequence

```mermaid
sequenceDiagram
  participant UI as Flutter Suggested Books UI
  participant Ctrl as UserRecommendationsController
  participant API as Express recommendationsController
  participant DB as MySQL
  participant ML as Flask /recommend
  participant GB as Google Books API

  UI->>Ctrl: generate(topN)
  Ctrl->>API: POST /api/recommendations/users/:user_id/generate
  API->>DB: SELECT user genre preferences
  DB-->>API: genre names
  API->>ML: POST /recommend {genres, user_id, top_n}
  ML->>DB: count user_reads for CF interaction level
  ML-->>API: ranked books with isbn13 and final_score
  loop each recommendation
    API->>DB: SELECT book_id WHERE isbn13 = ?
    alt missing book
      API->>GB: fetch metadata by ISBN
      GB-->>API: title, author, description, cover_url
      API->>DB: INSERT books
    end
    API->>DB: INSERT/UPDATE user_recommendations
  end
  API-->>Ctrl: generated recommendations
  Ctrl->>API: GET /api/recommendations/users/:user_id
  API->>DB: join recommendations with books and genres
  API-->>UI: saved recommendation list
```

## Library Recommendation Sequence

```mermaid
sequenceDiagram
  participant UI as Flutter Librarian UI
  participant API as Express recommendationsController
  participant DB as MySQL
  participant ML as Flask /recommend
  participant GB as Google Books API

  UI->>API: POST /api/recommendations/libraries/:library_id/generate
  API->>DB: verify library exists
  API->>DB: SELECT user_ids FROM user_libraries
  API->>DB: read user_reads stats
  API->>DB: read user_genres
  API->>API: compute weighted genre scores
  API->>DB: read genre_trends for library
  API->>API: boost top genres with trend scores
  API->>ML: POST /recommend {genres: topGenreNames, user_id: null}
  ML-->>API: content-ranked books
  loop each book
    API->>DB: resolve isbn13 to book_id
    alt not in books table
      API->>GB: fetch metadata by ISBN
      API->>DB: INSERT books
    end
    API->>DB: INSERT/UPDATE library_recommendations state NEW
  end
  API-->>UI: top_genres and saved recommendations
```

## Recommendation Feedback Loop

```mermaid
flowchart LR
  ReaderPrefs["Reader genre preferences<br/>user_genres"] --> WeightedGenres
  ReaderReads["Reader statuses/ratings<br/>user_reads"] --> WeightedGenres
  TrendScores["Existing trend scores<br/>genre_trends"] --> WeightedGenres
  WeightedGenres["Backend weighted genre scoring"] --> LibraryRecs["library_recommendations"]
  LibrarianAction["Librarian changes recommendation state"] --> StatePatch["PATCH recommendation state"]
  StatePatch --> Delta["STOCKED +0.5<br/>ORDERED +0.3<br/>IGNORED -0.3<br/>NEW 0"]
  Delta --> TrendScores
  ReaderReads --> Retrain["/api/ml/retrain"]
  LibraryRecs --> Retrain
  Retrain --> Artifacts["Updated model artifacts"]
  Artifacts --> Reload["POST Flask /reload"]
```

## ML Service Architecture

`recommender.py` is a Flask service. It loads the GoodReads CSV, cleans the data, loads model artifacts, and exposes recommendation endpoints.

```mermaid
flowchart TB
  Startup["Flask startup"] --> Env["Load env from backend/.env or ml/.env"]
  Env --> CSV["Read GOODREADS_CSV"]
  CSV --> Clean["Clean rows:<br/>required features, numeric types,<br/>latin-title filter, computed isbn13"]
  Clean --> LoadModels["Load joblib artifacts:<br/>xgb_model.pkl,<br/>le_author.pkl,<br/>le_format.pkl,<br/>tfidf_vectorizer.pkl,<br/>cf_model.pkl if present"]
  LoadModels --> API["Expose Flask routes"]

  API --> Recommend["POST /recommend"]
  API --> Suggest["POST /suggest"]
  API --> Compare["POST /compare"]
  API --> Reload["POST /reload"]
```

### ML Scoring Logic

```mermaid
flowchart TD
  A["Input genres + optional user_id"] --> B["Normalize genres"]
  B --> C["Build candidates by genre match"]
  C --> D["XGBoost score<br/>metadata/popularity features"]
  C --> E["TF-IDF cosine similarity<br/>genre profile from descriptions"]
  D --> F["Content score<br/>0.8 xgb + 0.2 tfidf"]
  E --> F
  A --> G{user_id and CF model?}
  G -- no --> H["final_score = content_score"]
  G -- yes --> I["Count user_reads interactions"]
  I --> J{interaction count}
  J -->|less than 5| K["content 1.0 / CF 0.0"]
  J -->|5 to 14| L["content 0.7 / CF 0.3"]
  J -->|15 or more| M["content 0.4 / CF 0.6"]
  K --> N["Blend final_score"]
  L --> N
  M --> N
  F --> N
  N --> O["Sort descending"]
  O --> P["Apply per-genre cap"]
  P --> Q["Return top_n books"]
```

### ML Endpoint Responsibilities

| Endpoint | Used by | Responsibility |
| --- | --- | --- |
| `POST /recommend` | Backend user/library generation and some older frontend service methods | Takes genres and optional `user_id`; returns top-N content or hybrid recommendations |
| `POST /suggest` | Older frontend/service flow and documented backend service method | Aggregates user preference payloads, picks top genres, returns recommendations |
| `POST /compare` | ML testing/evaluation | Returns content-only, CF-only, and hybrid results side by side |
| `POST /reload` | Backend retraining controller | Reloads joblib artifacts into the running Flask process |
| `GET /` | Health/info | Returns service name and CF availability |

## ML Retraining Pipeline

`retrain.py` merges production signals from MySQL with the Kaggle baseline, retrains XGBoost and collaborative filtering models when enough data exists, and writes model artifacts in place.

```mermaid
flowchart TD
  A["POST /api/ml/retrain"] --> B["Node spawns python retrain.py"]
  B --> C["Validate env:<br/>DB_HOST, DB_USER, DB_PASSWORD,<br/>DB_NAME, GOODREADS_CSV"]
  C --> D["Pull MySQL quality signals:<br/>user_reads ratings + library recommendation states"]
  C --> E["Pull CF interactions:<br/>user_id, isbn13, effective_rating"]
  D --> F["Build training data:<br/>GoodReads CSV + MySQL-only rated books"]
  F --> G["Engineer features:<br/>logs, popularity, review ratio,<br/>label encoders, genre dummies"]
  G --> H{enough XGB signals?}
  H -- yes --> I["Train XGBoost classifier"]
  H -- no --> J["Skip XGBoost"]
  E --> K{enough CF interactions?}
  K -- yes --> L["Train Surprise SVD"]
  K -- no --> M["Skip CF"]
  I --> N["Save xgb_model.pkl + encoders"]
  L --> O["Save cf_model.pkl"]
  J --> P["Emit JSON result"]
  M --> P
  N --> P
  O --> P
  P --> Q["Node parses JSON"]
  Q --> R["POST Flask /reload"]
```

## Notebook and Model Artifact Workflow

```mermaid
flowchart LR
  Notebook["good_reads_books_100k.ipynb<br/>initial experimentation/training"] --> Artifacts["xgb_model.pkl<br/>le_author.pkl<br/>le_format.pkl<br/>tfidf_vectorizer.pkl"]
  TestNotebook["test_pipeline.ipynb"] --> Validation["Manual pipeline validation"]
  Retrain["retrain.py<br/>production feedback retraining"] --> Artifacts
  Artifacts --> Recommender["recommender.py<br/>Flask runtime"]
  Recommender --> Backend["Node backend"]
```

## End-to-End Data Pipeline

```mermaid
flowchart TB
  subgraph Frontend["Flutter"]
    UI["Pages/widgets"]
    Providers["Riverpod providers/controllers"]
    Clients["Dio/Retrofit clients"]
  end

  subgraph Backend["Node.js Express"]
    Routes["routes"]
    Controllers["controllers"]
    Services["mlService/googleBooksService"]
  end

  subgraph Data["MySQL"]
    Identity["users, libraries, librarians, user_libraries"]
    Catalog["books, genres, book_genres, library_books"]
    Signals["user_genres, user_reads, genre_trends"]
    Outputs["user_recommendations, library_recommendations"]
  end

  subgraph ML["Python Flask"]
    CleanedCSV["cleaned GoodReads dataframe"]
    Content["XGBoost + TF-IDF content ranker"]
    CF["Surprise SVD collaborative filter"]
    Hybrid["Dynamic hybrid blender"]
  end

  UI --> Providers --> Clients --> Routes --> Controllers
  Controllers --> Identity
  Controllers --> Catalog
  Controllers --> Signals
  Controllers --> Services
  Services --> ML
  ML --> CleanedCSV
  ML --> Content
  ML --> CF
  Content --> Hybrid
  CF --> Hybrid
  Hybrid --> Services
  Controllers --> Outputs
  Outputs --> Clients --> Providers --> UI
```

## Key Workflows by Feature

### Authentication and Session

1. User submits login/register from Flutter authentication pages.
2. `AuthRemoteDataSource` calls `/api/users/login` or `/api/users/create`.
3. Backend hashes passwords on create and verifies with bcrypt on login.
4. Flutter stores `user_id`, `role`, email, and cached password/session keys in `SharedPreferences`.
5. `go_router` redirects based on `SessionState`:
   - guests can only access login/register;
   - logged-in readers without genre preferences go to `/preferred_location`;
   - logged-in users with complete setup go to `/home_page`.

### Reader Preferences

1. Flutter loads all genres with `GET /api/genres`.
2. Reader selects genres.
3. Flutter posts `{user_id, genre_ids}` to `/api/user-genres`.
4. Backend inserts rows into `user_genres`.
5. Session marks `has_genre_prefs=true` to unlock the main app.

### Reading List

1. Flutter calls `GET /api/reads/:user_id` to load reading status.
2. Reader saves a status/rating through `POST /api/reads`.
3. Backend upserts `user_reads`.
4. `user_reads` becomes both a product feature and an ML feedback signal.

### Library Inventory

1. Flutter resolves the current user's library with `/api/users/:user_id/library`.
2. Inventory pages call `GET /api/library-books/:library_id`.
3. Librarians update copy counts and low-stock threshold with `POST /api/library-books`.
4. Backend upserts `library_books`.

### Genre Trends

1. Trend pages call `/api/trends/top?library_id=...` or `/api/trends/libraries/:library_id`.
2. Backend reads `genre_trends`.
3. Library recommendation feedback modifies trends:
   - `STOCKED`: `+0.5`
   - `ORDERED`: `+0.3`
   - `IGNORED`: `-0.3`
   - `NEW`: no signal

## Deployment and Environment

| Component | Default local address | Important env |
| --- | --- | --- |
| Flutter app | device/emulator/browser | `DEV_CONNECTION_MODE`, `DEV_API_HOST`, `DEV_ML_HOST`, `API_BASE_URL`, `ML_BASE_URL` |
| Node API | `http://localhost:5000/api` | `PORT`, `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `ML_SERVICE_URL`, `GOOGLE_BOOKS_API_KEY` |
| Flask ML | `http://localhost:6000` | `GOODREADS_CSV`, `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` |
| MySQL | local MySQL | database `readiculous` |

The root `package.json` starts backend and ML together:

```bash
npm start
```

Backend scripts:

```bash
npm --prefix backend start
npm --prefix backend run seed:demo
npm --prefix backend run seed:catalog
npm --prefix backend run test:user-flow
```

## Known Architecture Notes

1. The frontend mostly calls the Node backend, but `ApiService` still contains older direct Flask calls for `/recommend` and `/suggest`. The current generated recommendation controllers use the backend endpoints, which is the safer production path because it persists recommendations and resolves books.
2. The checked-in SQL files do not fully match the effective schema used by controllers and seed scripts. A future migration should consolidate the full schema into a single source of truth.
3. `ratingRoutes.js` and the empty model files are placeholders. Current ratings are stored on `user_reads.rating`.
4. The backend does not issue JWTs today. Session persistence is client-side through `SharedPreferences` and silent login.
5. Recommendation generation persists results in MySQL, so UI refreshes can fetch saved recommendations without calling ML every time.
