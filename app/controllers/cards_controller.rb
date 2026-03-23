# frozen_string_literal: true

# T026 — Cards controller, nested under decks
class CardsController < ApplicationController
  before_action :require_login
  before_action :set_deck
  before_action :set_card, only: %i[edit update destroy]

  def index
    @cards = @deck.cards.order(:created_at)
  end

  def new
    @card = @deck.cards.build
  end

  def edit; end

  def create
    @card = @deck.cards.build(card_params)
    if @card.save
      flash[:notice] = 'Card was successfully created.'
      redirect_to deck_cards_path(@deck)
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @card.update(card_params)
      flash[:notice] = 'Card was successfully updated.'
      redirect_to deck_cards_path(@deck)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @card.destroy
    flash[:notice] = 'Card was deleted.'
    redirect_to deck_cards_path(@deck)
  end

  private

  def set_deck
    @deck = current_user.decks.find(params[:deck_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Deck not found.'
    redirect_to decks_path
  end

  def set_card
    @card = @deck.cards.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = 'Card not found.'
    redirect_to deck_cards_path(@deck)
  end

  def card_params
    params.require(:card).permit(:front, :back)
  end
end
