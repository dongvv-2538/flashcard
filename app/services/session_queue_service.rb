# frozen_string_literal: true

# T039 — SessionQueueService
#
# Manages the ordered card queue for a single study session.
# Cards rated :again are re-queued to the back of the queue, up to a
# maximum of MAX_AGAIN_REQUEUES times per card. Beyond that cap the card
# is dropped from the queue even if rated :again again.
#
# Queue state can be serialised to / restored from a plain Ruby Hash so it
# can be persisted in the Rails session (JSON-safe).
#
# Usage:
#   service = SessionQueueService.new(deck.cards)
#   card = service.next_card
#   service.advance!(:good)     # or :again / :hard / :easy
#   service.empty?              # => true when all cards done
#
#   # Persist across requests:
#   session[:queue_state] = service.to_session_state
#   service = SessionQueueService.from_session_state(session[:queue_state])
class SessionQueueService
  MAX_AGAIN_REQUEUES = 3

  # @param cards [Array<Card>, ActiveRecord::Relation]
  def initialize(cards)
    @queue        = cards.to_a.dup          # ordered list of Card objects
    @again_counts = Hash.new(0)             # card.id => re-queue count
    @total_count  = @queue.size
  end

  # ---------------------------------------------------------------------------
  # Query interface
  # ---------------------------------------------------------------------------

  # Returns the next card to be shown, or nil when the queue is empty.
  def next_card
    @queue.first
  end

  # Number of cards still in the queue (including the current card).
  def remaining_count
    @queue.size
  end

  # Total card count at session start (never changes after init).
  attr_reader :total_count

  # True when all cards have been completed (nothing left in queue).
  delegate :empty?, to: :@queue

  # ---------------------------------------------------------------------------
  # Mutation
  # ---------------------------------------------------------------------------

  # Advance past the current card, applying the learner's rating.
  # If rated :again and the card has not exceeded MAX_AGAIN_REQUEUES it is
  # pushed to the back of the queue; otherwise it is dropped.
  #
  # @param rating [Symbol] :again | :hard | :good | :easy
  def advance!(rating)
    card = @queue.shift
    return if card.nil?

    return unless rating.to_sym == :again && @again_counts[card.id] < MAX_AGAIN_REQUEUES

    @again_counts[card.id] += 1
    @queue.push(card)

    # For any other rating (or when cap reached) the card is simply dropped.
  end

  # ---------------------------------------------------------------------------
  # Serialisation — store/restore queue state in the Rails session (JSON-safe)
  # ---------------------------------------------------------------------------

  # Returns a plain Hash that can be stored in session[:queue_state].
  def to_session_state
    {
      'queue_ids' => @queue.map(&:id),
      'again_counts' => @again_counts.transform_keys(&:to_s),
      'total_count' => @total_count
    }
  end

  # Restores a SessionQueueService from a previously serialised state Hash.
  # Fetches Card records from the DB in the preserved queue order.
  #
  # @param state [Hash] output of #to_session_state
  # @return [SessionQueueService]
  def self.from_session_state(state)
    return new([]) if state.blank?

    queue_ids = Array(state['queue_ids']).map(&:to_i)
    cards_by_id = Card.where(id: queue_ids).index_by(&:id)
    ordered_cards = queue_ids.filter_map { |id| cards_by_id[id] }

    instance = allocate
    instance.send(:restore_state!,
                  ordered_cards,
                  state['again_counts'].to_h.transform_keys(&:to_i),
                  state['total_count'].to_i)
    instance
  end

  private

  def restore_state!(queue, again_counts, total_count)
    @queue        = queue
    @again_counts = Hash.new(0).merge(again_counts)
    @total_count  = total_count
  end
end
