# Readiculous

> Because the solution to bad library shelves is *ridiculous*... I mean, Readiculous.

## The Problem

Libraries have a shelf space problem. Walk into almost any public library and you'll find the same books that have been sitting there for decades — books that almost nobody checks out — while the books people actually want to read are nowhere to be found.

This isn't just a bad user experience. It's a waste of shelf space, a waste of paper, and a missed opportunity to bring people back to one of the most underrated places in a city.

## The Solution

Readiculous is a Flutter app that connects readers and librarians through shared reading data and machine learning.

**How it works:**

1. **Readers** create an account, set their genre preferences, and log the books they read
2. **Genre trends** build up over time — the app knows what readers in a given library's area actually want
3. An **ML model** analyzes those genre preferences and recommends specific books for the library to stock
4. **Librarians** see these recommendations, approve them, order the books, and update inventory
5. Books with the most community interest get stocked. The ones collecting dust get retired.

The result: libraries that feel alive, shelves that reflect what their community actually reads, and readers who keep coming back because the books they want are actually there.

## Who It's For

**Readers:**
- Browse your library's book catalog
- Log the books you've read
- Set your genre preferences
- Get personalized book recommendations based on your taste

**Librarians:**
- View genre trends from readers in your area
- See ML-powered recommendations for which books to order
- Manage your library's book inventory
- Track recommendation status (New → Ordered → Stocked)

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter |
| State Management | Riverpod |
| Routing | go_router |
| HTTP Client | Dio + Retrofit |
| Backend | Node.js + MySQL |
| ML Model | Python / Flask |
| ML Training Data | Kaggle book ratings dataset |

## Getting Started

This project uses [FVM](https://fvm.app/) for Flutter version management.

```bash
# Install dependencies
fvm flutter pub get

# Run the app
fvm flutter run
```

Make sure the backend (Node API on port 5000) and ML model (Flask on port 6000) are running. For Android emulator, both are accessible at `10.0.2.2`.

## Project Structure

```
lib/
├── core/
│   ├── features/
│   │   ├── authentication/     # Login, register, session
│   │   ├── home/               # Role-based home screen
│   │   ├── books/              # Add/view books
│   │   ├── library_database/   # Browse & search library catalog
│   │   ├── suggested_books/    # ML recommendations (user & library)
│   │   └── settings/           # Profile, logout
│   ├── network/                # Dio client + Retrofit API clients
│   ├── session/                # Riverpod session management
│   ├── routing/                # go_router configuration
│   ├── constants/              # Colors, fonts, routes
│   └── widgets/                # Shared UI components
└── main.dart
```

## API Overview

The backend exposes endpoints across these domains:

- **Users** — register, login, manage accounts and genre preferences
- **Books** — full CRUD, genre assignments
- **Libraries** — library management, book inventory
- **Librarians** — assign/unassign librarians to libraries
- **Reads** — user reading lists and read status
- **Recommendations** — ML-generated suggestions for users and libraries
- **Trends** — genre trend scores per library and globally

## The Inspiration

The idea came from spending too much time in Chicago libraries — Chinatown, Joe and Rika, and others — and noticing that the books available never quite matched what people actually wanted to read. The same unread books occupying the same shelves, year after year.

Readiculous is the answer to that frustration. A platform that makes library shelves smarter, one read at a time.
