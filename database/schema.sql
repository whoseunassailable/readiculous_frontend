use readiculous; 

CREATE TABLE users (
    user_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE genres (
    genre_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE user_genres (
    user_id INT UNSIGNED NOT NULL,
    genre_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (user_id, genre_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

CREATE TABLE books (
    isbn VARCHAR(20) PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT,
    description TEXT
);

CREATE TABLE book_genres (
    isbn VARCHAR(20) NOT NULL,
    genre_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (isbn, genre_id),
    FOREIGN KEY (isbn) REFERENCES books(isbn) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

CREATE TABLE ratings (
    rating_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    rating FLOAT CHECK (rating >= 0 AND rating <= 5),
    rated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, isbn),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (isbn) REFERENCES books(isbn) ON DELETE CASCADE
);

show tables;
describe users;

-- drop table users;