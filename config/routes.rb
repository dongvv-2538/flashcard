# frozen_string_literal: true

Rails.application.routes.draw do
  # Phase 2 — Authentication
  resources :users,   only: %i[new create]
  resource  :session, only: %i[new create destroy]

  # Phase 3 — Deck & Card Management (US1)
  resources :decks do
    resources :cards

    # Phase 4 — Practice Session (US2)
    resources :study_sessions, only: %i[new create show update] do
      member { get :summary }
    end
  end

  # Phase 5 — Review Queue (US3)
  resources :reviews, only: %i[index create]

  # Health check
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Root → login page
  root 'sessions#new'
end
