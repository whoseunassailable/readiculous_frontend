const bcrypt = require("bcrypt");
const { v4: uuidv4 } = require("uuid");

const db = require("../src/config/db");

const SALT_ROUNDS = 10;
const DEFAULT_LIBRARY = {
  name: "Chicago Public Library - Chinatown",
  location: "Chicago, IL",
};

const demoUsers = [
  {
    firstName: "Ava",
    lastName: "Martinez",
    email: "ava.reader@readiculous.demo",
    password: "AvaReads123!",
    role: "user",
    location: "Chicago",
    phone: "3125550101",
    dateOfBirth: "1996-04-12",
    preferredGenres: ["Fantasy", "Adventure", "Mystery"],
    reads: [
      { isbn13: "9780756404741", status: "reading", rating: null },
      { isbn13: "9780804139021", status: "want_to_read", rating: null },
      { isbn13: "9780062315007", status: "read", rating: 5 },
    ],
    recommendations: [
      {
        isbn13: "9780525559474",
        score: 0.9621,
        reason: "Strong overlap with fantasy-heavy favorites and current reading streak.",
      },
      {
        isbn13: "9780735219106",
        score: 0.9142,
        reason: "Local readers with similar taste patterns are also circling this title.",
      },
    ],
  },
  {
    firstName: "Noah",
    lastName: "Kim",
    email: "noah.reader@readiculous.demo",
    password: "NoahReads123!",
    role: "user",
    location: "Chicago",
    phone: "3125550102",
    dateOfBirth: "1994-08-03",
    preferredGenres: ["Sci-Fi", "Cyberpunk", "Dystopian"],
    reads: [
      { isbn13: "9780593135204", status: "reading", rating: null },
      { isbn13: "9780441013593", status: "read", rating: 5 },
      { isbn13: "9780451524935", status: "want_to_read", rating: null },
    ],
    recommendations: [
      {
        isbn13: "9780439023481",
        score: 0.9511,
        reason: "High dystopian and sci-fi overlap with recent completed reads.",
      },
      {
        isbn13: "9780307454546",
        score: 0.9017,
        reason: "Mystery-leaning readers in your library are finishing this quickly.",
      },
    ],
  },
  {
    firstName: "Mia",
    lastName: "Johnson",
    email: "mia.reader@readiculous.demo",
    password: "MiaReads123!",
    role: "user",
    location: "Chicago",
    phone: "3125550103",
    dateOfBirth: "1998-01-27",
    preferredGenres: ["Romance", "Drama", "Coming-of-Age"],
    reads: [
      { isbn13: "9780143127741", status: "read", rating: 4 },
      { isbn13: "9780316769488", status: "reading", rating: null },
      { isbn13: "9780141439556", status: "want_to_read", rating: null },
    ],
    recommendations: [
      {
        isbn13: "9781501161933",
        score: 0.9444,
        reason: "Matches your drama and romance preferences closely.",
      },
      {
        isbn13: "9780525559474",
        score: 0.8829,
        reason: "Strong emotional-fiction match based on similar readers.",
      },
    ],
  },
  {
    firstName: "Ethan",
    lastName: "Patel",
    email: "ethan.reader@readiculous.demo",
    password: "EthanReads123!",
    role: "user",
    location: "Chicago",
    phone: "3125550104",
    dateOfBirth: "1992-11-15",
    preferredGenres: ["Crime", "Detective", "Classic"],
    reads: [
      { isbn13: "9780062073488", status: "read", rating: 5 },
      { isbn13: "9780307277671", status: "reading", rating: null },
      { isbn13: "9780141439600", status: "want_to_read", rating: null },
    ],
    recommendations: [
      {
        isbn13: "9780307454546",
        score: 0.9378,
        reason: "Crime and detective fans in your area are rating it highly.",
      },
      {
        isbn13: "9780735219106",
        score: 0.8615,
        reason: "Blends mystery pacing with strong character drama.",
      },
    ],
  },
  {
    firstName: "Sophia",
    lastName: "Nguyen",
    email: "sophia.reader@readiculous.demo",
    password: "SophiaReads123!",
    role: "user",
    location: "Chicago",
    phone: "3125550105",
    dateOfBirth: "1997-06-21",
    preferredGenres: ["Children", "Classic", "Adventure"],
    reads: [
      { isbn13: "9780064404990", status: "read", rating: 5 },
      { isbn13: "9780142407332", status: "reading", rating: null },
      { isbn13: "9780061120084", status: "want_to_read", rating: null },
    ],
    recommendations: [
      {
        isbn13: "9780142407332",
        score: 0.9288,
        reason: "Adventure-driven classic suitable for your current reading pattern.",
      },
      {
        isbn13: "9780439023481",
        score: 0.8442,
        reason: "Popular among younger readers tied to your library.",
      },
    ],
  },
  {
    firstName: "Liam",
    lastName: "Brooks",
    email: "liam.reader@readiculous.demo",
    password: "LiamReads123!",
    role: "user",
    location: "Chicago",
    phone: "3125550106",
    dateOfBirth: "1990-02-09",
    preferredGenres: ["Biography", "Autobiography", "Educational"],
    reads: [
      { isbn13: "9780812981605", status: "read", rating: 4 },
      { isbn13: "9781501127625", status: "reading", rating: null },
      { isbn13: "9780812993547", status: "want_to_read", rating: null },
    ],
    recommendations: [
      {
        isbn13: "9780399590504",
        score: 0.9332,
        reason: "Memoir and education interests align strongly with this title.",
      },
      {
        isbn13: "9781524763138",
        score: 0.9012,
        reason: "Popular local nonfiction pick with strong completion rates.",
      },
    ],
  },
  {
    firstName: "Grace",
    lastName: "Hernandez",
    email: "grace.librarian@readiculous.demo",
    password: "GraceLibrary123!",
    role: "librarian",
    location: "Chicago",
    phone: "3125550199",
    dateOfBirth: "1988-09-14",
    preferredGenres: ["Mystery", "Fantasy", "Classic"],
    reads: [],
    recommendations: [],
  },
];

const libraryRecommendations = [
  {
    isbn13: "9780525559474",
    demandScore: 0.9642,
    demandLevel: "HIGH",
    reason: "Fantasy and drama demand is spiking among nearby readers.",
    state: "NEW",
  },
  {
    isbn13: "9780439023481",
    demandScore: 0.9124,
    demandLevel: "HIGH",
    reason: "Dystopian demand remains strong in current reader activity.",
    state: "ORDERED",
  },
  {
    isbn13: "9780399590504",
    demandScore: 0.7811,
    demandLevel: "MEDIUM",
    reason: "Memoir and educational reading trends suggest solid circulation.",
    state: "STOCKED",
  },
];

const demoBooks = [
  {
    title: "The Name of the Wind",
    author: "Patrick Rothfuss",
    description: "A gifted young man grows into the most notorious wizard his world has ever seen.",
    isbn13: "9780756404741",
    genres: ["Fantasy", "Adventure", "Epic"],
    inventory: { total: 7, available: 3, threshold: 2 },
  },
  {
    title: "Project Hail Mary",
    author: "Andy Weir",
    description: "A lone astronaut wakes up on a desperate mission to save humanity.",
    isbn13: "9780593135204",
    genres: ["Sci-Fi", "Adventure", "Comedy"],
    inventory: { total: 6, available: 2, threshold: 2 },
  },
  {
    title: "Dune",
    author: "Frank Herbert",
    description: "A political and ecological struggle unfolds on the desert planet Arrakis.",
    isbn13: "9780441013593",
    genres: ["Sci-Fi", "Epic", "Drama"],
    inventory: { total: 8, available: 5, threshold: 2 },
  },
  {
    title: "The Seven Husbands of Evelyn Hugo",
    author: "Taylor Jenkins Reid",
    description: "An aging Hollywood icon tells the truth about her glamorous and scandalous life.",
    isbn13: "9781501161933",
    genres: ["Drama", "Romance", "Biography"],
    inventory: { total: 5, available: 1, threshold: 2 },
  },
  {
    title: "The Midnight Library",
    author: "Matt Haig",
    description: "A woman explores alternate versions of her life in a mystical library.",
    isbn13: "9780525559474",
    genres: ["Fantasy", "Drama", "Coming-of-Age"],
    inventory: { total: 6, available: 4, threshold: 2 },
  },
  {
    title: "Where the Crawdads Sing",
    author: "Delia Owens",
    description: "A coming-of-age mystery set in the marshes of North Carolina.",
    isbn13: "9780735219106",
    genres: ["Mystery", "Drama", "Coming-of-Age"],
    inventory: { total: 4, available: 1, threshold: 1 },
  },
  {
    title: "Educated",
    author: "Tara Westover",
    description: "A memoir about self-invention through education.",
    isbn13: "9780399590504",
    genres: ["Autobiography", "Biography", "Educational"],
    inventory: { total: 3, available: 2, threshold: 1 },
  },
  {
    title: "Becoming",
    author: "Michelle Obama",
    description: "The former First Lady reflects on family, work, and public life.",
    isbn13: "9781524763138",
    genres: ["Autobiography", "Biography", "Educational"],
    inventory: { total: 5, available: 3, threshold: 1 },
  },
  {
    title: "The Hunger Games",
    author: "Suzanne Collins",
    description: "A televised fight to the death exposes the cruelty of a dystopian regime.",
    isbn13: "9780439023481",
    genres: ["Dystopian", "Adventure", "Drama"],
    inventory: { total: 7, available: 4, threshold: 2 },
  },
  {
    title: "The Girl with the Dragon Tattoo",
    author: "Stieg Larsson",
    description: "An investigative journalist and a hacker unravel a decades-old disappearance.",
    isbn13: "9780307454546",
    genres: ["Crime", "Mystery", "Detective"],
    inventory: { total: 4, available: 2, threshold: 1 },
  },
  {
    title: "To Kill a Mockingbird",
    author: "Harper Lee",
    description: "A classic novel of justice and conscience in the American South.",
    isbn13: "9780061120084",
    genres: ["Classic", "Drama", "Coming-of-Age"],
    inventory: { total: 6, available: 5, threshold: 2 },
  },
  {
    title: "Little Fires Everywhere",
    author: "Celeste Ng",
    description: "An unraveling suburban family drama centered on motherhood and identity.",
    isbn13: "9780735224315",
    genres: ["Drama", "Mystery", "Classic"],
    inventory: { total: 4, available: 0, threshold: 1 },
  },
];

async function main() {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const libraryId = await ensureLibrary(connection);
    const genreIdByName = await ensureGenres(connection);
    const bookIdByIsbn = await seedBooks(connection, genreIdByName, libraryId);
    const userIdByEmail = await seedUsers(connection, libraryId);
    await seedUserGenres(connection, genreIdByName, userIdByEmail);
    await seedUserReads(connection, bookIdByIsbn, userIdByEmail);
    await seedUserRecommendations(connection, bookIdByIsbn, userIdByEmail);
    await seedLibraryRecommendations(connection, bookIdByIsbn, libraryId);
    await seedTrendRows(connection, genreIdByName, libraryId);

    await connection.commit();

    printCredentials(libraryId);
  } catch (error) {
    await connection.rollback();
    console.error("Demo seed failed:", error);
    process.exitCode = 1;
  } finally {
    connection.release();
    await db.end();
  }
}

async function ensureLibrary(connection) {
  const [existing] = await connection.execute(
    "SELECT library_id FROM libraries WHERE name = ? ORDER BY library_id ASC LIMIT 1",
    [DEFAULT_LIBRARY.name],
  );
  if (existing.length > 0) {
    return existing[0].library_id;
  }

  const [result] = await connection.execute(
    "INSERT INTO libraries (name, location) VALUES (?, ?)",
    [DEFAULT_LIBRARY.name, DEFAULT_LIBRARY.location],
  );
  return result.insertId;
}

async function loadGenreMap(connection) {
  const [rows] = await connection.execute(
    "SELECT genre_id, name FROM genres",
  );
  return new Map(rows.map((row) => [row.name, row.genre_id]));
}

async function ensureGenres(connection) {
  const requiredGenres = new Set();

  for (const book of demoBooks) {
    for (const genre of book.genres) requiredGenres.add(genre);
  }
  for (const user of demoUsers) {
    for (const genre of user.preferredGenres) requiredGenres.add(genre);
  }

  const genreIdByName = await loadGenreMap(connection);

  for (const genreName of requiredGenres) {
    if (genreIdByName.has(genreName)) continue;

    const [result] = await connection.execute(
      "INSERT INTO genres (name) VALUES (?)",
      [genreName],
    );
    genreIdByName.set(genreName, result.insertId);
  }

  return genreIdByName;
}

async function seedBooks(connection, genreIdByName, libraryId) {
  const bookIdByIsbn = new Map();

  for (const book of demoBooks) {
    const [existingRows] = await connection.execute(
      "SELECT book_id FROM books WHERE isbn13 = ? LIMIT 1",
      [book.isbn13],
    );

    let bookId;
    if (existingRows.length > 0) {
      bookId = existingRows[0].book_id;
      await connection.execute(
        `UPDATE books
         SET title = ?, author = ?, description = ?
         WHERE book_id = ?`,
        [book.title, book.author, book.description, bookId],
      );
    } else {
      const [result] = await connection.execute(
        `INSERT INTO books (title, author, description, isbn13)
         VALUES (?, ?, ?, ?)`,
        [book.title, book.author, book.description, book.isbn13],
      );
      bookId = result.insertId;
    }

    bookIdByIsbn.set(book.isbn13, bookId);

    for (const genreName of book.genres) {
      const genreId = genreIdByName.get(genreName);
      if (!genreId) continue;
      await connection.execute(
        `INSERT INTO book_genres (book_id, genre_id)
         VALUES (?, ?)
         ON DUPLICATE KEY UPDATE genre_id = VALUES(genre_id)`,
        [bookId, genreId],
      );
    }

    await connection.execute(
      `INSERT INTO library_books
       (library_id, book_id, copies_total, copies_available, low_stock_threshold, is_deleted)
       VALUES (?, ?, ?, ?, ?, 0)
       ON DUPLICATE KEY UPDATE
         copies_total = VALUES(copies_total),
         copies_available = VALUES(copies_available),
         low_stock_threshold = VALUES(low_stock_threshold),
         is_deleted = 0`,
      [
        libraryId,
        bookId,
        book.inventory.total,
        book.inventory.available,
        book.inventory.threshold,
      ],
    );
  }

  return bookIdByIsbn;
}

async function seedUsers(connection, libraryId) {
  const userIdByEmail = new Map();

  for (const user of demoUsers) {
    const passwordHash = await bcrypt.hash(user.password, SALT_ROUNDS);
    const [existingRows] = await connection.execute(
      "SELECT user_id FROM users WHERE email = ? LIMIT 1",
      [user.email],
    );

    let userId;
    if (existingRows.length > 0) {
      userId = existingRows[0].user_id;
      await connection.execute(
        `UPDATE users
         SET first_name = ?, last_name = ?, role = ?, date_of_birth = ?, location = ?, phone = ?, password = ?
         WHERE user_id = ?`,
        [
          user.firstName,
          user.lastName,
          user.role,
          user.dateOfBirth,
          user.location,
          user.phone,
          passwordHash,
          userId,
        ],
      );
    } else {
      userId = uuidv4();
      await connection.execute(
        `INSERT INTO users
         (user_id, first_name, last_name, role, date_of_birth, location, email, phone, password)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          userId,
          user.firstName,
          user.lastName,
          user.role,
          user.dateOfBirth,
          user.location,
          user.email,
          user.phone,
          passwordHash,
        ],
      );
    }

    userIdByEmail.set(user.email, userId);

    if (user.role === "user") {
      await connection.execute(
        `INSERT INTO user_libraries (user_id, library_id)
         VALUES (?, ?)
         ON DUPLICATE KEY UPDATE library_id = VALUES(library_id), updated_at = CURRENT_TIMESTAMP`,
        [userId, libraryId],
      );
    } else {
      await connection.execute(
        `INSERT INTO librarians (user_id, library_id, verified)
         VALUES (?, ?, 1)
         ON DUPLICATE KEY UPDATE verified = VALUES(verified)`,
        [userId, libraryId],
      );
    }
  }

  return userIdByEmail;
}

async function seedUserGenres(connection, genreIdByName, userIdByEmail) {
  for (const user of demoUsers) {
    const userId = userIdByEmail.get(user.email);
    if (!userId) continue;

    await connection.execute(
      "DELETE FROM user_genres WHERE user_id = ?",
      [userId],
    );

    for (const genreName of user.preferredGenres) {
      const genreId = genreIdByName.get(genreName);
      if (!genreId) continue;
      await connection.execute(
        `INSERT INTO user_genres (user_id, genre_id)
         VALUES (?, ?)
         ON DUPLICATE KEY UPDATE genre_id = VALUES(genre_id)`,
        [userId, genreId],
      );
    }
  }
}

async function seedUserReads(connection, bookIdByIsbn, userIdByEmail) {
  for (const user of demoUsers) {
    if (user.role !== "user") continue;
    const userId = userIdByEmail.get(user.email);
    if (!userId) continue;

    await connection.execute(
      "DELETE FROM user_reads WHERE user_id = ?",
      [userId],
    );

    for (const read of user.reads) {
      const bookId = bookIdByIsbn.get(read.isbn13);
      if (!bookId) continue;
      await connection.execute(
        `INSERT INTO user_reads (user_id, book_id, status, rating)
         VALUES (?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE status = VALUES(status), rating = VALUES(rating)`,
        [userId, bookId, read.status, read.rating],
      );
    }
  }
}

async function seedUserRecommendations(connection, bookIdByIsbn, userIdByEmail) {
  for (const user of demoUsers) {
    if (user.role !== "user") continue;
    const userId = userIdByEmail.get(user.email);
    if (!userId) continue;

    await connection.execute(
      "DELETE FROM user_recommendations WHERE user_id = ?",
      [userId],
    );

    for (const recommendation of user.recommendations ?? []) {
      const bookId = bookIdByIsbn.get(recommendation.isbn13);
      if (!bookId) continue;
      await connection.execute(
        `INSERT INTO user_recommendations (user_id, book_id, score, reason)
         VALUES (?, ?, ?, ?)`,
        [userId, bookId, recommendation.score, recommendation.reason],
      );
    }
  }
}

async function seedLibraryRecommendations(connection, bookIdByIsbn, libraryId) {
  await connection.execute(
    "DELETE FROM library_recommendations WHERE library_id = ?",
    [libraryId],
  );

  for (const recommendation of libraryRecommendations) {
    const bookId = bookIdByIsbn.get(recommendation.isbn13);
    if (!bookId) continue;
    await connection.execute(
      `INSERT INTO library_recommendations
       (library_id, book_id, demand_score, demand_level, reason, state)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        libraryId,
        bookId,
        recommendation.demandScore,
        recommendation.demandLevel,
        recommendation.reason,
        recommendation.state,
      ],
    );
  }
}

async function seedTrendRows(connection, genreIdByName, libraryId) {
  const scores = [
    ["Fantasy", 9.4],
    ["Mystery", 8.9],
    ["Sci-Fi", 8.5],
    ["Drama", 7.7],
    ["Adventure", 7.3],
    ["Classic", 6.8],
  ];

  await connection.execute(
    `DELETE FROM genre_trends
     WHERE library_id = ?
       AND genre_id IN (?, ?, ?, ?, ?, ?)`,
    [
      libraryId,
      genreIdByName.get("Fantasy") ?? 0,
      genreIdByName.get("Mystery") ?? 0,
      genreIdByName.get("Sci-Fi") ?? 0,
      genreIdByName.get("Drama") ?? 0,
      genreIdByName.get("Adventure") ?? 0,
      genreIdByName.get("Classic") ?? 0,
    ],
  );

  for (const [genreName, score] of scores) {
    const genreId = genreIdByName.get(genreName);
    if (!genreId) continue;
    await connection.execute(
      `INSERT INTO genre_trends (library_id, genre_id, score, captured_at)
       VALUES (?, ?, ?, NOW())`,
      [libraryId, genreId, score],
    );
  }
}

function printCredentials(libraryId) {
  console.log("");
  console.log(`Demo data seeded for library_id=${libraryId}`);
  console.log("Known credentials:");
  for (const user of demoUsers) {
    console.log(
      `- ${user.role.toUpperCase()} | ${user.firstName} ${user.lastName} | ${user.email} | ${user.password}`,
    );
  }
}

main();
