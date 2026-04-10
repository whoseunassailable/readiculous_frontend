#!/usr/bin/env python3
"""
scrape_libraries.py
Scrapes every public library listed on publiclibraries.com/state/
and upserts the data into the readiculous MySQL `libraries` table.

Source page structure:  <table id="libraries">
Columns per row:        City | Library | Address | Zip | Phone

On first run the script will ADD columns (phone, state, zip, is_public)
to the existing libraries table and create the unique constraint needed
for upserts.  Safe to re-run — all changes are guarded by INFORMATION_SCHEMA
checks so nothing is duplicated.

Dependencies (already in the ML venv):
    requests, beautifulsoup4, lxml, pymysql

Usage:
    # from the ml/ directory
    source .venv/bin/activate
    python ../backend/scripts/scrape_libraries.py

    # override DB credentials via env vars
    DB_HOST=localhost DB_PASSWORD=secret python ../backend/scripts/scrape_libraries.py
"""

import os
import re
import time
import logging
import pymysql
import requests
from bs4 import BeautifulSoup

# ─── Config ──────────────────────────────────────────────────────────────────

DB_CONFIG = {
    "host":     os.getenv("DB_HOST",     "localhost"),
    "user":     os.getenv("DB_USER",     "root"),
    "password": os.getenv("DB_PASSWORD", "Jraonhvain11#"),
    "database": os.getenv("DB_NAME",     "readiculous"),
    "charset":  "utf8mb4",
}

BASE_URL      = "https://publiclibraries.com/state"
REQUEST_DELAY = 1.5  # seconds between page requests

# All 52 state/territory slugs + display names from publiclibraries.com/state/
STATES = [
    ("alabama",             "Alabama"),
    ("alaska",              "Alaska"),
    ("arizona",             "Arizona"),
    ("arkansas",            "Arkansas"),
    ("california",          "California"),
    ("colorado",            "Colorado"),
    ("connecticut",         "Connecticut"),
    ("delaware",            "Delaware"),
    ("district-of-columbia","District of Columbia"),
    ("florida",             "Florida"),
    ("georgia",             "Georgia"),
    ("hawaii",              "Hawaii"),
    ("idaho",               "Idaho"),
    ("illinois",            "Illinois"),
    ("indiana",             "Indiana"),
    ("iowa",                "Iowa"),
    ("kansas",              "Kansas"),
    ("kentucky",            "Kentucky"),
    ("louisiana",           "Louisiana"),
    ("maine",               "Maine"),
    ("maryland",            "Maryland"),
    ("massachusetts",       "Massachusetts"),
    ("michigan",            "Michigan"),
    ("minnesota",           "Minnesota"),
    ("mississippi",         "Mississippi"),
    ("missouri",            "Missouri"),
    ("montana",             "Montana"),
    ("nebraska",            "Nebraska"),
    ("nevada",              "Nevada"),
    ("new-hampshire",       "New Hampshire"),
    ("new-jersey",          "New Jersey"),
    ("new-mexico",          "New Mexico"),
    ("new-york",            "New York"),
    ("north-carolina",      "North Carolina"),
    ("north-dakota",        "North Dakota"),
    ("ohio",                "Ohio"),
    ("oklahoma",            "Oklahoma"),
    ("oregon",              "Oregon"),
    ("pennsylvania",        "Pennsylvania"),
    ("rhode-island",        "Rhode Island"),
    ("south-carolina",      "South Carolina"),
    ("south-dakota",        "South Dakota"),
    ("tennessee",           "Tennessee"),
    ("texas",               "Texas"),
    ("utah",                "Utah"),
    ("vermont",             "Vermont"),
    ("virginia",            "Virginia"),
    ("washington",          "Washington"),
    ("west-virginia",       "West Virginia"),
    ("wisconsin",           "Wisconsin"),
    ("wyoming",             "Wyoming"),
    ("us-virgin-islands",   "US Virgin Islands"),
]

# ─── Logging ─────────────────────────────────────────────────────────────────

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger(__name__)

# ─── Database ────────────────────────────────────────────────────────────────

def connect():
    return pymysql.connect(**DB_CONFIG, autocommit=False)


def ensure_schema(conn):
    """
    Add extra columns + a unique constraint to libraries if they don't exist.
    All operations are guarded by INFORMATION_SCHEMA checks — safe to re-run.
    """
    cur = conn.cursor()

    cur.execute(
        "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS "
        "WHERE TABLE_SCHEMA = %s AND TABLE_NAME = 'libraries'",
        (DB_CONFIG["database"],),
    )
    existing_cols = {row[0] for row in cur.fetchall()}

    new_cols = [
        ("phone",     "VARCHAR(30)"),
        ("website",   "VARCHAR(500)"),
        ("county",    "VARCHAR(150)"),
        ("state",     "VARCHAR(100)"),
        ("zip",       "VARCHAR(10)"),
        ("address",   "VARCHAR(255)"),          # street address separate from location
        ("is_public", "BOOLEAN NOT NULL DEFAULT FALSE"),
    ]
    for col, col_type in new_cols:
        if col not in existing_cols:
            cur.execute(f"ALTER TABLE libraries ADD COLUMN `{col}` {col_type}")
            log.info("Schema: added column `%s`", col)

    # Unique key on (name, state) drives the ON DUPLICATE KEY upsert
    cur.execute(
        "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS "
        "WHERE TABLE_SCHEMA = %s AND TABLE_NAME = 'libraries' "
        "AND CONSTRAINT_NAME = 'uq_library_name_state'",
        (DB_CONFIG["database"],),
    )
    if cur.fetchone()[0] == 0:
        cur.execute(
            "ALTER TABLE libraries "
            "ADD CONSTRAINT uq_library_name_state UNIQUE (name(191), state(100))"
        )
        log.info("Schema: created unique constraint uq_library_name_state")

    conn.commit()
    cur.close()


def upsert_library(cur, lib: dict):
    cur.execute(
        """
        INSERT INTO libraries
            (name, location, address, phone, website, county, state, zip, is_public)
        VALUES
            (%(name)s, %(location)s, %(address)s, %(phone)s, %(website)s,
             %(county)s, %(state)s, %(zip)s, %(is_public)s)
        ON DUPLICATE KEY UPDATE
            location  = VALUES(location),
            address   = VALUES(address),
            phone     = VALUES(phone),
            zip       = VALUES(zip),
            is_public = VALUES(is_public)
        """,
        lib,
    )

# ─── Scraping + parsing ──────────────────────────────────────────────────────

def scrape_state(slug: str, state_name: str, session: requests.Session) -> list[dict]:
    url = f"{BASE_URL}/{slug}/"
    log.info("%-25s  %s", state_name, url)

    try:
        resp = session.get(url, timeout=20)
        resp.raise_for_status()
    except requests.RequestException as exc:
        log.warning("  Could not fetch %s — %s", url, exc)
        return []

    soup = BeautifulSoup(resp.text, "lxml")

    # The page has exactly one <table id="libraries">
    table = soup.find("table", id="libraries")
    if not table:
        log.warning("  No <table id='libraries'> found on %s", url)
        return []

    rows = table.find_all("tr")
    # First row is the header — skip it
    libraries = []
    for row in rows[1:]:
        cells = [td.get_text(strip=True) for td in row.find_all("td")]
        if len(cells) < 5:
            continue  # malformed row

        city, name, address, zip_code, phone = cells[0], cells[1], cells[2], cells[3], cells[4]

        if not name:
            continue

        location = f"{city}, {state_name}"
        if zip_code:
            location += f" {zip_code}"

        libraries.append({
            "name":      name,
            "location":  location,
            "address":   address  or None,
            "phone":     phone    or None,
            "website":   None,    # not provided by this source
            "county":    None,    # not provided by this source
            "state":     state_name,
            "zip":       zip_code or None,
            "is_public": True,    # publiclibraries.com lists only public libraries
        })

    log.info("  → %d libraries found", len(libraries))
    return libraries

# ─── Entry point ─────────────────────────────────────────────────────────────

def main():
    conn = connect()
    log.info(
        "Connected to %s@%s/%s",
        DB_CONFIG["user"], DB_CONFIG["host"], DB_CONFIG["database"],
    )

    ensure_schema(conn)

    session = requests.Session()
    session.headers["User-Agent"] = (
        "Readiculous/1.0 (educational project; public library data aggregator)"
    )

    total_upserted = 0
    total_failed   = 0

    for slug, state_name in STATES:
        libraries = scrape_state(slug, state_name, session)

        if libraries:
            cur = conn.cursor()
            for lib in libraries:
                try:
                    upsert_library(cur, lib)
                    total_upserted += 1
                except Exception as exc:
                    log.warning("  Upsert failed [%s] — %s", lib.get("name", "?"), exc)
                    total_failed += 1
            conn.commit()
            cur.close()

        time.sleep(REQUEST_DELAY)

    conn.close()
    log.info(
        "Done.  Upserted: %d  |  Failed: %d  |  States scraped: %d",
        total_upserted, total_failed, len(STATES),
    )


if __name__ == "__main__":
    main()
