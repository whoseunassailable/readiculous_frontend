/**
 * seed_books_catalog.js
 *
 * Inserts a catalog of ~100 books across genres, then assigns every book
 * to every library with random copy counts.
 *
 * Safe to re-run — uses INSERT IGNORE throughout.
 *
 * Usage:
 *   node backend/scripts/seed_books_catalog.js
 */

const db = require("../src/config/db");

// genre_id map (from genres table)
const G = {
  Action: 1, Adventure: 2, Autobiography: 5, Biography: 6,
  ChickLit: 8, Children: 7, Classic: 9, Comedy: 10,
  ComingOfAge: 12, Crime: 13, Cyberpunk: 14, DarkFantasy: 15,
  Detective: 16, Drama: 17, Dystopian: 18, Educational: 19,
  Epic: 20, Espionage: 22, Fantasy: 23, Fiction: 24,
  Gothic: 26, Mystery: 36, Romance: 35, SciFi: 34,
};

// [title, author, isbn13, description, [...genre_ids]]
const BOOKS = [
  // ── Fantasy ──────────────────────────────────────────────────────────────
  ["The Name of the Wind", "Patrick Rothfuss", "9780756404741",
   "The riveting first-person narrative of Kvothe, a legendary figure known for his musical talent and magic.",
   [G.Fantasy, G.Epic, G.Adventure]],
  ["A Wizard of Earthsea", "Ursula K. Le Guin", "9780547773742",
   "A young boy discovers he has great powers of magic and sets out to find his destiny.",
   [G.Fantasy, G.Adventure, G.ComingOfAge]],
  ["The Way of Kings", "Brandon Sanderson", "9780765326355",
   "A sweeping epic fantasy set on the world of Roshar, following soldiers, scholars and assassins.",
   [G.Fantasy, G.Epic, G.Action]],
  ["The Lies of Locke Lamora", "Scott Lynch", "9780553588941",
   "A con artist and his crew pull elaborate heists in a city ruled by crime lords.",
   [G.Fantasy, G.Crime, G.Adventure]],
  ["Mistborn: The Final Empire", "Brandon Sanderson", "9780765311788",
   "A heist crew plans to overthrow an immortal emperor in a world where ash falls from the sky.",
   [G.Fantasy, G.Epic, G.Action]],
  ["The Priory of the Orange Tree", "Samantha Shannon", "9781635570298",
   "A world divided by ancient religions, female knights, and dragon riders.",
   [G.Fantasy, G.Epic, G.Romance]],
  ["Jonathan Strange & Mr Norrell", "Susanna Clarke", "9781582344164",
   "Two magicians struggle to bring magic back to England during the Napoleonic Wars.",
   [G.Fantasy, G.Gothic, G.Fiction]],

  // ── Sci-Fi ───────────────────────────────────────────────────────────────
  ["Project Hail Mary", "Andy Weir", "9780593135204",
   "A lone astronaut must save Earth from a distant star's dwindling light.",
   [G.SciFi, G.Adventure, G.Fiction]],
  ["Dune", "Frank Herbert", "9780441013593",
   "A desert planet holds the key to an intergalactic empire's most valuable resource.",
   [G.SciFi, G.Epic, G.Adventure]],
  ["The Martian", "Andy Weir", "9780804139021",
   "An astronaut stranded on Mars must science his way to survival.",
   [G.SciFi, G.Adventure, G.Comedy]],
  ["Ender's Game", "Orson Scott Card", "9780812550702",
   "A child genius is trained at a military school in space to fight an alien invasion.",
   [G.SciFi, G.Action, G.ComingOfAge]],
  ["Hyperion", "Dan Simmons", "9780553283686",
   "Seven pilgrims share their stories on a journey to the mysterious Time Tombs.",
   [G.SciFi, G.Epic, G.Mystery]],
  ["Blindsight", "Peter Watts", "9780765319647",
   "A crew of specialists travels to the edge of the solar system to investigate an alien signal.",
   [G.SciFi, G.Drama, G.Action]],
  ["Neuromancer", "William Gibson", "9780441569595",
   "A burned-out computer hacker is recruited for one last job in the sprawling megacity of the future.",
   [G.SciFi, G.Cyberpunk, G.Action]],
  ["Flowers for Algernon", "Daniel Keyes", "9780156030083",
   "The story of Charlie Gordon, a man with an IQ of 68 who undergoes surgery to increase his intelligence.",
   [G.SciFi, G.Drama, G.Fiction]],

  // ── Dystopian ────────────────────────────────────────────────────────────
  ["The Hunger Games", "Suzanne Collins", "9780439023481",
   "A teenager fights for survival in a televised death match in a dystopian future.",
   [G.Dystopian, G.Action, G.Adventure]],
  ["1984", "George Orwell", "9780451524935",
   "A man living under a totalitarian regime falls in love and begins to rebel.",
   [G.Dystopian, G.Classic, G.Fiction]],
  ["Brave New World", "Aldous Huxley", "9780060850524",
   "A future society based on pleasure and conditioning, where one man dares to question everything.",
   [G.Dystopian, G.Classic, G.SciFi]],
  ["The Handmaid's Tale", "Margaret Atwood", "9780385490818",
   "A woman's story of survival in a theocratic totalitarian state.",
   [G.Dystopian, G.Fiction, G.Drama]],
  ["Station Eleven", "Emily St. John Mandel", "9780385353304",
   "Twenty years after a devastating flu kills most of the world's population, a travelling theatre company keeps Shakespeare alive.",
   [G.Dystopian, G.Fiction, G.Drama]],

  // ── Mystery / Crime ───────────────────────────────────────────────────────
  ["The Girl with the Dragon Tattoo", "Stieg Larsson", "9780307454546",
   "A journalist and a hacker team up to investigate a decades-old disappearance.",
   [G.Mystery, G.Crime, G.Detective]],
  ["Gone Girl", "Gillian Flynn", "9780307588364",
   "A man's wife disappears on their anniversary and he quickly becomes the prime suspect.",
   [G.Mystery, G.Crime, G.Drama]],
  ["In the Woods", "Tana French", "9780143113492",
   "A detective investigates a murder that may be linked to a childhood trauma he cannot remember.",
   [G.Mystery, G.Crime, G.Detective]],
  ["Big Little Lies", "Liane Moriarty", "9780425274866",
   "Three women's seemingly perfect lives unravel to the point of murder.",
   [G.Mystery, G.Drama, G.Fiction]],
  ["The Thursday Murder Club", "Richard Osman", "9781984880819",
   "Four retirees at a peaceful village resort solve cold cases—until a real murder occurs.",
   [G.Mystery, G.Crime, G.Comedy]],
  ["Sharp Objects", "Gillian Flynn", "9780307341556",
   "A reporter returns to her hometown to cover the murders of two preteen girls.",
   [G.Mystery, G.Crime, G.Gothic]],
  ["Rebecca", "Daphne du Maurier", "9780380730407",
   "A young bride moves into her husband's mysterious estate, haunted by the memory of his first wife.",
   [G.Mystery, G.Gothic, G.Romance]],

  // ── Romance ───────────────────────────────────────────────────────────────
  ["The Seven Husbands of Evelyn Hugo", "Taylor Jenkins Reid", "9781501139239",
   "An aging Hollywood icon finally tells the truth about her glamorous and scandalous life.",
   [G.Romance, G.Drama, G.Fiction]],
  ["Outlander", "Diana Gabaldon", "9780440212560",
   "A WWII nurse falls back in time to 18th-century Scotland.",
   [G.Romance, G.Adventure, G.Fantasy]],
  ["Me Before You", "Jojo Moyes", "9780143124542",
   "A quirky small-town woman falls for a paralysed man who plans to end his life.",
   [G.Romance, G.Drama, G.Fiction]],
  ["The Notebook", "Nicholas Sparks", "9780446605236",
   "A poor country boy and a rich young woman fall in love despite their differences.",
   [G.Romance, G.Drama, G.Fiction]],
  ["It Ends with Us", "Colleen Hoover", "9781501110368",
   "A young woman's relationship with a charming neurosurgeon forces her to make difficult choices.",
   [G.Romance, G.Drama, G.Fiction]],
  ["Beach Read", "Emily Henry", "9781984806734",
   "Two writers challenge each other to write outside their genres over a summer.",
   [G.Romance, G.Comedy, G.Fiction]],

  // ── Coming-of-Age / Drama ──────────────────────────────────────────────
  ["The Midnight Library", "Matt Haig", "9780525559474",
   "Between life and death there is a library where you can try every life you could have lived.",
   [G.Fiction, G.Drama, G.Fantasy]],
  ["Normal People", "Sally Rooney", "9780571334650",
   "The complex relationship between two school friends as they move through adulthood.",
   [G.Fiction, G.Romance, G.ComingOfAge]],
  ["The Perks of Being a Wallflower", "Stephen Chbosky", "9781451696196",
   "A shy freshman navigates high school through letters to an anonymous stranger.",
   [G.ComingOfAge, G.Drama, G.Fiction]],
  ["To Kill a Mockingbird", "Harper Lee", "9780061935466",
   "A young girl witnesses her father defend a Black man falsely accused of rape in the American South.",
   [G.Classic, G.Drama, G.ComingOfAge]],
  ["The Catcher in the Rye", "J.D. Salinger", "9780316769174",
   "A teenager's disillusionment with the adult world after being expelled from prep school.",
   [G.Classic, G.Fiction, G.ComingOfAge]],
  ["Little Women", "Louisa May Alcott", "9780147514011",
   "Four sisters grow up during and after the Civil War in New England.",
   [G.Classic, G.Drama, G.ComingOfAge]],

  // ── Non-Fiction / Biography / Memoir ──────────────────────────────────
  ["Educated", "Tara Westover", "9780399590504",
   "A woman raises herself out of a survivalist family in the mountains of Idaho to earn a PhD from Cambridge.",
   [G.Autobiography, G.Drama, G.Educational]],
  ["Becoming", "Michelle Obama", "9781524763138",
   "The former First Lady reflects on her roots and her time in the White House.",
   [G.Autobiography, G.Biography, G.Educational]],
  ["Sapiens", "Yuval Noah Harari", "9780062316097",
   "A brief history of humankind, from the Stone Age to the twenty-first century.",
   [G.Educational, G.Biography, G.Fiction]],
  ["The Diary of a Young Girl", "Anne Frank", "9780553296983",
   "The diary kept by Anne Frank while she and her family were hiding from the Nazis.",
   [G.Autobiography, G.Drama, G.Biography]],
  ["When Breath Becomes Air", "Paul Kalanithi", "9780812988406",
   "A neurosurgeon diagnosed with terminal cancer reflects on what makes a life worth living.",
   [G.Autobiography, G.Drama, G.Biography]],
  ["Know My Name", "Chanel Miller", "9780735223707",
   "The survivor in the Stanford sexual assault case tells her full story.",
   [G.Autobiography, G.Drama, G.Biography]],
  ["Born a Crime", "Trevor Noah", "9780399588174",
   "The host of The Daily Show tells the story of growing up mixed-race in apartheid South Africa.",
   [G.Autobiography, G.Comedy, G.Biography]],

  // ── Classic Literature ─────────────────────────────────────────────────
  ["Pride and Prejudice", "Jane Austen", "9780141439518",
   "A witty story of love and marriage in early 19th-century England.",
   [G.Classic, G.Romance, G.Fiction]],
  ["Crime and Punishment", "Fyodor Dostoevsky", "9780140449136",
   "A student murders a pawnbroker and wrestles with guilt and paranoia in St. Petersburg.",
   [G.Classic, G.Crime, G.Drama]],
  ["The Great Gatsby", "F. Scott Fitzgerald", "9780743273565",
   "The tragic story of Jay Gatsby's obsessive quest for the American Dream.",
   [G.Classic, G.Fiction, G.Drama]],
  ["Moby-Dick", "Herman Melville", "9780142437247",
   "A sailor's obsessive quest to kill the white whale that took his leg.",
   [G.Classic, G.Adventure, G.Epic]],
  ["One Hundred Years of Solitude", "Gabriel García Márquez", "9780060883287",
   "Seven generations of the Buendía family in the mythical town of Macondo.",
   [G.Classic, G.Fiction, G.Fantasy]],
  ["Jane Eyre", "Charlotte Brontë", "9780141441146",
   "An orphaned governess falls in love with her brooding employer in Victorian England.",
   [G.Classic, G.Romance, G.Gothic]],

  // ── Thriller / Espionage ───────────────────────────────────────────────
  ["Where the Crawdads Sing", "Delia Owens", "9780735224292",
   "The story of an abandoned girl raised by the marshes of North Carolina who becomes a suspect in a murder.",
   [G.Mystery, G.Drama, G.Romance]],
  ["The Da Vinci Code", "Dan Brown", "9780307474278",
   "A Harvard professor and a French cryptologist unravel a conspiracy hidden in Leonardo da Vinci's art.",
   [G.Espionage, G.Mystery, G.Action]],
  ["Gone Girl", "Gillian Flynn", "9780307588371",
   "On their fifth wedding anniversary, Nick Dunne's wife Amy mysteriously disappears.",
   [G.Mystery, G.Crime, G.Drama]],
  ["The Bourne Identity", "Robert Ludlum", "9780553260783",
   "An amnesiac found floating in the Mediterranean discovers he is a trained assassin.",
   [G.Espionage, G.Action, G.Mystery]],
  ["All the Light We Cannot See", "Anthony Doerr", "9781476746586",
   "A blind French girl and a German boy's paths collide in occupied France during WWII.",
   [G.Fiction, G.Drama, G.Action]],

  // ── Adventure ─────────────────────────────────────────────────────────
  ["Life of Pi", "Yann Martel", "9780156027328",
   "A boy survives a shipwreck and shares a lifeboat with a Bengal tiger.",
   [G.Adventure, G.Fiction, G.Drama]],
  ["Into the Wild", "Jon Krakauer", "9780385486804",
   "A young man walks deep into the Alaskan wilderness with little supplies and never returns.",
   [G.Adventure, G.Autobiography, G.Drama]],
  ["The Alchemist", "Paulo Coelho", "9780062315007",
   "A young shepherd travels from Spain to Egypt in search of treasure and his Personal Legend.",
   [G.Adventure, G.Fiction, G.Fantasy]],
  ["Around the World in Eighty Days", "Jules Verne", "9781503215153",
   "An English gentleman wagers he can circle the globe in eighty days.",
   [G.Adventure, G.Classic, G.Action]],

  // ── Dark Fantasy / Gothic ─────────────────────────────────────────────
  ["American Gods", "Neil Gaiman", "9780062572110",
   "An ex-convict joins forces with old gods fighting new gods in modern America.",
   [G.DarkFantasy, G.Fantasy, G.Adventure]],
  ["Dracula", "Bram Stoker", "9780141439846",
   "A Transylvanian vampire attempts to move from Transylvania to England so he may find new blood.",
   [G.Gothic, G.Classic, G.DarkFantasy]],
  ["Frankenstein", "Mary Shelley", "9780141439471",
   "A young scientist creates a sapient creature and then struggles with the consequences.",
   [G.Gothic, G.Classic, G.SciFi]],
  ["The Picture of Dorian Gray", "Oscar Wilde", "9780141439570",
   "A young man's portrait ages in his place while he remains young and pursues a hedonistic life.",
   [G.Gothic, G.Classic, G.Drama]],

  // ── Fiction / Literary ────────────────────────────────────────────────
  ["Little Fires Everywhere", "Celeste Ng", "9780735224292",
   "Two families in an idyllic Ohio suburb collide as secrets come to light.",
   [G.Fiction, G.Drama, G.Mystery]],
  ["The Kite Runner", "Khaled Hosseini", "9781594631931",
   "The story of an unlikely friendship between a wealthy boy and the son of his father's servant in Afghanistan.",
   [G.Fiction, G.Drama, G.ComingOfAge]],
  ["A Thousand Splendid Suns", "Khaled Hosseini", "9781594483073",
   "Two Afghan women endure decades of civil war and Taliban rule.",
   [G.Fiction, G.Drama, G.Romance]],
  ["The Book Thief", "Markus Zusak", "9780375842207",
   "A girl living in Nazi Germany steals books and shares them with her neighbours.",
   [G.Fiction, G.Drama, G.ComingOfAge]],
  ["Pachinko", "Min Jin Lee", "9781455563920",
   "Four generations of a Korean family navigate love, sacrifice and ambition in Japan.",
   [G.Fiction, G.Drama, G.Epic]],
  ["Piranesi", "Susanna Clarke", "9781635575637",
   "A man lives in a mysterious house of infinite halls and tides, keeping meticulous journals.",
   [G.Fiction, G.Mystery, G.Fantasy]],
  ["Anxious People", "Fredrik Backman", "9781501160844",
   "A failed bank robber takes a group of strangers hostage at an open house.",
   [G.Fiction, G.Comedy, G.Drama]],
  ["Tomorrow, and Tomorrow, and Tomorrow", "Gabrielle Zevin", "9780593321201",
   "Two friends and collaborators build a video game company over thirty years.",
   [G.Fiction, G.Drama, G.Romance]],
  ["The Invisible Life of Addie LaRue", "V.E. Schwab", "9780765387561",
   "A woman makes a Faustian bargain to live forever but is forgotten by everyone she meets.",
   [G.Fantasy, G.Fiction, G.Romance]],
  ["Mexican Gothic", "Silvia Moreno-Garcia", "9780525620785",
   "A socialite investigates a creepy mansion in 1950s Mexico after her cousin sends a disturbing letter.",
   [G.Gothic, G.Mystery, G.DarkFantasy]],
  ["House of Leaves", "Mark Z. Danielewski", "9780375703768",
   "A family discovers their house is larger on the inside than the outside.",
   [G.Gothic, G.Mystery, G.DarkFantasy]],
  ["The Shadow of the Wind", "Carlos Ruiz Zafón", "9780143034902",
   "A young boy discovers a mysterious book and uncovers a dark secret in post-war Barcelona.",
   [G.Mystery, G.Fiction, G.Gothic]],
];

async function run() {
  // ── 1. Insert books ────────────────────────────────────────────────────
  console.log(`Inserting ${BOOKS.length} books...`);
  let booksInserted = 0;
  for (const [title, author, isbn13, description] of BOOKS) {
    const [r] = await db.query(
      `INSERT IGNORE INTO books (title, author, isbn13, description) VALUES (?, ?, ?, ?)`,
      [title, author, isbn13, description]
    );
    booksInserted += r.affectedRows;
  }
  console.log(`  ${booksInserted} new books inserted (${BOOKS.length - booksInserted} already existed).`);

  // ── 2. Assign genres ───────────────────────────────────────────────────
  console.log("Assigning genres...");
  let genresLinked = 0;
  for (const [title, , isbn13, , genreIds] of BOOKS) {
    const [rows] = await db.query(
      `SELECT book_id FROM books WHERE isbn13 = ?`, [isbn13]
    );
    if (!rows.length) continue;
    const bookId = rows[0].book_id;
    for (const genreId of genreIds) {
      const [r] = await db.query(
        `INSERT IGNORE INTO book_genres (book_id, genre_id) VALUES (?, ?)`,
        [bookId, genreId]
      );
      genresLinked += r.affectedRows;
    }
  }
  console.log(`  ${genresLinked} genre links added.`);

  // ── 3. Assign all books to all libraries ───────────────────────────────
  console.log("Fetching all libraries and books for inventory seeding...");
  const [libraries] = await db.query("SELECT library_id FROM libraries");
  const [books]     = await db.query("SELECT book_id FROM books");
  console.log(`  ${libraries.length} libraries × ${books.length} books = up to ${libraries.length * books.length} rows`);

  const rows = [];
  for (const { library_id } of libraries) {
    for (const { book_id } of books) {
      const total     = Math.floor(Math.random() * 5) + 1;
      const available = Math.floor(Math.random() * total) + 1;
      rows.push([library_id, book_id, total, available]);
    }
  }

  const CHUNK = 1000;
  let inventoryInserted = 0;
  for (let i = 0; i < rows.length; i += CHUNK) {
    const chunk = rows.slice(i, i + CHUNK);
    const [r] = await db.query(
      `INSERT IGNORE INTO library_books
         (library_id, book_id, copies_total, copies_available)
       VALUES ?`,
      [chunk]
    );
    inventoryInserted += r.affectedRows;
    process.stdout.write(`\r  ${Math.min(i + CHUNK, rows.length)}/${rows.length} processed, ${inventoryInserted} inserted`);
  }

  console.log(`\n  ${inventoryInserted} new inventory rows added.`);
  console.log("Done.");
  process.exit(0);
}

run().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});