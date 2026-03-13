# Tasks: Flashcard App with Spaced Repetition

**Input**: Design documents from `specs/001-flashcard-spaced-repetition/`
**Prerequisites**: plan.md ✅, spec.md ✅

**Organization**: Tasks are grouped by user story to enable independent
implementation and testing of each story.
**Tests**: REQUIRED per Constitution Principle II — TDD enforced throughout.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US4)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Rails application scaffolding, tooling, and base layout.

- [X] T001 Create new Rails 7.2 application with PostgreSQL (`rails new flashcard --database=postgresql`) and add gems to `Gemfile`: `rspec-rails`, `factory_bot_rails`, `capybara`, `simplecov`, `rubocop-rails`, `bootstrap`, `jquery-rails`
- [X] T002 [P] Configure RuboCop with `.rubocop.yml` at repo root: inherit `rubocop-rails`, enable `Metrics/CyclomaticComplexity` max 10, `Style/FrozenStringLiteralComment`
- [X] T003 [P] Configure RSpec: run `rails generate rspec:install`; add FactoryBot, Capybara, SimpleCov (≥80% minimum) includes to `spec/rails_helper.rb`
- [X] T004 [P] Configure Bootstrap 5 + jQuery in `app/javascript/application.js` and import Bootstrap CSS in `app/assets/stylesheets/application.scss`
- [X] T005 Create base application layout with Bootstrap navbar, flash messages, and yield in `app/views/layouts/application.html.erb`

---

## Phase 2: Foundational — Authentication

**Purpose**: User accounts with username/password login. ALL subsequent user stories
require a logged-in user and scoped data — nothing can be built before this.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Tests for Authentication (REQUIRED — Constitution Principle II)

> Write these tests FIRST; ensure they FAIL before implementation (TDD: Red → Green → Refactor)

- [X] T006 [P] Write system spec for full registration + login + logout flow in `spec/system/authentication_spec.rb` (Capybara)
- [X] T007 [P] Write model spec for User validations (username presence, uniqueness, password length) in `spec/models/user_spec.rb`

### Implementation for Authentication

- [X] T008 Create User migration with `username` (string, unique, not null), `password_digest` (string), timestamps in `db/migrate/..._create_users.rb`; run `rails db:migrate`
- [X] T009 Implement `User` model with `has_secure_password`, validates `username` presence + uniqueness in `app/models/user.rb`
- [X] T010 Implement `UsersController` with `new` and `create` actions (registration) in `app/controllers/users_controller.rb`
- [X] T011 Implement `SessionsController` with `new`, `create`, `destroy` (login/logout) in `app/controllers/sessions_controller.rb`
- [X] T012 Add `current_user`, `logged_in?`, `require_login` helpers and `before_action :require_login` to `app/controllers/application_controller.rb`
- [X] T013 [P] Create registration view (Bootstrap form: username + password + confirm) in `app/views/users/new.html.erb`
- [X] T014 [P] Create login view (Bootstrap form: username + password) in `app/views/sessions/new.html.erb`
- [X] T015 Add `resources :users` and `resource :session` to routes
- [X] T016 [P] Create FactoryBot factory for `User` in `spec/factories/users.rb`

**Checkpoint**: Any request without a valid session redirects to login. Registration and login work end-to-end.

---

## Phase 3: User Story 1 — Deck & Card Management (Priority: P1) 🎯 MVP

**Goal**: Learners can create, browse, edit, and delete Decks and Cards. The deck
list shows card counts. Deleting a deck cascades to its cards.

**Independent Test**: Create "Test Deck", add 3 cards, edit 1 card's back, delete 1 card — verify 2 cards remain. No session or scheduling needed.

### Tests for User Story 1 (REQUIRED — Constitution Principle II)

> Write these tests FIRST; ensure they FAIL before implementation

- [X] T017 [P] [US1] Write system spec for deck CRUD (create, edit, delete, card count display) in `spec/system/decks_spec.rb`
- [X] T018 [P] [US1] Write system spec for card CRUD within a deck (add, edit, delete, list) in `spec/system/cards_spec.rb`
- [X] T019 [P] [US1] Write model spec for `Deck` (validations: name required, belongs to user, has many cards dependent destroy) in `spec/models/deck_spec.rb`
- [X] T020 [P] [US1] Write model spec for `Card` (validations: front + back required, belongs to deck) in `spec/models/card_spec.rb`

### Implementation for User Story 1

- [X] T021 [P] [US1] Create `Deck` migration with `user_id` (references), `name` (string, not null), `description` (text), timestamps in `db/migrate/..._create_decks.rb`
- [X] T022 [P] [US1] Create `Card` migration with `deck_id` (references), `front` (text, not null), `back` (text, not null), timestamps in `db/migrate/..._create_cards.rb`; run `rails db:migrate`
- [X] T023 [US1] Implement `Deck` model: `belongs_to :user`, `has_many :cards, dependent: :destroy`, validates `name` presence, scope all queries to current user in `app/models/deck.rb`
- [X] T024 [US1] Implement `Card` model: `belongs_to :deck`, validates `front` and `back` presence in `app/models/card.rb`
- [X] T025 [US1] Implement `DecksController` (index, new, create, show, edit, update, destroy) scoped to `current_user` in `app/controllers/decks_controller.rb`
- [X] T026 [US1] Implement `CardsController` (index, new, create, edit, update, destroy) nested under decks in `app/controllers/cards_controller.rb`
- [X] T027 [P] [US1] Create deck views: `index.html.erb` (Bootstrap list with name, card count, due count placeholder, action buttons), `new.html.erb`, `edit.html.erb`, `show.html.erb` in `app/views/decks/`
- [X] T028 [P] [US1] Create card views: `index.html.erb` (list with front/back preview, action buttons), `new.html.erb`, `edit.html.erb` in `app/views/cards/`
- [X] T029 [US1] Add nested routes for decks/cards
- [X] T030 [P] [US1] Create FactoryBot factories for `Deck` and `Card` in `spec/factories/decks.rb` and `spec/factories/cards.rb`

**Checkpoint**: User Story 1 fully functional — CRUD for decks and cards works independently.

---

## Phase 4: User Story 2 — Practice Session with Recall Rating (Priority: P2)

**Goal**: Learners start a session on a deck, see card fronts one at a time, reveal
backs, rate recall (Again/Hard/Good/Easy), see Again cards requeued, and receive
a session-complete summary.

**Independent Test**: Session on 5-card deck — rate all cards including one "Again" (re-queued); see summary with rating breakdown. No schedule persistence needed.

### Tests for User Story 2 (REQUIRED — Constitution Principle II)

> Write these tests FIRST; ensure they FAIL before implementation

- [X] T031 [P] [US2] Write system spec for full session flow: start → flip card → rate → Again re-queue → summary in `spec/system/study_sessions_spec.rb`
- [X] T032 [P] [US2] Write model spec for `StudySession` (enum session_type, associations, completed? scope) in `spec/models/study_session_spec.rb`
- [ ] T033 [P] [US2] Write model spec for `SessionRating` (rating enum, associations) in `spec/models/session_rating_spec.rb`
- [ ] T034 [P] [US2] Write service spec for `SessionQueueService` (initial queue, Again re-queue capped at 3×, next_card, empty?) in `spec/services/session_queue_service_spec.rb`

### Implementation for User Story 2

- [ ] T035 [P] [US2] Create `StudySession` migration with `user_id`, `deck_id`, `session_type` (integer enum: full_deck/review_due), `started_at`, `ended_at`, `cards_reviewed_count` in `db/migrate/..._create_study_sessions.rb`
- [ ] T036 [P] [US2] Create `SessionRating` migration with `study_session_id`, `card_id`, `rating` (integer enum: again/hard/good/easy), `reviewed_at` in `db/migrate/..._create_session_ratings.rb`; run `rails db:migrate`
- [ ] T037 [US2] Implement `StudySession` model: `belongs_to :user`, `belongs_to :deck`, `has_many :session_ratings`, `enum :session_type`, `enum` not needed for rating (that's on `SessionRating`) in `app/models/study_session.rb`
- [ ] T038 [US2] Implement `SessionRating` model: `belongs_to :study_session`, `belongs_to :card`, `enum :rating, { again: 0, hard: 1, good: 2, easy: 3 }` in `app/models/session_rating.rb`
- [ ] T039 [US2] Implement `SessionQueueService`: initialise card queue from deck, track Again re-queue count per card (max 3), expose `next_card`, `remaining_count`, `total_count`, `empty?` in `app/services/session_queue_service.rb`; store queue state in Rails session (JSON)
- [ ] T040 [US2] Implement `StudySessionsController`: `create` (start session, init queue), `show` (current card), `update` (submit rating → create SessionRating, advance queue or end session) in `app/controllers/study_sessions_controller.rb`
- [ ] T041 [US2] Create session show view: card front display, "Show Answer" button (hidden back), rating buttons (Again/Hard/Good/Easy), progress indicator "Card X of Y" in `app/views/study_sessions/show.html.erb`
- [ ] T042 [P] [US2] Add jQuery for card flip: clicking "Show Answer" reveals the back panel and rating buttons via toggle in `app/javascript/study_session.js`
- [ ] T043 [US2] Create session summary view: total reviewed, count per rating (Bootstrap badge breakdown), "Back to Deck" link in `app/views/study_sessions/summary.html.erb`
- [ ] T044 [US2] Add study session routes: `resources :study_sessions, only: [:new, :create, :show, :update]` nested under decks in `config/routes.rb`
- [ ] T045 [P] [US2] Create FactoryBot factories for `StudySession` and `SessionRating` in `spec/factories/`

**Checkpoint**: User Story 2 fully functional — session with flip, rating, Again re-queue, and summary works independently.

---

## Phase 5: User Story 3 — Spaced Repetition Scheduling & Daily Review Queue (Priority: P3)

**Goal**: Each rating persists a `CardSchedule` with a next-review date computed by
SM-2. A Review view surfaces all due/overdue cards grouped by deck; learners
start a review-only session from there.

**Independent Test**: Rate card "Good" → next_review_date is several days out. Rate another "Again" → same day. Next day, Review view shows only those due cards.

### Tests for User Story 3 (REQUIRED — Constitution Principle II)

> Write these tests FIRST; ensure they FAIL before implementation

- [ ] T046 [P] [US3] Write unit spec for `SM2Scheduler` covering all four ratings, progressive interval growth, ease factor bounds in `spec/services/sm2_scheduler_spec.rb`
- [ ] T047 [P] [US3] Write model spec for `CardSchedule` (validations, scopes: `due_today`, `overdue`, `new_cards`) in `spec/models/card_schedule_spec.rb`
- [ ] T048 [P] [US3] Write service spec for `ReviewQueueService` (returns only due/overdue, grouped by deck, ordered correctly) in `spec/services/review_queue_service_spec.rb`
- [ ] T049 [P] [US3] Write system spec for Review view: due cards listed, no-due message, start review session from queue in `spec/system/review_queue_spec.rb`

### Implementation for User Story 3

- [ ] T050 [P] [US3] Create `CardSchedule` migration with `card_id` (references, unique), `next_review_date` (date), `interval_days` (integer, default 0), `ease_factor` (decimal, default 2.5), `review_count` (integer, default 0), `last_reviewed_at` in `db/migrate/..._create_card_schedules.rb`; run `rails db:migrate`
- [ ] T051 [US3] Implement `CardSchedule` model: `belongs_to :card`, scopes `due_today` (`next_review_date <= Date.today`), `overdue`, `new_cards` (`review_count == 0`) in `app/models/card_schedule.rb`
- [ ] T052 [US3] Implement `SM2Scheduler` service: given (current_schedule, rating) → compute new `interval_days`, `ease_factor` (clamped 1.3–2.5), `next_review_date`; return updated attributes in `app/services/sm2_scheduler.rb`
- [ ] T053 [US3] Wire `SM2Scheduler` into `StudySessionsController#update`: after creating `SessionRating`, upsert `CardSchedule` via `SM2Scheduler` in `app/controllers/study_sessions_controller.rb`
- [ ] T054 [US3] Implement `ReviewQueueService`: query all `CardSchedule` records due/overdue for `current_user`, group by deck, cap at 100 cards total in `app/services/review_queue_service.rb`
- [ ] T055 [US3] Implement `ReviewsController` with `index` (render queue grouped by deck) and `create` (start a `review_due` StudySession from the queue) in `app/controllers/reviews_controller.rb`
- [ ] T056 [P] [US3] Create review queue view: grouped deck sections with due card count, "Start Review" button, no-due-cards message + next scheduled date fallback in `app/views/reviews/index.html.erb`
- [ ] T057 [US3] Add review routes: `resources :reviews, only: [:index, :create]` to `config/routes.rb`; add link in navbar
- [ ] T058 [P] [US3] Create FactoryBot factory for `CardSchedule` in `spec/factories/card_schedules.rb`

**Checkpoint**: User Story 3 fully functional — ratings produce schedules; Review view shows only due/overdue cards; review session works.

---

## Phase 6: User Story 4 — Learning Progress Overview (Priority: P4)

**Goal**: A per-deck stats panel shows total, new (unreviewed), due-today, and
learned (interval > 1 day) card counts, updating after each session.

**Independent Test**: Complete a session on a 10-card deck; open deck stats; verify new count decrements and learned count increments.

### Tests for User Story 4 (REQUIRED — Constitution Principle II)

> Write these tests FIRST; ensure they FAIL before implementation

- [ ] T059 [P] [US4] Write service spec for `DeckStatsService` (correct counts: total, new, due, learned) in `spec/services/deck_stats_service_spec.rb`
- [ ] T060 [P] [US4] Write system spec for deck stats panel display and post-session update in `spec/system/stats_spec.rb`

### Implementation for User Story 4

- [ ] T061 [US4] Implement `DeckStatsService`: given a deck and current user, return `{ total:, new:, due_today:, learned: }` using `CardSchedule` scopes in `app/services/deck_stats_service.rb`
- [ ] T062 [US4] Add `stats` action to `DecksController` (or embed in `show`) that calls `DeckStatsService` and exposes `@stats` to the view in `app/controllers/decks_controller.rb`
- [ ] T063 [US4] Create deck stats partial with Bootstrap stat cards (total/new/due/learned) rendered inside `app/views/decks/show.html.erb` (embed `app/views/decks/_stats.html.erb`)
- [ ] T064 [US4] Ensure `decks#show` re-fetches stats after a completed study session redirects back (no stale cache) in `app/controllers/study_sessions_controller.rb`

**Checkpoint**: User Story 4 fully functional — deck stats panel updates correctly after sessions.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Code quality, accessibility, performance, and coverage gates.

- [ ] T065 [P] Run RuboCop `--autocorrect` across `app/` and `spec/`; fix remaining manual offenses; ensure zero violations in `.rubocop.yml`-governed files
- [ ] T066 [P] Accessibility audit: add `aria-label` to icon buttons, verify heading hierarchy (`h1`→`h2`→`h3`), test tab-order through session flow across `app/views/`
- [ ] T067 Add `includes(:card_schedules)` / eager loading to `DecksController#index` and `ReviewQueueService` to prevent N+1 queries
- [ ] T068 [P] Run SimpleCov coverage report; add missing unit tests in `spec/models/` and `spec/services/` until overall coverage ≥80%
- [ ] T069 Audit all flash messages and error messages across controllers for human-readable, actionable wording (Constitution Principle III) in `app/controllers/`
- [ ] T070 [P] Manual quickstart smoke test: register → create deck → add 5 cards → run session → check review queue next day (use `travel_to` in test or manually advance date)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Auth)**: Depends on Phase 1 — **BLOCKS all user story phases**
- **Phase 3 (US1)**: Depends on Phase 2 completion
- **Phase 4 (US2)**: Depends on Phase 3 (needs `Card` model and deck routing)
- **Phase 5 (US3)**: Depends on Phase 4 (needs `SessionRating` to feed the scheduler)
- **Phase 6 (US4)**: Depends on Phase 5 (needs `CardSchedule` scopes for counts)
- **Phase 7 (Polish)**: Depends on all story phases

### Within Each Phase

- Tests MUST be written first and MUST fail before implementation begins (TDD)
- Migrations before models; models before controllers; controllers before views
- Services are independent of views — can be built/tested in parallel with view work

### Parallel Opportunities

All tasks marked `[P]` within the same phase can run concurrently on separate branches.

---

## Parallel Example: User Story 1

```bash
# Run in parallel after Phase 2 is complete:
Task T017: spec/system/decks_spec.rb
Task T018: spec/system/cards_spec.rb
Task T019: spec/models/deck_spec.rb
Task T020: spec/models/card_spec.rb
Task T021: db/migrate/..._create_decks.rb
Task T022: db/migrate/..._create_cards.rb
Task T027: app/views/decks/ (after T025)
Task T028: app/views/cards/ (after T026)
Task T030: spec/factories/decks.rb + cards.rb
```

---

## Implementation Strategy

### MVP First (User Story 1 + Auth only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Authentication (CRITICAL)
3. Complete Phase 3: User Story 1 (Deck & Card CRUD)
4. **STOP and VALIDATE**: A user can register, log in, create a deck, and manage cards
5. Deploy/demo if ready

### Incremental Delivery

1. Setup + Auth → Foundation ✅
2. US1 (Deck/Card CRUD) → Independently testable MVP ✅
3. US2 (Sessions + Rating) → Independently testable ✅
4. US3 (SR Scheduling + Review Queue) → Independently testable ✅
5. US4 (Progress Stats) → Independently testable ✅
6. Polish → Release-ready ✅

---

## Summary

| Phase | Tasks | Parallelizable | Story |
|-------|-------|---------------|-------|
| Phase 1: Setup | T001–T005 | 3 | — |
| Phase 2: Auth (Foundational) | T006–T016 | 5 | — |
| Phase 3: Deck & Card Mgmt | T017–T030 | 8 | US1 (P1) |
| Phase 4: Practice Session | T031–T045 | 6 | US2 (P2) |
| Phase 5: SR Scheduling | T046–T058 | 5 | US3 (P3) |
| Phase 6: Progress Stats | T059–T064 | 2 | US4 (P4) |
| Phase 7: Polish | T065–T070 | 4 | — |
| **Total** | **70 tasks** | **33 [P]** | |
