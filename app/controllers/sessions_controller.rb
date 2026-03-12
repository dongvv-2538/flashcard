# frozen_string_literal: true

# T011 — Login / logout controller (singular resource: session)
class SessionsController < ApplicationController
  def new
    redirect_to decks_path if logged_in?
  end

  def create
    user = User.find_by(username: params[:session][:username].to_s.strip.downcase)

    if user&.authenticate(params[:session][:password])
      session[:user_id] = user.id
      flash[:notice] = "Welcome back, #{user.username}!"
      redirect_to decks_path
    else
      flash.now[:alert] = "Invalid username or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    @current_user = nil
    flash[:notice] = "You have been logged out."
    redirect_to new_session_path
  end
end
