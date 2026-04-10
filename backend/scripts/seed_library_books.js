/**
 * seed_library_books.js
 *
 * Assigns every book to every library with random copy counts.
 * Safe to re-run — uses INSERT IGNORE to skip existing rows.
 *
 * Usage:
 *   node backend/scripts/seed_library_books.js
 */

const db = require("../src/config/db");

async function run() {
  console.log("Fetching libraries and books...");

  const [libraries] = await db.query("SELECT library_id FROM libraries");
  const [books] = await db.query("SELECT book_id FROM books");

  console.log(`Found ${libraries.length} libraries and ${books.length} books.`);
  console.log(`Inserting up to ${libraries.length * books.length} rows...`);

  // Build all (library_id, book_id, copies_total, copies_available) rows
  const rows = [];
  for (const { library_id } of libraries) {
    for (const { book_id } of books) {
      const total = Math.floor(Math.random() * 5) + 1; // 1–5 copies
      const available = Math.floor(Math.random() * total) + 1; // 1–total available
      rows.push([library_id, book_id, total, available]);
    }
  }

  // Batch insert in chunks of 1000 to avoid hitting MySQL packet limits
  const CHUNK = 1000;
  let inserted = 0;
  for (let i = 0; i < rows.length; i += CHUNK) {
    const chunk = rows.slice(i, i + CHUNK);
    const [result] = await db.query(
      `INSERT IGNORE INTO library_books
         (library_id, book_id, copies_total, copies_available)
       VALUES ?`,
      [chunk]
    );
    inserted += result.affectedRows;
    process.stdout.write(`\r  ${i + chunk.length}/${rows.length} processed, ${inserted} inserted`);
  }

  console.log(`\nDone. ${inserted} new rows added.`);
  process.exit(0);
}

run().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});