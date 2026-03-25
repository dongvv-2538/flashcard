# 🃏 Flashcard — Spaced Repetition Learning App

A Ruby on Rails web application that helps learners memorise information efficiently using the **SM-2 spaced repetition algorithm**. Users create decks of flashcards and practise them in timed study sessions; the app automatically schedules each card's next review based on how well the learner recalled it.

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [Screenshots](#2-screenshots)
3. [Features](#3-features)
4. [Technology Stack](#4-technology-stack)
5. [Architecture](#5-architecture)
6. [Database Schema](#6-database-schema)
7. [SM-2 Spaced Repetition Algorithm](#7-sm-2-spaced-repetition-algorithm)
8. [Installation & Setup](#8-installation--setup)
9. [Running the Application](#9-running-the-application)
10. [Running Tests](#10-running-tests)
11. [Docker Deployment](#11-docker-deployment)
12. [API Routes](#12-api-routes)
13. [Project Structure](#13-project-structure)

---

## 1. Product Overview

**Flashcard** is a web-based spaced-repetition system (SRS) built with Ruby on Rails 7.  
Learners create **Decks** (topic collections) containing **Cards** (front/back pairs).  
During a **Study Session** the app presents cards one at a time; after seeing the answer the learner rates their recall as *Again*, *Hard*, *Good*, or *Easy*. The **SM-2 algorithm** then computes exactly when that card should reappear — a day, a week, or even a month later — ensuring review happens at the optimal moment before forgetting occurs.

A dedicated **Review Queue** dashboard surfaces every card that is due (or overdue) today, grouped by deck, so learners always know what needs attention at a glance.

---

## 2. Screenshots

### 2.1 Login Page

[insert image]

URL: `GET /` → redirects to `GET /session/new`

### 2.2 Register Page

[insert image]

URL: `GET /users/new`

### 2.3 My Decks (Dashboard)

[insert image]

URL: `GET /decks`

### 2.4 Deck Detail with Stats

[insert image]

URL: `GET /decks/:id`

### 2.5 Study Session — Front of Card

[insert image]

URL: `GET /decks/:deck_id/study_sessions/:id`

### 2.6 Study Session — Answer Revealed + Rating

[insert image]

### 2.7 Session Summary

[insert image]

URL: `GET /decks/:deck_id/study_sessions/:id/summary`

### 2.8 Review Queue

[insert image]

URL: `GET /reviews`

### 2.9 No Cards Due State

[insert image]

---

## 3. Features

### Authentication
- User registration with username + password (min 8 characters)
- Secure login / logout using `has_secure_password` (bcrypt)
- Session-based authentication; all deck/card/study data is scoped to the logged-in user
- Case-insensitive username normalisation

### Deck Management
- Create, view, edit, and delete decks
- Each deck has a **name** (required) and optional **description**
- Live stats panel per deck: **Total / New / Due Today / Learned**
- Confirmation prompts before destructive deletes

### Card Management (inside a Deck)
- Create, view, edit, and delete flashcards (front + back text)
- Cards are listed in a sortable table inside the deck view

### Study Session (Full Deck Mode)
- Start a session from any deck — all cards queued in order
- Progress bar and card counter (`Card X of Y`)
- Card flip interaction: front shown first → click *Show Answer* → back revealed
- Rate each card: **Again / Hard / Good / Easy**
- Cards rated *Again* are re-queued (up to 3 times) before being dropped
- Session auto-finalises when the queue is exhausted
- Session summary with rating breakdown

### Review Queue (Due/Overdue Mode)
- Dashboard showing all cards due today or overdue, grouped by deck
- Cap of **100 cards** per queue load to keep sessions manageable
- Start a *review_due* session directly from the queue page
- Next review date displayed when no cards are due

### Spaced Repetition (SM-2 Algorithm)
- Automatic scheduling after every card rating
- Interval, ease factor, and review count tracked per card
- Cards "graduate" from daily review once `interval_days > 1`

---

## 4. Technology Stack

| Layer | Technology |
|---|---|
| Language | Ruby 3.1 |
| Framework | Ruby on Rails 7.2 |
| Database | PostgreSQL 15+ |
| Frontend | Bootstrap 5.3 + Bootstrap Icons |
| JavaScript | Importmap + Turbo + Stimulus (no Node.js required) |
| Authentication | `has_secure_password` (bcrypt) |
| Testing | RSpec 6 + FactoryBot + Capybara + SimpleCov |
| Code Quality | RuboCop + rubocop-rails + rubocop-rspec |
| Deployment | Docker (multi-stage build) |
| Web Server | Puma 5+ |

---

## 5. Architecture

```
app/
├── controllers/           # HTTP request handlers (scoped to current_user)
│   ├── sessions_controller.rb        # Login / logout
│   ├── users_controller.rb           # Registration
│   ├── decks_controller.rb           # CRUD decks
│   ├── cards_controller.rb           # CRUD cards (nested under deck)
│   ├── study_sessions_controller.rb  # Practice session lifecycle
│   └── reviews_controller.rb         # Daily review queue
│
├── models/
│   ├── user.rb              # Authentication, owns decks & sessions
│   ├── deck.rb              # Collection of cards, belongs to user
│   ├── card.rb              # Front/back flashcard pair, belongs to deck
│   ├── study_session.rb     # A single practice session (full_deck | review_due)
│   ├── session_rating.rb    # Again/Hard/Good/Easy rating per card per session
│   └── card_schedule.rb     # SM-2 state (interval, ease_factor, next_review_date)
│
├── services/
│   ├── sm2_scheduler.rb          # Pure SM-2 calculation (stateless)
│   ├── session_queue_service.rb  # In-session card queue (serialisable to session)
│   ├── review_queue_service.rb   # Aggregate due cards across all decks
│   └── deck_stats_service.rb     # Total/New/Due/Learned counts for a deck
│
└── views/
    ├── sessions/      # Login form
    ├── users/         # Registration form
    ├── decks/         # Deck list, deck detail, forms
    ├── cards/         # Card forms
    ├── study_sessions/ # Flash card UI + session summary
    └── reviews/       # Daily review queue
```

### Request Flow — Study Session

```
POST /decks/:id/study_sessions
        │
        ▼
StudySessionsController#create
  → build StudySession record
  → SessionQueueService.new(deck.cards)
  → store queue state in Rails session (JSON)
        │
        ▼ redirect
GET /decks/:id/study_sessions/:session_id
  → restore queue from session
  → render current card (front only)
        │
        ▼ user clicks Show Answer, then picks a rating
PATCH /decks/:id/study_sessions/:session_id  { rating: "good" }
  → create SessionRating
  → SM2Scheduler.call(schedule, rating)  → update CardSchedule
  → queue.advance!(rating)               → re-queue if :again
  → if queue.empty? → redirect summary
  → else → redirect show (next card)
```

---

## 6. Database Schema

```
users
  id, username (unique), password_digest, created_at, updated_at

decks
  id, user_id (FK), name, description, created_at, updated_at

cards
  id, deck_id (FK), front (text), back (text), created_at, updated_at

study_sessions
  id, user_id (FK), deck_id (FK), session_type (0=full_deck 1=review_due),
  started_at, ended_at, cards_reviewed_count, created_at, updated_at

session_ratings
  id, study_session_id (FK), card_id (FK), rating (0=again 1=hard 2=good 3=easy),
  reviewed_at, created_at, updated_at

card_schedules
  id, card_id (FK, unique), next_review_date, interval_days, ease_factor,
  review_count, last_reviewed_at, created_at, updated_at
```

**Entity Relationship Diagram**

```
User ──< Deck ──< Card >── CardSchedule
  │         │       │
  └──< StudySession │
              │     │
              └──< SessionRating
```

---

## 7. SM-2 Spaced Repetition Algorithm

The SM-2 algorithm (by Piotr Woźniak) schedules the next review date based on how easily the learner recalled an item.

### Rating → Schedule Update

| Rating | Interval Change | Ease Factor Change |
|--------|-----------------|-------------------|
| **Again** (0) | Reset → 0 days | − 0.20 |
| **Hard** (1) | × 1.2 (min 1 day) | − 0.15 |
| **Good** (2) | × ease_factor (min 1 day) | unchanged |
| **Easy** (3) | × ease_factor × 1.3 (min 4 days) | + 0.15 |

### Constraints
- `ease_factor` is clamped between **1.3** and **2.5**
- First *Good* review → 1 day interval
- First *Easy* review → 4 day interval
- Cards with `interval_days > 1` are counted as **Learned**

### Example Progression (new card rated Good each time)

| Review # | Interval | Next Review |
|----------|----------|-------------|
| 1 | 1 day | tomorrow |
| 2 | 2 days | +2 days |
| 3 | 5 days | +5 days |
| 4 | 13 days | +13 days |
| 5 | 33 days | +33 days |

---

## 8. Installation & Setup

### Prerequisites

| Requirement | Version |
|---|---|
| Ruby | 3.1.x |
| Rails | 7.2.x |
| PostgreSQL | 15+ |
| Bundler | 2.x |

### 1 — Clone the repository

```bash
git clone <repository-url>
cd flashcard
```

### 2 — Install Ruby gems

```bash
bundle install
```

### 3 — Configure database credentials

Edit `config/database.yml` and set your PostgreSQL `username` and `password` under the `default:` section:

```yaml
default: &default
  adapter: postgresql
  host: localhost
  port: 5432
  username: your_postgres_user
  password: your_postgres_password
```

### 4 — Create and migrate the database

```bash
bin/rails db:create db:migrate
```

### 5 — (Optional) Seed sample data

```bash
bin/rails db:seed
```

---

## 9. Running the Application

### Development server

```bash
bin/rails server
# or
bin/rails s
```

The app will be available at **http://localhost:3000**.

### First-time usage

1. Open http://localhost:3000
2. Click **Register** and create a new account
3. After login, click **＋ New Deck** and create a deck
4. Open the deck → **＋ Add Card** → add front/back pairs
5. Click **Start Session** to begin a practice session
6. After reviewing, check **Review Queue** the following day for due cards

---

## 10. Running Tests

The project uses **RSpec** with FactoryBot, Capybara, and SimpleCov.  
Code coverage gate is **≥ 80%**.

```bash
# Run all specs
bundle exec rspec

# Run a specific file
bundle exec rspec spec/models/card_schedule_spec.rb

# Run with coverage report
COVERAGE=true bundle exec rspec

# View coverage HTML report
open coverage/index.html
```

### Test Structure

```
spec/
├── factories/          # FactoryBot factories
│   ├── users.rb
│   ├── decks.rb
│   ├── cards.rb
│   ├── card_schedules.rb
│   └── ...
├── models/             # Model unit tests
├── services/           # Service unit tests (SM2Scheduler, etc.)
├── system/             # Capybara end-to-end browser tests
└── support/            # Shared helpers & configuration
```

---

## 11. Docker Deployment

The provided `Dockerfile` uses a **multi-stage build** targeting production.

### Build the image

```bash
docker build -t flashcard-app .
```

### Run the container

```bash
docker run -d \
  -p 80:80 \
  -e RAILS_MASTER_KEY=$(cat config/master.key) \
  -e DATABASE_URL=postgresql://user:pass@db_host/flashcard_production \
  --name flashcard \
  flashcard-app
```

### Environment variables

| Variable | Description |
|---|---|
| `RAILS_MASTER_KEY` | Decrypts `config/credentials.yml.enc` |
| `DATABASE_URL` | Full PostgreSQL connection string |
| `RAILS_ENV` | Set to `production` (default in Dockerfile) |

---

## 12. API Routes

All routes are HTML-only (no JSON API). Authentication is required for all routes except `/`, `/users/new`, `/users`, `/session/new`, `/session`.

```
GET    /                                        → Login page (root)

# Authentication
GET    /users/new                               → Registration form
POST   /users                                  → Create user
GET    /session/new                             → Login form
POST   /session                                → Create session (login)
DELETE /session                                → Destroy session (logout)

# Decks
GET    /decks                                  → List all decks
GET    /decks/new                              → New deck form
POST   /decks                                  → Create deck
GET    /decks/:id                              → Deck detail + cards + stats
GET    /decks/:id/edit                         → Edit deck form
PATCH  /decks/:id                              → Update deck
DELETE /decks/:id                              → Delete deck (+ all cards)

# Cards (nested under Deck)
GET    /decks/:deck_id/cards/new               → New card form
POST   /decks/:deck_id/cards                   → Create card
GET    /decks/:deck_id/cards/:id/edit          → Edit card form
PATCH  /decks/:deck_id/cards/:id              → Update card
DELETE /decks/:deck_id/cards/:id              → Delete card

# Study Sessions (nested under Deck)
POST   /decks/:deck_id/study_sessions          → Start a new session
GET    /decks/:deck_id/study_sessions/:id      → Current card view
PATCH  /decks/:deck_id/study_sessions/:id      → Submit rating, advance queue
GET    /decks/:deck_id/study_sessions/:id/summary → Session summary

# Review Queue
GET    /reviews                                → Daily review queue
POST   /reviews                                → Start review_due session for a deck

# Health check
GET    /up                                     → Rails health check
```

---

## 13. Project Structure

```
flashcard/
├── app/
│   ├── assets/            # Stylesheets, images
│   ├── controllers/       # Request handlers
│   ├── javascript/        # Client-side JS (importmap)
│   │   ├── application.js # Flash auto-dismiss, Bootstrap init
│   │   └── study_session.js # Show Answer / rating reveal logic
│   ├── models/            # ActiveRecord models
│   ├── services/          # Business logic (SM-2, queue, stats)
│   └── views/             # ERB templates (Bootstrap 5)
├── config/
│   ├── routes.rb          # All URL routes
│   ├── database.yml       # PostgreSQL config
│   └── environments/      # dev / test / production settings
├── db/
│   ├── migrate/           # Database migrations
│   └── schema.rb          # Current schema snapshot
├── spec/                  # RSpec test suite
├── Dockerfile             # Multi-stage production Docker build
├── Gemfile                # Ruby dependencies
└── README.md              # This file
```

---

## License

This project is developed as an internal learning tool. All rights reserved.

