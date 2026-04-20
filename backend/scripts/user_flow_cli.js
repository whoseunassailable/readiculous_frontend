require("dotenv").config({ path: require("path").resolve(__dirname, "../.env") });

const axios = require("axios");
const readline = require("readline/promises");
const { stdin, stdout, stderr } = require("process");

const PORT = process.env.PORT || 5000;
const API_BASE_URL =
  process.env.BACKEND_API_URL || `http://localhost:${PORT}/api`;

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
});

const rl = readline.createInterface({ input: stdin, output: stdout });

const READ_STATUS_OPTIONS = [
  { label: "Want to Read", value: "want_to_read" },
  { label: "Reading", value: "reading" },
  { label: "Finished", value: "read" },
];

const LIBRARY_REC_STATE_OPTIONS = [
  { label: "NEW", value: "NEW" },
  { label: "ORDERED", value: "ORDERED" },
  { label: "STOCKED", value: "STOCKED" },
  { label: "IGNORED", value: "IGNORED" },
];

function printSection(title) {
  stdout.write(`\n=== ${title} ===\n`);
}

function formatReadStatus(status) {
  switch (status) {
    case "want_to_read":
      return "Want to Read";
    case "reading":
      return "Reading";
    case "read":
      return "Finished";
    default:
      return status || "Unknown";
  }
}

function stars(value) {
  if (value == null) return "-";
  const rounded = Math.max(1, Math.min(5, Math.round(Number(value))));
  return `${"★".repeat(rounded)}${"☆".repeat(5 - rounded)} (${value})`;
}

async function prompt(message) {
  const value = await rl.question(message);
  return value.trim();
}

async function promptChoice(message, max) {
  while (true) {
    const input = await prompt(message);
    const num = Number(input);
    if (Number.isInteger(num) && num >= 0 && num <= max) {
      return num;
    }
    stdout.write(`Enter a number between 0 and ${max}.\n`);
  }
}

async function fetchUsers() {
  const { data } = await api.get("/users/");
  return data.sort((a, b) => {
    const aName = `${a.first_name || ""} ${a.last_name || ""}`.trim();
    const bName = `${b.first_name || ""} ${b.last_name || ""}`.trim();
    return aName.localeCompare(bName);
  });
}

async function fetchBooks() {
  const { data } = await api.get("/books/");
  return data.sort((a, b) => a.title.localeCompare(b.title));
}

async function fetchLibraries() {
  const { data } = await api.get("/libraries/");
  return data.sort((a, b) => a.name.localeCompare(b.name));
}

async function fetchUserLibrary(userId) {
  const { data } = await api.get(`/users/${userId}/library`);
  return data;
}

async function fetchUserGenres(userId) {
  const { data } = await api.get(`/user-genres/${userId}`);
  return data;
}

async function fetchReads(userId) {
  const { data } = await api.get(`/reads/${userId}`);
  return data.sort((a, b) => a.title.localeCompare(b.title));
}

async function fetchUserRecommendations(userId) {
  const { data } = await api.get(`/recommendations/users/${userId}`);
  return data;
}

async function generateUserRecommendations(userId, topN = 10) {
  const { data } = await api.post(`/recommendations/users/${userId}/generate`, {
    top_n: topN,
  });
  return data;
}

async function fetchLibraryInventory(libraryId) {
  const { data } = await api.get(`/library-books/${libraryId}`);
  return data;
}

async function fetchLibraryActivity(libraryId) {
  const { data } = await api.get(`/libraries/${libraryId}/activity`);
  return data;
}

async function fetchLibraryRecommendations(libraryId) {
  const { data } = await api.get(`/recommendations/libraries/${libraryId}`);
  return data;
}

async function generateLibraryRecommendations(libraryId, topNBooks = 10) {
  const { data } = await api.post(
    `/recommendations/libraries/${libraryId}/generate`,
    { top_n_books: topNBooks },
  );
  return data;
}

async function updateLibraryRecommendationState(recommendationId, state) {
  const { data } = await api.patch(`/recommendations/libraries/${recommendationId}`, {
    state,
  });
  return data;
}

async function upsertRead({ userId, bookId, status, rating }) {
  await api.post("/reads", {
    user_id: userId,
    book_id: bookId,
    status,
    rating,
  });
}

async function retrainMl() {
  const { data } = await api.post("/ml/retrain", {});
  return data;
}

function printUsersByRole(users) {
  const readers = users.filter((user) => user.role === "user");
  const librarians = users.filter((user) => user.role === "librarian");

  printSection("Reader Accounts");
  if (readers.length === 0) {
    stdout.write("No reader accounts found.\n");
  } else {
    readers.forEach((user, index) => {
      stdout.write(
        `[${index + 1}] ${user.first_name} ${user.last_name} | ${user.email} | ${user.user_id}\n`,
      );
    });
  }

  printSection("Librarian Accounts");
  if (librarians.length === 0) {
    stdout.write("No librarian accounts found.\n");
  } else {
    librarians.forEach((user, index) => {
      stdout.write(
        `[${index + 1}] ${user.first_name} ${user.last_name} | ${user.email} | ${user.user_id}\n`,
      );
    });
  }
}

function printLibraries(libraries) {
  printSection("Libraries");
  libraries.forEach((library, index) => {
    stdout.write(
      `[${index + 1}] ${library.name} | ${library.location || "Unknown location"} | library_id=${library.library_id}\n`,
    );
  });
}

function printDataSnapshot(users, books, libraries) {
  const readers = users.filter((user) => user.role === "user").length;
  const librarians = users.filter((user) => user.role === "librarian").length;

  printSection("Data Snapshot");
  stdout.write(`Users: ${users.length}\n`);
  stdout.write(`Readers: ${readers}\n`);
  stdout.write(`Librarians: ${librarians}\n`);
  stdout.write(`Books: ${books.length}\n`);
  stdout.write(`Libraries: ${libraries.length}\n`);

  printUsersByRole(users);
  if (libraries.length > 0) {
    printLibraries(libraries);
  }
}

function filterBooks(books, query) {
  const normalized = query.toLowerCase();
  return books.filter((book) => {
    const haystack = `${book.title} ${book.author || ""} ${book.isbn13 || ""}`.toLowerCase();
    return haystack.includes(normalized);
  });
}

async function chooseBook(books) {
  while (true) {
    const query = await prompt(
      "\nSearch books by title/author/isbn (blank shows first 15, 0 cancels): ",
    );
    if (query === "0") {
      return null;
    }

    const matches = query ? filterBooks(books, query) : books;
    const visible = matches.slice(0, 15);

    if (visible.length === 0) {
      stdout.write("No matches found.\n");
      continue;
    }

    printSection("Book Matches");
    visible.forEach((book, index) => {
      stdout.write(
        `[${index + 1}] ${book.title} by ${book.author || "Unknown"} | book_id=${book.book_id}\n`,
      );
    });
    stdout.write("[0] Cancel\n");

    const selection = await promptChoice("Select a book: ", visible.length);
    if (selection === 0) {
      return null;
    }

    return visible[selection - 1];
  }
}

async function chooseOption(options, promptLabel) {
  printSection(promptLabel);
  options.forEach((option, index) => {
    stdout.write(`[${index + 1}] ${option.label}\n`);
  });
  stdout.write("[0] Cancel\n");

  const selection = await promptChoice("Choose an option: ", options.length);
  if (selection === 0) {
    return null;
  }
  return options[selection - 1].value;
}

async function chooseRating() {
  while (true) {
    const input = await prompt(
      "Enter rating 1-5, or press Enter to leave unrated: ",
    );
    if (!input) {
      return null;
    }

    const rating = Number(input);
    if (Number.isInteger(rating) && rating >= 1 && rating <= 5) {
      return rating;
    }

    stdout.write("Rating must be an integer from 1 to 5.\n");
  }
}

function printReads(reads) {
  printSection("Current Reads");
  if (reads.length === 0) {
    stdout.write("No read statuses saved yet.\n");
    return;
  }

  reads.forEach((item, index) => {
    stdout.write(
      `[${index + 1}] ${item.title} by ${item.author || "Unknown"} | ${formatReadStatus(item.status)} | Rating: ${stars(item.rating)}\n`,
    );
  });
}

function printUserRecommendations(recommendations) {
  printSection("User Recommendations");
  if (recommendations.length === 0) {
    stdout.write("No recommendations saved yet.\n");
    return;
  }

  recommendations.forEach((item, index) => {
    stdout.write(
      `[${index + 1}] ${item.title} by ${item.author || "Unknown"} | Score: ${Number(item.score || 0).toFixed(3)}\n`,
    );
  });
}

function printLibraryInventory(inventory) {
  printSection("Library Inventory");
  if (inventory.length === 0) {
    stdout.write("No inventory rows found.\n");
    return;
  }

  inventory.forEach((item, index) => {
    stdout.write(
      `[${index + 1}] ${item.title} | available ${item.copies_available}/${item.copies_total} | low stock <= ${item.low_stock_threshold}\n`,
    );
  });
}

function printLibraryActivity(activity) {
  printSection("Local Reader Activity");
  if (activity.length === 0) {
    stdout.write("No reader activity found for this library.\n");
    return;
  }

  activity.forEach((item, index) => {
    stdout.write(
      `[${index + 1}] ${item.title} | reading=${item.reading_count} want_to_read=${item.want_to_read_count} finished=${item.read_count} | readers=${item.reader_names || "-"}\n`,
    );
  });
}

function printLibraryRecommendations(recommendations) {
  printSection("Library Recommendations");
  if (recommendations.length === 0) {
    stdout.write("No library recommendations saved yet.\n");
    return;
  }

  recommendations.forEach((item, index) => {
    stdout.write(
      `[${index + 1}] ${item.title} by ${item.author || "Unknown"} | ${item.state || "NEW"} | demand=${Number(item.demand_score || 0).toFixed(3)} | recommendation_id=${item.recommendation_id}\n`,
    );
  });
}

async function chooseReader(users) {
  const readers = users.filter((user) => user.role === "user");
  printSection("Select Reader");
  readers.forEach((user, index) => {
    stdout.write(
      `[${index + 1}] ${user.first_name} ${user.last_name} | ${user.email} | ${user.user_id}\n`,
    );
  });
  stdout.write("[0] Cancel\n");

  const selection = await promptChoice("Select reader: ", readers.length);
  if (selection === 0) {
    return null;
  }

  return readers[selection - 1];
}

async function chooseLibrarian(users) {
  const librarians = users.filter((user) => user.role === "librarian");
  printSection("Select Librarian");
  librarians.forEach((user, index) => {
    stdout.write(
      `[${index + 1}] ${user.first_name} ${user.last_name} | ${user.email} | ${user.user_id}\n`,
    );
  });
  stdout.write("[0] Cancel\n");

  const selection = await promptChoice("Select librarian: ", librarians.length);
  if (selection === 0) {
    return null;
  }

  return librarians[selection - 1];
}

async function handleReaderReadUpdate(user, books) {
  const book = await chooseBook(books);
  if (!book) {
    return;
  }

  const status = await chooseOption(READ_STATUS_OPTIONS, "Read Status");
  if (!status) {
    return;
  }

  const rating = await chooseRating();
  await upsertRead({
    userId: user.user_id,
    bookId: book.book_id,
    status,
    rating,
  });

  stdout.write(
    `Saved: ${book.title} -> ${formatReadStatus(status)} | Rating: ${stars(rating)}\n`,
  );

  const shouldGenerate = await prompt(
    "Generate fresh user recommendations now? [Y/n]: ",
  );
  if (shouldGenerate.toLowerCase() !== "n") {
    const result = await generateUserRecommendations(user.user_id);
    stdout.write(`${result.message}\n`);
    printUserRecommendations(result.recommendations || []);
  }
}

async function handleReaderFlow(user, books) {
  while (true) {
    const [genres, reads, recommendations, library] = await Promise.all([
      fetchUserGenres(user.user_id),
      fetchReads(user.user_id),
      fetchUserRecommendations(user.user_id),
      fetchUserLibrary(user.user_id),
    ]);

    printSection("Reader Summary");
    stdout.write(`Name: ${user.first_name} ${user.last_name}\n`);
    stdout.write(`Email: ${user.email}\n`);
    stdout.write(`User ID: ${user.user_id}\n`);
    stdout.write(`Library: ${library?.name || "None"}\n`);
    stdout.write(
      `Genres: ${genres.length > 0 ? genres.map((g) => g.name).join(", ") : "None"}\n`,
    );
    stdout.write(`Reads tracked: ${reads.length}\n`);
    stdout.write(`Recommendations saved: ${recommendations.length}\n`);

    stdout.write("\n");
    stdout.write("[1] Add or update a book status and rating\n");
    stdout.write("[2] View current reads\n");
    stdout.write("[3] Generate recommendations now\n");
    stdout.write("[4] View saved recommendations\n");
    stdout.write("[5] Retrain ML pipeline now\n");
    stdout.write("[6] Switch reader\n");
    stdout.write("[0] Exit\n");

    const choice = await promptChoice("Choose an action: ", 6);

    if (choice === 0) return "exit";
    if (choice === 1) {
      await handleReaderReadUpdate(user, books);
      continue;
    }
    if (choice === 2) {
      printReads(reads);
      continue;
    }
    if (choice === 3) {
      const result = await generateUserRecommendations(user.user_id);
      stdout.write(`${result.message}\n`);
      printUserRecommendations(result.recommendations || []);
      continue;
    }
    if (choice === 4) {
      printUserRecommendations(recommendations);
      continue;
    }
    if (choice === 5) {
      stdout.write("Retraining ML pipeline. This can take a while...\n");
      const result = await retrainMl();
      stdout.write(`${result.message}\n`);
      continue;
    }
    if (choice === 6) {
      return "switch";
    }
  }
}

async function handleLibraryRecommendationStateUpdate(libraryRecommendations) {
  if (libraryRecommendations.length === 0) {
    stdout.write("No library recommendations available to update.\n");
    return;
  }

  printLibraryRecommendations(libraryRecommendations);
  stdout.write("[0] Cancel\n");

  const selection = await promptChoice(
    "Select a library recommendation: ",
    libraryRecommendations.length,
  );
  if (selection === 0) {
    return;
  }

  const recommendation = libraryRecommendations[selection - 1];
  const state = await chooseOption(
    LIBRARY_REC_STATE_OPTIONS,
    "Library Recommendation State",
  );
  if (!state) {
    return;
  }

  const result = await updateLibraryRecommendationState(
    recommendation.recommendation_id,
    state,
  );
  stdout.write(`${result.message}\n`);
}

async function handleLibrarianFlow(user) {
  while (true) {
    const library = await fetchUserLibrary(user.user_id);
    if (!library) {
      stdout.write("This librarian is not assigned to a library.\n");
      return "switch";
    }

    const [inventory, activity, recommendations] = await Promise.all([
      fetchLibraryInventory(library.library_id),
      fetchLibraryActivity(library.library_id),
      fetchLibraryRecommendations(library.library_id),
    ]);

    printSection("Librarian Summary");
    stdout.write(`Name: ${user.first_name} ${user.last_name}\n`);
    stdout.write(`Email: ${user.email}\n`);
    stdout.write(`User ID: ${user.user_id}\n`);
    stdout.write(`Library: ${library.name}\n`);
    stdout.write(`Library ID: ${library.library_id}\n`);
    stdout.write(`Inventory rows: ${inventory.length}\n`);
    stdout.write(`Reader activity rows: ${activity.length}\n`);
    stdout.write(`Library recommendations: ${recommendations.length}\n`);

    stdout.write("\n");
    stdout.write("[1] View library inventory\n");
    stdout.write("[2] View local reader activity\n");
    stdout.write("[3] Generate library recommendations now\n");
    stdout.write("[4] View saved library recommendations\n");
    stdout.write("[5] Update a library recommendation state\n");
    stdout.write("[6] Retrain ML pipeline now\n");
    stdout.write("[7] Switch librarian\n");
    stdout.write("[0] Exit\n");

    const choice = await promptChoice("Choose an action: ", 7);

    if (choice === 0) return "exit";
    if (choice === 1) {
      printLibraryInventory(inventory);
      continue;
    }
    if (choice === 2) {
      printLibraryActivity(activity);
      continue;
    }
    if (choice === 3) {
      const result = await generateLibraryRecommendations(library.library_id);
      stdout.write(`${result.message}\n`);
      printLibraryRecommendations(result.recommendations || []);
      continue;
    }
    if (choice === 4) {
      printLibraryRecommendations(recommendations);
      continue;
    }
    if (choice === 5) {
      await handleLibraryRecommendationStateUpdate(recommendations);
      continue;
    }
    if (choice === 6) {
      stdout.write("Retraining ML pipeline. This can take a while...\n");
      const result = await retrainMl();
      stdout.write(`${result.message}\n`);
      continue;
    }
    if (choice === 7) {
      return "switch";
    }
  }
}

async function main() {
  stdout.write(`Using backend API: ${API_BASE_URL}\n`);
  stdout.write("This CLI exercises backend + ML without Flutter.\n");

  while (true) {
    const [users, books, libraries] = await Promise.all([
      fetchUsers(),
      fetchBooks(),
      fetchLibraries(),
    ]);

    printDataSnapshot(users, books, libraries);
    stdout.write("\n");
    stdout.write("[1] Reader recommendation flow\n");
    stdout.write("[2] Librarian recommendation flow\n");
    stdout.write("[3] Refresh data snapshot\n");
    stdout.write("[0] Exit\n");

    const choice = await promptChoice("Choose a mode: ", 3);

    if (choice === 0) {
      return;
    }

    if (choice === 1) {
      const user = await chooseReader(users);
      if (!user) {
        continue;
      }

      const result = await handleReaderFlow(user, books);
      if (result === "exit") {
        return;
      }
      continue;
    }

    if (choice === 2) {
      const user = await chooseLibrarian(users);
      if (!user) {
        continue;
      }

      const result = await handleLibrarianFlow(user);
      if (result === "exit") {
        return;
      }
    }
  }
}

main()
  .catch((error) => {
    const message =
      error.response?.data?.message ||
      error.response?.data?.error ||
      error.message;
    stderr.write(`\nCLI failed: ${message}\n`);
    process.exitCode = 1;
  })
  .finally(async () => {
    await rl.close();
  });
