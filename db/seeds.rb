# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding sample data..."

# ---------------------------------------------------------------------------
# Demo user
# ---------------------------------------------------------------------------
demo_user = User.find_or_create_by!(username: "demo") do |u|
  u.password = "password123"
end

# ---------------------------------------------------------------------------
# Helper: create a card + its SM-2 schedule in one call
# ---------------------------------------------------------------------------
def add_card(deck, front:, back:, next_review_date: Date.today, interval_days: 0,
             ease_factor: 2.5, review_count: 0, last_reviewed_at: nil)
  card = deck.cards.find_or_create_by!(front: front) do |c|
    c.back = back
  end

  CardSchedule.find_or_create_by!(card: card) do |s|
    s.next_review_date = next_review_date
    s.interval_days    = interval_days
    s.ease_factor      = ease_factor
    s.review_count     = review_count
    s.last_reviewed_at = last_reviewed_at
  end
end

today = Date.today

# ---------------------------------------------------------------------------
# Deck 1 — Ruby Fundamentals
# ---------------------------------------------------------------------------
ruby_deck = Deck.find_or_create_by!(user: demo_user, name: "Ruby Fundamentals") do |d|
  d.description = "Core Ruby language concepts and syntax"
end

add_card ruby_deck,
  front: "What is the difference between `nil` and `false` in Ruby?",
  back:  "`nil` represents the absence of a value; `false` is a boolean. Both are falsy, but only `nil` responds to `.nil?` with `true`.",
  next_review_date: today, interval_days: 0, review_count: 0

add_card ruby_deck,
  front: "What does `attr_accessor` do?",
  back:  "Creates both a getter (`attr_reader`) and a setter (`attr_writer`) method for the named instance variable.",
  next_review_date: today - 2, interval_days: 1, ease_factor: 2.3, review_count: 2,
  last_reviewed_at: today - 2

add_card ruby_deck,
  front: "What is a Ruby symbol?",
  back:  "An immutable, reusable identifier (e.g. `:name`). Unlike strings, identical symbols are the same object in memory.",
  next_review_date: today + 3, interval_days: 6, ease_factor: 2.6, review_count: 3,
  last_reviewed_at: today - 3

add_card ruby_deck,
  front: "Explain the difference between `map` and `each`.",
  back:  "`each` iterates and returns the original array. `map` iterates and returns a new array of the block's return values.",
  next_review_date: today, interval_days: 0, review_count: 0

add_card ruby_deck,
  front: "What is a block in Ruby?",
  back:  "An anonymous piece of code delimited by `do...end` or `{ }` that can be passed to a method and executed via `yield`.",
  next_review_date: today - 1, interval_days: 1, ease_factor: 2.4, review_count: 1,
  last_reviewed_at: today - 1

add_card ruby_deck,
  front: "What is the difference between `proc` and `lambda`?",
  back:  "Both are closures. A `lambda` checks argument count and `return` exits only the lambda. A `proc` is lenient with args and `return` exits the enclosing method.",
  next_review_date: today + 7, interval_days: 14, ease_factor: 2.7, review_count: 5,
  last_reviewed_at: today - 7

add_card ruby_deck,
  front: "What does `freeze` do to an object?",
  back:  "Makes the object immutable — further attempts to modify it raise a `FrozenError`.",
  next_review_date: today, interval_days: 0, review_count: 0

# ---------------------------------------------------------------------------
# Deck 2 — Rails Essentials
# ---------------------------------------------------------------------------
rails_deck = Deck.find_or_create_by!(user: demo_user, name: "Rails Essentials") do |d|
  d.description = "Ruby on Rails MVC concepts, conventions, and helpers"
end

add_card rails_deck,
  front: "What does MVC stand for and how does Rails implement it?",
  back:  "Model-View-Controller. Models (ActiveRecord), Views (ERB/templates), Controllers (ActionController) each handle a distinct layer of the app.",
  next_review_date: today, interval_days: 0, review_count: 0

add_card rails_deck,
  front: "What is the purpose of `before_action` in a controller?",
  back:  "A callback that runs before specified (or all) actions, used for authentication, setting instance variables, etc.",
  next_review_date: today - 3, interval_days: 2, ease_factor: 2.2, review_count: 3,
  last_reviewed_at: today - 3

add_card rails_deck,
  front: "What is `strong parameters` and why is it important?",
  back:  "A security mechanism (`params.require(...).permit(...)`) that whitelists only the attributes a controller action is allowed to mass-assign, preventing mass-assignment attacks.",
  next_review_date: today + 5, interval_days: 10, ease_factor: 2.8, review_count: 4,
  last_reviewed_at: today - 5

add_card rails_deck,
  front: "Explain the Rails asset pipeline.",
  back:  "A framework to concatenate, minify, and fingerprint JavaScript and CSS assets for efficient delivery in production.",
  next_review_date: today, interval_days: 0, review_count: 0

add_card rails_deck,
  front: "What does `dependent: :destroy` do on an association?",
  back:  "When the parent record is destroyed, all associated child records are also destroyed (callbacks are fired). Contrast with `:delete_all` which skips callbacks.",
  next_review_date: today - 1, interval_days: 1, ease_factor: 2.5, review_count: 2,
  last_reviewed_at: today - 1

add_card rails_deck,
  front: "What is the N+1 query problem and how do you fix it?",
  back:  "Loading a collection then querying each record individually. Fix with eager loading: `includes(:association)` or `preload`/`eager_load`.",
  next_review_date: today + 10, interval_days: 21, ease_factor: 2.9, review_count: 6,
  last_reviewed_at: today - 11

# ---------------------------------------------------------------------------
# Deck 3 — SQL & Databases
# ---------------------------------------------------------------------------
sql_deck = Deck.find_or_create_by!(user: demo_user, name: "SQL & Databases") do |d|
  d.description = "Relational database fundamentals and SQL query patterns"
end

add_card sql_deck,
  front: "What is the difference between `INNER JOIN` and `LEFT JOIN`?",
  back:  "`INNER JOIN` returns only rows with matching records in both tables. `LEFT JOIN` returns all rows from the left table, filling NULLs where no match exists in the right table.",
  next_review_date: today, interval_days: 0, review_count: 0

add_card sql_deck,
  front: "What is a database index and why is it useful?",
  back:  "A data structure (typically a B-tree) that speeds up read queries on a column at the cost of slightly slower writes and extra storage.",
  next_review_date: today - 4, interval_days: 3, ease_factor: 2.4, review_count: 3,
  last_reviewed_at: today - 4

add_card sql_deck,
  front: "What is a database transaction?",
  back:  "A sequence of operations treated as a single atomic unit. It either fully commits (all succeed) or fully rolls back (none persist), ensuring ACID properties.",
  next_review_date: today + 4, interval_days: 8, ease_factor: 2.6, review_count: 4,
  last_reviewed_at: today - 4

add_card sql_deck,
  front: "What does `GROUP BY` do?",
  back:  "Aggregates rows sharing the same values in specified columns into summary rows, often used with aggregate functions like `COUNT`, `SUM`, `AVG`.",
  next_review_date: today, interval_days: 0, review_count: 0

add_card sql_deck,
  front: "What is a foreign key constraint?",
  back:  "A database rule that enforces referential integrity — the value in the foreign key column must match an existing primary key in the referenced table (or be NULL).",
  next_review_date: today - 2, interval_days: 1, ease_factor: 2.3, review_count: 2,
  last_reviewed_at: today - 2

# ---------------------------------------------------------------------------
# Deck 4 — JavaScript Basics
# ---------------------------------------------------------------------------
js_deck = Deck.find_or_create_by!(user: demo_user, name: "JavaScript Basics") do |d|
  d.description = "Core JavaScript language features and browser APIs"
end

add_card js_deck,
  front: "What is the difference between `==` and `===` in JavaScript?",
  back:  "`==` checks equality with type coercion. `===` (strict equality) checks value AND type — no coercion occurs.",
  next_review_date: today, interval_days: 0, review_count: 0

add_card js_deck,
  front: "What is a closure in JavaScript?",
  back:  "A function that retains access to its outer lexical scope even after the outer function has returned.",
  next_review_date: today - 5, interval_days: 3, ease_factor: 2.2, review_count: 4,
  last_reviewed_at: today - 5

add_card js_deck,
  front: "What is the event loop?",
  back:  "JavaScript's concurrency mechanism: a call stack executes synchronous code; async callbacks are queued in the task/microtask queues and processed when the stack is empty.",
  next_review_date: today + 6, interval_days: 12, ease_factor: 2.7, review_count: 5,
  last_reviewed_at: today - 6

add_card js_deck,
  front: "What does `Promise.all` do?",
  back:  "Takes an array of promises and returns a single promise that resolves when ALL input promises resolve, or rejects as soon as one rejects.",
  next_review_date: today, interval_days: 0, review_count: 0

add_card js_deck,
  front: "What is the difference between `let`, `const`, and `var`?",
  back:  "`var` is function-scoped and hoisted. `let` is block-scoped, not hoisted to usable state. `const` is block-scoped and cannot be reassigned (though objects/arrays are still mutable).",
  next_review_date: today - 1, interval_days: 1, ease_factor: 2.5, review_count: 2,
  last_reviewed_at: today - 1

add_card js_deck,
  front: "What is `async/await`?",
  back:  "Syntactic sugar over Promises. `async` marks a function as returning a Promise; `await` pauses execution inside the function until the awaited Promise resolves.",
  next_review_date: today + 3, interval_days: 6, ease_factor: 2.6, review_count: 3,
  last_reviewed_at: today - 3

# ---------------------------------------------------------------------------
# Deck 5 — Japanese Vocabulary — N5
# ---------------------------------------------------------------------------
jp_deck = Deck.find_or_create_by!(user: demo_user, name: "Japanese Vocabulary — N5") do |d|
  d.description = "JLPT N5 essential vocabulary: hiragana, katakana, and basic kanji"
end

add_card jp_deck, front: "水 (みず)",   back: "water",     next_review_date: today, interval_days: 0, review_count: 0
add_card jp_deck, front: "火 (ひ)",     back: "fire",      next_review_date: today - 1, interval_days: 1, ease_factor: 2.4, review_count: 2, last_reviewed_at: today - 1
add_card jp_deck, front: "山 (やま)",   back: "mountain",  next_review_date: today + 2, interval_days: 4, ease_factor: 2.6, review_count: 3, last_reviewed_at: today - 2
add_card jp_deck, front: "川 (かわ)",   back: "river",     next_review_date: today, interval_days: 0, review_count: 0
add_card jp_deck, front: "空 (そら)",   back: "sky",       next_review_date: today - 3, interval_days: 2, ease_factor: 2.3, review_count: 3, last_reviewed_at: today - 3
add_card jp_deck, front: "食べる (たべる)", back: "to eat", next_review_date: today + 1, interval_days: 3, ease_factor: 2.5, review_count: 2, last_reviewed_at: today - 2
add_card jp_deck, front: "飲む (のむ)",  back: "to drink",  next_review_date: today, interval_days: 0, review_count: 0
add_card jp_deck, front: "大きい (おおきい)", back: "big / large", next_review_date: today - 2, interval_days: 1, ease_factor: 2.4, review_count: 1, last_reviewed_at: today - 2
add_card jp_deck, front: "小さい (ちいさい)", back: "small / little", next_review_date: today + 5, interval_days: 10, ease_factor: 2.8, review_count: 5, last_reviewed_at: today - 5
add_card jp_deck, front: "新しい (あたらしい)", back: "new",   next_review_date: today, interval_days: 0, review_count: 0

puts ""
puts "✅  Seeding complete!"
puts "   User:  demo / password123"
puts "   Decks: #{Deck.where(user: demo_user).count}"
puts "   Cards: #{Card.joins(:deck).where(decks: { user: demo_user }).count}"
puts "   Due today (incl. overdue): #{CardSchedule.due_today.joins(card: :deck).where(decks: { user: demo_user }).count}"
