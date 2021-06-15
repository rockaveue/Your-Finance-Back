include Pagy::Backend
class ApplicationController < ActionController::API
  respond_to :json
  before_action :authenticate_api_v1_user!
  before_action :generate_new_token
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  

  def configure_permitted_parameters
    update_attrs = [:password, :password_confirmation, :current_password]
    devise_parameter_sanitizer.permit :account_update, keys: update_attrs
  end

  def render_404
    render json: {message: "Record Not found"}, status: 404
  end
  
  def jwt_subject
    self
  end

  protected

  # Шинэ токен үүсгэх
  def generate_new_token
    response.headers['Authorization'] = 'Bearer '+ Warden::JWTAuth::UserEncoder.new.call(current_api_v1_user, :api_v1_user, nil).first
    add_to_blacklist unless params[:reset_password_token].present?
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
  def authorization(id)
    if transaction = Transaction.find(id).blank?
      transaction = Category.find(id)
    end
    if transaction.user_id != current_api_v1_user.id
      render json: {message: 'unauthorized'}, status: 401
    end
    
  end

  def user_authorization
    if Integer(params[:id]) != current_api_v1_user.id
      render json: {message: 'unauthorized'}, status: 401
    end
  end
end
