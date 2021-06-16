class Api::V1::Users::PasswordsController < Devise::PasswordsController
  before_action :generate_new_token, only: :new
  append_before_action :assert_reset_token_passed, only: :edit
  
  # POST /api/v1/users/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      render json: { message: "You will receive an email with instructions on how to reset your password in a few minutes"}
    else
      render json: { message: "Email not sent"}
    end
  end

  # PUT /api/v1/users/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? 'Password updated.' : 'Password updated. Please sign in.'
        render json: {'message' => "#{flash_message}"}, status: 200
        resource.after_database_authentication
        sign_in(resource_name, resource)
      else
        render json: {'message' => 'Password not updated'}, status: 400
      end
    else
      render json: { 'message' => resource.errors }, status: 422
    end
  end
end