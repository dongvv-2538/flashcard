# Feature Specification: Flashcard App with Spaced Repetition

**Feature Branch**: `001-flashcard-spaced-repetition`
**Created**: 2026-03-12
**Status**: Approved
**Input**: User description: "Xây dựng app học Flashcards với lịch ôn theo spaced repetition. Người dùng tạo Deck và Card, luyện tập theo phiên (session), chấm mức độ nhớ (Again/Hard/Good/Easy) để hệ thống lên lịch ôn tự động."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Deck & Card Management (Priority: P1)

A learner wants to organise their study material. They create a named Deck
(e.g. "JLPT N3 Vocabulary"), then add Cards to it — each Card has a front side
(the prompt: a word, question, or image description) and a back side (the
answer or definition). They can also edit or delete existing Decks and Cards.

**Why this priority**: Without content there is nothing to study. This is the
foundational data-entry flow that every other story depends on. An MVP that
only has this story still delivers value (organised study material).

**Independent Test**: Create a deck called "Test Deck", add three cards, edit
one card's back text, delete another card, then verify two cards remain with
correct content. No session or scheduling needed.

**Acceptance Scenarios**:

1. **Given** the learner is on the home screen, **When** they create a new deck
   with a name and optional description, **Then** the deck appears in their deck
   list with the correct name and a card count of 0.
2. **Given** a deck exists, **When** the learner adds a card with front and back
   text, **Then** the card appears in the deck's card list and the deck's card
   count increments by 1.
3. **Given** a card exists, **When** the learner edits its front or back text
   and saves, **Then** the updated text is reflected in the card list.
4. **Given** a deck contains cards, **When** the learner deletes a card,
   **Then** the card is removed and the deck count decrements by 1.
5. **Given** a deck exists, **When** the learner deletes the deck, **Then** the
   deck and all its cards are permanently removed.
6. **Given** a deck has no cards, **When** the learner tries to start a session,
   **Then** the system prevents the session and prompts them to add cards first.

---

### User Story 2 — Practice Session with Recall Rating (Priority: P2)

A learner selects a deck and starts a study session. The system presents cards
one at a time showing only the front. The learner thinks of the answer, then
reveals the back. After seeing the answer they rate how well they recalled it:
**Again** (didn't remember), **Hard** (remembered with difficulty), **Good**
(remembered correctly), or **Easy** (remembered instantly). This rating drives
the scheduling algorithm.

**Why this priority**: This is the core interaction loop — the moment of active
recall and self-assessment. Without this, spaced repetition has no input signal.

**Independent Test**: Start a session on a deck with 5 cards. For each card:
reveal the back, select a rating. Verify the session ends after all cards are
rated and a summary screen is shown. No scheduling correctness check needed
for this story.

**Acceptance Scenarios**:

1. **Given** a deck with at least one card, **When** the learner starts a
   session, **Then** the first card's front is displayed and the back is hidden.
2. **Given** a card's front is visible, **When** the learner taps "Show
   Answer", **Then** the back is revealed alongside the four rating buttons
   (Again / Hard / Good / Easy).
3. **Given** the back is revealed, **When** the learner selects a rating,
   **Then** the next card is presented (or the session ends if it was the last
   card).
4. **Given** the learner rates a card "Again", **Then** that card is
   re-inserted later in the current session so the learner sees it again before
   the session ends.
5. **Given** all cards in the session have been rated (with no "Again" cards
   remaining), **When** the last card is rated, **Then** a session-complete
   screen is shown with a count of cards reviewed and a breakdown of ratings
   given.
6. **Given** a session is in progress, **When** the learner can see a progress
   indicator showing cards remaining vs. total cards in the session.

---

### User Story 3 — Spaced Repetition Scheduling & Daily Review Queue (Priority: P3)

After each rating in a session the system calculates a personalised next-review
date for that card using a spaced repetition algorithm. Cards rated "Again" are
scheduled for very soon (within hours or same day); "Hard", "Good", and "Easy"
extend the interval progressively. The learner can open a "Review" view that
shows only the cards due today or overdue, enabling focused daily practice
rather than re-studying the whole deck.

**Why this priority**: Scheduling is the defining feature of spaced repetition —
without it the app is just a random flashcard flipper. However the basic session
(P2) can ship first while scheduling is added on top.

**Independent Test**: Rate a card "Good" and verify its next review date is
scheduled multiple days in the future. Rate a different card "Again" and verify
it is scheduled for the same day. Open the review queue the following day and
confirm only due cards appear, not newly-added undue cards.

**Acceptance Scenarios**:

1. **Given** a card is rated during a session, **When** the rating is submitted,
   **Then** the system assigns that card a next-review date based on the rating
   (Again ≤ same day; Hard = short interval; Good = standard interval; Easy =
   extended interval).
2. **Given** a card has been reviewed before, **When** it is rated "Good" or
   "Easy" again, **Then** the interval grows longer than the previous interval
   (progressive spacing).
3. **Given** one or more cards are due today or overdue, **When** the learner
   opens the Review view, **Then** only those due/overdue cards are listed
   grouped by deck.
4. **Given** no cards are due today, **When** the learner opens the Review
   view, **Then** a message confirms there are no reviews due and shows the
   date of the next scheduled card.
5. **Given** the learner starts a review session from the Review view,
   **When** they rate all due cards, **Then** the reviewed cards are removed
   from today's queue and rescheduled.
6. **Given** a card was due yesterday but not reviewed, **When** the learner
   opens the Review view today, **Then** that card appears as overdue.

---

### User Story 4 — Learning Progress Overview (Priority: P4)

The learner wants to understand how their study is going. They can view a
per-deck statistics panel showing: total cards, how many are new (never
studied), how many are scheduled for today, and how many are in longer-term
intervals. This gives them confidence that the system is working and motivates
continued study.

**Why this priority**: Progress visibility increases motivation and retention.
It delivers value on top of the core scheduling loop but is not required for
the spaced repetition mechanism itself to function.

**Independent Test**: After completing a session on a 10-card deck, open the
deck's stats panel and verify the counts update to reflect cards that are now
scheduled vs. new.

**Acceptance Scenarios**:

1. **Given** a deck is selected, **When** the learner views its statistics,
   **Then** the system shows: total cards, new (unreviewed) cards, due-today
   count, and learned (interval > 1 day) count.
2. **Given** a deck's stats are visible, **When** the learner completes a
   session, **Then** the new/due/learned counts update to reflect the session
   results without requiring a manual refresh.
3. **Given** all cards in a deck have been reviewed at least once, **Then** the
   "new" count displays as 0.

---

### Edge Cases

- **Empty deck**: Starting a session on a deck with 0 cards is prevented; user
  is prompted to add cards.
- **All cards rated "Again" repeatedly**: The session continues presenting
  re-queued cards; there is no infinite loop — after a configurable maximum
  re-queue count per session the session ends with a summary note.
- **Deck deleted while session active**: The session is terminated gracefully;
  any ratings already submitted in that session are discarded since the cards
  no longer exist.
- **Large deck (500+ cards)**: A session or review queue with many cards remains
  responsive; the system paginates or streams card data as needed.
- **Card edited between sessions**: The updated front/back content is shown in
  the next session; the scheduling record for that card is preserved.
- **Overdue cards accumulate**: If a learner returns after many days, all
  overdue cards are surfaced; the review session gracefully handles large
  backlogs (e.g. capping a single review session at a configurable maximum).

## Requirements *(mandatory)*

### Functional Requirements

#### Deck Management

- **FR-001**: Users MUST be able to create a deck with a name (required) and
  optional description.
- **FR-002**: Users MUST be able to view a list of all their decks, each
  showing the deck name, total card count, and due-today count.
- **FR-003**: Users MUST be able to edit a deck's name and description.
- **FR-004**: Users MUST be able to delete a deck, which also permanently
  removes all cards and schedule records belonging to it.

#### Card Management

- **FR-005**: Users MUST be able to add a card to a deck; each card MUST have
  a non-empty front and a non-empty back.
- **FR-006**: Users MUST be able to edit a card's front and back content.
- **FR-007**: Users MUST be able to delete a card from a deck.
- **FR-008**: Users MUST be able to browse all cards in a deck in a list view.

#### Practice Session

- **FR-009**: Users MUST be able to start a study session for any deck with at
  least one card.
- **FR-010**: The system MUST present cards in a session one at a time, showing
  the front by default and hiding the back.
- **FR-011**: Users MUST be able to reveal the back of the current card with a
  single action.
- **FR-012**: After revealing the back, users MUST be presented with exactly
  four recall-rating options: Again, Hard, Good, Easy.
- **FR-013**: When a card is rated "Again", the system MUST re-queue that card
  to appear again later in the current session.
- **FR-014**: The session MUST display a progress indicator (e.g. "Card 4 of
  12") throughout the session.
- **FR-015**: When a session ends, the system MUST display a completion summary
  showing total cards reviewed and counts per rating.

#### Spaced Repetition Scheduling

- **FR-016**: Upon each rating submission, the system MUST recalculate and store
  the next-review date for that card using a spaced repetition algorithm.
- **FR-017**: Cards rated "Again" MUST have their next-review date set to the
  same day or within a few hours.
- **FR-018**: The interval between reviews MUST increase progressively for
  cards consistently rated "Good" or "Easy".
- **FR-019**: Cards rated "Hard" MUST have their interval reduced compared to a
  "Good" rating.
- **FR-020**: The system MUST maintain per-card scheduling state (interval,
  ease factor, next-review date, review count).

#### Review Queue

- **FR-021**: The system MUST provide a Review view that aggregates all cards
  whose next-review date is today or earlier, across all decks.
- **FR-022**: Users MUST be able to start a dedicated review session from the
  Review view containing only due/overdue cards.
- **FR-023**: The Review view MUST show the total number of cards due and group
  them by deck.
- **FR-024**: When no cards are due, the Review view MUST display the date of
  the next scheduled review.

#### Data Persistence

- **FR-025**: All decks, cards, schedules, and session results MUST be
  persisted so they survive application restarts.

#### User Accounts

- **FR-026**: The system MUST support multiple independent user accounts via
  username/password authentication.
- **FR-027**: Unauthenticated users MUST NOT be able to access any deck, card,
  session, or scheduling data.
- **FR-028**: Users MUST be able to register a new account with a username and
  password.
- **FR-029**: Users MUST be able to log in and log out of their account.
- **FR-030**: All decks, cards, schedules, and sessions MUST be strictly
  isolated per user — one user MUST NOT be able to view or modify another
  user's data.

### Key Entities

- **User**: An authenticated account holder. Attributes: username, encrypted
  password, created date. All other entities belong to a User.
- **Deck**: A named collection of cards on a single topic owned by one User.
  Attributes: name, description (optional), created date, owner (User).
- **Card**: A single flashcard belonging to a deck. Attributes: front content,
  back content, created date, last-modified date.
- **CardSchedule**: The per-card spaced repetition state. Attributes:
  card reference, next-review date, current interval (days), ease factor,
  review count, last-reviewed date.
- **Session**: A single study session. Attributes: deck reference, start time,
  end time, session type (learn-new / review-due / full-deck), cards reviewed
  count.
- **SessionRating**: A record of one card rating within a session. Attributes:
  session reference, card reference, rating (Again/Hard/Good/Easy), timestamp.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A learner can create a deck and add 10 cards in under 3 minutes
  from a standing start with no prior experience of the app.
- **SC-002**: A practice session of 20 cards completes without errors; each card
  transition takes no longer than 1 second after a rating is submitted.
- **SC-003**: After rating a card, the card's updated next-review date is visible
  to the learner within 1 second of submitting the rating.
- **SC-004**: The Review view correctly surfaces all and only the cards whose
  scheduled review date is today or earlier — 0% false positives, 0% false
  negatives.
- **SC-005**: All deck, card, and schedule data persists across application
  restarts with zero data loss.
- **SC-006**: Cards consistently rated "Good" across consecutive sessions show
  progressively longer intervals (day 1 → 3 → 7 → 14 → … pattern or
  equivalent).
- **SC-007**: 90% of first-time learners can complete a full deck session
  (create deck → add cards → practice → see summary) without external help.
- **SC-008**: The application remains responsive (no noticeable lag) when a deck
  contains 500 or more cards.

## Assumptions

The following reasonable defaults have been applied where the input description
was silent. They should be revisited if requirements change.

- **Algorithm**: The spaced repetition algorithm is modelled on the SM-2
  (SuperMemo 2) approach — a well-established open standard for the four-button
  rating model described. The specific formula is an implementation detail;
  what matters is the scheduling behaviour described in FR-016 to FR-020.
- **Session scope**: A "full deck" session presents all cards in a deck
  regardless of due date (useful for first-time learning). A "review" session
  (FR-022) presents only due/overdue cards.
- **"Again" re-queue limit**: To prevent infinite sessions, a card rated
  "Again" will be re-queued at most 3 times within a single session before
  being marked for re-review the following day.
- **Maximum daily review cap**: If more than 100 cards are due in one day, the
  Review session caps at 100 cards; remaining overdue cards are included in the
  next session started that day.
- **Platform**: Web application accessible via browser; no native mobile app
  assumed unless clarified.
- **Authentication**: The app supports multiple user accounts with
  username/password login (FR-026 to FR-030). Password recovery (e.g. reset
  via email) is out of scope for this version. OAuth/SSO is out of scope.
- **Content types**: Cards contain text only in the initial version; images,
  audio, and rich media are out of scope.
- **Import/Export**: Bulk import (e.g. CSV) and deck sharing are out of scope
  for this specification.
