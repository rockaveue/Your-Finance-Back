module ControllerMacros
  def authenticated_header(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :api_v1_user, nil).first
    return "Bearer #{token}"
  end
end