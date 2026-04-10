"""
import_books_from_csv.py

Imports the full GoodReads 100k CSV into the readiculous database:
  1. Inserts all ~85k books into the books table
  2. Matches CSV genres to the genres table
  3. Links book_genres
  4. Re-seeds library_books: 300 random books per library
     (existing rows cleared first to avoid stale data)

Usage (from repo root):
  python3 backend/scripts/import_books_from_csv.py

Requires:
  - GOODREADS_CSV env var OR default path in the script
  - pymysql  (pip install pymysql)
"""

import os, csv, sys, random, re
import pymysql
import pymysql.cursors

CSV_PATH = os.getenv(
    "GOODREADS_CSV",
    "/Users/whoseunassailable/Documents/datasets/GoodReads_100k_books.csv",
)

DB = dict(
    host=os.getenv("DB_HOST", "localhost"),
    user=os.getenv("DB_USER", "root"),
    password=os.getenv("DB_PASSWORD", "Jraonhvain11#"),
    database=os.getenv("DB_NAME", "readiculous"),
    charset="utf8mb4",
    cursorclass=pymysql.cursors.DictCursor,
)

BOOKS_PER_LIBRARY = 300   # random books assigned to each library
CHUNK = 500               # insert batch size


# ── helpers ──────────────────────────────────────────────────────────────────

def isbn10_to_isbn13(isbn10: str) -> str | None:
    """Convert ISBN-10 to ISBN-13, return None if input is invalid."""
    clean = re.sub(r"[^0-9Xx]", "", isbn10)
    if len(clean) != 10:
        return None
    # First 9 digits must all be numeric; 10th may be X (check digit)
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


# Map lowercase CSV genre tokens → our genre_id
GENRE_ALIASES: dict[str, str] = {
    "fantasy": "Fantasy",
    "sci-fi": "Sci-Fi", "science fiction": "Sci-Fi", "science-fiction": "Sci-Fi",
    "mystery": "Mystery",
    "romance": "Romance",
    "dystopian": "Dystopian", "dystopia": "Dystopian",
    "horror": "Dark Fantasy",
    "thriller": "Mystery",
    "crime": "Crime",
    "detective": "Detective",
    "adventure": "Adventure",
    "coming-of-age": "Coming-of-Age", "coming of age": "Coming-of-Age",
    "classics": "Classic", "classic": "Classic", "literary fiction": "Classic",
    "historical fiction": "Fiction", "historical": "Fiction",
    "fiction": "Fiction", "literary": "Fiction",
    "biography": "Biography",
    "autobiography": "Autobiography", "memoir": "Autobiography",
    "nonfiction": "Educational", "non-fiction": "Educational",
    "educational": "Educational", "self-help": "Educational",
    "drama": "Drama",
    "gothic": "Gothic",
    "epic": "Epic", "epic fantasy": "Epic",
    "cyberpunk": "Cyberpunk",
    "espionage": "Espionage", "spy": "Espionage",
    "children": "Children", "children's": "Children",
    "comedy": "Comedy", "humor": "Comedy", "humour": "Comedy",
    "chick lit": "Chick Lit", "chick-lit": "Chick Lit",
    "dark fantasy": "Dark Fantasy",
    "anthology": "Anthology",
    "action": "Action",
}


def match_genres(raw_genre: str, name_to_id: dict[str, int]) -> list[int]:
    tokens = [g.strip().lower() for g in raw_genre.split(",")]
    ids = []
    for token in tokens:
        canonical = GENRE_ALIASES.get(token)
        if canonical and canonical in name_to_id:
            gid = name_to_id[canonical]
            if gid not in ids:
                ids.append(gid)
        if len(ids) >= 3:
            break
    return ids


# ── main ─────────────────────────────────────────────────────────────────────

def main():
    conn = pymysql.connect(**DB)

    with conn.cursor() as cur:
        # Load genre lookup
        cur.execute("SELECT genre_id, name FROM genres")
        name_to_id = {r["name"]: r["genre_id"] for r in cur.fetchall()}

    print(f"Reading CSV: {CSV_PATH}")
    books_rows = []
    seen_isbn13 = set()

    with open(CSV_PATH, encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            title  = (row.get("title") or "").strip()
            author = (row.get("author") or "").strip()
            isbn10 = (row.get("isbn")   or "").strip()
            if not title or not author or not isbn10:
                continue
            isbn13 = isbn10_to_isbn13(isbn10)
            if isbn13 and isbn13 in seen_isbn13:
                continue
            if isbn13:
                seen_isbn13.add(isbn13)

            desc      = (row.get("desc") or "").strip() or None
            cover_url = (row.get("img")  or "").strip() or None
            genre_raw = (row.get("genre") or "").strip()
            books_rows.append((title, author, isbn13, desc, cover_url, genre_raw))

    print(f"Parsed {len(books_rows):,} unique books from CSV.")

    # ── 1. Insert books ───────────────────────────────────────────────────
    print("Inserting books…")
    inserted_books = 0
    book_id_cache: dict[str, int] = {}   # isbn13 → book_id

    for i in range(0, len(books_rows), CHUNK):
        chunk = books_rows[i : i + CHUNK]
        with conn.cursor() as cur:
            for (title, author, isbn13, desc, cover_url, _) in chunk:
                cur.execute(
                    """INSERT IGNORE INTO books (title, author, isbn13, description, cover_url)
                       VALUES (%s, %s, %s, %s, %s)""",
                    (title, author, isbn13, desc, cover_url),
                )
                inserted_books += cur.rowcount
        conn.commit()
        pct = min(i + CHUNK, len(books_rows))
        sys.stdout.write(f"\r  {pct:,}/{len(books_rows):,} processed, {inserted_books:,} inserted")

    print(f"\n  {inserted_books:,} new books inserted.")

    # Load book_id for all isbn13s we care about
    print("Loading book IDs…")
    isbn13_list = [b[2] for b in books_rows if b[2]]
    for i in range(0, len(isbn13_list), 1000):
        chunk = isbn13_list[i : i + 1000]
        placeholders = ",".join(["%s"] * len(chunk))
        with conn.cursor() as cur:
            cur.execute(
                f"SELECT book_id, isbn13 FROM books WHERE isbn13 IN ({placeholders})",
                chunk,
            )
            for r in cur.fetchall():
                book_id_cache[r["isbn13"]] = r["book_id"]

    # ── 2. Insert book_genres ─────────────────────────────────────────────
    print("Linking genres…")
    genre_rows = []
    for (_, _, isbn13, _, _, genre_raw) in books_rows:
        if not isbn13 or isbn13 not in book_id_cache:
            continue
        bid = book_id_cache[isbn13]
        for gid in match_genres(genre_raw, name_to_id):
            genre_rows.append((bid, gid))

    genre_inserted = 0
    for i in range(0, len(genre_rows), CHUNK):
        chunk = genre_rows[i : i + CHUNK]
        with conn.cursor() as cur:
            for (bid, gid) in chunk:
                cur.execute(
                    "INSERT IGNORE INTO book_genres (book_id, genre_id) VALUES (%s, %s)",
                    (bid, gid),
                )
                genre_inserted += cur.rowcount
        conn.commit()
    print(f"  {genre_inserted:,} genre links added.")

    # ── 3. Re-seed library_books ──────────────────────────────────────────
    print("Loading libraries and all book IDs…")
    with conn.cursor() as cur:
        cur.execute("SELECT library_id FROM libraries")
        library_ids = [r["library_id"] for r in cur.fetchall()]
        cur.execute("SELECT book_id FROM books")
        all_book_ids = [r["book_id"] for r in cur.fetchall()]

    n_books = min(BOOKS_PER_LIBRARY, len(all_book_ids))
    total_rows = len(library_ids) * n_books
    print(f"  {len(library_ids):,} libraries × {n_books} books = {total_rows:,} rows")
    print("Clearing old library_books…")
    with conn.cursor() as cur:
        cur.execute("DELETE FROM library_books")
    conn.commit()

    print("Inserting new inventory…")
    inv_inserted = 0
    batch = []

    for lib_id in library_ids:
        sample = random.sample(all_book_ids, n_books)
        for book_id in sample:
            total_c    = random.randint(1, 5)
            available  = random.randint(1, total_c)
            batch.append((lib_id, book_id, total_c, available))

        if len(batch) >= CHUNK:
            with conn.cursor() as cur:
                cur.executemany(
                    """INSERT IGNORE INTO library_books
                         (library_id, book_id, copies_total, copies_available)
                       VALUES (%s, %s, %s, %s)""",
                    batch,
                )
            inv_inserted += len(batch)
            conn.commit()
            batch = []
            sys.stdout.write(f"\r  {inv_inserted:,}/{total_rows:,} rows inserted")

    if batch:
        with conn.cursor() as cur:
            cur.executemany(
                """INSERT IGNORE INTO library_books
                     (library_id, book_id, copies_total, copies_available)
                   VALUES (%s, %s, %s, %s)""",
                batch,
            )
        inv_inserted += len(batch)
        conn.commit()

    print(f"\n  {inv_inserted:,} inventory rows inserted.")
    conn.close()
    print("All done.")


if __name__ == "__main__":
    main()
