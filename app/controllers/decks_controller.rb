# frozen_string_literal: true

# T025 — Decks controller, scoped to current_user
class DecksController < ApplicationController
  before_action :require_login
  before_action :set_deck, only: %i[show edit update destroy]

  def index
    # T067 — Eager load cards + card_schedules to prevent N+1 on index (due count display)
    @decks = current_user.decks.includes(cards: :card_schedule).order(:name)
  end

  def show
    @cards = @deck.cards.order(:created_at)
    # T062 — Load stats via DeckStatsService (always fresh, no stale cache)
    @stats = DeckStatsService.new(deck: @deck, user: current_user).call
  end

  def new
    @deck = current_user.decks.build
  end

  def edit; end

  def create
    @deck = current_user.decks.build(deck_params)
    if @deck.save
      flash[:notice] = 'Deck was successfully created.'
      redirect_to @deck
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @deck.update(deck_params)
      flash[:notice] = 'Deck was successfully updated.'
      redirect_to @deck
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @deck.destroy
    flash[:notice] = 'Deck was deleted.'
    redirect_to decks_path
  end

  private

  def set_deck
    @deck = current_user.decks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Deck not found.'
    redirect_to decks_path
  end

  def deck_params
    params.require(:deck).permit(:name, :description)
  end
end
