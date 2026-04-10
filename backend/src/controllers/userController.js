// userController.js
const bcrypt = require("bcrypt");
const db = require("../config/db");
const { v4: uuidv4 } = require("uuid");
const logger = require("../config/logger");

const saltRounds = 10;

// ✅ Create user
exports.createUser = async (req, res) => {
  const {
    first_name,
    last_name,
    role,
    date_of_birth,
    location,
    email,
    phone,
    password,
  } = req.body;

  if (!first_name || !last_name || !email || !password) {
    logger.warn({ email }, "createUser: missing required fields");
    return res.status(400).json({ message: "Required fields missing" });
  }

  try {
    const user_id = uuidv4();
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    const userRole = role || "user";

    await db.execute(
      `INSERT INTO users (
        user_id, first_name, last_name, role, date_of_birth, location, email, phone, password
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        user_id,
        first_name,
        last_name,
        userRole,
        date_of_birth || null,
        location || null,
        email,
        phone || null,
        hashedPassword,
      ],
    );

    logger.info({ user_id, email, role: userRole }, "createUser: user created");

    return res.status(201).json({
      message: "User created",
      data: {
        user_id,
        first_name,
        last_name,
        role: userRole,
        date_of_birth: date_of_birth || null,
        location: location || null,
        email,
        phone: phone || null,
      },
    });
  } catch (error) {
    if (error.code === "ER_DUP_ENTRY") {
      logger.warn({ email }, "createUser: duplicate email");
      return res.status(409).json({ message: "Email already exists" });
    }
    logger.error(error, "createUser: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// ✅ Delete user
exports.deleteUser = async (req, res) => {
  const { user_id } = req.params;

  if (!user_id) {
    logger.warn("deleteUser: user_id missing");
    return res.status(400).json({ message: "User ID is required" });
  }

  try {
    const [result] = await db.execute("DELETE FROM users WHERE user_id = ?", [
      user_id,
    ]);

    if (result.affectedRows === 0) {
      logger.warn({ user_id }, "deleteUser: user not found");
      return res.status(404).json({ message: "User not found" });
    }

    logger.info({ user_id }, "deleteUser: user deleted");
    return res.json({ message: "User deleted successfully" });
  } catch (error) {
    logger.error(error, "deleteUser: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// ✅ Login user
exports.loginUser = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    logger.warn("loginUser: email or password missing");
    return res.status(400).json({ message: "Email and password are required" });
  }

  try {
    logger.debug({ email }, "loginUser: looking up user");

    const [rows] = await db.execute("SELECT * FROM users WHERE email = ?", [
      email,
    ]);

    if (rows.length === 0) {
      logger.warn({ email }, "loginUser: no user found with this email");
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const user = rows[0];
    const match = await bcrypt.compare(password, user.password);

    if (!match) {
      logger.warn({ email }, "loginUser: password mismatch");
      return res.status(401).json({ message: "Invalid credentials" });
    }

    logger.info({ user_id: user.user_id, email, role: user.role }, "loginUser: login successful");

    return res.json({
      message: "Login successful",
      user: {
        user_id: user.user_id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    logger.error(error, "loginUser: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// ✅ Fetch all users
exports.getAllUsers = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `SELECT
         user_id,
         first_name,
         last_name,
         role,
         date_of_birth,
         location,
         email,
         phone,
         created_at
       FROM users`,
    );
    logger.info({ count: rows.length }, "getAllUsers: fetched users");
    return res.json(rows);
  } catch (error) {
    logger.error(error, "getAllUsers: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// ✅ Fetch users' preferences (genres) + top_m/top_n
exports.getUserPreferences = async (req, res) => {
  try {
    const [users] = await db.execute(`SELECT user_id FROM users`);
    const userIds = users.map((u) => u.user_id);

    if (userIds.length === 0) {
      logger.info("getUserPreferences: no users found, returning empty");
      return res.json({
        user_preferences: [],
        top_m_genres: 6,
        top_n_books: 3,
      });
    }

    const [prefs] = await db.query(
      `SELECT
         ug.user_id,
         GROUP_CONCAT(g.name ORDER BY g.name SEPARATOR ',') AS genres
       FROM user_genres ug
       JOIN genres g ON ug.genre_id = g.genre_id
       WHERE ug.user_id IN (?)
       GROUP BY ug.user_id`,
      [userIds],
    );

    const prefMap = prefs.reduce((m, row) => {
      m[row.user_id] = row.genres;
      return m;
    }, {});

    const user_preferences = userIds.map((id) => ({
      user_id: id,
      genres: prefMap[id] || "",
    }));

    logger.info({ count: user_preferences.length }, "getUserPreferences: fetched preferences");

    return res.json({
      user_preferences,
      top_m_genres: 6,
      top_n_books: 3,
    });
  } catch (error) {
    logger.error(error, "getUserPreferences: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// ✅ Set/Update a user role (e.g., librarian)
exports.setUserRole = async (req, res) => {
  const { user_id } = req.params;
  const { role } = req.body;

  if (!user_id || !role) {
    logger.warn({ user_id, role }, "setUserRole: user_id or role missing");
    return res.status(400).json({ message: "user_id and role are required" });
  }

  const allowedRoles = new Set(["user", "librarian"]);
  if (!allowedRoles.has(role)) {
    logger.warn({ user_id, role }, "setUserRole: invalid role provided");
    return res.status(400).json({ message: "Invalid role" });
  }

  try {
    const [result] = await db.execute(
      "UPDATE users SET role = ? WHERE user_id = ?",
      [role, user_id],
    );

    if (result.affectedRows === 0) {
      logger.warn({ user_id }, "setUserRole: user not found");
      return res.status(404).json({ message: "User not found" });
    }

    logger.info({ user_id, role }, "setUserRole: role updated");
    return res.json({ message: "Role updated", user_id, role });
  } catch (error) {
    logger.error(error, "setUserRole: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// GET /api/users/:user_id/library
exports.getUserLibrary = async (req, res) => {
  const { user_id } = req.params;

  try {
    logger.debug({ user_id }, "getUserLibrary: querying library for user");

    const [rows] = await db.execute(
      `SELECT library_id, name, location, verified, association_type
       FROM (
         SELECT
           l.library_id,
           l.name,
           l.location,
           lb.verified,
           'librarian' AS association_type,
           0 AS association_priority
         FROM librarians lb
         JOIN libraries l ON l.library_id = lb.library_id
         WHERE lb.user_id = ?
         UNION ALL
         SELECT
           l.library_id,
           l.name,
           l.location,
           NULL AS verified,
           'reader' AS association_type,
           1 AS association_priority
         FROM user_libraries ul
         JOIN libraries l ON l.library_id = ul.library_id
         WHERE ul.user_id = ?
       ) associations
       ORDER BY association_priority ASC
       LIMIT 1`,
      [user_id, user_id],
    );

    if (rows.length === 0) {
      logger.info({ user_id }, "getUserLibrary: no library association found");
      return res.json({ library: null });
    }

    logger.info(
      {
        user_id,
        library_id: rows[0].library_id,
        association_type: rows[0].association_type,
      },
      "getUserLibrary: library found",
    );
    return res.json({ library: rows[0] });
  } catch (error) {
    logger.error(error, "getUserLibrary: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// POST /api/users/:user_id/library
exports.upsertUserLibrary = async (req, res) => {
  const { user_id } = req.params;
  const { library_id } = req.body;

  if (!user_id || !library_id) {
    logger.warn({ user_id, library_id }, "upsertUserLibrary: missing required fields");
    return res.status(400).json({ message: "user_id and library_id are required" });
  }

  try {
    const [userRows] = await db.execute(
      "SELECT role FROM users WHERE user_id = ? LIMIT 1",
      [user_id],
    );

    if (userRows.length === 0) {
      logger.warn({ user_id }, "upsertUserLibrary: user not found");
      return res.status(404).json({ message: "User not found" });
    }

    if (userRows[0].role === "librarian") {
      logger.warn({ user_id, library_id }, "upsertUserLibrary: librarians must use librarian assignment");
      return res.status(400).json({ message: "Librarian accounts must use librarian assignment" });
    }

    const [libraryRows] = await db.execute(
      "SELECT library_id FROM libraries WHERE library_id = ? LIMIT 1",
      [library_id],
    );

    if (libraryRows.length === 0) {
      logger.warn({ user_id, library_id }, "upsertUserLibrary: library not found");
      return res.status(404).json({ message: "Library not found" });
    }

    await db.execute(
      `INSERT INTO user_libraries (user_id, library_id)
       VALUES (?, ?)
       ON DUPLICATE KEY UPDATE
         library_id = VALUES(library_id),
         updated_at = CURRENT_TIMESTAMP`,
      [user_id, library_id],
    );

    logger.info({ user_id, library_id }, "upsertUserLibrary: association saved");
    return res.status(201).json({ message: "User library association saved", user_id, library_id });
  } catch (error) {
    logger.error(error, "upsertUserLibrary: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};

// DELETE /api/users/:user_id/library
exports.removeUserLibrary = async (req, res) => {
  const { user_id } = req.params;

  try {
    const [result] = await db.execute(
      "DELETE FROM user_libraries WHERE user_id = ?",
      [user_id],
    );

    if (result.affectedRows === 0) {
      logger.warn({ user_id }, "removeUserLibrary: association not found");
      return res.status(404).json({ message: "User library association not found" });
    }

    logger.info({ user_id }, "removeUserLibrary: association removed");
    return res.json({ message: "User library association removed" });
  } catch (error) {
    logger.error(error, "removeUserLibrary: unexpected error");
    return res.status(500).json({ message: "Internal server error" });
  }
};
