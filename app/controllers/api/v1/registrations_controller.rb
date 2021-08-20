class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    @user = User.new(sign_up_params)
    if @user.save
      render json: { user: @user }, status: 200
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  private

  def sign_up_params
    begin
      params.require(:user).permit(:email, :full_name, :password, :password_confirmation)
    rescue StandardError => e
    end
  end
end
