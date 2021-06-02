class Api::V1::Users::SessionsController < Devise::SessionsController
    respond_to :json
    # before_action :generate_new_token

    # POST /users/sign_in
    # def create
    #   user = User.find_by_email(params[:email])
    #   # render json: user
    #   if user && user.valid_password?(params[:password])
    #     # user.generate_new_token
    #     respond_with(user)
    #   else
    #     render json: { errors: 'email эсвэл password буруу байна'}, status: :unprocessable_entity
    #   end
    # end
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