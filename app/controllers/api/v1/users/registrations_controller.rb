class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_action :generate_new_token
  # параметрүүдийг бүгдийг авах бүртгүүлэх функц
  def create
    resource = build_resource(sign_up_params)
    if resource.save
      UserMailer.welcome_email(resource).deliver_now
      register_success && return if resource.persisted?
    else
      render json: {message: resource.errors}, status: 422
    end
  end
  private
  def register_success
    render json: { message: 'Signed in successfully.' }
  end
  def sign_up_params
    params.require(:api_v1_user).permit(:email, :password, :last_name, :first_name)
  end
end
