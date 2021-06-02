class Api::V1::Users::SessionsController < Devise::SessionsController
  TODO skip authenticate_user
  respond_to :json
  
  private

  def respond_with(resource, _opts = {})
    render json: { message: 'Та нэвтэрлээ.', resource: resource }, status: :ok
  end

  def respond_to_on_destroy
    log_out_success && return if current_api_v1_user

    log_out_failure
  end

  def log_out_success
    render json: { message: "Амжилттай гарлаа." }, status: :ok
  end

  def log_out_failure
    render json: { message: "Гарахад алдаа гарлаа."}, status: :unauthorized
  end
end