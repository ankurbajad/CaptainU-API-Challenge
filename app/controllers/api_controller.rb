class ApiController < ApplicationController
  before_action :set_default_format
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  before_action :check_current_user, except: [:current_user]

  def current_user
    token = request.headers['AUTHTOKEN'].presence
    if token
      @current_user ||= User.find_by_authentication_token(token)
    end
  end

  def check_current_user
    unless current_user.present?
      render json: { errors: 'Not authenticated' }, status: 401
    end
  end

  def authenticate_with_token!
    render json: { errors: "Not authenticated"}, status: :unauthorized unless current_user.present?
  end

  def not_found
    render json: { errors: 'Not found' }, status: 404
  end

  private
  def set_default_format
    request.format = :json
  end
end
