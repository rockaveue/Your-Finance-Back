include Pagy::Backend
class ApplicationController < ActionController::API

    respond_to :json
    before_action :authenticate_api_v1_user!
    before_action :generate_new_token
    # before_action :add_to_blacklist


    def jwt_subject
        self
    end
    
    protected

    # Шинэ токен үүсгэх
    def generate_new_token        
        response.headers['Authorization'] = 'Bearer '+ Warden::JWTAuth::UserEncoder.new.call(current_api_v1_user, :api_v1_user, nil).first
    end

    def add_to_blacklist
        decoded = decode_token
        # user = User.find_by_id(decoded[0]['sub'])
        jti =  decoded[0]['jti']
        old_token = JwtBlacklist.new(jti: jti)
        old_token.save
        # render json: JwtBlacklist.jwt_revoked?(decoded, user)
    end
    
    def decode_token
        decoder = JWT::Decode.new(
            request.headers['Authorization'].split(' ')[1],
            'GENERATED_TOKEN',
            nil,
            nil
        )
        decoder.decode_segments
    end
    #  params[:user_id].present? Байвал ажиллана
    def authorization
        decoded = decode_token
        if params[:user_id] != decoded[0]['sub']
            raise "Хандах эрхгүй хэрэглэгч"
        end
    end
end
