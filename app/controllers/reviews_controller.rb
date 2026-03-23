# frozen_string_literal: true

# T055 — ReviewsController
#
# Surfaces the daily review queue of due/overdue cards grouped by deck,
# and allows the learner to start a review_due StudySession for a specific deck.
class ReviewsController < ApplicationController
  before_action :require_login

  # GET /reviews
  def index
    service          = ReviewQueueService.new(current_user)
    @grouped_by_deck = service.grouped_by_deck
    @next_review_date = service.next_review_date
  end

  # POST /reviews
  # Params: deck_id (required)
  def create
    deck  = current_user.decks.find(params[:deck_id])
    cards = due_cards_for(deck)

    if cards.empty?
      flash[:alert] = "No cards are due for '#{deck.name}'."
      return redirect_to reviews_path
    end

    study_session = current_user.study_sessions.create!(
      deck: deck,
      session_type: :review_due,
      started_at: Time.current
    )

    queue = SessionQueueService.new(cards)
    session[:"queue_state_#{study_session.id}"] = queue.to_session_state

    redirect_to deck_study_session_path(deck, study_session)
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Deck not found."
    redirect_to reviews_path
  end

  private

  def due_cards_for(deck)
    CardSchedule
      .due_today
      .joins(:card)
      .where(cards: { deck_id: deck.id })
      .includes(:card)
      .order(:next_review_date)
      .map(&:card)
  end
end
