class Api::V1::Users::PasswordsController < Devise::PasswordsController
  before_action :generate_new_token, only: :new
  append_before_action :assert_reset_token_passed, only: :edit
  
  # POST /api/v1/users/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      # respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
      render json: { message: "You will receive an email with instructions on how to reset your password in a few minutes"}
    else
      render json: { message: "Email not sent"}
    end
  end
  # GET /api/v1/users/password/edit
  def edit
    begin
      user = User.with_reset_password_token(params[:reset_password_token])
      sign_in(user)
      generate_new_token
      render json: { message: "Valid token" }
    rescue RuntimeError
      render json: { message: "Invalid token" }
    end
  end

  # PUT /api/v1/users/password
  def update
    @user = User.find(current_api_v1_user.id)
    if @user.reset_password(user_params)
      bypass_sign_in(@user)
      render json: { message: "Password updated"}
    else
      render json: { message: "There was an error"}
    end
  end
  private
  def user_params
    params.permit(:password, :password_confirmation)
  end
end