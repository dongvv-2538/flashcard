# frozen_string_literal: true

# T052 — SM2Scheduler service
#
# Implements the SM-2 spaced repetition algorithm.
#
# Given a current schedule hash and a rating symbol, computes:
#   - interval_days   (next review interval in days)
#   - ease_factor     (clamped between 1.3 and 2.5)
#   - next_review_date
#   - review_count    (incremented by 1)
#
# Usage:
#   result = SM2Scheduler.call(
#     schedule: { interval_days: 0, ease_factor: 2.5, review_count: 0 },
#     rating:   :good
#   )
#   # => { interval_days: 1, ease_factor: 2.5, next_review_date: Date.today + 1, review_count: 1 }
#
# Rating mapping (aligns with SessionRating enum):
#   :again (0) — did not recall   → reset interval to 1; lower ease by 0.20
#   :hard  (1) — recalled w/ difficulty → keep interval (×1.2 floor 1); lower ease by 0.15
#   :good  (2) — recalled correctly     → interval × ease_factor; ease unchanged
#   :easy  (3) — recalled easily        → interval × ease_factor × 1.3; raise ease by 0.15
class SM2Scheduler
  EASE_MIN  = 1.3
  EASE_MAX  = 2.5

  # @param schedule [Hash] keys: :interval_days, :ease_factor, :review_count
  # @param rating   [Symbol] :again | :hard | :good | :easy
  # @return [Hash] updated schedule attrs (does NOT persist)
  def self.call(schedule:, rating:)
    new(schedule, rating).compute
  end

  def initialize(schedule, rating)
    @interval    = schedule[:interval_days].to_i
    @ease        = schedule[:ease_factor].to_f
    @review_count = schedule[:review_count].to_i
    @rating = rating.to_sym
  end

  def compute
    new_interval, new_ease = updated_interval_and_ease

    {
      interval_days: new_interval,
      ease_factor: clamp_ease(new_ease),
      next_review_date: Time.zone.today + new_interval,
      review_count: @review_count + 1,
      last_reviewed_at: Time.current
    }
  end

  private

  def updated_interval_and_ease
    case @rating
    when :again
      [0, @ease - 0.20]
    when :hard
      new_int = [@interval.zero? ? 1 : (@interval * 1.2).ceil, 1].max
      [new_int, @ease - 0.15]
    when :good
      new_int = [@interval.zero? ? 1 : (@interval * @ease).ceil, 1].max
      [new_int, @ease]
    when :easy
      new_int = [@interval.zero? ? 4 : (@interval * @ease * 1.3).ceil, 4].max
      [new_int, @ease + 0.15]
    else
      raise ArgumentError, "Unknown rating: #{@rating.inspect}"
    end
  end

  def clamp_ease(value)
    value.clamp(EASE_MIN, EASE_MAX).round(2)
  end
end
