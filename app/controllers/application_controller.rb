class ApplicationController < ActionController::API
    respond_to :json
    before_action :process_token

    private

    # authorization header-аас шалгах хэсэг байвал кодыг тайлна
    def process_token
        if request.headers['Authorization'].present?
            begin
                jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1], Rails.application.secrets.secret_key_base).first
                @current_user_id = jwt_payload['id']
            rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecoderError
                head :unauthorized
            end
        end
            # head: unauthorized
    end

    # Хэрэв нэвтрээгүй бол unauthorized алдааг буцаана
    def authenticate_user!(options = {})
        head :unauthorized unless @current_user_id.present?
    end

    
    # current_user хоосон хэрэглэгчийг онооно
    def current_user
        @current_user ||= super || User.find(@current_user_id)
    end
    

end
