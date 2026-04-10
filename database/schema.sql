use readiculous;

CREATE TABLE IF NOT EXISTS libraries (
    library_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    location   VARCHAR(255) NOT NULL,
    phone      VARCHAR(30),
    website    VARCHAR(500),
    county     VARCHAR(150),
    state      VARCHAR(100),
    zip        VARCHAR(10),
    address    VARCHAR(255),
    is_public  BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT uq_library_name_state UNIQUE (name(191), state(100))
);

CREATE TABLE users (
    user_id VARCHAR(255) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    location VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    password VARCHAR(255),
    role ENUM('user','librarian') NOT NULL DEFAULT 'user'
);

CREATE TABLE genres (
    genre_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE user_genres (
    user_id VARCHAR(255) NOT NULL,
    genre_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (user_id, genre_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

CREATE TABLE user_libraries (
    user_id VARCHAR(255) NOT NULL PRIMARY KEY,
    library_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_libraries_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_user_libraries_library FOREIGN KEY (library_id) REFERENCES libraries(library_id) ON DELETE CASCADE ON UPDATE CASCADE
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
    user_id VARCHAR(255) NOT NULL,
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
