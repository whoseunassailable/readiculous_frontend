const mysql = require('mysql2/promise');

const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'Jraonhvain11#',
    database: 'readiculous'
});

module.exports = db;
