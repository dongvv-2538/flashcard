# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # T012 — Auth helpers available in all controllers and views
  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    flash[:alert] = 'You must be logged in to access this page.'
    redirect_to new_session_path
  end
end
