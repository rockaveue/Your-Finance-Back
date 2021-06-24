class Api::V1::Users::SessionsController < Devise::SessionsController
  skip_before_action :generate_new_token
  # respond_to :json
  
  private

  def respond_with(resource, _opts = {})
    render json: { message: 'Logged in.', resource: resource }, status: :ok
  end

  def respond_to_on_destroy
    log_out_success && return if current_api_v1_user

    log_out_failure
  end

  def log_out_success
    render json: { message: "Logged out successfully." }, status: :ok
  end

  def log_out_failure
    render json: { message: "Errors occured while logging out."}, status: :unauthorized
  end
end