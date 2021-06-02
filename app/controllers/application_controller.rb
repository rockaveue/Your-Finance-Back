include Pagy::Backend
class ApplicationController < ActionController::API

    respond_to :json
    before_action :authenticate_api_v1_user!
    
    # before_action :add_to_blacklist


    def jwt_subject
        self
    end
    
    protected

    # Шинэ токен үүсгэх
    def generate_new_token        
        response.headers['Authorization'] = 'Bearer '+ Warden::JWTAuth::UserEncoder.new.call(current_api_v1_user, :api_v1_user, nil).first
    end

    # Blacklist рүү нэмэх
    def add_to_blacklist
        decoded_token = decode_token
        # jti ялгаж авах
        jti =  decoded_token[0]['jti']

        old_token = JwtBlacklist.new(jti: jti)
        old_token.save
    end
    
    # JWT тайлах функц
    def decode_token
        decoder = JWT::Decode.new(
            request.headers['Authorization'].split(' ')[1],
            'GENERATED_TOKEN',
            nil,
            nil
        )
        decoder.decode_segments
    end

    # Simple authorization
    # params[:user_id] байгаа газар ашиглана
    def authorization
        decoded_token = decode_token
        if params[:user_id] == decoded_token[0]['sub'] || params[:id] == decoded_token[0]['sub']

        else
            raise "Хандах эрхгүй хэрэглэгч"
        end
    end

end
