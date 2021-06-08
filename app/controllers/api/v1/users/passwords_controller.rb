class Api::V1::Users::PasswordsController < Devise::PasswordsController
  before_action :generate_new_token, only: :new
  append_before_action :assert_reset_token_passed, only: :edit
  # GET password/edit
  def edit
    # super
    begin
      self.resource = resource_class.new
      # set_minimum_password_length
      resource.reset_password_token = params[:reset_password_token]
      # current_api_v1_user = check_valid_token
      user = User.with_reset_password_token(params[:reset_password_token])
      sign_in(user)
      generate_new_token
      render json: current_api_v1_user
    rescue RuntimeError
      # RuntimeError: Could not find a valid mapping for nil
      render json: {message: "Token already used"}
    end
  end

  # PUT password/
  # def update
  #   self.resource = resource_class.reset_password_by_token(resource_params)
  #   # render json: resource
  #   yield resource if block_given?

  #   if resource.errors.empty?
  #     resource.unlock_access! if unlockable?(resource)
  #     if Devise.sign_in_after_reset_password
  #       flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
  #       set_flash_message!(:notice, flash_message)
  #       resource.after_database_authentication
  #       sign_in(resource_name, resource)
  #     else
  #       set_flash_message!(:notice, :updated_not_active)
  #     end
  #     respond_with resource, location: after_resetting_password_path_for(resource)
  #   else
  #     # set_minimum_password_length
  #     # respond_with resource
  #     render json: resource.errors
  #   end
  # end
  def update
    # super
    # render json: current_api_v1_user
    @user = User.find(current_api_v1_user.id)
    
    if @user.reset_password(params[:password], params[:password_confirmation])
      bypass_sign_in(@user)
      render json: { message: "Password updated"}
    else
      render json: { message: "There was an error"}
    end
  end
  protected

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def assert_reset_token_passed
    if params[:reset_password_token].blank?
      # set_flash_message(:alert, :no_token)
      # redirect_to new_session_path(resource_name)
      render json: { message: "No reset password token found."}
    end
  end

  def check_valid_token
    resetCode = (params[:reset_password_token])
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, resetCode)
    user = find_or_initialize_with_error_by(reset_password_token: reset_password_token)
    user
  end
end