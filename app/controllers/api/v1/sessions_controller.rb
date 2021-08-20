class Api::V1::SessionsController < ApiController
  before_action :check_current_user, only: [:destroy]
  
  def create
    @user = User.find_by(email: params[:user][:email])
    if @user&.valid_password?(params[:user][:password])
      @user.authentication_token = JsonWebToken.encode(sub: @user.id)
      @user.save
      render json: { email: @user.email, access_token: @user.authentication_token }, status: 200
    else
      render json: { errors: 'Invalid Email or Password' }, status: 401
    end
  end

  def destroy
    if current_user.present?
      sign_out
       current_user.authentication_token = ''
       current_user.save
      render json: { status: 'successful', message: 'successfully sign out'}
    end
  end
end
