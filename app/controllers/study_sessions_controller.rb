# frozen_string_literal: true

# T040 — StudySessionsController
#
# Handles the practice session lifecycle:
#   POST   /decks/:deck_id/study_sessions        → create (start session, init queue)
#   GET    /decks/:deck_id/study_sessions/:id    → show  (display current card)
#   PATCH  /decks/:deck_id/study_sessions/:id    → update (submit rating, advance or end)
class StudySessionsController < ApplicationController
  before_action :require_login
  before_action :set_deck
  before_action :set_study_session, only: %i[show update summary]

  # GET /decks/:deck_id/study_sessions/:id
  def show
    queue = load_queue

    if queue.empty?
      redirect_to summary_deck_study_session_path(@deck, @study_session)
    else
      @card             = queue.next_card
      @remaining_count  = queue.remaining_count
      @total_count      = queue.total_count
      @card_number      = @total_count - @remaining_count + 1
    end
  end

  # POST /decks/:deck_id/study_sessions
  def create
    cards = @deck.cards.order(:created_at)

    if cards.empty?
      flash[:alert] = 'This deck has no cards. Add some cards before starting a session.'
      return redirect_to @deck
    end

    @study_session = current_user.study_sessions.build(
      deck: @deck,
      session_type: :full_deck,
      started_at: Time.current
    )

    if @study_session.save
      queue = SessionQueueService.new(cards)
      store_queue_state(queue)
      redirect_to deck_study_session_path(@deck, @study_session)
    else
      flash[:alert] = 'Could not start session. Please try again.'
      redirect_to @deck
    end
  end

  # PATCH /decks/:deck_id/study_sessions/:id
  def update
    rating = params[:rating]&.to_sym

    unless SessionRating.ratings.key?(rating.to_s)
      flash[:alert] = 'Invalid rating.'
      return redirect_to deck_study_session_path(@deck, @study_session)
    end

    queue = load_queue
    card  = queue.next_card

    if card
      SessionRating.create!(
        study_session: @study_session,
        card: card,
        rating: rating,
        reviewed_at: Time.current
      )

      # T053 — Update (or create) the card's SM-2 schedule
      update_card_schedule(card, rating)

      queue.advance!(rating)
      store_queue_state(queue)

      if queue.empty?
        finalize_session
        redirect_to summary_deck_study_session_path(@deck, @study_session)
      else
        redirect_to deck_study_session_path(@deck, @study_session)
      end
    else
      finalize_session
      redirect_to summary_deck_study_session_path(@deck, @study_session)
    end
  end

  # GET /decks/:deck_id/study_sessions/:id/summary
  def summary
    @ratings_breakdown = @study_session
                         .session_ratings
                         .group(:rating)
                         .count
                         .transform_keys { |k| SessionRating.ratings.key(k) }
  end

  private

  def set_deck
    @deck = current_user.decks.find(params[:deck_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Deck not found.'
    redirect_to decks_path
  end

  def set_study_session
    @study_session = current_user.study_sessions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Session not found.'
    redirect_to @deck
  end

  def queue_session_key
    :"queue_state_#{@study_session.id}"
  end

  def store_queue_state(queue)
    session[queue_session_key] = queue.to_session_state
  end

  def load_queue
    state = session[queue_session_key]
    SessionQueueService.from_session_state(state)
  end

  def finalize_session
    reviewed_count = @study_session.session_ratings.count
    @study_session.update!(
      ended_at: Time.current,
      cards_reviewed_count: reviewed_count
    )
    session.delete(queue_session_key)
  end

  # T053 — Upsert the CardSchedule for a card using SM2Scheduler
  def update_card_schedule(card, rating)
    schedule = card.card_schedule || CardSchedule.new(card: card)

    current = {
      interval_days: schedule.interval_days || 0,
      ease_factor: schedule.ease_factor || 2.5,
      review_count: schedule.review_count || 0
    }

    attrs = SM2Scheduler.call(schedule: current, rating: rating)
    schedule.assign_attributes(attrs)
    schedule.save!
  rescue StandardError => e
    Rails.logger.error("SM2Scheduler failed for card #{card.id}: #{e.message}")
  end
end
